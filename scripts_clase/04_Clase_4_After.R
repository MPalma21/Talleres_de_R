# ==============================================================================
# CLASE 4: MANIPULACIÓN DE DATOS EN R
# ==============================================================================
# Profesor : Santiago Neira
# Objetivos:
# - Crear y manipular data frames en R
# - Examinar la estructura y características de conjuntos de datos
# - Gestionar valores faltantes (NA) de manera efectiva
# - Reordenar y filtrar datos según diferentes criterios
# - Aplicar funciones estadísticas usando la familia apply
# - Trabajar con diferentes formatos de archivos (CSV, Excel, TXT)
# - Realizar análisis exploratorio de datos básico
#


# ==============================================================================
# CREACIÓN DE DATA FRAMES
# ==============================================================================
# Un data frame es una tabla / estructura bidimensional en la que:
# - Cada columna puede tener un tipo distinto (numérico, character, factor...)
# - Todas las columnas tienen el mismo número de filas
# - Cada columna tiene un nombre único

set.seed(2026)

df <- data.frame(
  letra     = sample(LETTERS[1:10], 1100, replace = TRUE),
  ingreso   = runif(1100, 0, 1000),
  categoria = sample(c("estrato 1", "estrato 2"), 1100, replace = TRUE)
)


# ==============================================================================
# EXAMINANDO LA ESTRUCTURA DEL DATA FRAME
# ==============================================================================

str(df)          # descripción de los datos y sus tipos
names(df)        # nombres de las columnas

head(df, 2)       # primeras observaciones

tail(df)          # últimas observaciones

View(df)          # Nota: esto abre la "vista" de RStudio (no funciona fuera de RStudio)


# ==============================================================================
# REORDENAMIENTO DE DATOS
# ==============================================================================
# Para esto se utiliza order() (sort() ordena valores, order() ordena índices)
?order

# ---------- Ordenar por una columna ----------

# order() devuelve los ÍNDICES que dejarían la columna ordenada
orden_indices <- order(df$ingreso, decreasing = FALSE)
head(orden_indices)

df_ordenado <- df[orden_indices, ]
head(df_ordenado)

# Forma abreviada (equivalente, sin guardar los índices por separado)
df_ordenado_2 <- df[order(df$ingreso), ]

head(df_ordenado_2)

# ---------- Ordenar por múltiples columnas ----------

# Forma sencilla: el signo "-" invierte el orden en columnas NUMÉRICAS

df_multi_orden <- df[order(df$letra, -df$ingreso), ]

head(df_multi_orden)

# Forma general: sirve también con columnas de texto/factor
# (decreasing acepta un vector, uno por columna, con method = "radix")

df_multi_orden_2 <- df[order(df$categoria, df$ingreso,
                             decreasing = c(TRUE, FALSE), method = "radix"), ]
head(df_multi_orden_2)


# ---------- Reordenar columnas ----------

df_ordenado_columnas <- df[  , c(3, 1, 2)]               # por posición
head(df_ordenado_columnas)

df_ordenado_nombre_columnas <- df[, c("categoria", "letra", "ingreso")]  # por nombre
head(df_ordenado_nombre_columnas)

df_cat_letra <-df[,c("categoria","letra")] ## Cuando queremos filtrar columnas 
head(df_cat_letra,2)

# ==============================================================================
# MANEJO DE VALORES FALTANTES
# ==============================================================================

# Introducimos NA's artificialmente para practicar
set.seed(32)

indices_a_reemplazar <- sample(nrow(df), 30)

df$categoria[indices_a_reemplazar] <- NA


head(is.na(df), 20)          # matriz lógica: TRUE donde hay NA

colSums(is.na(df))           # cantidad de NA por columna

colMeans(is.na(df)) * 100    # porcentaje de NA por columna


# ==============================================================================
# MANIPULACIÓN DE NOMBRES DE COLUMNAS Y FILAS
# ==============================================================================

colnames(df)                                  # nombres actuales

colnames(df) <- c("Letter", "Income", "Category")   # cambiar TODOS los nombres

# Ejemplo: cambiar solo UN nombre puntual (la última columna)

