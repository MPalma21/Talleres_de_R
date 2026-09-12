# ==============================================================================
# TALLER 2 - TALLER DE PROGRAMACIÓN EN R
# Grupo 10
# ==============================================================================

# REQUISITOS GENERALES ---------------------------------------------------------

# El script debe estar organizado por puntos y subpuntos y debe ejecutarse
# completamente desde una sesión limpia de R.

# Debe utilizar una única ruta base declarada al inicio. Todo el código deberá
# funcionar modificando únicamente esa ruta.

# Los microdatos deben estar organizados en las carpetas GEIH_2023, GEIH_2024
# y EMICRON_2024. Solo deben utilizarse los archivos CSV y no deben cambiarse
# sus nombres.

# La carpeta outputs debe contener todas las tablas y gráficas exportadas desde
# R. Los nombres de los archivos deben corresponder al numeral del taller.

# Limpiar ambiente
rm(list = ls())

# Librerías
library(here)
library(dplyr)
library(readr)


# RUTAS DE CARPETAS

ruta_geih_2023 <- here("GEIH_2023")
#ruta_geih_2024 <- here("GEIH_2024")
#ruta_emicron_2024 <- here("EMICRON_2024")
#ruta_outputs <- here("outputs")

# 1. CONFORMACIÓN Y UNIÓN DE LAS BASES DE DATOS --------------------------------

# here() identifica automáticamente la raíz del proyecto
ruta <- here()

# Verificar la ruta
print(ruta)

# 1.1. PEGUE DE LAS BASES DE DATOS DE LA GEIH

# Crear un loop que una los módulos mensuales de la GEIH de enero a diciembre
# para 2023 y 2024.

# Utilizar como módulo base "Características generales, seguridad social en
# salud y educación" y pegar los módulos de fuerza de trabajo, ocupados y no
# ocupados.

# Utilizar como llave las variables DIRECTORIO, SECUENCIA_P y ORDEN.

# Verificar que la llave de persona no tenga registros duplicados en ninguno de
# los módulos.

# Verificar que ningún pegue aumente el número de registros del módulo base.

# Implementar una estrategia eficiente de importación, procesamiento y unión
# utilizando únicamente las herramientas trabajadas en clase.

# Explicar en el documento el significado de la llave, las generalidades de la
# GEIH, la lógica del loop y la estrategia utilizada para manejar los datos.

# 1.2. DESCRIPCIÓN GENERAL DE LOS DATOS

# Crear una tabla para la GEIH 2024 que incluya el tamaño total de la muestra de
# cada mes, el total anual y el número de observaciones de los módulos de
# características generales, fuerza de trabajo, ocupados y no ocupados.

# Explicar las diferencias en el número de observaciones y verificar que sean
# coherentes con las definiciones de PET, fuerza de trabajo, ocupados y
# desocupados.

# 1.3. CONSTRUCCIÓN Y DOCUMENTACIÓN DE LA BASE ANALÍTICA

# Conservar dentro del loop únicamente las siguientes variables:

# a. Características generales:
# DIRECTORIO, SECUENCIA_P, ORDEN, PERIODO, MES, P3271, P3042, P6090,
# P6040, P6160, DPTO, AREA, CLASE, FEX_C18 y PT.

# b. Fuerza de trabajo:
# PET, FT, FFT y P6240.

# c. Ocupados:
# OCI, RAMA2D_R4, P6430 e INGLABO.

# d. No ocupados:
# DSI.

# e. Identificar y conservar las variables necesarias para construir la
# variable de formalidad requerida en el punto 2.3.

# Crear la variable ANIO a partir de PERIODO.

# Verificar mediante código que la base final contenga únicamente las variables
# solicitadas, las variables requeridas para formalidad y ANIO.

# Construir en el documento un diccionario con variable, módulo de origen,
# descripción y categorías o unidad de medida para las variables de los
# literales a, b, c y d.

# Crear etiquetas interpretables para las categorías utilizadas en las tablas y
# gráficas posteriores.

