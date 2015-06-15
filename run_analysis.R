# This file is a result of course project for coursera getdata-015 course
# Exact condition statement are following:
#  You should create one R script called run_analysis.R that does the following. 
#    1. Merges the training and the test sets to create one data set.
#    2. Extracts only the measurements on the mean and standard deviation 
#       for each measurement. 
#    3. Uses descriptive activity names to name the activities in the data set
#    4. Appropriately labels the data set with descriptive variable names. 
#    5. From the data set in step 4, creates a second, independent tidy data set
#       with the average of each variable for each activity and each subject.
#



# We will use features names from features.txt as descriptive column names
# in "main" data sets
features_list<-read.table(
  "UCI HAR Dataset/features.txt",
  stringsAsFactors=F,col.names=c("featureId","featureName"))

# By course project statement we should, literally:
#   "Extracts only the measurements on the mean and standard deviation for each measurement."
# This statement is a little bit ambiguous because there are three different kinds of measurement
#  related to "means" in a given data. 
#   1. "Straightforward" means for variables (e.g. tBodyAcc-mean()-X, fBodyBodyGyroMag-mean() )
#   2. Additional vectors which averaging the signals in a signal window sample
#      (e.g. gravityMean, tBodyAccMean)
#   3. "Angle" measurements (e.g. angle(tBodyAccMean,gravity), angle(tBodyAccJerkMean),gravityMean))
# The statement bellows is to select only means of the first type.
# To extract all three kinds of means use this statement instead:
#  meanAndStdColumns<-grepl("mean",features_list$V2)|grepl("std\\(\\)",features_list$V2)
# To extract only first and second types of mean use this statement instead:
#  meanAndStdColumns<-grepl("-mean",features_list$V2)|grepl("std\\(\\)",features_list$V2)

meanAndStdColumns<-
  grepl("mean\\(\\)",features_list$featureName)|
  grepl("std\\(\\)",features_list$featureName)

# columnClasses will be passed as colClasses parameter in "main data" read.table calls 
# and only columns "marked" as type "numeric" will be actually loaded, and columns marked as
# type "NULL" will be completely ignored, saving our memory and improving overall load time  
#
# 66 out of 561 columns expected to be selected in case of "first type of means" is chosen
# (see above)  
columnsClasses<-rep("NULL",nrow(features_list))
columnsClasses[meanAndStdColumns]<-"numeric"

# activities labels will be used to provide descriptive activity names 
# to name the activities in the reslting data set
activities<-read.table(
  "UCI HAR Dataset/activity_labels.txt",col.names=c("ActivityId","ActivityName"))


# Actually loads first portion of "main data" only selected columns as described above
x_data_test_std_mean_columns<-
  read.table(
    "UCI HAR Dataset/test/X_test.txt",
    colClasses = columnsClasses,
    col.names = features_list$featureName)

# Loads activity id column of first portion of "main data" stored in separate file
y_data_test<-read.table(
  "UCI HAR Dataset/test/y_test.txt",col.names=c("ActivityId"))

# Loads subject id column of first portion of "main data" stored in separate file
subjects_data_test<-read.table(
  "UCI HAR Dataset/test/subject_test.txt",col.names=c("SubjectId"))

# prepare columns for futher use in cbind in order to use cbind's autonaming
SubjectId<-subjects_data_test$SubjectId

# data activity ids merged with activity id to name maping data in order to provide
# descriptive activity name labels
ActivityName<-merge(y_data_test,activities)$ActivityName

#Combine all necessary columns of first portion of data into one dataset
# expected result dimension is 2947 rows of 68 columns
data_test<-cbind(
  SubjectId,
  ActivityName,
  x_data_test_std_mean_columns)

# cleanup unnecessary intermediate data to free up some memory 
rm(x_data_test_std_mean_columns)
rm(y_data_test)
rm(subjects_data_test)


# Actually loads second portion of "main data" only selected columns as described above
x_data_train_std_mean_columns<-
  read.table(
    "UCI HAR Dataset/train/X_train.txt",
    colClasses = columnsClasses,
    col.names = features_list$featureName)

# Loads activity id column of second portion of "main data" stored in separate file
y_data_train<-read.table(
  "UCI HAR Dataset/train/y_train.txt",col.names=c("ActivityId"))

# Loads subject id column of second portion of "main data" stored in separate file
subjects_data_train<-read.table(
  "UCI HAR Dataset/train/subject_train.txt",col.names=c("SubjectId"))

# prepare columns for futher use in cbind in order to use cbind's autonaming
SubjectId<-subjects_data_train$SubjectId

# data activity ids merged with activity id to name maping data in order to provide
# descriptive activity name labels
ActivityName<-merge(y_data_train,activities)$ActivityName

#Combine all necessary columns of second portion of data into one dataset
# expected result dimension is 7352 rows of 68 columns
data_train <-cbind(
  SubjectId,
  ActivityName,
  x_data_train_std_mean_columns)

# cleanup unnecessary intermediate data to free up some memory 
rm(x_data_train_std_mean_columns)
rm(y_data_train)
rm(subjects_data_train)


#Combine all rows of first portion data with all rows of second portion of data
#in order to get resulting tidy data set
# expected final result dimension is 10299 rows of 68 columns
tidy_data<-rbind(
  data_test,
  data_train
  )

# cleanup unnecessary intermediate data to free up some memory 
rm(data_test,data_train)


# Original feature names is better choice for column names rather than default "data.frame" names
# because "data.frame" column names were transformed into "safe form" and names like "tBodyAcc-mean()-X" 
# now looks like "tBodyAcc.mean...X"     
effColNames=c("SubjectId","ActivityName",features_list$featureName[columnsClasses=="numeric"])

#write resulting tidy data set
write.table(tidy_data,"tidy-UCI-HAR-data.csv",row.names=F,col.names=effColNames,sep=",")

#As a second task in course project we need to create a second, 
# independent tidy data set with the average of each variable for 
# each activity and each subject from resulting tidy data set

#first two columns are subjectId and activityName
#statement bellow actually calculates necessary averages for all data variables
#groped by subjectId and activityName
tidy_data_means<-aggregate(tidy_data[,3:68], by = tidy_data[,1:2], FUN=mean)

#just for aesthetic purposes sort by subjectId and activityName and remove original rownums 
tidy_data_means<-tidy_data_means[order(tidy_data_means$SubjectId,tidy_data_means$ActivityName),]
rownames(tidy_data_means) <- NULL

#write resulting tidy aggregates data
write.table(tidy_data_means,"tidy-UCI-HAR-data-means.csv",row.names=F,col.names=effColNames,sep=",")

