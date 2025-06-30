/*
 * ImageJ macro to load a large stack and split it into n smaller substacks, saving each with a unique nameSave each frame of hyperstack as a separate image in a folder
 */

macro "Save N Substacks From Stack" {
	
	if (nImages > 0) exit ("Please close all open images");
	
	filepath = File.openDialog("Select stack");
	outputdir = getDirectory("Destination for substacks ");
	
	// make the choice of what we will do
	Dialog.create("Substack Details");
	Dialog.addMessage("How many substacks?");
	Dialog.addNumber("Total substacks ", 1);
	Dialog.addMessage("Substack name format (* is wild, increments by 1)");
	Dialog.addString("Output name ", "cell*_0000.tif");
	Dialog.addNumber("Substitute for *", 6);
	Dialog.show();
	nSub = Dialog.getNumber();
	stemName = Dialog.getString();
	initN = Dialog.getNumber();
	
	setBatchMode(true);
	
	open(filepath);
	run("Select None");
	imageID = getImageID();
	title = getTitle();

	getDimensions(width, height, channels, slices, frames);
	
	nSlice = Math.ceil(slices / nSub);

	for (i = 0; i < nSub; i++) {
		selectWindow(title);
		start = 1 + (nSlice * i);
		end = start + nSlice - 1;
		if(end > slices) {
			range = "" + start + "-" + slices;
		} else {
			range = "" + start + "-" + end;
		}
		print(range);
		run("Make Substack...", "  slices=" + range);
		vString = d2s(initN + i,0);
		newTitle = replace(stemName, "*", vString);
		save(outputdir + newTitle);
		close();
	}
	close();
	setBatchMode(false);
}