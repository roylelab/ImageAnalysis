/*
 * This script will take the first frame from each movie in a directory (and subdirectories)
 * and stack them so that we can pick nice images for a Figure (frames are labelled with original filename)
 * Options:
 * 	recurse the directory or to stay in the top directory
 * 	make a normalised RGB output - this option is useful if there are differences in intensity across the dataset
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ Boolean (label = "Recursive?", value = true, persist = false) recur
#@ Boolean (label = "RGB and normalise?", value = true, persist = false) rgbnorm

setBatchMode(true);
close("*");
print("\\Clear");
if (recur == true) {
	processFolder(input);
} else {
	processTopFolder(input);
}

// adjust brightness/contrast for each frame
selectWindow("bigstack");
getDimensions(width, height, channels, slices, frames);
if (rgbnorm == true) {
	rename("allImages");
	run("Delete Slice");
} else {
	run("Duplicate...", "title=allImages duplicate frames=2-"+frames);	
	enhanceContrast();
}
close("bigstack");

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
			processFile(input, list[i]);
	}
}

function processTopFolder(input) {
	if(endsWith(input, "/")) input = substring(input, 0, (lengthOf(input)-1));
	if(!endsWith(input, "/") | !endsWith(input,"\\")) input = input + File.separator;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	path = input + file;
	open(path);
	print(path);
	img = getTitle();
	getDimensions(width, height, channels, slices, frames);
	bits = bitDepth();
	run("Duplicate...", "title=copy duplicate frames=1-1");
	run("Set Label...", "label="+img);
	
	// assumes all files will be the same dimensions
	if (!isOpen("bigstack")) {
		if (rgbnorm == true) {
			newImage("bigstack", "RGB composite-mode", width, height, 1, 1, 1);
		} else {
			bitString = "" + bits + "-bit composite-mode";
			newImage("bigstack", bitString, width, height, channels, 1, 1);
		}
	}
	
	if (rgbnorm == true) {
		selectWindow("copy");
		run("Make Composite");
		enhanceContrast();
		run("RGB Color");
		run("Concatenate...", "  title=bigstack image1=bigstack image2=[copy (RGB)] image3=[-- None --]");
		close("copy");
	} else {
		run("Concatenate...", "  title=bigstack image1=bigstack image2=copy image3=[-- None --]");
	}
	selectWindow(img);
	close();
}

function enhanceContrast() {
	getDimensions(width, height, channels, slices, frames);
	for (i = 0; i < channels; i++) {
		Stack.setChannel(i+1);
		run("Enhance Contrast", "saturated=0.35");
	}
}
