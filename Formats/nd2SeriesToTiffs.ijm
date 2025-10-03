/* 
/ ImageJ script for batch conversion of ND2 series to TIFF format files
*/

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".nd2") suffix

// script starts here
if (nImages > 0) exit("Close any open images");
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
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	path = input + file;  
	run("Bio-Formats Importer", "open=[" + path + "] open_all_series");
	
	// input maybe the parent directory or a subdirectory
	// destination may not have the necessary subdirectories
	outpath = replace(input, correctDirEnding(in), output);
	if(!File.exists(outpath)) File.makeDirectory(outpath);

	while (nImages > 0) {
		name = getTitle();
		// it is possible to have a / in the window name which will cause problems
		name = replace(name, "/", "_");
		save(outpath + File.separator + name + ".tif");
		close();
	}
}
