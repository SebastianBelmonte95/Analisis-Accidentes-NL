-- DROP TABLE accidents
CREATE TABLE accidents(
	id VARCHAR(10) UNIQUE NOT NULL,
	latitude NUMERIC,
	longitude NUMERIC,
	zip_code TEXT,
	street TEXT,
	neighbourhood TEXT,
	cause TEXT,
	vehicle_type TEXT,
	color TEXT,
    model TEXT,
	damage TEXT,
    punto_impacto TEXT,
	_year INT,
	_month INT,
	_day INT,
	weekday TEXT,
	_hour INT,
	state TEXT,
	city TEXT,
	_date DATE NOT NULL
)

-- Importing state information data
 COPY accidents(id,
				latitude,
				longitude,
				zip_code,
			    street,
				neighbourhood,
				cause,
				vehicle_type,
				color,
				model,
				damage,
				punto_impacto,
				_year,
				_month,
				_day,
				weekday,
				_hour,
				state,
				city,
				_date) 
 FROM 'mty_car_accidents.csv' 
 DELIMITER ',' 
 CSV HEADER;

-- Limpamos la base de datos de registros anómalos o incompletos
UPDATE accidents
SET color = UPPER(color),
street = UPPER(street),
neighbourhood = UPPER(neighbourhood)
------------
UPDATE accidents
SET color = 'BLANCO'
WHERE color like '%BLANC%' OR color LIKE '%B%CO%'
------------
UPDATE accidents
SET color = 'GRIS'
WHERE color like '%GRIS%' OR color LIKE 'GRSIS'
------------
UPDATE accidents
SET color = 'ROJO'
WHERE color like '%ROJ%'
------------
UPDATE accidents
SET color = 'AMARILLO'
WHERE color like '%AMA%'
------------
UPDATE accidents
SET color = 'AZUL'
WHERE color like '%AZ%'
------------
UPDATE accidents
SET color = 'GUINDA'
WHERE color like '%GUIN%'
------------
UPDATE accidents
SET color = 'VERDE'
WHERE color like '%VER%'
------------
UPDATE accidents
SET zip_code = '64000' where neighbourhood = 'CENTRO'
------------
DELETE FROM accidents WHERE 
	latitude IS NULL OR
	longitude IS NULL OR
	vehicle_type NOT IN ('Auto','Camión','Camión Ligero','Motocicleta') OR
	damage NOT IN ('Sin daño','Bajo','Medio','Alto') OR
	zip_code NOT LIKE '6____' OR
	latitude NOT BETWEEN 23 AND 28 OR
	longitude NOT BETWEEN -102 AND -98 OR
	color IS NULL;
	
-- Se limpió la base de datos y de eliminaron 5862 registros incompletos o fuera de los parámetros aceptables quedando 37568

-- Exportar nueva tabla al archivo CSV
COPY (SELECT * FROM accidents) TO 'Prueba\clean_db.csv' CSV HEADER;

-- 1. Desarrollar y mostrar evidencia de un diagnóstico general de la base de datos
-- La base de datos contenía un total de 5862 registros incompletos o bien con coordenadas totalmente equívocas, por ejemplo en Lima, Perú, Ciudad de México, el océano pacífico, entre otros. Se lidió con los registros no útiles y se redujo la base de datos a 37568 registros. Además de ello, en la categoría 'Color' existen muchos registros con abreviaciones, combinaciones de colores, colores por tonalidad y combinaciones de letras y números. A pesar de que es posible filtrar esos registros o bien, cambiar los valores de las celdas con valores poco usuales, únicamente se realizó una reasignación de valores a los colores más comunes y relevantes para nuestro estudio.
-- El promedio de accidentes por día en el intervalo de tiempo estudiado es de 41.22. MAX 123, MIN 2

-- 2. ¿En qué códigos postales se generan más choques? 64000 (5681), 64620 (2678), 64590 (2392)

SELECT zip_code,COUNT(*) FROM accidents
GROUP BY zip_code
ORDER BY COUNT(*) DESC

-- 3. ¿Existen temporalidades de choques?
SELECT _hour,count(*) FROM accidents
GROUP BY _hour
ORDER BY count(*) DESC

