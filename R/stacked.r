#!/usr/bin/R -s -f

library("rjson")
library(jsonlite)
library(ggplot2)
library(dplyr)

# json to dataframe
myData <- fromJSON("myJSON.json")

minYear = 1990
maxYear = max(myData$year)
print(maxYear)
years = seq(minYear, maxYear, 1)
genres <- unlist(myData$genres)
genres <- unique(genres)
print(genres)
# initializing a matrix of 0s 
mat = matrix(0, length(years), length(genres))
count = 0
ig = 1
iy = 1

for(i in 1:length(myData$year)){
  iy <- which(years==myData$year[i])
  print(myData$year[i])
  if(myData$year[i] >= minYear){
    for(genre in myData$genres[i]){
      for(g in genre){
        ig <- which(genres==g)
        mat[iy, ig]  <-  mat[iy, ig] + 1
      }  
    }
  }
}
a=c(mat)
# create data
time <- as.numeric(years)  # x Axis
value <- a             # y Axis
group <- genres       # group, one shape per group
data <- data.frame(time, value, group)
# create and save plot
ggplot(data, aes(x=time, y=value, fill=group)) + geom_area(alpha=0.6 , size=0.1, colour="black")
ggsave("stacked.png", width = 2560, height = 1440, units = "px")
# normalize plot
for (i in 1:nrow(mat)){
  print(mat[i, ])
  mat[i, ] <- mat[i, ] / sum(mat[i, ])
}
a=c(mat)
# create data
time <- as.numeric(years)  # x Axis
value <- a             # y Axis
group <- genres       # group, one shape per group
data <- data.frame(time, value, group)
# create and save plot
ggplot(data, aes(x=time, y=value, fill=group)) + geom_area(alpha=0.6 , size=0.1, colour="black")
ggsave("normalizedStacked.png", width = 2560, height = 1440, units = "px")