## Script to load data from seperate datasets, merge data into one data frame and export summarised data to text file

# Load activity names to a vector
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", sep="", col.names = c("Activity","Activity_Desc"))

# Load features for column labels and convert to lower case, remove characters
features <- read.table("UCI HAR Dataset/features.txt", sep="")
features$V2 <- tolower(features$V2)
remove <- c("\\(", "\\)", "-", ",")
for (char in remove) {
  features$V2 <- gsub(char, "", features$V2)
}

#Load all data from test directory
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", sep="", col.names = features[ ,2])
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt", sep="", col.names = c("Activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", sep="", col.names = c("Subject"))

#Load all data from train directory
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", sep="", col.names = features[ ,2])
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt", sep="", col.names = c("Activity"))
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", sep="", col.names = c("Subject"))

# Merge subject data and activity to measurements
x_train <- cbind(subject_train, x_train)
x_train <- cbind(merge(y_train,activity_labels,by="Activity", all=TRUE), x_train)
x_test <- cbind(subject_test, x_test)
x_test <- cbind(merge(y_test,activity_labels,by="Activity", all=TRUE), x_test)

# Append test to train
mergedData <- rbind(x_train, x_test)

# Select columns with "mean" or "std"
colNames <- names(mergedData)
meanCol <- grep("mean", colNames)
stdCol <- grep("std", colNames)
selectedCol <- sort(c(2,3,meanCol,stdCol))
selectedData <- mergedData[ ,selectedCol]

# Order data by subject then activity
selectedData <- selectedData[order(selectedData$Subject,selectedData$Activity_Desc) , ]

# Summarise data by taking mean of results
df_melt <- melt(selectedData, id = c("Subject", "Activity_Desc"))
result <- dcast(df_melt, Subject + Activity_Desc ~ variable , fun.aggregate = mean)

# Output final result to a text file for presentation
write.table(result, "getdata_006.txt", sep="\t", row.name=FALSE)