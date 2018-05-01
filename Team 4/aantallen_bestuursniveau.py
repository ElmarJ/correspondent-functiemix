import os
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Dit leest het bestand in de map 'Team 4'
df_gen = pd.read_csv('bestuursniveau2012-2016.csv', header=0, encoding="ISO-8859-1", delimiter=',')


YEARS = [2012, 2013, 2014, 2015, 2016]

for YEAR in YEARS:
	print("Year: ", YEAR)

	# df = df.loc[df['JAAR'] == 2016]  # YEARS
	df = df_gen.loc[df_gen['JAAR'] == YEAR]

	print("Besturen in het jaar - ", df.shape[0])

		# do same but attach it to the dataframe
	df['Gewenste_LB_Omvang'] = df.apply(lambda row: (row.OMVANG_FORMATIE_OP_LA_bestuurniveau + row.OMVANG_FORMATIE_OP_LB_bestuurniveau) * 0.4, axis=1)

	df['Extra_geld_voor_streefniveau'] = df.apply(lambda row: (row.Gewenste_LB_Omvang - row.OMVANG_FORMATIE_OP_LB_bestuurniveau) * 7000, axis=1)

	df['Nettoresultaat_Nieuw'] = df.apply(lambda row: (row.Nettoresultaat - row.Extra_geld_voor_streefniveau), axis=1)


	# df = df.loc[df['Nettoresultaat'] > 0]
	# print("Besturen daarvan met positief nettoresultaat - ", df.shape[0])

	df = df.loc[df['AANDEEL_FORMATIE_OP_LB_bestuurniveau'] < 40]
	print("Besturen daarvan met minder dan 40 procent LB - ", df.shape[0])
	
	# df = df.loc[df['Solvabiliteit I'] > 0.5]
	df = df.loc[df['Nettoresultaat_Nieuw'] > 0]
	print("Besturen daarvan met positief _nieuw_nettoresultaat - ", df.shape[0])
