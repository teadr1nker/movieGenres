#!/usr/bin/python3

import numpy as np
import re, string, pickle
from sklearn.datasets import load_files
from datetime import datetime

# Remove html from html and turn lowercase
def custom_standardization(input_data):
    lowercase = input_data.lower()
    stripped_html = re.sub("<br />", " ", str(lowercase))
    return re.sub(
         f"[{re.escape(string.punctuation)}]", "", stripped_html
    )

# Load text classifier
name = 'text_classifier'
print(datetime.now(), f'Loading model {name}')
with open(name, 'rb') as training_model:
    model = pickle.load(training_model)  

# Load text vectorizer    
name = 'text_vectorizer'
print(datetime.now(), f'Loading model {name}')
with open(name, 'rb') as vect:
    vectorizer = pickle.load(vect)      

while True:
    x = input(str(datetime.now()) + ' Write you review below!\n> ')
    # Vectorize input
    x = vectorizer.transform([custom_standardization(x)]).toarray()    
    # Classify review
    y = model.predict(x)
    
    if y == [1]:
        print('Review is positive!')
    else:    
        print('Review is negative!')