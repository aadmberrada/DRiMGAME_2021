#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Dec 10 21:22:37 2021

@author: Abdoul_Aziz_Berrada
"""

import warnings
warnings.filterwarnings('ignore')
import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
#plt.style.use('dark_background')
st.set_option('deprecation.showPyplotGlobalUse', False)
import plotly.express as px
from plotly.subplots import make_subplots
import plotly.graph_objects as go
import seaborn as sns


#-------------------- Data
path = "/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/Données/"
##Données de projection
df = pd.read_excel(path+"scenarios_proj_propre.xlsx")
df.rename(columns = {'DR_baseline':'Baseline', 'DR_central':'Central', 'DR_adverse':'Adverse'}, inplace = True)
df = df[["Date", "Baseline", "Central", "Adverse"]]

df[ "Baseline"] = 100*df[ "Baseline"]
df[ "Central"] = 100*df[ "Central"]
df[ "Adverse"] = 100*df[ "Adverse"]
df["DRnew"] = df["Baseline"].iloc[0:27,]
dff = df[["Date","DRnew"]].dropna()


##Z_projeté
Z_baseline_2018 = 2.005
Z_central_2018 = 1.948
Z_adverse_2018 = 1.835

Z_baseline_2019 = 2.082
Z_central_2019 = 1.741
Z_adverse_2019 = 1.219

Z_baseline_2020 = 2.060
Z_central_2020 = 1.308
Z_adverse_2020 = 0.348

##Matrices PIT
PIT_proj_baseline_2018 = pd.read_excel(path + "PIT_proj_baseline_2018.xlsx").iloc[:, 1:]
PIT_proj_central_2018 = pd.read_excel(path + "PIT_proj_central_2018.xlsx").iloc[:, 1:]
PIT_proj_adverse_2018 = pd.read_excel(path + "PIT_proj_adverse_2018.xlsx").iloc[:, 1:]

PIT_proj_baseline_2019 = pd.read_excel(path + "PIT_proj_baseline_2019.xlsx").iloc[:, 1:]
PIT_proj_central_2019 = pd.read_excel(path + "PIT_proj_central_2019.xlsx").iloc[:, 1:]
PIT_proj_adverse_2019 = pd.read_excel(path + "PIT_proj_adverse_2019.xlsx").iloc[:, 1:]

PIT_proj_baseline_2020 = pd.read_excel(path + "PIT_proj_baseline_2020.xlsx").iloc[:, 1:]
PIT_proj_central_2020 = pd.read_excel(path + "PIT_proj_central_2020.xlsx").iloc[:, 1:]
PIT_proj_adverse_2020 = pd.read_excel(path + "PIT_proj_adverse_2020.xlsx").iloc[:, 1:]

##Passage défaut
passage = pd.read_excel(path + "passage_defaut_classes_scenarios.xlsx")
passage18 = pd.read_excel(path+  "passage_defaut_2018.xlsx")
passage19 = pd.read_excel(path+  "passage_defaut_2019.xlsx")
passage20 = pd.read_excel(path+  "passage_defaut_2020.xlsx")

#c = sns.heatmap(PIT_proj_central_2018)
#st.dataframe(c)

def color(val, s):
    color = 'green' if val > s else 'red'
    return f'background-color:{color}'

def _color_red_or_green(val):
    color = 'red' if val < 0.5 else 'green'
    return 'background_gradient: %s' % color

#df.style.applymap(_color_red_or_green)

#st.dataframe(PIT_proj_baseline_2018.style.applymap(_color_red_or_green))

#-------------------- Head

##---- Header
st.title("DRiM GAME")
st.title("Challenge Data Science & Risque de crédit")
col1, col2, col3, col4 = st.columns(4)

col4.image("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/mosef3.png")
col1.image("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/rci.png")
col2.image("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/deloitte.png")
col3.image("/Users/Abdoul_Aziz_Berrada/Documents/M2_MOSEF/3_DrimChallenge/DRiMGAME_2021/sas.png")
#--------------------





#-------------------- Sidebar
st.sidebar.title("**MoSEF**")
st.sidebar.subheader("Abdoul A. Berrada - Morgane Caillosse")
st.sidebar.subheader("Hugo Hamon - Amira Slimene")

st.sidebar.title("Choix des paramètres")
annee = st.sidebar.selectbox("Choix de l'année", [2018, 2019, 2020])
#scenario = st.sidebar.multiselect("Choix de scénario(s)", ["Baseline", 'Central', "Adverse"])
number = st.sidebar.slider("Nombre de scénarios à voir", 1, 3, 1)

if number == 1:
    choix = st.sidebar.selectbox("Lequel?", ["Baseline", 'Central', "Adverse"])

if number == 2:
    choix = st.sidebar.selectbox("Lesquels?", ["Baseline & Central", "Baseline & Adverse", 'Adverse & Central'])

if number == 3:
    choix = 'Baseline & Central & Adverse'
    st.sidebar.write("Vous avez choisi de voir les 3 scénarios!")

    
bouton = st.sidebar.button("Voir les résultats")

#-------------------- 






#-------------------- Corps

st.markdown("Veuillez sélectionner dans le menu à gauche une année de référence et un ou des scénarios macroéconomiques")

st.write("Vous avez choisi l'année", annee)
#st.write("Scénario(s) macroéconomique(s)", scenario)

if number == 3:
    st.write("Vous avez choisi les scénarios : Baseline, Central & Adverse")
if number == 2:
    st.write("Vous avez choisi les scénarios :", choix)
if number == 1:
     st.write("Vous avez choisi le scénario :", choix)   
##---- Graphiques
### Scénarios macros
if number == 1:
    st.subheader("Scénario macroéconomique")
if number > 1:
    st.subheader("Scénarios macroéconomiques")
    
fig = make_subplots(specs=[[{"secondary_y": True}]])

trace1 = go.Scatter(
x = df["Date"],
y = df['Central'],
mode = "lines",
name = "Central",
marker = dict(color = 'orange'))

trace2 = go.Scatter(
x = df["Date"],
y = df["Baseline"],
#mode ="lines+markers"
mode ="lines",
name = "Baseline",
marker = dict(color = 'green'))

trace3 = go.Scatter(
x = df["Date"],
y = df["Adverse"],
mode = "lines",
name = "Adverse",
marker = dict(color = 'red'))

trace4 = go.Scatter(
x = dff["Date"],
y = dff["DRnew"],
mode = "lines",
name = "Taux de défaut estimé",
marker = dict(color = 'blue'))


fig.add_trace(trace1, secondary_y=False);
fig.add_trace(trace2, secondary_y=False);
fig.add_trace(trace3, secondary_y=False);
fig.add_trace(trace4, secondary_y=True);
#data = [trace1, trace2,trace3, trace4]


def graphique():
   
    data = []
    
    if "Central" in choix:
        data.append(trace1)
    
    if "Baseline" in choix:
        data.append(trace2)

    if "Adverse" in choix:
        data.append(trace3)
        
    data.append(trace4)
        
    return data
        
data = graphique()
layout = dict(autosize=False,
                  width=840,
                  height=550,
                  title = 'Évolution du défaut en fonction des scénarios macroéconomiques',
xaxis= dict(title= 'Date',ticklen= 5, dtick = 2, zeroline= True, tickangle=45),
yaxis= dict(title= 'Taux de défaut en %',ticklen= 5, zeroline= True))
fig = dict(data = data, layout = layout)

st.plotly_chart(fig)

### Passage en défaut 

#-------------

def _adv18(annee):
    
    base = passage18
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2018'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figa = _adv18(annee)

def _cent18(annee):

    base = passage18
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2018'],
    name = "Central",
    marker = dict(color = 'orange'))
    fig1.add_trace(trace5, secondary_y=False);
    
    data2 = [trace5]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figc = _cent18(annee)

def _base18(annee):
    base = passage18
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2018'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    
    data2 = [trace6]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figb = _base18(annee)

def _centbase18(annee):
    base = passage18
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2018'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2018'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace5, secondary_y=False);
    
    data2 = [trace6, trace5]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figcb = _centbase18(annee)

def _advbase18(annee):
    
    base = passage18
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2018'],
    name = "Adverse",
    marker = dict(color = 'red'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2018'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace6, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figab = _advbase18(annee)

def _centadv18(annee):
    base = passage18
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2018'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2018'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace5, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace5, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figca = _centadv18(annee)

def _basecentadv18(annee):
    
    base = passage18
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2018'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2018'],
    name = "Baseline",
    marker = dict(color = 'green'))

    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2018'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace5, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace6, trace5, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figbca = _basecentadv18(annee)


def _adv19(annee):
    
    base = passage19
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2019'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figa = _adv19(annee)

def _cent19(annee):

    base = passage19
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2019'],
    name = "Central",
    marker = dict(color = 'orange'))
    fig1.add_trace(trace5, secondary_y=False);
    
    data2 = [trace5]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figc = _cent19(annee)

def _base19(annee):
    base = passage19
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2019'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    
    data2 = [trace6]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figb = _base19(annee)

def _centbase19(annee):
    base = passage19
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2019'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2019'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace5, secondary_y=False);
    
    data2 = [trace6, trace5]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figcb = _centbase19(annee)

def _advbase19(annee):
    
    base = passage19
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2019'],
    name = "Adverse",
    marker = dict(color = 'red'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2019'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace6, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figab = _advbase19(annee)

def _centadv19(annee):
    base = passage19
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2019'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2019'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace5, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace5, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figca = _centadv19(annee)

def _basecentadv19(annee):
    
    base = passage19
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2019'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2019'],
    name = "Baseline",
    marker = dict(color = 'green'))

    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2019'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace5, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace6, trace5, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figbca = _basecentadv19(annee)

def _adv20(annee):
    
    base = passage20
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2020'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figa = _adv20(annee)

def _cent20(annee):

    base = passage20
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2020'],
    name = "Central",
    marker = dict(color = 'orange'))
    fig1.add_trace(trace5, secondary_y=False);
    
    data2 = [trace5]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figc = _cent20(annee)

def _base20(annee):
    base = passage20
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2020'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    
    data2 = [trace6]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figb = _base20(annee)

def _centbase20(annee):
    base = passage20
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2020'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2020'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace5, secondary_y=False);
    
    data2 = [trace6, trace5]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figcb = _centbase20(annee)

def _advbase20(annee):
    
    base = passage20
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2020'],
    name = "Adverse",
    marker = dict(color = 'red'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2020'],
    name = "Baseline",
    marker = dict(color = 'green'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace6, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figab = _advbase20(annee)

def _centadv20(annee):
    base = passage20
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2020'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2020'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace5, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace5, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1

figca = _centadv20(annee)

def _basecentadv20(annee):
    
    base = passage20
    fig1 = make_subplots(specs=[[{"secondary_y": True}]])
    trace5 = go.Bar(
    x = base["classe"],
    y = base['central_2020'],
    name = "Central",
    marker = dict(color = 'orange'))

    trace6 = go.Bar(
    x = base["classe"],
    y = base['baseline_2020'],
    name = "Baseline",
    marker = dict(color = 'green'))

    trace7 = go.Bar(
    x = base["classe"],
    y = base['adverse_2020'],
    name = "Adverse",
    marker = dict(color = 'red'))
    fig1.add_trace(trace6, secondary_y=False);
    fig1.add_trace(trace5, secondary_y=False);
    fig1.add_trace(trace7, secondary_y=False);
    
    data2 = [trace6, trace5, trace7]
    layout = dict(autosize=False,
                      width=840,
                      height=550,
                      title = 'Taux de passage en défaut à 1 an en fonction des classes de risque initiales',
    xaxis= dict(title= 'Classes de risque à t',ticklen= 5, dtick = 1, zeroline= True),
    yaxis= dict(title= 'Taux de passage en défaut en %',ticklen= 5, zeroline= True))
    fig1 = dict(data = data2, layout = layout)
    return fig1
figbca = _basecentadv20(annee)



#---------------







##---- Z_projeté
if number == 1:
    st.subheader("Z_projetés")
if number > 1:
    st.subheader("Z_projetés")
    


#2018
if annee==2018 and choix=="Baseline":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2018)
if annee==2018 and choix=="Central":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2018)
if annee==2018 and choix=="Adverse":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2018)
if annee==2018 and choix=="Baseline & Central":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2018)
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2018)
if annee==2018 and choix=="Baseline & Adverse":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2018)   
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2018)    
if annee==2018 and choix=='Adverse & Central':
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2018)   
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2018)    
if annee==2018 and choix =='Baseline & Central & Adverse':
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2018)
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2018)   
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2018)

#2019
if annee==2019 and choix=="Baseline":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2019)
if annee==2019 and choix=="Central":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2019)
if annee==2019 and choix=="Adverse":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2019)
if annee==2019 and choix=="Baseline & Central":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2019)
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2019)
if annee==2019 and choix=="Baseline & Adverse":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2019)   
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2019)    
if annee==2019 and choix=='Adverse & Central':
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2019)   
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2019) 
if annee==2019 and choix =='Baseline & Central & Adverse':  
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2019)
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2019) 
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2019)
     
#2020
if annee==2020 and choix=="Baseline":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2020)
if annee==2020 and choix=="Central":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2020)
if annee==2020 and choix=="Adverse":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2020)
if annee==2020 and choix=="Baseline & Central":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2020)
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2020)
if annee==2020 and choix=="Baseline & Adverse":
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2020)   
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2020)  
if annee==2020 and choix=='Adverse & Central':
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2020)   
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2020)
if annee==2020 and choix =='Baseline & Central & Adverse':
    st.write("Le Z projeté pour l'année", annee, "et le scénario Baseline est", Z_baseline_2020) 
    st.write("Le Z projeté pour l'année", annee, "et le scénario Central est", Z_central_2020)     
    st.write("Le Z projeté pour l'année", annee, "et le scénario Adverse est", Z_adverse_2020)
     
    
    
    
    
    
    
##---- Matrices
if number == 1:
    st.subheader("Matrice")
if number > 1:
    st.subheader("Matrices")


#PIT_proj_baseline_2018 = PIT_proj_baseline_2018.reset_index(drop=True)

for matrices in [PIT_proj_baseline_2018, PIT_proj_central_2018, PIT_proj_adverse_2018, PIT_proj_baseline_2019, PIT_proj_central_2019, PIT_proj_adverse_2019,
PIT_proj_baseline_2020, PIT_proj_central_2020, PIT_proj_adverse_2020]:
    matrices.columns = range(1, 12) #rename les colonnes de 1 à 11 et pas de 0 à 10
    matrices.index = range(1, 12) #rename les lignes de 1 à 11 et pas de 0 à 10
    
PIT_proj_baseline_2018 = PIT_proj_baseline_2018.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')
PIT_proj_central_2018 = PIT_proj_central_2018.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')
PIT_proj_adverse_2018 = PIT_proj_adverse_2018.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')

PIT_proj_baseline_2019 = PIT_proj_baseline_2019.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')
PIT_proj_central_2019 = PIT_proj_central_2019.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')
PIT_proj_adverse_2019 = PIT_proj_adverse_2019.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')

PIT_proj_baseline_2020 = PIT_proj_baseline_2020.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')
PIT_proj_central_2020 = PIT_proj_central_2020.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')
PIT_proj_adverse_2020 = PIT_proj_adverse_2020.style.background_gradient(text_color_threshold = 0, low = 0.3, high = 0.3, axis=1, cmap='RdYlGn')
#PIT_proj_adverse_2020 = PIT_proj_adverse_2020.style.background_gradient(axis=0, cmap='RdYlGn')
#a = PIT_proj_baseline_2018
#a["max"] = a.max(axis = 1)
#a["min"] = a.min(axis = 1)

#c = a.style.background_gradient(axis=0, cmap='RdYlGn')

#st.dataframe(c)


#2018
if annee==2018 and choix=="Baseline":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2018)
if annee==2018 and choix=="Central": 
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est :")
    st.table(PIT_proj_central_2018)
if annee==2018 and choix=="Adverse" :
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2018)
if annee==2018 and choix=="Baseline & Adverse":    
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2018)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2018)
if annee==2018 and choix=="Baseline & Central":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2018)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est :")
    st.table(PIT_proj_central_2018)
if annee==2018 and choix=='Adverse & Central':
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2018)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est :")
    st.table(PIT_proj_central_2018)
if annee==2018 and choix =='Baseline & Central & Adverse':
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2018)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est :")
    st.table(PIT_proj_central_2018)    
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2018)

#2019
if annee==2019 and choix=="Baseline":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :" )
    st.table(PIT_proj_baseline_2019)
if annee==2019 and choix== "Central":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est : ")
    st.table(PIT_proj_central_2019)
if annee==2019 and choix== "Adverse":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est : ")
    st.table(PIT_proj_adverse_2019)
if annee==2019 and choix=="Baseline & Adverse":    
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2019)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2019)
if annee==2019 and choix=="Baseline & Central":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :" )
    st.table(PIT_proj_baseline_2019)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est : ")
    st.table(PIT_proj_central_2019)
if annee==2019 and choix=='Adverse & Central':
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2019)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est : ")
    st.table(PIT_proj_central_2019)
if annee==2019 and choix =='Baseline & Central & Adverse':
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2019)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est :")
    st.table(PIT_proj_central_2019)    
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2018)
    
#2020
if annee==2020 and choix=="Baseline":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :" )
    st.table(PIT_proj_baseline_2020)
if annee==2020 and choix== "Central":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est : ")
    st.table(PIT_proj_central_2020)
if annee==2020 and choix== "Adverse":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est : ")
    st.table(PIT_proj_adverse_2020)
if annee==2020 and choix=="Baseline & Adverse":    
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2020)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2020)
if annee==2020 and choix=="Baseline & Central":
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :" )
    st.table(PIT_proj_baseline_2020)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est : ")
    st.table(PIT_proj_central_2020)
if annee==2020 and choix=='Adverse & Central':
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2020)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est : ")
    st.table(PIT_proj_central_2020)
if annee==2020 and choix =='Baseline & Central & Adverse':
    st.write("La matrice PIT pour l'année", annee, "et le scénario Baseline est :")
    st.table(PIT_proj_baseline_2020)
    st.write("La matrice PIT pour l'année", annee, "et le scénario Central est :")
    st.table(PIT_proj_central_2020)    
    st.write("La matrice PIT pour l'année", annee, "et le scénario Adverse est :")
    st.table(PIT_proj_adverse_2020)







##Barcharts
if annee==2018 and choix=="Adverse":
    st.plotly_chart(figa)
if annee==2018 and choix=="Baseline":
    st.plotly_chart(figb)
if annee==2018 and choix=="Central":
    st.plotly_chart(figc)
if annee==2018 and choix=="Baseline & Central":
    st.plotly_chart(figcb)
if annee==2018 and choix=="Adverse & Central":
    st.plotly_chart(figca)
if annee==2018 and choix=="Baseline & Adverse":
    st.plotly_chart(figab)
if annee==2018 and choix =='Baseline & Central & Adverse':
    st.plotly_chart(figbca)


if annee==2019 and choix=="Adverse":
    st.plotly_chart(figa)
if annee==2019 and choix=="Baseline":
    st.plotly_chart(figb)
if annee==2019 and choix=="Central":
    st.plotly_chart(figc)
if annee==2019 and choix=="Baseline & Central":
    st.plotly_chart(figcb)
if annee==2019 and choix=="Adverse & Central":
    st.plotly_chart(figca)
if annee==2019 and choix=="Baseline & Adverse":
    st.plotly_chart(figab)
if annee==2019 and choix =='Baseline & Central & Adverse':
    st.plotly_chart(figbca)

if annee==2020 and choix=="Adverse":
    st.plotly_chart(figa)
if annee==2020 and choix=="Baseline":
    st.plotly_chart(figb)
if annee==2020 and choix=="Central":
    st.plotly_chart(figc)
if annee==2020 and choix=="Baseline & Central":
    st.plotly_chart(figcb)
if annee==2020 and choix=="Adverse & Central":
    st.plotly_chart(figca)
if annee==2020 and choix=="Baseline & Adverse":
    st.plotly_chart(figab)
if annee==2020 and choix =='Baseline & Central & Adverse':
    st.plotly_chart(figbca)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    