/*
 * Macro template to print pixel sizes to the log
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

setBatchMode(true);
processFolder(input);
setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	if(endsWith(input, "/")) input = substring(input, 0, (lengthOf(input)-1));
	if(!endsWith(input, "/") || !endsWith(input,"\\")) input = input + File.separator;
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
	getPixelSize(unit, pixelWidth, pixelHeight);
	print(pixelWidth + " " + unit + " : " + input + file);
	close();
}