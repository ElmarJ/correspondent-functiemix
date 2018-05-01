import pandas as pd

# inlezen bestanden
functiemix_besturen = pd.read_csv('functiemix-besturen.csv')
balans_2012_2016_compleet = pd.read_csv('01-balans-2012-2016.xlsx - Balans.csv')

# Selecteer alleen de basisscholen
balans_2012_2016 = balans_2012_2016_compleet[balans_2012_2016_compleet['Sector'] == 'PO']

# Combineer de dataframes met een inner-join. Let op: dit gooit alle data weg die niet in beide bestanden voortkomt. Er zijn scholen die wel in 1 van beide voortkomen, maar niet in allebei.
gecombineerde_df = functiemix_besturen.merge(balans_2012_2016, 
                      left_on=['BEVOEGD_GEZAGNUMMER','JAAR'], 
                      right_on = ['Bevoegd Gezag','Jaar'],
                      how='inner')
                      
# Schrijf naar een csv bestand.
gecombineerde_df.to_csv('functiemix_besturen_balans_2012_2016.csv')