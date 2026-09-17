# ==============================================================================
# CLASE 6: MANIPULACIÓN DE DATOS EN R - EDA CON DPLYR
# ==============================================================================
# Base de Datos: Encuesta Multipropósito de Bogotá 2021 (SDP)
# Profesor : Santiago Neira
# Objetivos:
# - Aplicar los verbos básicos de dplyr (select, mutate, filter, arrange)
#   sobre una base de datos real
# - Agrupar y resumir datos con group_by() + summarise()
# - Encadenar transformaciones de forma legible con el operador pipe (%>%)
# - Transformar datos entre formato ancho y largo (pivot_longer / pivot_wider)
# - Combinar tablas con joins (left_join)
# - Exportar resultados a CSV y Excel
# ==============================================================================


# ==============================================================================
# CONFIGURACIÓN INICIAL DEL AMBIENTE
# ==============================================================================

# install.packages("dplyr")     # solo la primera vez
# install.packages("tidyr")     # solo la primera vez
# install.packages("readr")     # solo la primera vez
# install.packages("openxlsx")  # solo la primera vez

library(dplyr)
library(tidyr)
library(readr)
library(openxlsx)


# ==============================================================================
# DIRECTORIO DE TRABAJO Y CARGA DE DATOS
# ==============================================================================

username <- Sys.getenv("USERNAME")     # usuario del sistema

# CUIDADO: esta ruta es la de la carpeta de Santiago. Cada quien debe
# ajustarla a la ubicación de SU carpeta "Datos/Datos Clase 5" en su computador.
ruta_dinamica <- paste0("C:/Users/", username,
                        "/OneDrive - Universidad de los andes/2026 - 2/Taller de R 2026 20/Datos/Datos Clase 6")
setwd(ruta_dinamica)

em_bogota <- read_csv("em_bogota.csv")

# Un vistazo rápido (str(), dim() y head() ya se vieron en la Clase 4)
str(em_bogota)
cat("Dimensiones de la base de datos:", dim(em_bogota), "\n")


# ==============================================================================
# EXPLORACIÓN GEOGRÁFICA Y LIMPIEZA BÁSICA
# ==============================================================================

# ---------- Cobertura geográfica ----------
unique(em_bogota$LOCALIDAD)
length(unique(em_bogota$UPZ))

# ---------- Tabla de frecuencias por localidad ----------
tabla_localidades <- table(em_bogota$LOCALIDAD)
freq_localidades <- data.frame(
  LOCALIDAD = names(tabla_localidades),
  FRECUENCIA = as.numeric(tabla_localidades),
  PORCENTAJE = round(as.numeric(prop.table(tabla_localidades)) * 100, 2)
)

freq_ordenado<-arrange(freq_localidades, desc(FRECUENCIA))

head(freq_ordenado, 10)

# ---------- Quitar registros sin localidad ----------
# complete.cases() ya se vio en la Clase 4; aquí lo aplicamos sobre una sola columna
em_bogota <- em_bogota[complete.cases(em_bogota$LOCALIDAD), ]


# ==============================================================================
# SELECCIÓN DE VARIABLES (select)
# ==============================================================================

# select() elige columnas por nombre, sin usar índices como df[, c(...)]
variables_vivienda <- select(em_bogota,
                             ID_VIVIENDA, LOCALIDAD, VIA_ACCESO, ESTADO_VIA,
                             ANDEN, NUM_PISOS, ASCENSOR, TIPO_VIVIENDA,
                             MATERIAL_PAREDES, MATERIAL_PISOS, FACTOR_EXPANSION)

head(variables_vivienda, 5)


# ==============================================================================
# CREACIÓN DE VARIABLES DERIVADAS (mutate)
# ==============================================================================

# ---------- Indicador: ¿tiene algún problema estructural? ----------
em_bogota <- mutate(em_bogota,
                    ALGUN_PROBLEMA_ESTRUCTURA = ifelse(
                      PROBLEMA_HUMEDAD_PAREDES == 1 | PROBLEMA_GOTERAS == 1 |
                        PROBLEMA_GRIETAS_PAREDES == 1 | PROBLEMA_TUBERIAS == 1 |
                        PROBLEMA_GRIETAS_PISO == 1 | PROBLEMA_TECHO == 1 |
                        PROBLEMA_VENTILACION == 1,
                      "Sí tiene problemas", "No tiene problemas"))

# ---------- Índice: cuántos problemas estructurales tiene ----------
em_bogota <- mutate(em_bogota,
                    PROBLEMAS_ESTRUCTURA = (PROBLEMA_HUMEDAD_PAREDES == 1) + (PROBLEMA_GOTERAS == 1) +
                      (PROBLEMA_GRIETAS_PAREDES == 1) + (PROBLEMA_TUBERIAS == 1) +
                      (PROBLEMA_GRIETAS_PISO == 1) + (PROBLEMA_TECHO == 1) +
                      (PROBLEMA_VENTILACION == 1))

