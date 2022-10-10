//////////////////
//////////////////
///written by Jan Oltmer
///10092022
///howto: Move all input files into "input" folder
///move scripts into "scripts" folder in "input" folder
///generate "output" folder in "input" folder
///Run "bach_preprocess.ijm" as a plugin with Fiji/ImageJ
//////////////////
//////////////////

//set variables
imgName = getTitle();
origimgName = getTitle();
title = substring(imgName, 0, lastIndexOf(imgName,"."));
path = getDir("image")
savepath = path +"/output/";
last = 1;
setBackgroundColor(255, 255, 255);
last = false;
roilabel = "xx";

//GO PREPROCESS
run("8-bit");
run("Make Inverse");
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");
run("Select None");
run("Invert");
imgName = getTitle();
setTool("freehand");
waitForUser("Select the cell layer you want to analyze by circling it. Don't select background. Use shift to add to the selection and alt/option key to remove from the selection");
run("Duplicate...", origimgName);
run("Make Inverse");
run("Clear", "slice");
run("Select None");
rename(title + "_adjcontr_inv.tif");
savename = getTitle();
//save whole cutout
run("Duplicate...", savename);
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");
run("Select None");
saveAs("Tiff", savepath + savename);
selectWindow(savename);

//GO PARCELLATE
if(getBoolean("Would you like to further parcellate the selection?","Yes","No"))
	{
	imgName = getTitle();
	title = substring(imgName, 0, lastIndexOf(imgName,"."));
	while (last == false)
		{
		selectWindow(imgName);
  		run("Select None");
		setTool("freehand");
		Dialog.create ("Parcellation");
		Dialog.addString("Name:", roilabel);
		Dialog.addCheckbox("last subregion?", false);
  		Dialog.show();
  		roilabel = Dialog.getString();
  		last = Dialog.getCheckbox();
		waitForUser("Select " + roilabel + " hold shift to add and alt/option to remove from selection.");
		run("Duplicate...", imgName);
		run("Make Inverse");
  		run("Clear", "slice");
		run("Select None");
		run("Enhance Contrast", "saturated=0.35");
		run("Apply LUT");
		rename(title + "_" + roilabel + ".tif");
		savename = getTitle();
		saveAs("Tiff", savepath + "/" + savename);
		selectWindow(imgName);
		run("Clear", "slice");
		run("Select None");
	}
}
else
{
}

/////wrap up
if (isOpen("Results")) {
         selectWindow("Results");
         run("Close" );
}
if (isOpen("Log")) {
         selectWindow("Log");
         run("Close" );
}
if (isOpen("ROI Manager")) {
     	 selectWindow("ROI Manager");
     	 run("Close");
}
while (nImages()>0) {
         selectImage(nImages());
         run("Close");
}
