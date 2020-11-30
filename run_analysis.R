library(reshape2)

filename <- "getdata_dataset.zip"

## download :
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
# unzip the dataset
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels 
activity_Labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_Labels[,2] <- as.character(activity_Labels[,2])

#Load features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted_names <- features[featuresWanted,2]
#replace mean with MEan and std with Std and remove ()
featuresWanted_names = gsub('-mean', 'Mean', featuresWanted_names)
featuresWanted_names = gsub('-std', 'Std', featuresWanted_names)
featuresWanted_names <- gsub('[-()]', '', featuresWanted_names)

# Load the datasets for train
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
activities_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subjects_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(subjects_train, activities_train, x_train)

# Load the datasets for test
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
activities_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subjects_test<- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(subjects_test, activities_test, x_test)

# merge datasets and add labels
allData <- rbind(train, test)
head(allData)
#renaming variables
colnames(allData) <- c("subject", "activity", featuresWanted_names)
head(allData)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activity_Labels[,1], labels = activity_Labels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
head(allData.melted)
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
