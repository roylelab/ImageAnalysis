/*
 * Macro to take a multipoint ROI and make a csv of the coordinates
 * to be used for registration.
 * 
 * quantixed, Mar 2024
 */

// load the movie file
// use multipoint tool to record a fiducial of interest
// the single ROI can be saved and loaded as required for complex annotations
// works with poor man's registration ijm

macro Get_Multipoint_Positions	{
	if (nImages != 1) exit("One image and multipoint ROI required");
	original = getTitle();
	// error checking
	getDimensions(width, height, channels, slices, frames);
	if ((slices == 1) && (frames == 1)) exit("This macro requires a z-stack or time series.");
	if (roiManager("count") != 1) exit("One multipoint ROI required.");
	
	dir = getDirectory("image");
	if (File.exists(dir + "/positions.csv")){
		File.delete(dir + "/positions.csv");
	}
	f = File.open(dir + "/positions.csv");
	print(f, "x,y,t");
	
	roiManager("select", 0);
	// get array of x and y coords
	getSelectionCoordinates(xCoords, yCoords);
	// to get the frame numbers we need this little hack
	run("Clear Results");
	run("Measure");
	frameNumbers = newArray(nResults());
	for (i = 0; i < nResults(); i++) {
	    frameNumbers[i] = getResult('Frame', i);
	}
	// now write out the frame poisitions
	j = 0;
	for (i = 1; i <= frames; i++) {
		if(i == frameNumbers[j]) {
			print(f, xCoords[j] + "," + yCoords[j] + "," + frameNumbers[j]);
			j += 1;
		} else {
			print(f, xCoords[j] + "," + yCoords[j] + "," + i);
		}
	}
}