# ---------- Índice: riesgos del entorno ----------
em_bogota <- mutate(em_bogota,
                    RIESGOS_ENTORNO = (RIESGO_INUNDACION == 1) + (RIESGO_DERRUMBE == 1) + (RIESGO_HUNDIMIENTO == 1))

# ---------- Indicador: servicios públicos completos ----------
em_bogota <- mutate(em_bogota,
                    SERVICIOS_COMPLETOS = ifelse(SERVICIO_ENERGIA == 1 & SERVICIO_ACUEDUCTO == 1 &
                                                   SERVICIO_ALCANTARILLADO == 1 & SERVICIO_BASURAS == 1,
                                                 "Servicios Completos", "Servicios Incompletos"))

# ---------- Recodificar tipo de vivienda con etiquetas (case_when) ----------
em_bogota <- mutate(em_bogota,
                    TIPO_VIVIENDA = case_when(
                      TIPO_VIVIENDA == 1 ~ "Casa",
                      TIPO_VIVIENDA == 2 ~ "Apartamento",
                      TIPO_VIVIENDA == 3 ~ "Cuarto(s)",
                      TIPO_VIVIENDA == 4 ~ "Otro tipo",
                      TRUE ~ "No especificado"))


# ==============================================================================
# FILTRADO DE DATOS (filter)
# ==============================================================================

# filter() selecciona FILAS según una condición (equivalente dplyr de df[cond, ])
viviendas_problemas <- filter(em_bogota, PROBLEMAS_ESTRUCTURA > 3)
cat("Viviendas con más de 3 problemas estructurales:", nrow(viviendas_problemas), "\n")

viviendas_servicios_completos <- filter(em_bogota, SERVICIOS_COMPLETOS == "Servicios Completos")
cat("Viviendas con servicios completos:", nrow(viviendas_servicios_completos), "\n")

em_bogota <- filter(em_bogota, !is.na(LOCALIDAD))


# ==============================================================================
# AGRUPACIÓN Y RESÚMENES ESTADÍSTICOS (group_by + summarise)
# ==============================================================================

# ---------- Un solo grupo ----------

# Paso 1: agrupar (todavía no calcula nada, solo "etiqueta" el data frame)
datos_agrupados <- group_by(em_bogota, LOCALIDAD)
class(datos_agrupados)     # sigue siendo un data frame, pero agrupado
n_groups(datos_agrupados)  # número de localidades únicas

# Paso 2: calcular estadísticas por grupo
resumen_simple <- summarise(datos_agrupados,
                            total_viviendas = n(),
                            promedio_pisos = mean(NUM_PISOS, na.rm = TRUE))
head(resumen_simple, 8)

# Paso 3: un resumen más completo, ordenado
resumen_completo <- summarise(datos_agrupados,
                              total_viviendas = n(),
                              promedio_pisos = round(mean(NUM_PISOS, na.rm = TRUE), 2),
                              max_pisos = max(NUM_PISOS, na.rm = TRUE),
                              viviendas_con_ascensor = sum(ASCENSOR == 1, na.rm = TRUE))

head(arrange(resumen_completo, desc(total_viviendas)), 10)

# ---------- Dos grupos a la vez ----------

datos_multi_grupo <- group_by(em_bogota, LOCALIDAD, TIPO_VIVIENDA)
n_groups(datos_multi_grupo)   # muchos más grupos: cada combinación localidad x tipo

resumen_multi <- summarise(datos_multi_grupo,
                           conteo = n(),
                           promedio_pisos = round(mean(NUM_PISOS, na.rm = TRUE), 1),
                           total_con_ascensor = sum(ASCENSOR == 1, na.rm = TRUE))

# Filtrar solo combinaciones con suficientes casos (promedio de pisos >= 5)
resumen_multi_filtrado <- filter(resumen_multi, promedio_pisos >= 5)
resumen_multi_ordenado <- arrange(resumen_multi_filtrado, desc(promedio_pisos))
head(resumen_multi_ordenado, 10)


# ==============================================================================
# EL OPERADOR PIPE (%>%)
# ==============================================================================
# El pipe encadena pasos sin crear un objeto intermedio por cada uno:
#   datos %>% función()   es equivalente a   función(datos)
#
# Forma tradicional:
#   resultado <- función3(función2(función1(datos)))
# Con pipe:
#   resultado <- datos %>%
#     función1() %>%
#     función2() %>%
#     función3()

