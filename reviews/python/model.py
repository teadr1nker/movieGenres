#!/usr/bin/python3

import numpy as np
import re, string, pickle
import nltk
nltk.download('stopwords')
from nltk.corpus import stopwords
from sklearn.datasets import load_files
from datetime import datetime

# Remove html from html and turn lowercase
def custom_standardization(input_data):         
    lowercase = input_data.lower()
    stripped_html = re.sub("<br />", " ", str(lowercase))
    return re.sub(
         f"[{re.escape(string.punctuation)}]", "", stripped_html
    )
    
# Load IMDB dataset    
print(datetime.now(), 'Loading files')
reviews = load_files("../../data/learning/aclImdb/train")
X, y = reviews.data, reviews.target

# Standardize all reviews
print(datetime.now(), 'Standartizaton')
for i in range(len(X)):
    X[i] = custom_standardization(X[i])

# Vectorize reviews
print(datetime.now(), 'Vectorization')
from sklearn.feature_extraction.text import CountVectorizer
vectorizer = CountVectorizer(max_features=1500,
 stop_words=stopwords.words('english'))
X = vectorizer.fit_transform(X).toarray()

# Save vectorizer for classifying new reviews
name = 'text_vectorizer'
print(datetime.now(), f'Saving vectorizer as {name}')
with open(name, 'wb') as picklefile:
    pickle.dump(vectorizer, picklefile)

# Split dataset 1/5 test/train
print(datetime.now(), 'Splitting set')
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y,
 test_size=0.2, random_state=0)

# Train random forest classifier
from sklearn.ensemble import RandomForestClassifier
print(datetime.now(), 'Fitting model')
classifier = RandomForestClassifier(n_estimators=1000, random_state=0)
classifier.fit(X_train, y_train)

# Run test set
print(datetime.now(), 'testing')
y_pred = classifier.predict(X_test)

# Evaluate model
print(datetime.now(), 'Evaluating')
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
print(confusion_matrix(y_test,y_pred))
print(classification_report(y_test,y_pred))
print(accuracy_score(y_test, y_pred))

# Save classifier for classifying new reviews
name = 'text_classifier'
print(datetime.now(), f'Saving model as {name}')
with open(name, 'wb') as picklefile:
    pickle.dump(classifier,picklefile)