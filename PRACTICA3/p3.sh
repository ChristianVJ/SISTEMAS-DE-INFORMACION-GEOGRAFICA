#!/bin/sh
#
#José Manuel Rodríguez-Rabadán Romero de Ávila
#Práctica 3
#
#

#Cargamos los mapas y ajustamos la región
g.mapset -c mapset=P3
g.region n=267500 s=189000 e=704500 w=586500
g.region res=100
r.resamp.interp elev_state_500m output=elevacion_100m --o
#Realizamos las reclasificaciones
r.recode elevacion_100m output=elevacion_d --o <<END_RECODE
0:50:0:0
50:75:1:1
75:100:2:2
100:125:3:3
125:250:4:4
end
END_RECODE

r.reclass elevacion_d output=altura --o <<END_RECLASS
0 = 0 de 0 a 50m
1 = 1 de 50 a 75m
2 = 2 de 75 a 100m
3 = 3 de 100 a 125m
4 = 4 de 125 a 250m
end
END_RECLASS
#Se calcula la altura
r.mapcalc "alturaWake=if(boundary_county_500m==183,altura,null())"
#Reclasificamos el mapa altura y alturaWake
r.colors altura color=rules <<END_COLORS
0 255:188:100
1 255:255:100
2 100:255:100
3 160:100:80
4 255:100:100
end
END_COLORS
r.colors alturaWake color=rules <<END_COLORS
0 yellow
1 orange
2 green
3 brown
4 red
end
END_COLORS
r.reclass alturaWake output=Vlegend --o <<END_RECLASS
0 = 0 Carreteras
1 = 1 Limites
end
END_RECLASS
r.colors Vlegend color=rules <<END_COLORS
0 black
1 blue
end
END_COLORS

#Pintamos los mapas en una ventana
d.mon start=x0
d.erase
d.frame -e
d.frame -c frame=titulo at=0,20,0,100
echo "Elevacion en condado de Wake"|d.text at=10,70 size=25 color=black -b
d.frame -c frame=leyenda at=20,100,80,100
echo "Elevacion"|d.text at=5,95 size=4 color=black -b
d.legend altura -c at=90,70,10,20
echo "Simbolos"|d.text at=5,45 size=4 color=black -b
d.legend Vlegend -c at=40,30,10,20
d.frame -c frame=mapa at=20,100,0,80
d.rast -o map=altura
d.rast -o map=alturaWake
d.vect -c map=boundary_county type=boundary color=blue
d.vect map=roadsmajor
d.barscale at=0,0
