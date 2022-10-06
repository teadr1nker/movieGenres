#!/usr/bin/python3
import pandas as pd
import numpy as np
import re

data = pd.read_csv("../data/movies.csv")

#print(data)

movies = pd.DataFrame(columns=['id', 'title', 'year', 'genres'])
id = 0
for index, row in data.iterrows():
  name = row['title']
  try:
    year = re.search(r'\((\d*)\)', name).group(1)
    year = int(year)
    name = name.replace(f'({year})', '')
  except:
    year = 0
  if row['genres'] != '(no genres listed)':
    movies.loc[id] = [row['movieId'], name, year, row['genres']]
    id+=1
  print(f'{index}/{len(data)}', end='\r')
  
  #if id > 1000:
  #  break
movies.to_csv('../data/sorted.csv')
  
  

