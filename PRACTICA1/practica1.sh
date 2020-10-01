#!/bin/sh
#José Manuel Rodríguez-Rabadán Romero de Ávila
#Práctica 1 GIS

#Borramos los frames por si el monitor ya está creado
d.frame -e

#Se crea el monitor
d.mon start=x0

#Frame para el pie
d.frame -c frame=leyenda at=0,20,0,100
#Título para el frame

echo "Condado de Wake"|d.text at=25,70 size=30 color=black -b

#Frame para el mapa
d.frame -c frame=mapa at=20,100,0,100

#Creación del mapa elev_state_500m
d.rast map=elev_state_500m -o

#Visualización hospitales
#Forma:caja
#color:gris
#tamaño:8
d.vect map=hospitals display=shape color=126:126:126 lcolor=0:0:0 fcolor=170:170:170  type=point,line,boundary,area icon=basic/box size=8 layer=1 lsize=8 xref=left yref=center llayer=1

#Visualización carreteras linea fina 
d.vect map=roadsmajor color=255:16:0 lcolor=0:0:0 fcolor=200:200:200  type=point,line,boundary,area icon=basic/circle size=8 width=0.5 layer=1 lsize=8 xref=left yref=center llayer=1

#Visualización carreteras linea gruesa | MULTILANE
d.vect map=roadsmajor color=255:103:0 lcolor=255:0:11 fcolor=200:200:200  type=point,line,boundary,area icon=basic/circle size=5 width=2 layer=1 lsize=8 xref=left yref=center llayer=1 where="MULTILANE='yes'"

#Visualización del mapa boundary_county de los condados que no son WAKE
d.vect map=boundary_county -c  display=shape color=255:16:0 lcolor=150:150:150 fcolor=200:200:200  type=point,line,boundary,area icon=basic/circle attrcol='NAME' size=5 layer=1 lsize=8 xref=left yref=center llayer=1 where="NAME<>'WAKE'"  

#Etiquetado de los condados que no son WAKE #Tipo attr(etiqueta)
d.vect map=boundary_county -c  display=attr color=255:16:0 lcolor=0:0:0 fcolor=200:200:200  type=point,line,boundary,area icon=basic/circle attrcol='NAME' size=8 layer=1 lsize=8 xref=left yref=center llayer=1 where="NAME<>'WAKE'"  

#Barra de escala
d.barscale tcolor=0:0:0 bcolor=255:255:255 at=2,2





