/*
 * This macro is to extract the metadata filename and match it to the actual filename
 * It is useful for crops where the crop may be mislabelled i.e. you can use it to check
 * whether they are the same.
 */

// specify image directory
InputPath = getDirectory("Select input directory");

setBatchMode(true);
//open a txt file to write into
f = File.open(InputPath + "fileInfo.txt");

//loop over images and open only tif files
list = getFileList(InputPath);
for(i = 0; i < list.length; i++){ 
	input = InputPath+list[i];

	if (endsWith(input,".tif")) {
		open(input);
		// extract image title to be added to file
		ImageTitle = getTitle();
  
		// pull the Show Info String
		strInfo = getImageInfo;
		// split the string by newline characters
		arrInfo = split(strInfo, "\n");
		// this line can be modified to do whatever is needed
		// filter the array to only include lines with Series 0 Name and create a new array
		arrInfo_Names = Array.filter(arrInfo, "(Series 0 Name*)");
		
		// this is used to turn an array into a string - it could be multiple lines
		theName = "";
		for (j = 0; j < arrInfo_Names.length; j++) {
			theName = theName + arrInfo_Names[j];
		}
				
		// add the datils
		print(f, ImageTitle + "\t" + theName);
		close();
	}
}
File.close(f);
setBatchMode(false);