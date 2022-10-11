#!/usr/bin/python3

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

print('Loading data')
movies = pd.read_json('../data/sorted.json').sort_values('year')

print('Loaded data')
#find min
for year in movies['year']:
  if year > 0:
    min = year
    break

years = np.arange(min, movies['year'].max())
print(years)
