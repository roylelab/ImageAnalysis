/*
 * Point ImageJ macro at a directory to get a list of filenames
 * and all of their scaling data
 */

macro "Get all scaling for all images in directory"	{
	dir = getDirectory("Choose a Directory ");
	list = getFileList(dir);
	setBatchMode(true);

	f = File.open(dir+"scaling.txt");
	print(f,"Index\tFileName\txSize\tzSize\tUnits\tWidth\tHeight\tChannels\t\Slices\tFrames");
	for (i = 0; i < list.length; i ++)	{
		inputPath = dir+list[i];
		if (endsWith(inputPath, ".tif") || endsWith(inputPath, ".tiff")) {
			open(inputPath);
			title = getTitle();
			getVoxelSize(width, height, depth, unit);
			Stack.getDimensions(width, height, channels, slices, frames);
			close();
			print(f,(i+1) + "\t" + title + "\t" + d2s(width,5) + "\t" + d2s(depth,5) + "\t" + unit + "\t" + width + "\t" + height + "\t" + channels + "\t" + slices + "\t" + frames);
		}
	}
	File.close(f);
	setBatchMode(false);
}
