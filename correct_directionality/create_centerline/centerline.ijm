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
//set up
imgName = getTitle();
path = getDir("image");
title = substring(imgName, 0, lastIndexOf(imgName,"."));

//manually create center line and render as one point every 3pxl
setTool("polyline");
waitForUser("Draw the center line. End the line with right click. then hit OK"); 
run("Fit Spline");
run("Interpolate", "interval=3 smooth adjust");
getSelectionCoordinates(xCoordinates, yCoordinates);

//export center line as CSV file
for(i=0; i<lengthOf(xCoordinates); i++) {
    setResult("X_mean", i, xCoordinates[i]);
    setResult("Y_mean", i, yCoordinates[i]);
}
updateResults();
saveAs("Results", path + "output/" + title + "_centerline.csv");

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