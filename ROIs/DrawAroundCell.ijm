/*
 * This script will open each file in a folder and its subfolders,
 * and prompt the user to draw a ROI around the cell of interest.
 * It checks if the ROI already exists, so that it can be rerun
 * without having to draw the ROI again.
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

processFolder(input);

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
	if (File.exists(input + stub + "_cell.roi")) return; // ROI already exists, skip processing
	
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
	
	// here we will preprocess to get be able to find the biggest cell
	run("Duplicate...", "title=temp duplicate channels=1-2");
	// because we may have extreme differences in the channels
	run("Z Project...", "projection=[Max Intensity]");
	run("Gaussian Blur...", "sigma=2");
	Stack.setChannel(1);
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(2);
	run("Enhance Contrast", "saturated=0.35");
	close("\\Others");
	// Draw ROI around cell and save it
	cellROI(input + stub + "_cell.roi");

	// close the image
	close("*");
}


// Save ROI of shape drawn around cell.

function cellROI(name) {
	// Draw around the cell and save that ROI
	setTool("freehand");
	waitForUser("cellROI", "Draw around the cell");
	roiManager("add");
	roiManager("Save", name);
}