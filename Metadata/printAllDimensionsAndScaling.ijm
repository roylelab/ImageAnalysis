/*
 * Point ImageJ macro at a directory to print a list of filenames
 * and their dimensions and scaling
 */

macro "Get scaling for all images in directory"	{
	print("\\Clear");
	dir = getDirectory("Choose a Directory ");
	list = getFileList(dir);
	setBatchMode(true);
	
	for (i = 0; i < list.length; i ++)	{
		inputPath = dir+list[i];
		if (endsWith(inputPath, ".tif") || endsWith(inputPath, ".tiff")) {
			open(inputPath);
			title = getTitle();
			getDimensions(width, height, channels, slices, frames);
			getPixelSize(unit, pixelWidth, pixelHeight);
			close();
			print(title, width, height, channels, slices, frames, unit, pixelWidth, pixelHeight);
			}
	}
	setBatchMode(false);
}