/*
 * This script will find the biggest object in the image and perform JaCoP on it
 * saves the output in the same directory as the image
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
		} else {
//			print("[Files]", "SKIP: " + input + list[i] + "\n");
		}
	}
}

function processFile(input, file) {
	
	run("Clear Results");
	print("\\Clear");
	
	open(input + file);
	win = getTitle();
	
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
	setAutoThreshold("Otsu dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Dilate");
	run("Fill Holes");
	
	run("Set Measurements...", "area centroid stack display redirect=None decimal=4");
	run("Analyze Particles...", "size=10-Infinity display clear add");
	
	// find the biggest particle
	n = roiManager("count");
	rows = nResults;
	
	if (n == 0 || rows == 0) {
		print("[Files]", "ERROR" + "\n");
		close("*");
		return 0;
	}
	
	overall = 0;
	
	for (i = 0; i < rows; i++) {
		currArea = Table.get("Area", i, "Results");
		if(currArea > overall) {
			overall = currArea;
			biggest = i;
		}
	}
	selectWindow(mask);
	roiManager("Select", biggest);
	save(input + "msk_" + file);
	close();
	run("Clear Results");
	
	// select original image
	selectWindow(win);
	roiManager("Select", biggest);
	roiManager("reset");
	roiManager("Add");
	
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