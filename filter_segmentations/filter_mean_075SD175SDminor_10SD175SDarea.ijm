///////////////////
//////////////////
///written by Jan Oltmer
///10092022
///howto: Move all input files into "input" folder
///move scripts into "scripts" folder in "input" folder
///generate "output" folder in "input" folder
///generate "csv", "labeled", "nolabel", and "filtered_percentages" folders in "output" folder
///Run "batch_process.ijm" as a plugin with Fiji/ImageJ
///change filtering parameters below
//////////////////
//////////////////
//DEFINE FILTERING PARAMETERS HERE (set 10 to deactivate)
//MODIFY INSTANCES OF PARAMETER VARIABLE TO FIT NEW THRESHOLDS!
upperdiameter = 1.75;
lowerdiameter = 0.75;
upperarea = 1.75;
lowerarea = 10;
//////////////////
//////////////////

//set up
imgName = getTitle();
splitName = split(imgName,"_");
case = splitName[0];
slide = splitName[4];
roiid = splitName[5];
//roiid = splitName[2];
//roiid = splitName[8];
zoom = splitName[1];
zooms = newArray;
path = getDir("image");
title = substring(imgName, 0, lastIndexOf(imgName,"."));
parameters = newArray;
numbers = newArray;
areas = newArray;
densities = newArray;
percentages = newArray;
parameters = newArray;
numbers = newArray;
percentages = newArray;
roiids = newArray;
deleteROIfilter0 = newArray;
deleteROIfilter = newArray;
deleteROIfilter2 = newArray;
deleteROIfilter3 = newArray;
deleteROIfilter4 = newArray;
NNmean = newArray;
NNSD = newArray;
NN3mean = newArray;
NN3SD = newArray;
cases2 = newArray;
slides2 = newArray;
roiids2 = newArray;
zooms2 = newArray;
parameters2 = newArray;
numbers2 = newArray;
percentages2 = newArray;
areas2 = newArray;
densities2 = newArray;
NNmean2 = newArray;
NNSD2 = newArray;
NN3mean2 = newArray;
NN3SD2 = newArray;
means_area = newArray;
SDs_area = newArray;
means_minor = newArray;
SDs_minor = newArray;
means_circ = newArray;
SDs_circ = newArray;
wallmean = newArray;
wallSD = newArray;
means_area2 = newArray;
SDs_area2 = newArray;
means_minor2 = newArray;
SDs_minor2 = newArray;
means_circ2 = newArray;
SDs_circ2 = newArray;
wallmean2 = newArray;
wallSD2 = newArray;
N=0;
total_area=0;
mean_area=0;
total_variance=0;
variance_area=0;
SD_Circ=0;
SE_Circ=0;
CI95SD_Circ=0;
max_Circ=0;
min_Circ=0;
SD_Area=0;
SE_Area=0;
CI95_Area=0;
max_Area=0;
min_Area=0;
total_minor=0;
mean_minor=0;
total_variance=0;
variance_minor=0;
SD_Minor=0;
SE_Minor=0;
CI95_Minor=0;
max_minor=0;
min_minor=0;
roiManager("Show All with labels");
//setBatchMode(true);
//basic formatiing
run("Invert");
run("Clear Results");
run("Set Scale...", "distance=1 known=0.75488 unit=um");
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness invert display redirect=None decimal=3");
//remove 00 rois
nROIROIs = roiManager("count");
nROIs = roiManager("count");
roiManager("Measure");
for (i = 0; i < nROIs; i++)
{
    roiManager("select", i);
    Minor1 = getResult("Minor", i);
    if (Minor1 > 0)
    {
    }
    else
    {
    deleteROIfilter0 = Array.concat(deleteROIfilter0, i);
    }
}
if (deleteROIfilter0.length < 1)
    {
    print("nothing to filter 00");
    }
    else
    {
    roiManager("Select", deleteROIfilter0);
	  roiManager("Delete");
	  run("Clear Results");
	  print("filtered 00");
    }
	  run("Clear Results");

//rename rois with index
nROIROIs = roiManager("count");
  for (i = 0; i < nROIROIs; i++)
  {
	roiManager("select", i);
	roiManager("Rename", i);
  }
roiManager("Deselect");
run("Select None");

