## Set working directory
getwd()
setwd("C:/Users/bseely/OneDrive/R Projects/CourseraDataCleaningFinalProject")

## load tidyr, dplyr, and data.table
library(tidyr)
library(dplyr)
library(data.table)

## Read in activity labels
activity_labels <- read.table("./data/activity_labels.txt")

## Read in feature names
feature_names <- read.table("./data/features.txt")

## Read in test data
X_test <- read.table("./data/test/X_test.txt")
y_test <- read.table("./data/test/y_test.txt")
subject_test <- read.table("./data/test/subject_test.txt")

## Read in train data
X_train <- read.table("./data/train/X_train.txt")
y_train <- read.table("./data/train/y_train.txt")
subject_train <- read.table("./data/train/subject_train.txt")

## Build master table allData from elements imported from ./data directory

X_all<-rbind(X_train,X_test)                    ## Combine X_train and X_test using rbind
rm(X_train, X_test)                             ## Clean up X_train and X_test
y_all<-rbind(y_train,y_test)                    ## Combine y_train and y_test using rbind
rm(y_train, y_test)                             ## Clean up y_train and y_test
subject_all<-rbind(subject_train,subject_test)  ## Combine subject_train and subject_test using rbind
rm(subject_train, subject_test)                 ## Clean up subject_train and subject_test

names(X_all)<-feature_names$V2                  ## Apply the feature names to the feature columns
names(subject_all)<-"subject"                   ## Name the subject column 
names(y_all)<-"activity_idx"                    ## Name the activity index column
names(activity_labels) <- c("activity_idx", "activity")  ## Name the columns in the activity_labels lookup table


X_all<-subset(X_all, select = grep("mean\\(|std", names(X_all))) ## Drop columns not containing mean, std deviation
allData<-cbind.data.frame(subject_all, y_all, X_all)             ## Combine columns for x, y and subject labels
rm(subject_all, y_all, X_all)                                    ## Remove intermediate tables
allData<-merge(allData, activity_labels, by = "activity_idx")    ## Add activity labels
allData<-tibble::rownames_to_column(allData, "orig_order")       ## Add rownames as column to capture original order

## reshape data into rows for for each combination of activity x subject x measure
allData<-gather(allData, key, value, -orig_order, -subject, -activity_idx, -activity)
allData<-cbind(allData,measure=rep(allData$key))
allData<-separate(allData, key, c("base", "statistic", "measurement_axis"), "-", fill="right")
allData<-allData[ , !(names(allData) %in% c("activity_idx","base","measurement_axis"))]

## Eliminate mean() and std() from the measure
allData$measure<-sub("-mean\\(\\)","", allData$measure)
allData$measure<-sub("-std\\(\\)","", allData$measure)

## Get everything in order
(allData%>%select(subject, activity, measure, statistic, orig_order, value)%>%
        arrange(subject, activity, measure, statistic, orig_order)) -> allData_thin

## Make tab-delimited file of allDatat_thin
write.table (allData_thin, "./allData_thin.txt", sep="\t", row.names=FALSE)

## Create table AllAverages with means by activity x subject X measure
(allData_thin %>% spread(statistic, value, fill=NA)%>%
        group_by(subject, activity, measure) %>%
        select(-orig_order)%>%
        summarise_each(funs(mean))) -> allAverages

## Clean up column names in allAverages
names(allAverages) <- c("subject","activity_label","measure", "mean", "std_deviation")

## Make tab-delimited file of allAverages
write.table (allAverages, "./allAverages.txt", sep="\t", row.names=FALSE)

str(allAverages)
names(allAverages)
head(allAverages)
tail(allAverages)


