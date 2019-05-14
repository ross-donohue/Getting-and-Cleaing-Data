library(tidyverse)
library(data.table)
library(stringr)

#download and unzip files to your directory
#Change filepaths below to match where you've saved the files and to where you would like to save the output
file.names <- "UCI Har Dataset/features.txt"
file.train <- "UCI Har Dataset/train/X_train.txt"
file.test <- "UCI Har Dataset/test/X_test.txt"
file.train.activity <- "UCI Har Dataset/train/Y_train.txt"
file.test.activity <- "UCI Har Dataset/test/Y_test.txt"
file.activity.labels <- "UCI Har Dataset/activity_labels.txt"
file.train.subjects <- "UCI Har Dataset/train/subject_train.txt"
file.test.subjects <- "UCI Har Dataset/test/subject_test.txt"

file.output.raw <- "Tidy Merged Data.csv"
file.output.averaged <- "Tidy Data (transformed to averages).csv"

#Read in names of variables
names <- read.table(file.names, header = FALSE, sep = "", stringsAsFactors = FALSE)[,2]

#Read in train dataset and apply colnames
train <- fread(file = file.train, header = FALSE, stringsAsFactors = FALSE)
colnames(train) <- names

#Read in activity codes for training set
train$Activity.Code <- fread(file = file.train.activity, header = FALSE, stringsAsFactors = FALSE)[,1]

#Read in Subjects for training set
train$Subject <- fread(file=file.train.subjects, header = FALSE, stringsAsFactors = FALSE)[,1]

#Read in test dataset and apply colnames
test <- fread(file = file.test, header = FALSE, stringsAsFactors = FALSE)
colnames(test) <- names

#Read in activity codes for test set
test$Activity.Code <- fread(file.test.activity, header = FALSE, stringsAsFactors = FALSE)[,1]

#Read in Subjects for test set
test$Subject <- fread(file=file.test.subjects, header = FALSE, stringsAsFactors = FALSE)[,1]

#Bind test and train datasets together
Merged <- rbindlist(l = list(train, test))

#Identify applicable variables (mean | std)
mean.variables <- grepl("mean", colnames(Merged))
std.variables <- grepl("std", colnames(Merged))
other.variables <- colnames(Merged) == "Activity.Code" | colnames(Merged) == "Subject"
selected.variables <- mean.variables|std.variables|other.variables

#Select only applicable variables from Merged

Merged <- Merged[,selected.variables, with = FALSE]

#Replace Activity.Code with activity.labels
activity.labels <- read.table(file.activity.labels, header = FALSE, sep = "", stringsAsFactors = FALSE)
Merged <- Merged %>%
  left_join(activity.labels, by = c("Activity.Code" = "V1")) %>%
  select(-Activity.Code)
colnames(Merged)[length(colnames(Merged))] <- "Activity"

#Factorize ID variables
Merged$Subject <- as.factor(Merged$Subject)
Merged$Activity <- as.factor(Merged$Activity)

#Save the final dataset
write.csv(Merged, file.output.raw)
#Create tidy set
#First split along identifying variables
t1 <- split(Merged, list(Merged$Subject, Merged$Activity))
#Transform variables into mean averages of their values
for(i in seq_along(t1)){
t2<- colMeans(t1[[i]][,1:(length(colnames(t1[[i]]))-2)]) %>%
  t() %>%
  as.data.frame()
t2$Activity <- t1[[i]]$Activity[1]
t2$Subject <- t1[[1]]$Subject[1]
t1[[i]] <- t2
}

#Collapse list of newly reduced dataframes into one dataframe
t3 <- bind_rows(t1)

#Melt dataframe into a narrow tidy version
tidy.set <- melt(t3, id.vars = c("Subject", "Activity"))

#Write the data set to a CSV
write.csv(tidy.set, file.output.averaged)