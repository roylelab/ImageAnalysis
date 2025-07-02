/*
 * Convert to 8-bit and WRITE OVER original
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ Boolean (label = "Recursive?", value = true, persist = false) recur
#@ Boolean (label = "Overwrite data?", value = false, persist = false) overwrite

// script starts here
setBatchMode(true);
setOption("ScaleConversions", true);
processFolder(input);
setBatchMode(false);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	if(endsWith(input, "/")) input = substring(input, 0, (lengthOf(input)-1));
	if(!endsWith(input, "/") || !endsWith(input,"\\")) input = input + File.separator;
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]) && recur == true)
			processFolder(input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	open(input + file);
	run("8-bit");
	if (overwrite == true) {
		save(input + file);
	} else {
		copyname = replace(file, suffix, "_crop" + suffix);
		save(input + copyname);
	}
	close();
}