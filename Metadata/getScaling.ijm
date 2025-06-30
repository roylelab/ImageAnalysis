/*
 * Point ImageJ macro at a directory to get a list of filenames
 * their scaling data
 */

macro "Get scaling for all images in directory"	{
	dir = getDirectory("Choose a Directory ");
	list = getFileList(dir);
	setBatchMode(true);
	
	f = File.open(dir+"scaling.txt");
	print(f,"Index\tFileName\tPixelSize\tUnits");
	for (i = 0; i < list.length; i ++)	{
		inputPath = dir+list[i];
		if (endsWith(inputPath, ".tif") || endsWith(inputPath, ".tiff")) {
			open(inputPath);
			title = getTitle();
			getPixelSize(unit, pixelWidth, pixelHeight);
			close();
			print(f,(i+1) + "\t" + title + "\t" + d2s(pixelWidth,5) + "\t" + unit);
		}
	}
	File.close(f);
	setBatchMode(false);
}