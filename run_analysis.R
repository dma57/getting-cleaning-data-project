#########################################################################################################
##
## script run_analysis.R

## 1-Merges the training and the test sets to create one data set.
## 2-Extracts only the measurements on the mean and standard deviation for each measurement.
## 3-Uses descriptive activity names to name the activities in the data set
## 4-Appropriately labels the data set with descriptive variable names.
## 5-From the data set in step 4, creates a second, independent tidy data set with the average 
## of each variable for each activity and each subject.

#########################################################################################################

## Download the zip file
zipFileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(zipFileUrl,destfile="./Dataset.zip",method="curl")

## unzip the zip file in the working directory
unzip(zipfile="./Dataset.zip",exdir=".")

## name of the folder created after unzipping
data_folder <- "UCI HAR Dataset"

## load the activity labels & features files
activityLabels <- read.table(file.path(data_folder,"activity_labels.txt"))
featuresNames <- read.table(file.path(data_folder,"features.txt"))

## load the train dataset
trainFeatures <- read.table(file.path(data_folder,"train","X_train.txt"))
trainActivities <- read.table(file.path(data_folder,"train","Y_train.txt"))
trainSubjects <- read.table(file.path(data_folder,"train","subject_train.txt"))

## load the test dataset
testFeatures <- read.table(file.path(data_folder,"test","X_test.txt"))
testActivities <- read.table(file.path(data_folder,"test","Y_test.txt"))
testSubjects <- read.table(file.path(data_folder,"test","subject_test.txt"))

## merge the training and test data tables
features <- rbind(trainFeatures, testFeatures)
activities <- rbind(trainActivities, testActivities)
subjects <- rbind(trainSubjects, testSubjects)

## name the columns
names(features) <- featuresNames$V2
names(activities) <- c("activities")
names(subjects) <- c("subjects")

## merge all in one
alldata <- cbind(subjects, activities, features)

## extracts only the measurements on the mean and standard deviation for each measurement
featuresNamesMeanStd <- grep("mean\\(\\)|std\\(\\)", featuresNames$V2)
featuresNamesKept <- featuresNames$V2[featuresNamesMeanStd]
featuresNamesKept <- as.character(featuresNamesKept)
alldata <- subset(alldata, select = c("subjects", "activities", featuresNamesKept))

## Use descriptive activity names to name the activities in the data set
alldata$activities <- factor(alldata$activities, levels = activityLabels$V1, labels = activityLabels$V2)

## Appropriately labels the data set with descriptive variable names
names(alldata)<-gsub("Acc", "Accelerometer", names(alldata))
names(alldata)<-gsub("Gyro", "Gyroscope", names(alldata))
names(alldata)<-gsub("Mag", "Magnitude", names(alldata))
names(alldata)<-gsub("^t", "time", names(alldata))
names(alldata)<-gsub("^f", "frequency", names(alldata))

## create a second, independent tidy data set with the average 
## of each variable for each activity and each subject.
alldata2 <- aggregate(. ~subjects + activities, alldata, mean)

## generate de txt file from the alldata2 data frame
write.table(alldata2, file = "tidyDataAvg.txt",row.name=FALSE)
