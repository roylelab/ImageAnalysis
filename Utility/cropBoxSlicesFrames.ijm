/*
 * Make a rectangular crop and crop slices and time - and WRITE OVER original
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ Integer (label = "Box width (px)", value = 50) xsize
#@ Integer (label = "Box height (px)", value = 50) ysize
#@ Integer (label = "Box upper-left x (px)", value = -1) xul
#@ Integer (label = "Box upper-left y (px)", value = -1) yul
#@ Integer (label = "Starting slice", value = 3) zstart
#@ Integer (label = "Ending slice", value = 3) zstop
#@ Integer (label = "Starting frame", value = 1) tstart
#@ Integer (label = "Ending frame", value = 30) tstop

// script starts here
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
	open(input + file);
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	// select box
	if (xul == -1) {
		x1 = floor((width / 2) - (xsize / 2));
	} else {
		x1 = xul;
	}
	if (yul == -1) {
		y1 = floor((height / 2) - (ysize / 2));
	} else {
		y1 = yul;
	}
	makeRectangle(x1, y1, xsize, ysize);
	run("Duplicate...", "title=test duplicate slices=" + zstart + "-" + zstop + " frames=" + tstart + "-" + tstop);
	save(input + file);
	close();
	close();
}