-- Entre las 12:00 y las 19:00 existe una mayor probabilidad de accidentarse. Existen picos locales de 8 a 9, de 13 a 14 y a las 18hrs. Es posible inferir esto debido a que son horarios pico y hay una movilidad significativamente mayor que en otros horarios. Analicemos ahora día a día. 
SELECT weekday,COUNT(*) FROM accidents
GROUP BY weekday
ORDER BY COUNT(*) DESC
-- Como era de esperarse, los días viernes existe una cantidad mayor de accidentes, sin embargo, de manera poco intuitiva, el sábado es uno de los días con menos sinisestros. Ahondemos un poco más:
SELECT _day,COUNT(*) FROM accidents
GROUP BY _day
ORDER BY COUNT(*) DESC
-- El día 15 de cada mes tiene una alta incidencia de accidentes, junto con el 23 y el 4, pero contrario a lo esperado, los días primero, 31 y 30  presentan bajas incidencias.

SELECT _year,COUNT(*)-- / COUNT(DISTINCT _date) AS avg_per_day
FROM accidents
Group by _year
ORDER BY _year
-- Existe una tendencia bajista en el promedio de accidentes diarios. 2016: 47, 2017: 37, 2018: 35
-- Esto mismo repercute en la cantidad de accidentes anuales: 2016 - 17439, 2017 - 13784, 2018 - 6345 (6 meses)

-- 4. ¿Hay alguna diferencia significativa en el tipo de vehículo?
SELECT vehicle_type,COUNT(*) FROM accidents
GROUP BY vehicle_type
ORDER BY COUNT(*) DESC
-- Como es de notar, los Autos (que se entienden como personales/familiares) son los que tienen más accidentes.
-- Esta conclusión es obvia considerando la proporcion de los mismos respecto a vehículos de carga y transporte
-- público. En Julio de 2018 existían 2,259,403 vehículos registrados en MTY, de los cuáles 1,617,190 (71.57%)
-- correspondían a vehículos privados y 30,783 a transporte público
-- fuente https://www.elfinanciero.com.mx/monterrey/complicada-la-movilidad-en-la-zona-metropolitana/#:~:text=A%20julio%20de%202018%2C%20el,autom%C3%B3vil%20de%20servicio%20p%C3%BAblico%20estatal.

SELECT vehicle_type,damage,COUNT(*) FROM accidents
GROUP BY vehicle_type,damage
ORDER BY vehicle_type,damage,COUNT(*) DESC

-- Como es de esperar, los vehículos pesados tienen una tasa alta de no daño. Comparando con los Autos, el 60%
-- de ellos tendrá como mínimo un nivel de daño bajo si se ve involucrado en un siniestro.


-- 5. ¿Algún color de auto es más propenso a chocar? De evidencia de su respuesta
SELECT UPPER(color),COUNT(*) FROM accidents
GROUP BY UPPER(color)
ORDER BY COUNT(*) DESC

-- EL 32% de los accidentes registrados involucran un vehículo color blanco con al menos 12362 casos,
-- mientras que los vehículos grises se encuentran en segunda posición con 7534 casos representando el 20%

-- 6. ¿Qué gráficos serían más efectivos para comunicar estadísticas de choques a un asegurador de coches y por qué?
-- Magnitud de daño vs tipo de vehículo
-- Frecuencia de accidente vs tipo de vehículo
-- Heatmap de accidentes en la región
-- Color del vehículo vs cantidad de accidentes

-- 7. ¿Si pudieras cruzar estos datos con otras bases con cuál sería y por qué?
-- Una base de datos que disponga de las edades de los siniestrados, la magnitud detallada del siniestro (que tipo de lesiones se contraen, que tipo de daño hubo a los vehículos) el estado de seguro de los automóviles y personas sinisetradas, registro de vehículos en el estado, gastos incurridos por accidente, categorización por precio de refacciones por modelo de auto, clima por fecha / hora.

-- 8. ¿Cuáles son hipótesis de choques en Nuevo León que podrías generar y validar?

-- Uno de cada 3 accidentes involucra un automotor blanco. Considerando la temporalidad diaria de los accidentes, es probable que la reflexión de la luz solar en los vehículos blancos deslumbre a otros conductores y pueda generar un siniestro.

-- Ligado a la cantidad de vehículos registrados por tipo, es mucho más probable que al existir un accidente, éste involucre un auto familiar o privado

-- La zona centro de la metrópoli es la que tiene el record de mayor cantidad de accidentes por unidad de área como se puede validar en el heatmap provisto. La avenida más accidentada es Dr. José Eleuterio González, particularmente en intersecciones.

-- Con fines estadísticos, es deseable contar con información más detallada de cada caso. Así podría calcularse la probabilidad de verse involucrado en un accidente según el tipo de auto, y otros indicadores demográficos.
