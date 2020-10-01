#!/bin/sh
#José Manuel Rodríguez-Rabadán Romero de Ávila
#Práctica 2 GIS
#Mapas descargados: mapa de un lago: 
#Ortofotos: h10_1020_4-2.tif, h10_1020_3-2.tif
#Topográficos 102032.tif, 102042.tif

#importar los dos mapas de elevación
r.in.gdal input=./h10_1020_4-2/h10_1020_4-2.tif output=h10_1020_4-2 location=pract2
r.in.gdal -e input=./h10_1020_3-2/h10_1020_3-2.tif output=h10_1020_3-2

#Fusión de mapas de elevación
r.patch input=h10_1020_4-2,h10_1020_3-2 output=elevacionCosta

#Ajustamos la resolución
g.region res=1

#Importación de ortofotos
r.in.gdal input=./20140623_MTA_TIF_30102032/102032.tif output=102032 -o
r.in.gdal input=./20140623_MTA_TIF_30102042/102042.tif output=102042 -o

#Composición de ortofotos(se cambiaron a mapas topográficos para que se cargara la página)
r.composite red=102032.red green=102032.green blue=102032.blue output=102032_colores
r.composite red=102042.red green=102042.green blue=102042.blue output=102042_colores


#Fusión de los dos ortomapas
r.patch input=102032_colores,102042_colores output=ortofoto05m

