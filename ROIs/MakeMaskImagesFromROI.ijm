/*
 * This script will generate a binary mask from a .roi file.
 * It uses the original image to get the dimensions of the mask.
 * The mask will be saved in the same folder as the original image.
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);
setBatchMode(true);
processFolder(input);
setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	if(!endsWith(input, File.separator)) input = input + File.separator;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	
	stub = File.getNameWithoutExtension(file);
	if (!File.exists(input + stub + "_cell.roi")) return; // ROI doesn't exist, skip processing
	
	// else we will process the file
	roiManager("reset");
	
	if (suffix == ".tif") {
		open(input + file);	
	} else {
		s = "open=[" + input + file;
		s = s + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
	    run("Bio-Formats Importer", s);
	}
	win = getTitle();
	getDimensions(width, height, channels, slices, frames);
	close();
	// make a new black 8-bit image the same width and height as the original image
	newImage("mask", "8-bit black", width, height, 1);
	// load the ROI file and fill it
	open(input + stub + "_cell.roi");
	run("Fill", "slice");

	// Save the mask image
	selectWindow("mask");
	run("Select None");
	save(input + stub + "_mask.tif");

	// close the image
	close("*");
}