/*
 * This script prompts the user to draw around the cell in the image and perform JaCoP on it
 * saves the output in the same directory as the image. If ROI file exists, it uses that.
 * It is semi-automated, as the user has to draw the ROI around the cell.
 * Workflow works on movies and images.
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ Integer (label = "Channel A", value = 1) ch_a
#@ Integer (label = "Channel B", value = 2) ch_b

run("Text Window...", "name=[Files] width=120 height=100");
processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	if(endsWith(input, "/")) input = substring(input, 0, (lengthOf(input)-1));
	if(!endsWith(input, "/") || !endsWith(input,"\\")) input = input + File.separator;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix) && !startsWith(list[i], "msk_")) {
			print("[Files]", "***" + input + list[i] + "\n");
			processFile(input, list[i]);
		}
	}
}

function processFile(input, file) {
	
	run("Clear Results");
	print("\\Clear");
	roiManager("reset");
	
	open(input + file);
	win = getTitle();
	
	stub = File.getNameWithoutExtension(file);
	if (File.exists(input + stub + "_cell.roi")) {
		// load roi
		open(input + stub + "_cell.roi");
		roiManager("add");
	} else {
		run("Clear Results");
		roiManager("reset");
		// here we will preprocess to get be able to find the biggest cell
		run("Duplicate...", "title=temp duplicate channels=1-2");
		run("Hyperstack to Stack");
		// because we may have extreme differences in the channels
		Stack.setChannel(1);
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT", "slice");
		Stack.setChannel(2);
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT", "slice");
		run("Z Project...", "projection=[Max Intensity]");
		mask = getTitle();
		run("Gaussian Blur...", "sigma=2");
		// Draw ROI around cell and save it	
		cellROI(input + stub + "_cell.roi");
	}
	
	// select original image
	selectWindow(win);
	roiManager("Select", 0);
	
	run("BIOP JACoP", "channel_a=" + ch_a + " channel_b=" + ch_b + " threshold_for_channel_a=Otsu threshold_for_channel_b=Otsu manual_threshold_a=0 manual_threshold_b=0 get_pearsons get_overlap costes_block_size=5 costes_number_of_shuffling=100");
	
	roiManager("reset");
	close("*");
	
	// Save results
	selectWindow("Results");
	outpath = input + File.getNameWithoutExtension(file) + ".csv";
	saveAs("results", outpath);
	
	// memory handling
	run("Collect Garbage");
}


// Save ROI of shape drawn around cell.

function cellROI(name) {
	// Draw around the cell and save that ROI
	setTool("freehand");
	waitForUser("cellROI", "Draw around the cell");
	roiManager("add");
	roiManager("Save", name);
}