nombres_actuales <- colnames(df)

nombres_actuales[length(nombres_actuales)] <- "Estrato"

#es lo mismo que nombres_actuales[3] <- "Estrato"

colnames(df) <- nombres_actuales

# Ejemplo: cambiar la segunda columna por posición

nombres_actuales[2] <- "Ingreso real"
colnames(df) <- nombres_actuales

rownames(df)                                  # nombres de fila actuales (por defecto: "1","2",...)
rownames(df) <- paste0("obs_", 1:nrow(df))    # renombrar filas

df["obs_991", ]                               # acceso por nombre de fila


# ==============================================================================
# TRABAJANDO CON CONJUNTOS DE DATOS INCORPORADOS
# ==============================================================================
# R trae datasets de ejemplo listos para usar. airquality: calidad del aire
# en Nueva York, 1973 (con NA's reales, útil para practicar).

data(airquality)

head(airquality)

colnames(airquality)

colSums(is.na(airquality))

# complete.cases() = TRUE si la fila NO tiene ningún NA

airquality_complete   <- airquality[complete.cases(airquality), ]      # solo filas completas

airquality_incomplete <- airquality[!complete.cases(airquality), ]     # solo filas con algún NA

head(airquality_complete)

colSums(is.na(airquality_complete))

head(airquality_incomplete)

# complete.cases() también acepta un subconjunto de columnas

airquality_nan_ozono     <- airquality[!is.na(airquality$Ozone), ]                       # sin NA en Ozono

airquality_nan_ozono_rad <- airquality[complete.cases(airquality[, c("Ozone", "Solar.R")]), ]  # sin NA en Ozono NI Solar.R

head(airquality_nan_ozono)

head(airquality_nan_ozono_rad)

colMeans(airquality, na.rm = TRUE)


# ==============================================================================
# DIRECTORIO DE TRABAJO Y RUTAS DE ARCHIVOS
# ==============================================================================

getwd()                                # directorio actual

username <- Sys.getenv("USERNAME")     # usuario del sistema

# CUIDADO: esta ruta es la de la carpeta de Santiago. Cada quien debe
# ajustarla a la ubicación de SU carpeta "Datos/Clase_4" en su computador.
ruta_dinamica <- paste0("C:/Users/", username,
                        "/OneDrive - Universidad de los andes/2026 - 2/Taller de R 2026 20/Datos/Datos_clase_4")

setwd(ruta_dinamica)

## Para MAC
getwd()                                # directorio actual
username <- Sys.getenv("USER")         # usuario del sistema (USER en Mac, USERNAME en Windows)

# Opción 1: Si OneDrive está en ~/Library/CloudStorage/ (ubicación típica)
ruta_dinamica <- paste0("~/Library/CloudStorage/OneDrive-Personal/",
                        "2026 - 2/Taller de R 2026 20/Datos/Datos_clase_4")

# Opción 2: Si está sincronizado directamente en tu home directory
ruta_dinamica <- paste0("~/OneDrive - Universidad de los andes/",
                        "2026 - 2/Taller de R 2026 20/Datos/Datos_clase_4")

# Opción 3: Ruta completa (usando ~ que se expande a /Users/tu_usuario)
ruta_dinamica <- paste0(Sys.getenv("HOME"), "/OneDrive - Universidad de los andes/",
                        "2026 - 2/Taller de R 2026 20/Datos/Datos_clase_4")

setwd(ruta_dinamica)


# ==============================================================================
# LECTURA DE DIFERENTES TIPOS DE ARCHIVOS
# ==============================================================================

# ---------- .txt ----------
datos_txt <- read.table("info_clima.txt",
                        header = TRUE,
                        sep = "",                # separador: cualquier espacio en blanco
                        stringsAsFactors = FALSE,
                        na.strings = "NA")

# ---------- .xlsx ----------
#install.packages("openxlsx")  # solo la primera vez

library(openxlsx)

datos_excel <- read.xlsx("info_accidentes.xlsx", sheet = 1)

# ---------- .csv ----------
datos_csv <- read.csv("info_futbol.csv",sep=";")