# Explicar la diferencia conceptual entre DPTO, AREA y CLASE.

# 1.4. INCORPORACIÓN DE LA EMICRON 2024 Y UNIÓN CON LA GEIH

# a. Construcción de la base EMICRON.
# Importar los módulos de identificación, características del micronegocio,
# inclusión financiera y ventas o ingresos. Unirlos mediante DIRECTORIO,
# SECUENCIA_P y SECUENCIA_ENCUESTA. Verificar la calidad de la base resultante.

# b. Documentación de la relación entre las encuestas.
# Explicar cómo se selecciona la muestra EMICRON a partir de la GEIH, cuál es la
# población elegible, su cobertura geográfica, el papel de F_EXP y el período de
# referencia de la EMICRON.

# c. Identificación de la persona y relación temporal.
# Determinar empíricamente la relación entre SECUENCIA_ENCUESTA de EMICRON y
# ORDEN de GEIH. Comparar MES_REF y MES considerando el mismo mes, un mes hacia
# atrás y un mes hacia adelante. Presentar una tabla con las coincidencias.

# MES_REF y MES no deben incorporarse a la llave del pegue. No deben construirse
# llaves artificiales ni descartarse observaciones para aumentar la
# correspondencia.

# d. Pegue de las encuestas.
# Unir EMICRON con la GEIH 2024 utilizando únicamente las variables que
# identifican a la persona. Llamar base_micro a la base resultante.

# Verificar que el pegue no aumente las filas de EMICRON. Reportar el número y
# porcentaje de registros EMICRON que encontraron contraparte en GEIH.

# e. Validación de la calidad del pegue.
# Comparar P35 con P3271, P241 con P6040 y CLASE_TE con CLASE. Reportar el
# porcentaje de coincidencia de cada comparación.

# f. Auditoría del pegue.
# Construir una tabla por mes con registros EMICRON, registros emparejados,
# porcentaje de correspondencia y registros no emparejados.

# Explicar en máximo 200 palabras la razón estructural por la cual un subconjunto
# de EMICRON no puede tener contraparte en los archivos GEIH 2024 y
# cuantificarlo. Describir también la relación observada entre MES_REF y MES.

# g. Interpretación.
# Construir la distribución de P6430 en la GEIH para las personas que EMICRON
# identifica como propietarias de un micronegocio. Interpretar el resultado en
# máximo 150 palabras.

# 2. CONSTRUCCIÓN DE INDICADORES DE MERCADO LABORAL ----------------------------

# 2.1. TASAS Y POBLACIONES

# Construir dos tablas, una para hombres y otra para mujeres, con información
# trimestral de 2023 y 2024 para el total nacional.

# Incluir TGP, TO, TD, población total, PET, fuerza de trabajo, población
# ocupada y población desocupada.

# Expandir los datos con FEX_C18. Para poblaciones promedio trimestrales, dividir
# el factor de expansión entre tres.

# Verificar la consistencia entre fuerza de trabajo, población ocupada y
# población desocupada.

# Exportar las tablas como:
# 2_1_tasas_hombres.xlsx
# 2_1_tasas_mujeres.xlsx

# 2.2. ANÁLISIS DE LAS TASAS DE MERCADO LABORAL

# Crear una serie de tiempo con TGP, TO y TD para el total nacional según sexo.
# Utilizar paneles o facetas y diferenciar hombres y mujeres.

# Incluir título, colores, marcadores, etiquetas, leyenda, ejes, fuente y
# período. Interpretar las tasas, las brechas por sexo y el origen de la
# variación de la tasa de desempleo.

# Exportar el gráfico como:
# 2_2_tasas_sexo.png

# 2.3. POBLACIÓN OCUPADA SEGÚN FORMALIDAD

# Adaptar a R el código del DANE del anexo de Empleo informal y seguridad social
# para construir EI, donde EI = 1 representa población formal y EI = 0 población
# informal.