//export tissue mean and std
run("Select None");
run("Duplicate...", imgName);
rename(title + "_thresholdbackground.tif");
selectWindow(title + "_thresholdbackground.tif");
run("Select None");
setThreshold(253, 255);
run("Analyze Particles...", "size=30000-Infinity show=Masks clear in_situ");
run("Create Selection");
run("Make Inverse");
selectWindow(imgName);
run("Restore Selection");
run("Measure");
a = getResult("StdDev");
b = getResult("Mean");
c = b - 0.25 * a;
areawhole = getResult("Area");
nROIs = roiManager("count");
saveAs("Results", path + "output/csv/" + title + "_mean_stddev.csv");
run("Clear Results");

//CALCULATE THRESHOLDS
////////create minor threshold
//Number of results in "Minor" Column
roiManager("Measure");
N = nResults;
//Mean "Minor"column
total_minor = 0;
for (a=0; a<nResults(); a++) {
    total_minor=total_minor+getResult("Minor",a);
}
mean_minor=total_minor/nResults;
total_variance = 0;
//Variance of "Minor" column
for (a=0; a<nResults(); a++) {
    total_variance=total_variance+(getResult("Minor",a)-(mean_minor))*(getResult("Minor",a)-(mean_minor));
}
variance_minor=total_variance/(nResults-1);
//SD of "Minor" column (note: requires variance)
SD_Minor=sqrt(variance_minor);
//upper threshold
cutoffminorup = mean_minor + upperdiameter * SD_Minor;
cutoffminordown = mean_minor - lowerdiameter *  SD_Minor;
run("Clear Results");

////////create area threshold
//Number of results in "Area" Column
roiManager("Measure");
N = nResults;
//Mean "Area"column
total_area = 0;
for (a=0; a<nResults(); a++) {
    total_area=total_area+getResult("Area",a);
}
mean_area=total_area/nResults;
total_variance = 0;
//Variance of "Area" column
for (a=0; a<nResults(); a++) {
    total_variance=total_variance+(getResult("Area",a)-(mean_area))*(getResult("Area",a)-(mean_area));
}
variance_area=total_variance/(nResults-1);
//SD of "Area" column (note: requires variance)
SD_Area=sqrt(variance_area);
//upper threshold
cutoffareaup = mean_area + upperarea * SD_Area;
cutoffareadown = mean_area - lowerarea * SD_Area;
run("Clear Results");
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////START
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
//export unfiltered inverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness invert display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
parameter = "unfiltered";
saveAs("Results", path + "output/csv/" + title + "_results_inv_" + parameter + ".csv");
selectWindow(imgName);
//export unfiltered noninverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
saveAs("Results", path + "output/csv/" + title + "_results_noninv_" + parameter + ".csv");

//flatten and save with labels
roiManager("Show All with labels");
run("Flatten");
rename(title + "_unfiltered_flat.tif");
saveAs("Jpeg", path + "output/labeled/" +  getTitle());
selectWindow(imgName);

//flatten and save without labels
roiManager("Show All without labels");
run("Flatten");
rename(title + "_unfiltered_flat.tif");
saveAs("Jpeg", path + "output/nolabel/" +  getTitle());
selectWindow(imgName);
run("Clear Results");
//filter mean
selectWindow(imgName);
roiManager("Measure");
nROIs = roiManager("count");
for (i = 0; i < nROIs; i++)
{
    roiManager("select", i);
    mean = getResult("Mean", i);
    if (mean < c)
    {
    }
    else
    {
    deleteROIfilter = Array.concat(deleteROIfilter, i);
    }
}
if (deleteROIfilter.length < 1)
    {
    print("nothing to filter MEAN");
    }
    else
    {
    roiManager("Select", deleteROIfilter);
	  roiManager("Delete");
	  run("Clear Results");
	  print("filtered MEAN");
    }
;
//export filtered mean inverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness invert display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  	for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
parameter = "mean";
saveAs("Results", path + "output/csv/" + title + "_results_inv_" + parameter + ".csv");
run("Clear Results");

//export filtered noninverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  	for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
saveAs("Results", path + "output/csv/" + title + "_results_noninv_" + parameter + ".csv");
run("Clear Results");

//flatten and save with labels
selectWindow(imgName);
roiManager("Show All with labels");
run("Flatten");
rename(title + "_filtered_" + parameter + "_flat.tif");
saveAs("Jpeg", path + "output/labeled/" +  getTitle());
selectWindow(imgName);

