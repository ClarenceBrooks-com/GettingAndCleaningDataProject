library(reshape2)

# Set local filename for downloaded zip file to "dataset.zip".
filename <- "dataset.zip"

# Download the zip file from the link specified in the course project:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename, method="curl")  # curl might not be needed on Linux
}  


# When file is unzipped, the unzipped folder is "UCI HAR Dataset".
# If this folder doesn't already exist, unzip the zip file to create it.
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load the activity labels.
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])  # might not be needed

# Load the features.
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])  # might not be needed

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
# Replace "-mean" with "Mean".
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
# Replace "-std" with "Std".
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
# Replace brackets, dashes, parentheses with nothing.
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# Load the train datasets.
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
# Column bind (cbind) these datasets.
train <- cbind(trainSubjects, trainActivities, train)

# Load the test datasets.
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
# Column bind (cbind) these datasets.
test <- cbind(testSubjects, testActivities, test)

# Merge the datasets (row bind).
fullData <- rbind(train, test)
# Add labels ("subject","activity").
colnames(fullData) <- c("subject", "activity", featuresWanted.names)

# Turn activities into factors.
fullData$activity <- factor(fullData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
# Turn subjects into factors.
fullData$subject <- as.factor(fullData$subject)

# melt the dataframe; make it taller and skinnier by making separate rows for column values.
fullData.melted <- melt(fullData, id = c("subject", "activity"))
# cast the dataframe; put subject + activity in the rows and variable in the columns, and take the mean (average).
fullData.mean <- dcast(fullData.melted, subject + activity ~ variable, mean)

# Write the result to "tidy.txt" in the local directory.
write.table(fullData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)







