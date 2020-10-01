#!/bin/sh
# ==================================================================================================
# Sistemas de Información Geográfica
# practica 5
# José Manuel Rodríguez-Rabadán Romero de Ávila
# ==================================================================================================

#
# Funcion para cargar las coordenas en variables
#
getCoord( ) {
X=$1;
Y=$2;	
	}

#
# Funcion para cargar la altura en la variable Z
#
getZ( ) {
Z=$(./u.getZ.py $1); 
        }

# ==================  E N T R A D A    D E    D A T O S  ==================================

#
# Leemos la posicion de la toma del canal
#
d.mon start=x0 > /dev/null 2> /dev/null
d.rast elev_ned_30m> /dev/null 2> /dev/null
d.vect streets_wake@ color=black > /dev/null 2> /dev/null
d.vect streams color=cyan width=2 > /dev/null 2> /dev/null

echo Indica la posicion de la toma


getCoord $(d.where -1)
getZ $(r.what elev_ned_30m east_north=$X,$Y)
HT=$Z;			# Altura de la toma
XT=$X;			# Posicion de la toma
YT=$Y;

echo "Toma en: $XT,$YT a altura: $HT"
#
# Leemos la posicion del desagüe del canal
#
echo Indica la posicion del desagüe

getCoord $(d.where -1)>/dev/null
getZ $(r.what elev_ned_30m east_north=$X,$Y)
HD=$Z;			# Altura del desagüe
XD=$X;			# Posicion del desagüe
YD=$Y;
echo "Desagüe en: $XD,$YD a altura: $HD"

# ===========  C A L C U L O   D E   L A   S U P E R F I C I E   D E   C O S T E ======================
#
# Calculo del mapa de coste unitario
#
# 	Concepto				Coste por metro  
# Canalización						 200,00 €
# Hasta 5m de elevación sobre terreno
#  		Muro soporte (por m de altura)		 200,00 €
# Más de 5m de elevación sobre el terreno
#		Estructura acueducto			1000,00 €
#		Soporte acueducto (por m de altura) 	 100,00 €
# Soterramiento
#		Excavación y pared (por m de altura)	 300,00 €

# Creamos mapas de distancias para estimar la altura del canal

echo Creando mapa de distancias

g.remove rast=uno,dToma,dDesague,HTeo > /dev/null 2> /dev/null
r.mapcalc "uno=1" > /dev/null  2> /dev/null

r.cost -k input=uno output=dToma coordinate=$XT,$YT > /dev/null 2> /dev/null

r.cost -k input=uno output=dDesague coordinate=$XD,$YD > /dev/null 2> /dev/null

r.mapcalc "HTeo=($HD*dToma +$HT*dDesague)/(dToma+dDesague)" > /dev/null  2> /dev/null



g.region res=30 > /dev/null 2> /dev/null	# Nos aseguramos de tner resolucion de 30 m
# coste por celda en K€ (resolucion 3ox30) es
# Canalización						 6,00 k€
# Hasta 5m de elevación sobre terreno
#  		Muro soporte (por m de altura)		 6,00 k€
# Más de 5m de elevación sobre el terreno
#		Estructura acueducto			60,00 k€
#		Soporte acueducto (por m de altura) 	 3,00 k€
# Soterramiento
#		Excavación y pared (por m de altura)	 9,00 k€

g.copy rast=elev_ned_30m,H > /dev/null 2> /dev/null	# Para poder abreviar en las formulas

# crear cuCanal. Se ha modificado el calculo de cuCanal porque la entrega anterior el cálculo era erróneo.
r.mapcalc "cuCanal=if((HTeo-H)<0,6-9*(HTeo-H),if((HTeo-H)>5,6+60+3*(HTeo-H),6+6*(HTeo-H)))"

# Calculo de la superficie de coste
r.cost --o cuCanal output=coste coordinate=$XT,$YT


#  Mostranos el coste total
#

getZ $(r.what coste east_north=$XD,$YD) 
COSTE=$Z;
echo "El coste es: $COSTE k€"


# ==============  C A L C U L O   D E L   C A M I N O   M I N I M O  =========================
#




# crear mapa canal
r.drain -c --o coste output=canal coordinate=$XD,$YD


#
# ====================================  D I B U J O   =========================================
#

g.remove vect=canal > /dev/null  2> /dev/null
r.to.vect canal output=canal feature=line > /dev/null 2> /dev/null

echo Dibujando mapa de situacion

d.frame -e > /dev/null 2> /dev/null
d.frame -c frame=mapa at=5,100,0,100 > /dev/null 2> /dev/null
d.rast aspect > /dev/null 2> /dev/null

d.vect roads  color=brown > /dev/null 2> /dev/null
d.vect streams color=cyan  > /dev/null 2> /dev/null

d.vect canal color=red width=2 > /dev/null 2> /dev/null

d.barscale  at=10.0,92.0 

# creamos un frame para el pie

d.frame -c frame=leyenda at=0,5,0,100
echo "Trazado del canal"|d.text at=10,40 size=80 color=black -b

d.out.file output=canal  res=1 format=png compression=0 quality=75 > /dev/null 2> /dev/null



# =========================== N V I Z ======================================

echo Dibujando mapa con nviz
r.buffer canal output=bcanal distances=30 --o
r.mapcalc "elevacion=if(isnull(bcanal),elev_ned_30m,HTeo)"
r.colors elevacion rast=elev_ned_30m
nviz elevation=elevacion  vector=canal




