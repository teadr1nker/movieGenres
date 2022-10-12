#!/usr/bin/python3

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os

minYear=1960

print('Loading data')
movies = pd.read_json('../data/sorted.json').sort_values('year')
    
print('Loaded data')
#find min
for year in movies['year']:
  if year > minYear:
    min = year
    break
    
years = list(np.arange(min, movies['year'].max()+1))
#print(years)
print('Getting unique genres')
genres = []
for row in movies['genres']:
  for genre in row:
    if genre not in genres:
      genres.append(genre)
          
#print(genres)
print('Counting genres')
data = np.zeros((len(years), len(genres)))
    
for index, row in movies.iterrows():
  if row['year'] > minYear:
    for genre in row['genres']:
      data[years.index(row['year']), genres.index(genre)] += 1
      print(f'{index+1}/{len(movies)}', end='\r')      
      
np.save('../data/stacked.npy', data)

plt.stackplot(years, data.T)
plt.legend(genres)
plt.show()
