# Getting-and-Cleaing-Data

# run_analysis.R

To begin, download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip to the directory of your choice.

Lines 7- 17 of the included code are there to configure where to find the data and where to save the output to. Change it to your preference.

When running the code it first reads in the variable names to a vector (using read.table as the file is small) to name the future columns, and then the train and test data sets using fread (size of the data lends to remarkably improved performance using fread over read.table).

The data set columns are then replaced with the vector imported from features.txt. Activity codes are imported and attached to the train and test datasets before they are merged.

The datasets are then combined using rbindlist (again the size of the data leads to considerably improved performance using the data.table suite of functions)

The dataframe is reduced to applicable variables by running the columns names through grepl to establish a selection cipher. This is done thrice: Once for mean variables, once for standard deviation variables, and once for identifying variables. Afterward the activity codes are replaced with its accompanying labels. Identifying variables are factorized for the upcoming analysis and the data set is written to a CSV.

The dataset is split along its identifying variables and averages calculated for its measurements. The averages are then recompiled into a single dataframe before it is melted into a narrow form tidy dataset.

# Tidy Merged Data.csv

This data set is the combination of the training and test datasets from the Human Activity Recognition database

# Tidy Data (transformed to averages).csv

This data set is a second transformation performed to the raw data, reducing the data to averages calculated according to subject and activity

# Codebook.md

This document explains the variables included in the different files. The transformed data uses the same variables as the Merged Data with the exception that they are mean averages as well as stored vertically instead of horizontally
