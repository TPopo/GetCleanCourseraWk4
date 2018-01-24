## below specifies libraries and regularly used variables for below

library(data.table)
library(plyr)
directory = "./Week4Assignment" ## where you want the files
filename = "data.zip" ## specify filename and extension
fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

## below creates files and downloads data

if(!dir.exists(directory)){
            dir.create(directory)
}

if(!file.exists(paste(directory,"/",filename))){
      download.file(fileUrl, paste(directory,"/",filename, sep=""))
}

## below unzips the .zip file

zipF <- as.character(paste(directory,"/",filename, sep=""))
outDir <- as.character(directory)
unzip(zipF,exdir=outDir)

## below lists files in dataset

files <- list.files(as.character(directory))
print(files)

## below reads sets, and set names, and subject ids of 6 required files

x.train <- read.table("./Week4Assignment/UCI HAR Dataset/train/X_train.txt")
x.test <- read.table("./Week4Assignment/UCI HAR Dataset/test/X_test.txt")

subj.train <- read.table("./Week4Assignment/UCI HAR Dataset/train/subject_train.txt")
subj.test <- read.table("./Week4Assignment/UCI HAR Dataset/test/subject_test.txt")

y.train <- read.table("./Week4Assignment/UCI HAR Dataset/train/y_train.txt")
y.test <- read.table("./Week4Assignment/UCI HAR Dataset/test/y_test.txt")

## bind each together

x.features <- rbind(x.train, x.test)
subj <- rbind(subj.train, subj.test)
y.activities <- rbind(y.train, y.test)

## below sets descriptive names

names(subj) <- c("subject")
names(y.activities) <- c("activity")
dataFeaturesNames <- read.table("./Week4Assignment/UCI HAR Dataset/features.txt", head=FALSE)
names(x.features)<- dataFeaturesNames$V2

# below creates 1 data set, fulfills requirement #1

combined <- cbind(subj, y.activities)
data <- cbind(x.features, combined)

## below will extract all variable names, by using grep, that match variable names
## in the features as described in features.txt that contain mean() OR std(), 
## using \\ will escape the parentheses

subdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

## using this list, we can subset only the variable names that contain mean and std,
## this fulfills requirement #2

selectedNames <- c(as.character(subdataFeaturesNames), "subject", "activity" )
subsetdata <- subset(data,select=selectedNames)

## now we go on to give things descriptive names, fulfilling #3 & 4 requirement

activitylabels <-read.table("./Week4Assignment/activity_labels.txt", header=FALSE)

names(subsetdata) <- gsub("^t", "time", names(subsetdata))
names(subsetdata) <- gsub("^f", "frequency", names(subsetdata))
names(subsetdata) <- gsub("Acc", "Accelerometer", names(subsetdata))
names(subsetdata) <- gsub("Gyro", "Gyroscope", names(subsetdata))
names(subsetdata) <- gsub("Mag", "Magnitude", names(subsetdata))
names(subsetdata) <- gsub("BodyBody", "Body", names(subsetdata))

## then we output the second tidy data frame, fulfilling #5

data2 <- aggregate(. ~subject + activity, subsetdata, mean)
data2 <- data2[order(data2$subject,data2$activity),]
write.table(data2, file = "./Week4Assignment/tidydata.txt", row.name = FALSE)
