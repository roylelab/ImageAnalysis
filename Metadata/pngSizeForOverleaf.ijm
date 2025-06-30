/*
 * Figure out the width of png images for Overleaf
 * png are 300 dpi and page width is 170 mm
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".png") suffix

setBatchMode(true);
processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	print("Processing: " + file);
	open(input + File.separator + file);
	getDimensions(width, height, channels, slices, frames);
	pagefrac = ((width / 300) * 25.4) / 170;
	print("Image is: " + d2s(width,0) + "pixels. Page width is: " + d2s(pagefrac,2));
	close();
}
setBatchMode(false);