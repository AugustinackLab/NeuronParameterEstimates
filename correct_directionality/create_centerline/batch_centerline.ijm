//////////////////
//////////////////
///written by Jan Oltmer
///10092022
///howto: Move all input files into "input" folder
///move scripts into "scripts" folder in "input" folder
///generate "output" folder in "input" folder
///Run "bach_centerline.ijm" as a plugin with Fiji/ImageJ
//////////////////
//////////////////
directory = getDirectory("Choose the input directory");
directorymacro = File.getDirectory(getInfo("macro.filepath"));
filelist = getFileList(directory);
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")) {
        open(directory + File.separator + filelist[i]);
	print(filelist[i]+ " processing");
      	runMacro(directorymacro + "centerline.ijm");
        print(filelist[i]+ " processed");
    }
}
print("Done!");