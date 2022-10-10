from ij import IJ;
from ij.plugin.frame import RoiManager;
from ij.gui import PolygonRoi;
from ij.gui import Roi;
from java.awt import FileDialog
from ij import IJ, WindowManager
from ij.gui import GenericDialog

imp = WindowManager.getCurrentImage()
title = imp.getTitle()
if title.endswith('.tif'):
    title = title[:-4]
imp2 = IJ.getImage()
path = imp2.getOriginalFileInfo().directory
file_name = path + title + "_cp_outlines.txt"
print(file_name)

RM = RoiManager()
rm = RM.getRoiManager()

imp = IJ.getImage()

with open(file_name, 'r') as textfile:
	for line in textfile:
		if not line.rstrip():
       			continue
		xy = map(int, line.rstrip().split(','))
		X = xy[::2]
		Y = xy[1::2]
		imp.setRoi(PolygonRoi(X, Y, Roi.POLYGON));
		#IJ.run(imp, "Convex Hull", "")
		roi = imp.getRoi()
		print roi
		rm.addRoi(roi)

rm.runCommand("Associate", "true")
rm.runCommand("Show All with labels")
