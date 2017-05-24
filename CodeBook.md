---
title: "CodeBook.md"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
## Overview

### This analysis takes data from the Human Activity Recognition database built from
### the recorded activities of 30 subjects performing activities of daily living (ADL)
### while carrying a waist-mounted smartphone with embedded inertial sensors.


## Libraries

### This analysis uses functions from the following libraries: tidyr, dplyr, and data.table

```{r}
## load tidyr, dplyr, and data.table
library(tidyr)
library(dplyr)
library(data.table)
```

## Input Files (located in the ./data/ directory)
```
##    Table                           Description of table contents
## activity_labels.txt     lookup table containing an integer code (from 1 to 6) and an activity_label
## feature_names.txt       Lookup for all the feature names (correspond to columns in X_test and X_train)
## X_test.txt              Feature data for each test observation (row)
## y_test.txt              Activity labels for each test observation (row)
## subject_test.txt        Identifiers for the subject corresponding to each test observation (row)
## X_train.txt             Feature data for each training observation (row)
## y_train.txt             Activity labels for each training observation (row)
## subject_train.txt       Activity labels for each test observation (row)
```

## Reading the original data into R from the ./data/ directory
```
## Read in activity labels
activity_labels <- read.table("./data/activity_labels.txt")
## Code to inspect activity labels
activity_labels

## Read in feature names
feature_names <- read.table("./data/features.txt")
## Code to inspect feature names
head(feature_names)
str(feature_names)

## Read in test data in three parts: x_test (feature values), y_test (activity labels) & subject_test (id of person tested)
X_test <- read.table("./data/test/X_test.txt")
y_test <- read.table("./data/test/y_test.txt")
subject_test <- read.table("./data/test/subject_test.txt")
## Code to inspect the test data
str(X_train)
head(X_train)
str(y_train)
head(y_train)
str(subject_train)
head(subject_train)


## Read in training data in three parts: x_train (feature values), y_train (activity labels) & subject_test (id of person tested)
X_train <- read.table("./data/train/X_train.txt")
y_train <- read.table("./data/train/y_train.txt")
subject_train <- read.table("./data/train/subject_train.txt")
## Code to inspect the training data
str(X_test)
head(X_test)
str(y_test)
head(y_test)
str(subject_test)
head(subject_test)

```
## Build a master table, allData, from all the elements imported from the /data directory above
```
X_all<-rbind(X_train,X_test)                    ## Combine X_train and X_test using rbind
rm(X_train, X_test)                             ## Clean up X_train and X_test
y_all<-rbind(y_train,y_test)                    ## Combine y_train and y_test using rbind
rm(y_train, y_test)                             ## Clean up y_train and y_test
subject_all<-rbind(subject_train,subject_test)  ## Combine subject_train and subject_test using rbind
rm(subject_train, subject_test)                 ## Clean up subject_train and subject_test

names(X_all)<-feature_names$V2                  ## Apply the feature names to the feature columns
names(subject_all)<-"subject"                   ## Name the subject column 
names(y_all)<-"activity_idx"                    ## Name the activity index column

## Name the columns in the activity_labels lookup table
names(activity_labels) <- c("activity_idx", "activity")

## Drop columns not containing mean, std deviation
X_all<-subset(X_all, select = grep("mean\\(|std", names(X_all))) 

## Combine columns for x, y and subject labels
allData<-cbind.data.frame(subject_all, y_all, X_all)

## Remove intermediate tables
rm(subject_all, y_all, X_all)
## Add activity labels
allData<-merge(allData, activity_labels, by = "activity_idx")
## Add rownames as column to retain order
allData<-tibble::rownames_to_column(allData, "orig_order")       

## Code to inspect allData table
str(allData)
head(allData)

```
## Reshape AllData into a thin table, allData_thin with one measure and value (mean or std) per row
```
## convert all the measurements (keys), which are columns, into rows
allData<-gather(allData, key, value, -orig_order, -subject, -activity_idx, -activity)

## make a copy of the key column (original will be parsed into parts)
allData<-cbind(allData,measure=rep(allData$key))

## parse the key column into parts: base, statistic, and measurement axis. We'll keep statistic and drop the others
allData<-separate(allData, key, c("base", "statistic", "measurement_axis"), "-", fill="right")

## drop the unused parts of the parsed key column, and the activity_idx which has fulfilled its purpose
allData<-allData[ , !(names(allData) %in% c("activity_idx","base","measurement_axis"))]
```

