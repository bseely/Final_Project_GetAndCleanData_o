---
title: "README.md"
author: "Bill Seely"
date: "May 23, 2017"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
# Final_Plan_GetAndCleanData_o
### This is code to calculate summary statistics from data from the Human Activity Recognition database

## Overview
#### The script named **run_analysis.R** imports data about accelerometer readings, gyroscope readings,
#### and activity collected in experimental trials. It then formats the data in a tidy format that
#### minimizes data complexity, and stores it in an intermediate table called allData_thin. Then it calculates
#### and outputs the average for each of the measures collected during the experimental trials into a table called
#### **allAverages**. This is then exported to a file called allAverages.txt

## Setup
#### 1. Clone the this repo, which contains both the raw data files and the code
#### 2. Make sure you have installed these R packages from CRAN: tidyr, dplyr, data.table

## Running the Process

#### Run the R script in the file named run_analysis.R