# Crear un gráfico de torta con la distribución porcentual de personas ocupadas
# formales e informales según sexo, para diciembre de 2024 y el total de las 13
# ciudades y áreas metropolitanas.

# Expandir los resultados con FEX_C18 y comparar las cifras con las publicadas
# por el DANE.

# Exportar el gráfico como:
# 2_3_formalidad_13ciudades.png

# 2.4. POBLACIÓN OCUPADA SEGÚN POSICIÓN OCUPACIONAL

# Crear un gráfico de barras horizontales para enero de 2023 con la distribución
# de personas ocupadas según P6430, para el total nacional, hombres y mujeres.

# Utilizar OCI, P6430 y P3271. Expandir con FEX_C18 y calcular las proporciones
# dentro de cada grupo, de manera que cada uno sume 100 %.

# Ordenar las posiciones ocupacionales de mayor a menor e incluir título,
# leyenda y etiquetas porcentuales.

# Interpretar la proporción conjunta de trabajadores por cuenta propia y
# patrones o empleadores.

# Exportar el gráfico como:
# 2_4_posicion_nacional.png

# 3. CARACTERIZACIÓN DE LOS MICRONEGOCIOS EN COLOMBIA --------------------------

# 3.1. INDICADORES BÁSICOS DE LOS MICRONEGOCIOS

# Construir para el total nacional de 2024:
# - Número total de micronegocios.
# - Distribución por GRUPOS12.
# - Distribución según sexo del propietario, P35.
# - Porcentaje con RUT, P1633.
# - Porcentaje registrado ante Cámara de Comercio, P1055.

# Expandir con F_EXP y comparar los resultados con el boletín técnico de la
# EMICRON 2024.

# Exportar la tabla como:
# 3_1_indicadores.xlsx

# 3.2. INCLUSIÓN FINANCIERA DE LOS MICRONEGOCIOS

# Construir el porcentaje expandido de micronegocios que acepta cada forma de
# pago, P1764_1 a P1764_7, desagregado por GRUPOS4.

# Resolver las siete variables mediante un loop o una función de la familia
# apply, sin repetir siete veces el mismo bloque de código.

# Crear un gráfico de barras apiladas o agrupadas. Relacionar los resultados con
# la solicitud de crédito, P1765, y el ahorro, P3014. Interpretar en máximo 200
# palabras.

# Exportar el gráfico como:
# 3_2_formas_pago.png

# 3.3. ANÁLISIS CONJUNTO GEIH - EMICRON

# Formular una pregunta que solamente pueda responderse mediante base_micro.

# Cruzar al menos una variable exclusiva de la GEIH con una variable de la
# EMICRON.

# Presentar una tabla de contingencia o de estadísticas descriptivas y un
# gráfico autocontenido.

# Indicar el factor de expansión utilizado, justificar su elección y delimitar
# el universo y el período representado. No mezclar FEX_C18 y F_EXP en un mismo
# indicador.

# Presentar conclusiones descriptivas y mencionar al menos dos explicaciones no
# causales cuando se encuentre una asociación fuerte.

# Exportar el gráfico como:
# 3_3_cruce.png

# 4. ANÁLISIS SOCIOECONÓMICO DE LA POBLACIÓN COLOMBIANA ------------------------

# Seleccionar variables adicionales y crear tres gráficos para 2024.

# Utilizar tres tipos de gráficos distintos entre sí y distintos de las series
# de tiempo con paneles, barras horizontales, tortas y barras apiladas o
# agrupadas utilizadas anteriormente.

# Utilizar tres conjuntos distintos de variables.

# Incluir al menos un gráfico con desagregación geográfica inferior al nivel
# nacional.

# Incluir al menos un gráfico con una variable porcentual.

# Construir al menos un gráfico a partir de base_micro o EMICRON.

# Presentar para cada gráfico un análisis de máximo 150 palabras.

# Exportar los gráficos con nombres que comiencen por:
# 4_1_
# 4_2_
# 4_3_