# ==============================================================================
# FUNCIONES APPLY
# ==============================================================================
# apply() aplica una función a cada fila (MARGIN = 1) o columna (MARGIN = 2)
# de un data frame/matriz.

df_ejemplo <- data.frame(
  x = c(1, 2, 2, 3, 5),
  y = c(4, 4, 6, 7, 8),
  z = c(7, 7, 9, 9, 9)
)

data(airquality)
head(airquality)

apply(df_ejemplo, MARGIN = 2, FUN = function(x) x * 2)   # multiplicar cada columna por 2

apply(df_ejemplo, MARGIN = 2, FUN = summary)              # estadísticas básicas por columna

apply(airquality, MARGIN = 2, FUN = summary)              # lo mismo, sobre datos reales

# lapply() es el equivalente para listas: siempre devuelve una lista
lapply(df_ejemplo, function(x) x * 2)


apply(df_ejemplo, MARGIN = 1, FUN = function(x) x * 2)    # por FILA en vez de columna


# También se pueden aplicar funciones propias
rango_function <- function(x) {
  return(max(x) - min(x))
}

apply(df_ejemplo, MARGIN = 2, rango_function)
df_ejemplo

# ==============================================================================
# TAREA: ANÁLISIS DE DATOS DE CALIDAD DEL AIRE
# ==============================================================================
# Trabajaremos con 'airquality': mediciones diarias de calidad del aire en
# Nueva York durante 5 meses de 1973.
#
# Variables:
# - Ozone: Ozono (ppb)          - Wind: Velocidad del viento (mph)
# - Solar.R: Radiación solar (lang) - Temp: Temperatura (°F)
# - Month: Mes (1-12)           - Day: Día del mes

# ==============================================================================
# EJERCICIOS
# ==============================================================================

# 1. EXPLORACIÓN INICIAL
# 1.1 Carga la base de datos airquality
data(airquality)

# 1.2 Muestra las primeras 6 filas del dataset
# 1.3 Usa str() para ver la estructura de los datos
# 1.4 ¿Cuántas filas y columnas tiene el dataset? (pista: nrow(), ncol())


# 2. VALORES FALTANTES
# 2.1 ¿Cuántos valores NA hay en cada columna?
# 2.2 ¿Qué porcentaje de datos faltantes hay en cada columna?
# 2.3 Crea un nuevo dataset solo con las filas que no tienen NA (complete.cases())


# 3. ESTADÍSTICAS DESCRIPTIVAS
# 3.1 Calcula para la columna Temp: media, mediana, máximo, mínimo
# 3.2 Usa summary() para ver un resumen de todas las columnas


# 4. ORDENAMIENTO
# 4.1 Ordena el dataset por temperatura (Temp) de mayor a menor
#     y muestra las 5 temperaturas más altas
# 4.2 Ordena el dataset por mes (Month) y luego por día (Day)
#     y muestra las primeras 6 filas


# 5. FUNCIÓN APPLY
# 5.1 Usa apply para calcular la media de todas las columnas numéricas
#     (ignora los NA's con na.rm = TRUE)
# 5.2 Usa apply para encontrar el valor máximo de cada columna numérica
#     (ignora los NA's con na.rm = TRUE)


# 6. RANGO INTERCUARTÍLICO (IQR)
# El rango intercuartílico usa los cuartiles Q1 (25%) y Q3 (75%):
#
#   quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
#
# Ejemplo:
#   datos <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
#   Q1 <- quantile(datos, 0.25)
#   Q3 <- quantile(datos, 0.75)
#   IQR <- Q3 - Q1
#
# 6.1 Crea una función 'calcular_iqr' que reciba un vector numérico y
#     retorne, en una lista, Q1, Q3 y el IQR (Q3 - Q1).
#
# 6.2 Pruébala con calcular_iqr(airquality$Temp)
#
# 6.3 Usa apply para aplicarla a todas las columnas numéricas del dataset
#     (ignorando los NA's)
#
# 6.4 Interpreta: ¿qué variable tiene mayor variabilidad según el IQR?
