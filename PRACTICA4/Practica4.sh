#!/bin/sh
#José Manuel Rodríguez-Rabadán Romero de Ávila
#Práctica 4 GIS

#Delimitamos la región de trabajo a landuse96_28m
g.region rast=landuse96_28m 

#Seleccionamos las zonas con colegios y creamos un mapa
v.to.rast schools_wake output=colegios use=cat --o


#Zonas urbanizadas. Reclasificamos landuse96_28m y creamos una salida con la categoría 1 que será urbanizadoDenso
r.reclass landuse96_28m output=urbanizadoDenso <<END_RECLASS
1 = 1 high
end
END_RECLASS

#Zonas urbanizables
r.reclass landuse96_28m output=urbanizadoDisperso <<END_RECLASS
2 = 1 low
end
END_RECLASS


#Creamos el mapa de zonas cubiertas por colegio
r.buffer colegios output=buffColegios1km distance=1000 --o

#Creamos las zonas que no están cubiertas por los colegios
r.mapcalc "noColegio=if(isnull(buffColegios1km) && (urbanizadoDenso==1), 1, null())"

#Creamos un mapa de las zonas que están a menos de un kilometro de las zonas sin colegio con el nombre CandidatoDistancia
r.buffer noColegio output=CandidatoDistancia distance=1000 --o


#Se crea un mapa con las zonas zonas con desnivel menor que seis metros
r.neighbors elev_srtm_30m output=alturaMaxima method=maximum size=5 --o
r.neighbors elev_srtm_30m output=alturaMinima method=minimum size=5 --o
r.mapcalc "d=(alturaMaxima-alturaMinima)"
r.mapcalc "desnivel=if(d<=6,1,null())"

#Se selecciona el conjunto de zonas llanas que pueden edificarse con un mapcalc
r.mapcalc "llano=if((desnivel && urbanizadoDisperso),1,null())"

#Ahora creamos un mapa con las zonas candidatas, es decir las que son llanas y se pueden construir en ellas
r.mapcalc "candidato=if(llano && CandidatoDistancia,1,null())"




#Creamos un mapa con las ubicaciones ajustando la resolución a 83
g.region res=83
r.neighbors input=noColegio output=cubiertasBR method=sum size=25 -c --o

#Para obtener un mapa a 28m de resolución interpolamos el mapa anterior.
g.region rast=landuse96_28m

#En lugar de utilizar r.bilinear se utiliza r.resamp.interp ya que nos dice que el módulo está inutilizable. Grass nos sugiere la utilización de este otro
r.resamp.interp cubiertasBR output=cubiertasInterpolada --o

#Cada celda cubierta representa un área de 83*83 metros cuadrados lo que supone 6.889,00 metros cuadrados
r.mapcalc "ubicacion=if(candidato==1,cubiertasInterpolada*6.889,null())"



r.reclass roadsmajor output=callesNegras --o <<END_RECLASS
1 = 1 Calles
end
END_RECLASS


r.reclass landuse96_28m  output=colegiosRojos --o <<END_RECLASS
1 = 1 Colegios
end
END_RECLASS


#Añadimos el color de las calles y a los colegios
r.colors callesNegras color=rules <<END_COLORS
1 black
end
END_COLORS

r.colors colegiosRojos color=rules <<END_COLORS
1 red
end
END_COLORS

r.colors ubicacion color=rules <<END_COLORS
6.889000 yellow
571 green
1134 green
2817.601000 blue
end
END_COLORS


#Inicializamos el monitor
d.mon x0

d.frame -c frame=noLateral at=15,100,0,80
#Barra de escala
d.barscale tcolor=0:0:0 bcolor=255:255:255 at=2,95

#Añadimos el mapa de calles
d.vect map=streets_wake color=136:136:136 size=1 

#Añadimos el mapa raster de ubicacion
d.rast -o map=ubicacion

#Añadimos el mapa de calles
d.vect map=roadsmajor lcolor=18:18:18

#Añadimos el mapa vectorial de escuelas del condado de Wake
d.vect map=schools_wake color=red width=3 icon=basic/circle

#Frame inferior
d.frame -c frame=inferior at=0,15,0,100
echo "Ubicacion para nuevo colegio" |d.text at=30,70 size=15 color=black -b
echo "(superficie cubierta en miles de metros cuadrados)"|d.text at=25,20 size=13 color=black

#Frame lateral derecho	bottom, top, right, left
d.frame -c frame=lateral at=15,100,80,100
#Leyenda. Añadimos en superfice para que solo salgan 4 valores en la etiqueta
echo "Superficie"|d.text at=0,95 size=3 color=black -b
d.legend ubicacion labelnum=4 at=80,50,10,20
echo "Simbolos"|d.text at=0,20 size=3 color=black -b
d.legend colegiosRojos -c at=5,0,20,30
d.legend callesNegras -c at=10,5,20,30









