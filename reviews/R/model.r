#!/usr/bin/R -s -f

library(tensorflow)
library(keras)
library(tfdatasets)

batch_size <- 32
seed <- 42

# loading data
raw_train_ds <- text_dataset_from_directory(
  '../../data/learning/aclImdb/train/',
  batch_size = batch_size,
  validation_split = 0.2,
  subset = 'training',
  seed = seed
)

raw_val_ds <- text_dataset_from_directory(
  '../../data/learning/aclImdb/train',
  batch_size = batch_size,
  validation_split = 0.2,
  subset = 'validation',
  seed = seed
)

raw_test_ds <- text_dataset_from_directory(
  '../../data/learning/aclImdb/test',
  batch_size = batch_size
)

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

max_features <- 1500
sequence_length <- 250

vectorize_layer <- layer_text_vectorization(
  max_tokens = max_features,
  output_mode = "int",
  output_sequence_length = sequence_length
)

# Make a text-only dataset (without labels), then call adapt
train_text <- raw_train_ds %>%
  dataset_map(function(text, label) text)
vectorize_layer %>% adapt(train_text)

# vectroization function
vectorize_text <- function(text, label) {
  text <- custom_standardization(text)
  text <- tf$expand_dims(text, -1L)
  list(vectorize_layer(text), label)
}
# creating dataset maps
train_ds <- raw_train_ds %>% dataset_map(vectorize_text)
val_ds <- raw_val_ds %>% dataset_map(vectorize_text)
test_ds <- raw_test_ds %>% dataset_map(vectorize_text)

AUTOTUNE <- tf$data$AUTOTUNE

# dataset_cache() keeps data in memory after it’s loaded off disk
# dataset_prefetch() overlaps data preprocessing and model execution while training

train_ds <- train_ds %>%
  dataset_cache() %>%
  dataset_prefetch(buffer_size = AUTOTUNE)
val_ds <- val_ds %>%
  dataset_cache() %>%
  dataset_prefetch(buffer_size = AUTOTUNE)
test_ds <- test_ds %>%
  dataset_cache() %>%
  dataset_prefetch(buffer_size = AUTOTUNE)

embedding_dim <- 16

# creating model

model <- keras_model_sequential() %>%
  layer_embedding(max_features + 1, embedding_dim) %>%
  layer_dropout(0.2) %>%
  layer_global_average_pooling_1d() %>%
  layer_dropout(0.2) %>%
  layer_dense(1)

# pringing model summary
summary(model)

# applying loss function and optimzier
model %>% compile(
  loss = loss_binary_crossentropy(from_logits = TRUE),
  optimizer = 'adam',
  metrics = metric_binary_accuracy(threshold = 0)
)

# training model
epochs <- 5
history <- model %>%
  fit(
    train_ds,
    validation_data = val_ds,
    epochs = epochs
  )

model %>% evaluate(test_ds)

plot(history)

# exporting model for future use
export_model <- keras_model_sequential() %>%
  vectorize_layer() %>%
  model() %>%
  layer_activation(activation = "sigmoid")

export_model %>% compile(
  loss = loss_binary_crossentropy(from_logits = FALSE),
  optimizer = "adam",
  metrics = 'accuracy'
)

# saving export_model
save_model_tf(export_model, "model")
