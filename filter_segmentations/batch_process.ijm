//////////////////
//////////////////
///written by Jan Oltmer
///10092022
///howto: Move all input files into "input" folder (*.tif and corresponding CellPose *.txt segmentations
///move scripts into "scripts" folder in "input" folder
///generate "output" folder in "input" folder
///ADJUST THE FILTERING PARAMETER IN FILTERING SCRIPT IF NEEDED
///CHANGE THE NAME OF THE FILTERING SCRIPT HERE WHEN CHANGED
///Run "bach_projess.ijm" as a plugin with Fiji/ImageJ
//////////////////
//////////////////
directory = getDirectory("Choose the input directory");
directorymacro = File.getDirectory(getInfo("macro.filepath"));

filelist = getFileList(directory);
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")||endsWith(filelist[i], ".tiff")||endsWith(filelist[i], "_inv.tif")) {
        open(directory + File.separator + filelist[i]);
      	runMacro(directorymacro + "imagej_roi_converter.py");
      	runMacro(directorymacro + "filter_mean_075SD10SDminor.ijm");
        print(filelist[i]+ " processed");
    }
}
print("Done");
