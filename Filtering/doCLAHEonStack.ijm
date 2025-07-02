/* doCLAHEonStack.ijm
 * 
 * This script applies the Enhance Local Contrast (CLAHE) filter to each slice of a stack.
 * It is designed to work with multi-dimensional stacks, applying the filter to each slice
 * across all frames.
 * 
 * Usage: Open a stack and run this script.
 */


inputId = getImageID(); // get active image 
inputTitle = getTitle(); 

Stack.getDimensions(width, height, channels, slices, frames); 
setBatchMode("hide");
for (i=1; i<frames+1; i++){ 
        Stack.setFrame(i); 
        for (j=1; j<slices+1; j++) { 
                Stack.setSlice(j); 
                run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=2 mask=*None*"); 
        } 
}
setBatchMode("show");