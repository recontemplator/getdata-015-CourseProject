#Code book for Coursera getdata-015 course project
##Code book content
This code book describes the variables, the data, and all transformations and work that is necessary to clean up the initial data in order to complete tasks described in course project statement.

##Actual tasks of the course project
Create one R script called `run_analysis.R` that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##Initial data
[Link to the zip file with raw data for the project](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

##instructions
###Short version
In your shell 
```sh
cd path/to/my/dir
git clone https://github.com/recontemplator/getdata-015-CourseProject.git
```
In your R prompt
```r
setwd("path/to/my/dir")
source("getrawdata.R")
source("run_analysis.R")
```
Your results are in
```r
tidy-UCI-HAR-data.csv
tidy-UCI-HAR-data-means.csv
```

###Explained version
####Obtaining initial raw data

It is assumed that your working directory  points to the folder where this repository were cloned to (directory which contains this `CodeBook.md` file).
You can set up your working dir by `setwd("path/to/my/dir")` command.

Link given above points to "UCI HAR Dataset.zip" 60M zip file. It could be downloaded by any means (e.g. with browser) by link above, or you can use the following R command to do so :

```r
download.file(
  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
  destfile = "UCI HAR Dataset.zip")
```

This command is already included into `getrawdata.r` for your convenience.

Then you will need to unzip the content of the file into your R working directory. Zip file previously downloaded to your working directory by command above could be unzipped by following R command:

```r
unzip("UCI HAR Dataset.zip")
```

This command is already included into `getrawdata.r` for your convenience.

####Description of raw data
Now your working dir contains folder `UCI HAR Dataset` which includes all the initial data what we need to
process in order to get tidy data set as described in course project tasks statement.

These data are result of experiments. The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING UPSTAIRS, WALKING DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly **partitioned into two sets**, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

These portions are stored in two folders. Namely `test` and `train` in the uniform manner.
For each record (in each portion) it is provided:

For each record it is provided:

- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 

These records are actually stored in following files:

- 'README.txt'
- 'features_info.txt': Shows information about the variables used on the feature vector.
- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.
- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
- 'test/subject_test.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
- 'test/Inertial Signals' and 'train/Inertial Signals' folders contains extra triaxial acceleration and angular velocity data. These data were not required to be included in result tidy data set and could be ignored.

####Steps need to be made to obtain tidy data (primary task)

It is requested that tidy data should include only selected subset of measurements from long 561-feature vector.
 By course project statement we should, literally:
 
> Extracts only the measurements on the mean and standard deviation for each measurement.

Unfortunately this statement is a little bit ambiguous because there are three different kinds of measurement related to "means" in a given data (for actual measurements names see `features.txt` file). 
 1. "Straightforward" means for variables (e.g. tBodyAcc-mean()-X, fBodyBodyGyroMag-mean() )
 2. Additional vectors which averaging the signals in a signal window sample (e.g. gravityMean, tBodyAccMean)
 3. "Angle" measurements (e.g. angle(tBodyAccMean,gravity), angle(tBodyAccJerkMean),gravityMean))

Current implementation assumes that we need only "first type of means". But code could be easily adopted to other interpretations (see comments in `run_analysis.R`)

Another challenge that should be addressed: data which should be included into resulting data set are split across different files in initial data. Namely resulting data set should contain data stored in `subject_*.txt`, `y_*.txt`, and subset of columns stored in `x_*.txt`

And last but not the least, resulting tidy data set should contain descriptive column names and descriptive activity names for each experiment.

Detailed description of how all these challenged were addressed you can found in the explained comments in the `run_analysis.R` script.
As a result of all necessary manipulations `run_analysis.R` script creates in working dir `tidy-UCI-HAR-data.csv` which contains self-describing `SubjectId` column, `ActivityName` column, 33 columns with -mean, and 33 columns with -std values, named exactly as specified in `features.txt` file (some examples: `tBodyAcc-mean()-X`,`tBodyAcc-std()-Y`,`tGravityAcc-mean()-Z`, and so on).
Resulting `tidy-UCI-HAR-data.csv` is included in this repository.
`tidy-UCI-HAR-data.csv` contains 10299 rows (2947 from test dataset plus 7352 from train dataset) and 68 columns (1 subectId, 1 ActivityName,33 -mean columns, 33 -std columns)

####Steps need to be made to obtain tidy data (secondary task)

It is also requested:

> From the data set in previous step, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

So we need to summarize data(by calculating the mean) for each combination of Subect and Activity type. It could be easily done by following R command (tidy_data is data set obtained in previous step):
```r
tidy_data_means<-aggregate(tidy_data[,3:68], by = tidy_data[,1:2], FUN=mean)
```
All the code necessary is already included into `run_analysis.R` script. And as a result `tidy-UCI-HAR-data-means.csv' is created which contains all aggregates (means) for all measurements for all combinations of Subject and Activity.

Note: There are only 40 rows in `tidy-UCI-HAR-data-means.csv` because for one subject initial data mostly contains data related to only one activity type. Some subject have data about 2 different activity types, but there are no subjects with data related to 3 or more activity types. `tidy-UCI-HAR-data-means.csv' contains the same 68 columns (1 subectId, 1 ActivityName,33 -mean columns, 33 -std columns)




