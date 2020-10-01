##########################################################################################
#Diseñar el recorrido más corto para una línea circular de autobús que una los		 #
#centros de secundaria del municipio de Cary en Wake (en él o a menos de 2km del mismo). #  
#									                 #
#José Manuel Rodríguez-Rabadán Romero de Ávila						 #
#Práctica 6					 					 #
#										 	 #
##########################################################################################

#Analizamos el mapa de municipios
db.columns table=boundary_municp database='$GISDBASE/$LOCATION_NAME/PERMANENT/dbf/'

#Consultamos las zonas cubiertas po rel municipio Cary
echo "SELECT * FROM boundary_municp WHERE MB_NAME = 'Cary'" | db.select database='$GISDBASE/
$LOCATION_NAME/PERMANENT/dbf/'
#Resultado de la ejecución:
#cat
#OBJECTID
#AREA
#PERIMETER
#MBPOW04_
#MBPOW04_ID
#MB_NAME
#...


#Consultamos la tabla del mapa de colegios
db.describe -c table=schools_wake database='$GISDBASE/$LOCATION_NAME/PERMANENT/dbf/'
#Resultado:
#ncols: 29
#nrows: 167
#Column 1: cat:INTEGER:11
#Column 2: TAG:CHARACTER:32
#Column 3: NAMESHORT:CHARACTER:20
#Column 4: NAMELONG:CHARACTER:41
#Column 5: CORECAPACI:DOUBLE PRECISION:20
#Column 6: MOBILEUNIT:DOUBLE PRECISION:20
#Column 7: MOBILECAPA:DOUBLE PRE...

#A continuación seleccionamos los de enseñanza superior
echo "SELECT * FROM schools_wake WHERE GLEVEL = 'H'" | db.select database='$GISDBASE/$LOCATION_NAME/PERMANENT/dbf/'
#Resultado:
#cat|TAG|NAMESHORT|NAMELONG|CORECAPACI|MOBILEUNIT|MOBILECAPA|GLEVEL|LOGRADE|HIGRADE|CALENDAR|HASBASE|ISMAGNET|PHONE|ADDRNUMBER|ADDRPREFIX|ADDRROOT|#ADDRTYPE|ADDRSUFFIX|ADDRCITY|ADDRZIPCOD|SPED|STATUS|NODEID|CAPACITYTO|ESL|BOARDDIS2|PROJ_CAP|NOTES
#4|368|CARY|CARY HIGH|2287|4||H|||T|||4603549|638||Walnut St|||Cary|27511||H|370.2|2254|Y|9|2302|15
#7|316|APEX|APEX HIGH|1639|20||H|||T|||3872208|1501||Laura Duncan Rd|||Apex|27502||H|386.0|2119|Y|8|2119|
#11|318|ATHENS DR|ATHENS DRIVE HIGH|1735|7||H|||T|||2334050|1420||Athens Dr|||Raleigh|27606||H|136.0|1792|Y|5|1792|
#...

#Vamos a generar el mapa del municipio. Empezamos con v.extract
v.extract boundary_municp output=Cary where="MB_NAME = 'Cary'" --o

#Se ajusta la región a solamente esta zona
g.region vect=Cary

#Generamos un mapa de centros de enseñanza superior
v.extract schools_wake output=HighSchool where="GLEVEL = 'H'" --o

#Después generamos el buffer de municipio Cary
v.buffer Cary output=influencia type=boundary,centroid,area distance=2000 --o


#Creamos un mapa de High Schools en área de influencia con v.select para recortar el mapa de colegios a la zona del buffer
v.select ainput=HighSchool atype=point binput=influencia btype=area output=HS_Cary operator=overlap --o

#Generamos mapa de calles
v.select ainput=streets_wake atype=line binput=influencia btype=area output=calles_Cary operator=overlap --o

#Creamos una copia de calles que contenga conexiones a los colegios
v.net calles_Cary points=HS_Cary output=calles operation=connect alayer=1 nlayer=2 thresh=500 --o

#Se puede comprobar que se han añadido los colegios
v.category calles op=report

#Añadimos coste a las calles calculando el tiempo que tardamos en recorrerlas. Se añade una nueva columna con el valor
v.db.addcol map=calles layer=1 columns="tiempo DOUBLE PRECISION"
v.db.update calles layer=1 col=tiempo val="SHAPE_LEN/SPEED"

#Por último resolvemos el problema del viajante de comercio
v.category calles op=print layer=2
#Resultado
#4
#7
#49
#91
#101


#Usamos los valores resultantes anteriores en la orden v.net.salesman(viajante de comercio)
v.net.salesman calles output=ruta type=line,boundary alayer=1 nlayer=2 acolumn=tiempo ccats=4,7,49,91,101 --o


#Iniciamos la ventana para visualizar el mapa
d.mon x0

#Mostramos las calles de Cary
d.vect calles color=cyan
#Mostramos la ruta calculada
d.vect ruta color=green width=3
#Mostramos los colegios
d.vect HS_Cary -c display=shape type=point,line,boundary,area color=red width=4 icon=basic/circle attrcol='TAG' llayer=1 layer=1 lsize=8

#Transformamos los mapas a ráster para realizar cambios en 
v.to.rast ruta output=callesFinal use=cat --o
v.to.rast HS_Cary output=caryFinal use=cat --o

#Reclasificamos los valores para añadir nombres
r.reclass input=callesFinal output=callesRec --o <<END_RECLASS
1 = 1 ruta
end
END_RECLASS

r.reclass input=caryFinal output=caryRec --o <<END_RECLASS
4 = 4 Colegios
end
END_RECLASS

#Añadimos el color para crear la leyenda de los dos mapas
r.colors callesRec color=rules <<END_COLORS
1 green
end
END_COLORS

r.colors caryRec color=rules <<END_COLORS
4 red
end
END_COLORS

#Añadimos la barra de escala
d.barscale tcolor=0:0:0 bcolor=255:255:255 at=2,95

#Creamos la barra lateral derecha para mostrar la leyenda
d.frame -c frame=lateral at=70,100,80,100
d.legend caryRec -c at=90,70,10,20
d.legend callesRec -c at=80,60,10,20