## Preparing allData_thin interim table for export
```
## Eliminate "mean()"" and "std()"" from the measure names
allData$measure<-sub("-mean\\(\\)","", allData$measure)
allData$measure<-sub("-std\\(\\)","", allData$measure)

## Get everything in order
(allData%>%select(subject, activity, measure, statistic, orig_order, value)%>%
        arrange(subject, activity, measure, statistic, orig_order)) -> allData_thin
```
# write tab-delimited file, allData_thin.txt,  to project directory
```
write.table (allData_thin, "./allData_thin.txt", sep="\t", row.names=FALSE)
```
## Prepare final output file, allAverages
```
## Create table AllAverages with means by activity x subject X measure

(allData_thin %>% spread(statistic, value, fill=NA)%>%          ## put statistic (mean, std) into columns
        group_by(subject, activity, measure) %>%                ## group by subject, activity, and measure
        select(-orig_order)%>%                                  ## drop orig_order
        summarise_each(funs(mean))) -> allAverages              ## calculate means for measures, store
        
## Clean up column names in allAverages
names(allAverages) <- c("subject","activity_label","measure", "mean", "std_deviation")
```

# write tab-delimited file, allAverages.txt,  to project directory
```
## Make tab-delimited file of allAverages
write.table (allAverages, "./allAverages.txt", sep="\t", row.names=FALSE)
```

## Fields in the output file, allAverages.txt
```
## File Name: AllAverages.txt  	. contains the averages for each subject-activity-measure combination
##
##subject
##		1 . . 30  .integer identifying the person for whom data was collected
##
##activity
##	factor with six levels - activity label for each observation
##		1  .LAYING
##		2  .SITTING
##		3  .STANDING
##		4  .WALKING
##		5  .WALKING DOWNSTAIRS
##		6  .WALKING UPSTAIRS
##
##measure
##	.character string,  name of the quantity measured 
##              fBodyAcc-X    .frequency domain accelerometer reading on the x-axis
##              fBodyAcc-Y    . frequency domain accelerometer reading on the y-axis
##              fBodyAcc-Z    . frequency domain accelerometer reading on the z-axis
##              fBodyAccJerk-X        . frequency domain jerk of the accelerometer on the x-axis
##              fBodyAccJerk-Y        . frequency domain jerk of the accelerometer on the y-axis
##              fBodyAccJerk-Z        . frequency domain jerk of the accelerometer on the z-axis
##              fBodyAccMag    frequency domain accelerometer reading magnitude
##              fBodyBodyAccJerkMag    frequency domain accelerometer jerk magnitude
##              fBodyBodyGyroJerkMag    frequency domain gyroscope jerk magnitude
##              fBodyBodyGyroMag    frequency domain gyroscope reading magnitude
##              fBodyGyro-X    frequency domain gyroscope reading on the x-axis
##              fBodyGyro-Y    frequency domain gyroscope reading on the y-axis
##              fBodyGyro-Z    frequency domain gyroscope reading on the z-axis
##              tBodyAcc-X     .time domain accelerometer reading on the x-axis
##              tBodyAcc-Y     .time domain accelerometer reading on the y-axis
##              tBodyAcc-Z     .time domain accelerometer reading on the z-axis
##              tBodyAccJerk-X     .time domain accelerometer jerk on the x-axis
##              tBodyAccJerk-Y     .time domain accelerometer jerk on the y-axis
##              tBodyAccJerk-Z     .time domain accelerometer jerk on the z-axis
##              tBodyAccJerkMag    . time domain accelerometer jerk magnitude
##              tBodyAccMag     .time domain accelerometer magnitude
##              tBodyGyro-X    .time domain gyroscope reading on the x-axis
##              tBodyGyro-Y    .time domain gyroscope reading on the x-axis
##              tBodyGyro-Z    .time domain gyroscope reading on the x-axis
##              tBodyGyroJerk-X    .time domain gyroscope jerk on the x-axis
##              tBodyGyroJerk-Y    .time domain gyroscope jerk on the x-axis
##              tBodyGyroJerk-Z    .time domain gyroscope jerk on the x-axis
##              tBodyGyroJerkMag    .time domain gyroscope jerk magnitude
##              tBodyGyroMag    .time domain gyroscope magnitude
##              tGravityAcc-X    .time domain gravity acceleration on the x-axis
##              tGravityAcc-Y    .time domain gravity acceleration on the x-axis
##              tGravityAcc-Z    .time domain gravity acceleration on the x-axis
##
##average    	.range= -1.0000000000000 to 1.0000000000000
##	average of means over observations for subject-activity-measure combination
##
##standard deviation  	.range= -1.0000000000000 to 1.0000000000000
##      average of standard deviations over observations for a subject-activity-measure combination
```