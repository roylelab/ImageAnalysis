#@ File (style = "directory", label = "Input folder") inputFolder
#@ File (style = "directory", label = "Output folder") outputFolder
#@ Double (label = "Spot radius", value = 0.25, stepSize = 0.01) radius
#@ Double (label = "Quality threshold", value = 2.5, stepSize = 0.1) threshold
#@ Integer (label = "Max frame gap", value = 1) frameGap
#@ Double (label = "Linking max distance", value = 1, stepSize = 0.1) linkingMax
#@ Double (label = "Gap-closing max distance", value = 1, stepSize = 0.1) closingMax

import ij.IJ
import fiji.plugin.trackmate.Model
import fiji.plugin.trackmate.Settings
import fiji.plugin.trackmate.TrackMate

import fiji.plugin.trackmate.detection.LogDetectorFactory

import fiji.plugin.trackmate.tracking.jaqaman.SparseLAPTrackerFactory

import fiji.plugin.trackmate.io.TmXmlWriter

def main() {
	inputFolder.eachFileRecurse {
		name = it.getName()
		if (name.endsWith(".tif")) {
			process(it, inputFolder, outputFolder)
		}
	}
}

def process(file, src, dst) {
	println "Processing $file"

	// Opening the image
	imp = IJ.openImage(file.getAbsolutePath())
	imp.show();
	// Swap Z and T dimensions if T=1
	dims = imp.getDimensions() // default order: XYCZT
	if (dims[4] == 1) {
		imp.setDimensions( dims[2,4,3] )
	}
	
	// Anticipate an roiset that is the same name as file but .tif is replaced by _cell.roi
	roiFile = new File(src, file.getName().replaceAll("\\.tif", "_cell.roi"))
	if (roiFile.exists()) {
		println "Found ROI file: $roiFile"
		// Load the ROI
		roi = IJ.open(roiFile.getAbsolutePath())
	} else {
		println "No ROI file found for $file"
	}
	
	// Setup settings for TrackMate
	settings = new Settings(imp)
	
	settings.detectorFactory = new LogDetectorFactory()
	settings.detectorSettings = settings.detectorFactory.getDefaultSettings()
	settings.detectorSettings['RADIUS'] = radius
	settings.detectorSettings['THRESHOLD'] = threshold
	settings.detectorSettings['DO_SUBPIXEL_LOCALIZATION'] = true
	settings.detectorSettings['DO_MEDIAN_FILTERING'] = false
	println settings.detectorSettings
	
	settings.trackerFactory = new SparseLAPTrackerFactory()
	settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
	settings.trackerSettings['MAX_FRAME_GAP']  = frameGap
	settings.trackerSettings['LINKING_MAX_DISTANCE']  = linkingMax
	settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE']  = closingMax
	println settings.trackerSettings
	
	settings.addAllAnalyzers()
	
	// Run TrackMate and store data into Model
	model = new Model()
	model.setPhysicalUnits("µm","s")
	trackmate = new TrackMate(model, settings)
	
	println trackmate.checkInput()
	println trackmate.process()
	println trackmate.getErrorMessage()
	
	println model.getSpots().getNSpots(true)
	println model.getTrackModel().nTracks(true)
	
	// Save tracks as XML
	
	filename = file.getName()
	if (!filename.endsWith(".xml")) {
		filename += ".xml"
	}
	
	// check output directory exists - useful if we have subdirectories of input directory
	// so that we can mirror the directory tree in output directory. Only works
	// one subdir deep
	subDir = file.getAbsoluteFile().getParentFile().getName()
	outDir = new File(dst,subDir)
	
	outFile = new File(outDir, filename)
	if(!outFile.getParentFile().exists()) { // Checks for "full/path/to".
    	outFile.getParentFile().mkdirs(); // Creates any missing directories.
	}
	writer = new TmXmlWriter(outFile) //a File path object)
	writer.appendModel(model)
	writer.appendSettings(settings)
	writer.writeToFile()

	// Clean up
	imp.close()
}

main()
