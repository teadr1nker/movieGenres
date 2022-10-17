#!/usr/bin/python3

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
#import os

minYear=1900

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

count=0
for index, row in movies.iterrows():
  if row['year'] > minYear:
    for genre in row['genres']:
      data[years.index(row['year']), genres.index(genre)] += 1
    count+=1
    print(f'{count}/{len(movies)}', end='\r')      
      
np.save('../data/stacked.npy', data)
dpi = 128
plt.figure(figsize=(2560/dpi, 1440/dpi), dpi=dpi)
print('Generating stacked plot')
plt.stackplot(years, data.T)
plt.legend(genres, loc=2)
#plt.show()
plt.savefig('stackedPlot.png')

print('Normalizing data')
for i in range(len(data)):
  data[i] /= datap[i].sum()
  print(f'{i}/{len(data)}')
