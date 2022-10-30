#!/usr/bin/python3
import pandas as pd
import numpy as np
import re

data = pd.read_csv("data/movies.csv")

#print(data)

movies = pd.DataFrame(columns=['id', 'title', 'year', 'genres'])
id = 0
for index, row in data.iterrows():
  name = row['title']
  try:
    year = re.search(r'\((\d{4})\)', name).group(1)
    year = int(year)
    name = name.replace(f'({year})', '')
  except:
    year = 0
  if row['genres'] != '(no genres listed)':
    movies.loc[id] = [row['movieId'], name, year, row['genres'].split('|')]
    id+=1
  print(f'{index}/{len(data)}', end='\r')

  # limit
  #if id > 10240:
    #break
movies.to_json('data/sorted.json')
  
  