# ---------- El mismo resumen de arriba (localidad x tipo), ahora con pipe ----------
resumen_multi_pipe <- em_bogota %>%
  group_by(LOCALIDAD, TIPO_VIVIENDA) %>%
  summarise(
    conteo = n(),
    promedio_pisos = round(mean(NUM_PISOS, na.rm = TRUE), 1),
    total_con_ascensor = sum(ASCENSOR == 1, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(promedio_pisos > 5) %>%
  arrange(desc(promedio_pisos))

head(resumen_multi_pipe, 10)

# ---------- Un resumen nuevo por localidad, todo en un solo pipe ----------
resumen_localidad <- em_bogota %>%
  group_by(LOCALIDAD) %>%
  summarise(
    TOTAL_VIVIENDAS = n(),
    PROMEDIO_PROBLEMAS = round(mean(PROBLEMAS_ESTRUCTURA, na.rm = TRUE), 2),
    PORCENTAJE_SERVICIOS_COMPLETOS = round(mean(SERVICIOS_COMPLETOS == "Servicios Completos", na.rm = TRUE) * 100, 2),
    PROMEDIO_PISOS = round(mean(NUM_PISOS, na.rm = TRUE), 2),
    PROMEDIO_RIESGOS = round(mean(RIESGOS_ENTORNO, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(TOTAL_VIVIENDAS))

head(resumen_localidad, 10)


# ==============================================================================
# WIDE A LONG (pivot_longer)
# ==============================================================================
# Datos WIDE: una columna por variable (ENTORNO_RUIDO, ENTORNO_INSEGURIDAD, ...)
# Datos LONG: una fila por cada observación-variable (más fácil de agrupar)

datos_entorno_long <- em_bogota %>%
  select(LOCALIDAD, TIPO_VIVIENDA, starts_with("ENTORNO_")) %>%
  pivot_longer(
    cols = starts_with("ENTORNO_"),
    names_to = "TIPO_PROBLEMA",
    values_to = "PRESENTE"
  ) %>%
  filter(PRESENTE == 1)

head(datos_entorno_long, 10)

# Problemas del entorno más frecuentes por localidad
problemas_frecuentes <- datos_entorno_long %>%
  group_by(LOCALIDAD, TIPO_PROBLEMA) %>%
  summarise(FRECUENCIA = n(), .groups = "drop") %>%
  arrange(LOCALIDAD, desc(FRECUENCIA))

head(problemas_frecuentes, 15)


# ==============================================================================
# PEGUE DE BASES DE DATOS (JOINS)
# ==============================================================================
# Un join combina dos tablas usando una "llave" común (aquí: LOCALIDAD)

resumen_basico <- em_bogota %>%
  group_by(LOCALIDAD) %>%
  summarise(
    TOTAL_VIVIENDAS = n(),
    PROMEDIO_PISOS = round(mean(NUM_PISOS, na.rm = TRUE), 1),
    PORCENTAJE_CON_ASCENSOR = round(mean(ASCENSOR == 1, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  )

calidad_localidad <- em_bogota %>%
  group_by(LOCALIDAD) %>%
  summarise(
    PORCENTAJE_CON_PROBLEMAS = round(mean(ALGUN_PROBLEMA_ESTRUCTURA == "Sí tiene problemas", na.rm = TRUE) * 100, 1),
    PROMEDIO_PROBLEMAS = round(mean(PROBLEMAS_ESTRUCTURA, na.rm = TRUE), 1),
    .groups = "drop"
  )

# left_join: conserva TODAS las filas de resumen_basico, pega lo que encuentre
consolidado <- resumen_basico %>%
  left_join(calidad_localidad, by = "LOCALIDAD")

head(consolidado, 8)


# ==============================================================================
# LONG A WIDE (pivot_wider)
# ==============================================================================

comparativo_vivienda <- em_bogota %>%
  filter(!is.na(TIPO_VIVIENDA)) %>%
  group_by(LOCALIDAD, TIPO_VIVIENDA) %>%
  summarise(PROMEDIO_PISOS = round(mean(NUM_PISOS, na.rm = TRUE), 1), .groups = "drop") %>%
  pivot_wider(
    names_from = TIPO_VIVIENDA,
    values_from = PROMEDIO_PISOS,
    names_prefix = "Pisos_"
  )

head(comparativo_vivienda, 8)


# ==============================================================================
# EXPORTAR RESULTADOS
# ==============================================================================

write.csv(consolidado, "resumen_consolidado_localidades.csv", row.names = FALSE)
write.csv(comparativo_vivienda, "comparativo_tipos_vivienda.csv", row.names = FALSE)

write.xlsx(list(
  "Resumen_Localidades" = consolidado,
  "Comparativo_Viviendas" = comparativo_vivienda
), "Analisis_EM_Simplificado.xlsx")

cat("Archivos exportados: resumen_consolidado_localidades.csv,",
    "comparativo_tipos_vivienda.csv, Analisis_EM_Simplificado.xlsx\n")