//flatten and save without labels
selectWindow(imgName);
roiManager("Show All without labels");
run("Flatten");
rename(title + "_filtered_" + parameter + "_flat.tif");
saveAs("Jpeg", path + "output/nolabel/" +  getTitle());
selectWindow(imgName);

///////////////////////////////////////
//filter minor
run("Clear Results");
selectWindow(imgName);
roiManager("Deselect");
run("Select None");
nROIs = roiManager("count");
roiManager("Measure");

////// remove too small and too large
for (i = 0; i < nROIs; i++)
{
    roiManager("select", i);
    minor = getResult("Minor", i);
    if (minor > cutoffminorup)
    {
    deleteROIfilter2 = Array.concat(deleteROIfilter2, i);
    }
    if (minor < cutoffminordown)
    {
    deleteROIfilter2 = Array.concat(deleteROIfilter2, i);
    }
}
if (deleteROIfilter2.length < 1)
    {
    print("nothing to filter MINOR");
    }
    else
    {
    roiManager("Select", deleteROIfilter2);
	  roiManager("Delete");
	  run("Clear Results");
	  print("filtered MEAN MINOR");
    }
;
//export minor filtered inverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness invert display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  	for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
parameter = "mean+075SD10SDminor";
saveAs("Results", path + "output/csv/" + title + "_results_inv_" + parameter + ".csv");

//export filtered noninverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  	for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
saveAs("Results", path + "output/csv/" + title + "_results_noninv_" + parameter + ".csv");
run("Clear Results");

//flatten and save with labels
roiManager("Show All with labels");
selectWindow(imgName);
run("Flatten");
rename(title + "_filtered_" + parameter + "_flat.tif");
saveAs("Jpeg", path + "output/labeled/" +  getTitle());
selectWindow(imgName);

//flatten and save without labels
roiManager("Show All without labels");
selectWindow(imgName);
run("Flatten");
rename(title + "_filtered_" + parameter + "_flat.tif");
saveAs("Jpeg", path + "output/nolabel/" +  getTitle());
selectWindow(imgName);
/////

///////////////////////////////////////
//filter area
run("Clear Results");
selectWindow(imgName);
roiManager("Deselect");
run("Select None");
nROIs = roiManager("count");
roiManager("Measure");

////// remove too small and too large
for (i = 0; i < nROIs; i++)
{
    roiManager("select", i);
    area = getResult("Area", i);
    if (area > cutoffareaup)
    {
    deleteROIfilter3 = Array.concat(deleteROIfilter3, i);
    }
    if (area < cutoffareadown)
    {
    deleteROIfilter3 = Array.concat(deleteROIfilter3, i);
    }
}
if (deleteROIfilter3.length < 1)
    {
    print("nothing to filter AREA");
    }
    else
    {
    roiManager("Select", deleteROIfilter3);
	  roiManager("Delete");
	  run("Clear Results");
	  print("filtered MEAN MINOR AREA");
    }
;
//export area filtered inverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness invert display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  	for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
parameter = "mean+075SD10SDminor+10SD10SDarea";
saveAs("Results", path + "output/csv/" + title + "_results_inv_" + parameter + ".csv");
run("Clear Results");

//export filtered noninverted
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated skewness display redirect=None decimal=3");
roiManager("Deselect");
run("Select None");
roiManager("Measure");
  	for (i=0; i<nResults; i++) {
    oldLabel = getResultLabel(i);
    delimiter = indexOf(oldLabel, ":");
    newLabel = substring(oldLabel, delimiter+1);
    setResult("Label", i, newLabel);
  }
saveAs("Results", path + "output/csv/" + title + "_results_noninv_" + parameter + ".csv");
run("Clear Results");

//flatten and save with labels
roiManager("Show All with labels");
selectWindow(imgName);
run("Flatten");
rename(title + "_filtered_" + parameter + "_flat.tif");
saveAs("Jpeg", path + "output/labeled/" +  getTitle());
selectWindow(imgName);

//flatten and save without labels
roiManager("Show All without labels");
selectWindow(imgName);
run("Flatten");
rename(title + "_filtered_" + parameter + "_flat.tif");
saveAs("Jpeg", path + "output/nolabel/" +  getTitle());
selectWindow(imgName);

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
