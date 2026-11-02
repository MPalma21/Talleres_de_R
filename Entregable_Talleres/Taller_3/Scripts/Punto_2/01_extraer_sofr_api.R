# ==============================================================================
# Taller 3 - Punto 2: Integración de Series Macroeconómicas y Financieras
# Script: 01_extraer_sofr_api.R
# Propósito: Extracción y tratamiento de la tasa diaria SOFR Overnight (ON)
#            desde la API del Federal Reserve Bank of New York (NY Fed).
# Técnica: REST API (Petición HTTP GET con payload JSON).
# Destino: Archivo crudo 'sofr_raw.json' y CSV tratado 'sofr_diaria_2020_2025.csv'
#          en la carpeta Outputs/Data/raw/.
# ==============================================================================

library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)
library(here)

# 1. Configuración de parámetros y rutas ---------------------------------------
fecha_inicio <- "2020-01-01"
fecha_fin    <- "2025-10-31"

dir_raw <- here("Entregable_Talleres", "Taller_3", "Outputs", "Data", "raw")
dir.create(dir_raw, showWarnings = FALSE, recursive = TRUE)

ruta_json_raw <- file.path(dir_raw, "sofr_raw.json")
ruta_csv_raw  <- file.path(dir_raw, "sofr_diaria_2020_2025.csv")

# 2. Petición a la API REST de la Reserva Federal de Nueva York ----------------
endpoint_sofr <- "https://markets.newyorkfed.org/api/rates/secured/sofr/search.json"

respuesta_api <- GET(
  url = endpoint_sofr,
  query = list(startDate = fecha_inicio, endDate = fecha_fin),
  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
)

if (status_code(respuesta_api) != 200) {
  stop("La API de la NY Fed devolvió un código de error: ", status_code(respuesta_api))
}

# Almacenamiento del archivo crudo en JSON
contenido_json <- content(respuesta_api, as = "text", encoding = "UTF-8")
writeLines(contenido_json, con = ruta_json_raw, useBytes = TRUE)

# 3. Estructuración, tipado y tratamiento de la serie --------------------------
datos_crudos <- fromJSON(contenido_json, flatten = TRUE)

df_sofr <- datos_crudos$refRates |>
  as_tibble() |>
  transmute(
    fecha     = ymd(effectiveDate),
    tasa_sofr = as.numeric(percentRate)
  ) |>
  filter(
    !is.na(tasa_sofr),
    fecha >= ymd(fecha_inicio),
    fecha <= ymd(fecha_fin)
  ) |>
  arrange(fecha)

# 4. Exportación de la serie en CSV dentro de la carpeta raw/ -------------------
write_csv(df_sofr, ruta_csv_raw)

message("Serie SOFR tratada y guardada en raw/: ", ruta_csv_raw)
