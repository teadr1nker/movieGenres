#!/usr/bin/R -s -f
library(readxl)
library("rjson")
library("stringr")
movies <- read.csv('../python/data/movies.csv')
id = 0
movies <- na.omit(movies)
# get year out of title
movies$year = movies$title
for(i in 1:length(movies$title)){
  god = str_match(movies$title[i], '\\((\\d{4})\\)')
  movies$year[i] = as.integer(god[1, 2])
}
# sort by year
movies <- movies[order(movies$year),]
movies <- subset(movies, gsub(".*?\\((\\d{4})\\S", "\\1", movies$title) != movies$title)
# remove films with no genres
movies$genres <- gsub("\\(no genres listed)", '0', movies$genres)
movies <- subset(movies, gsub("\\(no genres listed)", '0', movies$genres) != "0")

movies$genres <- strsplit(movies$genres, split = '|', fixed=T)
# remove films with year==NA
movies <- na.omit(movies)
# save json
myfile <- toJSON(movies)
write(myfile, "myJSON.json")
