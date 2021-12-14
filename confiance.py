#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 14 04:48:58 2021

@author: Abdoul_Aziz_Berrada
"""

"""            
if (v.iloc[m, n]<i.iloc[m, n]) and (v.iloc[m, n]<s.iloc[m, n]):
    print("Col hors de l'intervalle")            
if (v.iloc[m, n]<i.iloc[m, n]) and (v.iloc[m, n]>s.iloc[m, n]):
    print("Col hors de l'intervalle")             
if (v.iloc[m, n]<i.iloc[m, n]) and (v.iloc[m, n]<s.iloc[m, n]):
    print("Col hors de l'intervalle") 
"""                


import pandas as pd
import numpy as np


def confiance(i, s, v):
    for matrices in [i, s, v]:
        matrices.columns = range(1, 12) #rename les colonnes de 1 à 11 et pas de 0 à 10
        matrices.index = range(1, 11)
        
    
    a = np.zeros((10, 11))
    
    
    
    for m in range(0, 10):
        for n in range(0, 11):
            if (v.iloc[m, n]>i.iloc[m, n]) and (v.iloc[m, n]<s.iloc[m, n]):
                #print("Col dans l'intervalle")
                a[m, n] = 1
    print(a)

    return a

##2020
""" 2020 Baseline """
ib20 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2020_baseline_inf.csv", sep = ";")
sb20 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2020_baseline_sup.csv", sep = ";")
base_18 = pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2020_transp.csv", sep = ";").drop('key1', axis = 1)
"""  2020 Central """
ic20 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2020_central_inf.csv", sep = ";")
sc20 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2020_central_sup.csv", sep = ";")
"""  2020 Adverse """
ia20 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2020_baseline_inf.csv", sep = ";")
sa20 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2020_baseline_sup.csv", sep = ";")


##2019
""" 2019 Baseline """
ib19 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2019_baseline_inf.csv", sep = ";")
sb19 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2019_baseline_sup.csv", sep = ";")
base_19 = pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2019_transp.csv", sep = ";").drop('key1', axis = 1)
""" 2019 Central """
ic19 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2019_central_inf.csv", sep = ";")
sc19 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2019_central_sup.csv", sep = ";")
""" 2019 Adverse """
ia19 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2019_baseline_inf.csv", sep = ";")
sa19 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2019_baseline_sup.csv", sep = ";")

b = confiance(ib19, sb19, base_19)
a = confiance(ia19, sa19, base_19)
c = confiance(ic19, sc19, base_19)            
            

##2018
""" 2018 Baseline """
ib18 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2018_baseline_inf.csv", sep = ";")
sb18 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2018_baseline_sup.csv", sep = ";")
base_18 = pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2018_transp.csv", sep = ";").drop('key1', axis = 1)
"""  2018 Central """
ic18 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2018_central_inf.csv", sep = ";")
sc18 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2018_central_sup.csv", sep = ";")
"""  2018 Adverse """
ia18 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2018_baseline_inf.csv", sep = ";")
sa18 = 100*pd.read_csv("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/data/PIT_2018_baseline_sup.csv", sep = ";")

b = confiance(ib18, sb18, base_18)
a = confiance(ia18, sa18, base_18)
#c = confiance(ic19, sc19, base_19)            
            

b = pd.DataFrame(b)
b.columns = range(1, 12) #rename les colonnes de 1 à 11 et pas de 0 à 10
b.index = range(1, 11)
import seaborn as sns
#b.sum()

sns.histplot(b)

b.sum()

            
            
            
            
            
            