##################
##################
###written by Jan Oltmer
###10092022
###howto: Move all input files into "input" folder (filtered csv files)
###move scripts into "scripts" folder in "input" folder
###generate "output" folder in "input" folder
###LINK THE PATH VARIABLE TO THE INPUT FOLDER
###LINK THE pathMean VARIABLE TO THE CENTERLINE
###LINK THE pathOutput VARIABLE TO THE OUTPUT FOLDER
###RUN THE SCRIPT
##################
##################
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(zoo)
library(RANN)
library(ggquiver)
library(imputeTS)
library(stringr)
library(gridExtra)
library(circular)
library(REdaS)
library(spatstat)
library(dismo)
library(raster)

########define paths
path <- "PATH TO FILTERED INPUT CSV"
pathMean <- "PATH TO CENTERLINE CSV"
pathOutput<- "PATH TO OUTPUT FOLDER"

########import data 
files <- list.files(path=path) ## creates a vector with all file names in your folder
filesMean <- list.files(path=pathMean) ## creates a vector with all file names in your folder
gridsize <- 210

####create arrays
case <- rep(0,length(files))
slide <- rep(0,length(files))
subregion <- rep(0,length(files))
angle <- rep(0,length(files))
meanangle <- rep(0,length(files))
doubleangle <- rep(0,length(files))
meandoubleangle <- rep(0,length(files))
datafull <- data.frame()
j <- 1

for(i in (files)){
  print(files[j])
  ### fill vectors and define names
  spl <- unlist(strsplit(files[j], "_"))
  spl2 <- spl
  case[j] <- spl[1]
  slide[j] <- spl[5]
  subregion[j] <- spl[9]
  namePathIn <- paste(path,files[j],sep="")
  nameOut <- paste(case[j],"_",slide[j],"_",subregion[j],sep="")
  namePathOut <- paste(path,case[j],"_",slide[j],"_",subregion[j],sep="")
  
  ##### read in data, define names
  data <- fread(namePathIn) %>% data.frame
  rownames(data) <- data$Label
  
  #### change flip y direction for angle
  data$Angle <- 180 - data$Angle
  
  ##read in centerline
  spl <- unlist(strsplit(files[j], "_results"))
  nameNoCsv <- unlist(strsplit(files[j], "_results"))
  nameNoCsv <- nameNoCsv[1]
  centerlineName <- paste(pathMean,nameNoCsv,"_centerline.csv",sep="")
  centerline <- read.csv(file = centerlineName)
  X_mean <- centerline$X_mean*0.75488
  Y_mean <- centerline$Y_mean*0.75488
  centerline <- data.frame(X_mean,Y_mean)
  
  ### calculate nearest points between datapoints and centerline
  nearest <- nn2(centerline[,c("X_mean","Y_mean")],data[,c("X","Y")],k=1)
  nearest$X_check <- data$X
  nearest$Y_check <- data$Y
  newX <- rep(0,length(data))
  newY <- rep(0,length(data))
  g <- 1
  for (z in nearest$nn.idx) {
    newX[g] <- X_mean[z]
    newY[g] <- Y_mean[z]
    g <- g + 1
  }
  nearest$X_mean <- newX
  nearest$Y_mean <- newY
  
  ### calculate angle between datapoint and registered centerpoint
  correctionAngle <- rep(0,length(data))
  X <- nearest$X_check
  Y <- nearest$Y_check
  g <- 1
  for (z in nearest$nn.idx) {
    correctionAngle[g] <- (atan2(nearest$Y_mean[g]-nearest$Y_check[g],nearest$X_mean[g]-nearest$X_check[g]))*(180/pi)
    g <- g + 1
  }
  nearest$correctionAngle <- correctionAngle
  nearest <- as.data.frame(nearest)
  
  ### only positive correction angles
  g <- 1
  for (z in nearest$correctionAngle) {
    if (nearest$correctionAngle[g] < 0) {
      nearest$correctionAngle[g] <- 180 - abs(nearest$correctionAngle[g])
    }
    g <- g + 1
  }
  
  ### calclate corrected angle
  nearest$correctedAngle <- data$Angle - nearest$correctionAngle + 90
  
  ### only positive corrected angles
  g <- 1
  for (z in nearest$correctedAngle) {
    if (nearest$correctedAngle[g] < 0) {
      nearest$correctedAngle[g] <- 180 - abs(nearest$correctedAngle[g])
    }
    g <- g + 1
  }
  
  ### only 0-180 corrected angles
  g <- 1
  for (z in nearest$correctedAngle) {
    if (nearest$correctedAngle[g] > 180) {
      nearest$correctedAngle[g] <- nearest$correctedAngle[g] - 180
    }
    g <- g + 1
  }
  
  ### calculate nearest neighbor distance
  nearest$nndist<-nndist(nearest$X_check,data$Y_check)
  
  ### add normal angle, case, slide, subregion
  nearest$Angle <- data$Angle
  nearest$case <- nearest$Angle
  nearest$slide <- nearest$Angle
  nearest$subregion <- nearest$Angle
  g <- 1
  for (z in nearest$Angle) {
    nearest$case[g] <- case[j]
    nearest$slide[g] <- slide[j]
    nearest$subregion[g] <- subregion[j]
    g <- g + 1
  }

  ### add absolute difference to 90 angle
  nearest$AngleDifference <- abs(90-nearest$correctedAngle)
  
  ##save individual csv
  data <- cbind(data,nearest)
  write.csv(data,paste(pathOutput,nameOut,"_corrected.csv",sep=""))
  
  ##prepare next step
  j <- j+1
}