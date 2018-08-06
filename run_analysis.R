library(dplyr)
library(qdap)

#################################### GETTING DATA ##########################################

fileURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'

# Check if the data already exists, otherwise dowlonwd it to the work directory.
# Check if the downlowded zip file is unzipped, otherwise unzip it in the work directory.

if(!file.exists('zip_file')){
  download.file(fileURL, 'zip_file')
} else {
  if(!file.exists('UCI HAR Dataset')){
    unzip('zip_file')
  }
}

################################## READING DATA ############################################

trainSubjects <- read.table(file.path('UCI HAR Dataset', 'train', 'subject_train.txt'))
trainValues <- read.table(file.path('UCI HAR Dataset', 'train', 'X_train.txt'))
trainActivity <- read.table(file.path('UCI HAR Dataset', 'train', 'y_train.txt'))

testSubjects <- read.table(file.path('UCI HAR Dataset', 'test', 'subject_test.txt'))
testValues <- read.table(file.path('UCI HAR Dataset', 'test', 'X_test.txt'))
testActivity <- read.table(file.path('UCI HAR Dataset', 'test', 'y_test.txt'))

features <- read.table(file.path('UCI HAR Dataset', 'features.txt'), as.is = TRUE)

activities <- read.table(file.path('UCI HAR Dataset', 'activity_labels.txt'))

############################ MERGING TRAINING SET AND TEST SET #############################

dataset <- rbind(
  cbind(trainSubjects, trainActivity, trainValues),
  cbind(testSubjects, testActivity, testValues)
)

# Retrieve column names from features file

cols <- c('subject', 'activity', features[,2])
colnames(dataset) <- cols

# Filter column names by "mean" and "std" key words to select the desired variables

wantedFeatures <- features[grepl('mean|std', features[,2]),2]
wantedDataset <- dataset[c('subject', 'activity', wantedFeatures)]

####################### NAMING THE ACTIVITIES IN THE DATA SET ############################## 

wantedDataset$activity <- factor(wantedDataset$activity, labels = activities[,2]) 

######################## USING DESCRIPTIVE VARIABLE NAMES ##################################

colnames(wantedDataset) <- lapply(colnames(wantedDataset), function(x) mgsub(
  c('Acc','Mag','std','mean','BodyBody','-','()'), 
  c('Acceler','Magnit','Std','Mean','Body','',''), x)) 

################ CREATING A TIDY DATA SET WITH THE AVERAGE OF EACH VARIABLE ################

tidyData <- wantedDataset %>% group_by(subject, activity) %>% summarize_all(mean)

# Save the tidy data to a text file

write.table(tidyData, "tidy_data.txt")