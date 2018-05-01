import os
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


Y='AANDEEL_FORMATIE_OP_LB'

# X='LEERLING_LERAAR_RATIO'
# X='AANTAL_LEERLINGEN'
# X='OMVANG_FORMATIE_TOTAAL'
# X='OMVANG_FORMATIE_MANAGER'
# X='GEMIDDELD_LEERLINGGEWICHT'
# X='Netto werkkapitaal'
# X='Solvabiliteit I'
X='Liquiditeit (quick ratio)'
# X='Liquiditeit (current ratio)'

# Dit gebruikt de dataset die ik (Dion) heb gemaakt, staat in de map 'Python/data'
df = pd.read_csv('functiemix_jaarrekeningen.csv', header=0, encoding="ISO-8859-1", delimiter=';')
# df = pd.read_csv('data/functiemix/functiemix-instellingen.csv', header=0, encoding="ISO-8859-1")

# df = df.applymap(str)

# FILTERS
df = df.loc[df['SCHOOLTYPE'] == 'bao']  # Basisonderwijs
df = df.loc[df['JAAR'] == 2016]  # 2016

# print(df.head(1)['AANDEEL_FORMATIE_OP_LB'])
# print(df.head(1)['LEERLING_LERAAR_RATIO'])
# exit()

df[X] = pd.to_numeric(df[X], errors='coerce', downcast='float')
df[Y] = pd.to_numeric(df[Y], errors='coerce', downcast='float')

df.plot.scatter(x=X, y=Y, alpha=0.2)
# plt.xlim((0, 50))
plt.show()