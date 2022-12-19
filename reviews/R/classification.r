#!/usr/bin/R -s -f

# to create a model run model.r before this script

library(tensorflow)
library(keras)
library(tfdatasets)

# creating a regex with all punctuation characters for replacing.
re <- reticulate::import("re")

punctuation <- c("!", "\\", "\"", "#", "$", "%", "&", "'", "(", ")", "*",
"+", ",", "-", ".", "/", ":", ";", "<", "=", ">", "?", "@", "[",
"\\", "\\", "]", "^", "_", "`", "{", "|", "}", "~")

punctuation_group <- punctuation %>%
  sapply(re$escape) %>%
  paste0(collapse = "") %>%
  sprintf("[%s]", .)

custom_standardization <- function(input_data) {
  lowercase <- tf$strings$lower(input_data)
  stripped_html <- tf$strings$regex_replace(lowercase, '<br />', ' ')
  tf$strings$regex_replace(
    stripped_html,
    punctuation_group,
    ""
  )
}

# loading model
model <- load_model_tf('model')


while (1) {
    cat("Write your review below!\n> ")
    x <- readLines(con = "stdin", n = 1)
    # standerdize review
    x <- custom_standardization(x)
    # predict
    y <- predict(model, as.array(x))
    if (y[1] <= 0.5){
        cat('Review is negative!\n')
    } else {
        cat('Review is positive!\n')
    }
}