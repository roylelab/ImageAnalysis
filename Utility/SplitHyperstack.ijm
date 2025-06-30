/*
 * Save each frame of hyperstack as a separate image in a folder
 */

macro "Save Each Frame of Hyperstack" {
	if (nImages > 0) exit ("Please close any images and try again.");
	
	inputDir = getDirectory("Original Hyperstacks ");
	outputDir = getDirectory("New Hyperstacks ");
	list = getFileList(inputDir);
	list = Array.sort(list);
	
	setBatchMode(true);
	for (i = 0; i < list.length; i++) {
		fPath = inputDir + File.separator + list[i];
		if(!endsWith(fPath, ".tif")) continue;
		open(fPath);
		title = getTitle();
		run("Select None");
		Stack.getDimensions(width, height, channels, slices, frames);
		if(frames == 1) continue;
		
		basename = File.nameWithoutExtension;
		len = Math.ceil(log(frames)); // for padding the digits in filename
		
		for (j = 0; j < frames; j++) {
			selectWindow(title);
			run("Duplicate...", "title=[" + basename + "_" + IJ.pad(j+1,len) + ".tif] duplicate frames=" + j+1);
			newTitle = getTitle();
			save(outputDir + File.separator + newTitle);
			close();
		}
		close();
	}
	setBatchMode(false);
}