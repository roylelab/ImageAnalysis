/*
 * Macro to save first and last frame as a new file
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

setBatchMode(true);
processFolder(input);
setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	if(endsWith(input, "/")) input = substring(input, 0, (lengthOf(input)-1));
	if(!endsWith(input, "/") | !endsWith(input,"\\")) input = input + File.separator;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	open(input + file);
	img = getTitle();
	getDimensions(width, height, channels, slices, frames);
	if(frames == 1) {
		print("File only has one frame");
		return;
	}
	run("Duplicate...", "title=" + img + "_01 duplicate range=1-1");
	newname = replace(file, ".tif", "_01.tif");
	save(output + File.separator + newname);
	close();
	selectWindow(img);
	run("Duplicate...", "title=" + img + "_01 duplicate range=" + frames + "-" + frames);
	newname = replace(file, ".tif", "_" + frames + ".tif");
	save(output + File.separator + newname);
    close();
    close();
}

