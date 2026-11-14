# ==============================================================================
# Taller 3 - Punto 2: Integración de Series Macroeconómicas y Financieras
# Script: 02_extraer_ibr_banrep.R
# Propósito: Extracción y tratamiento del Indicador Bancario de Referencia
#            (IBR Overnight - ON) del Banco de la República de Colombia.
# Técnica: Web Scraping / XML Web Harvesting (Feed SDMX parseado con xml2 y XPath).
# Destino: Archivo crudo 'ibr_raw.xml' y CSV tratado 'ibr_diaria_2020_2025.csv'
#          en la carpeta Outputs/Data/raw/.
# ==============================================================================

# Paquetes adicionales identificados explícitamente con [PAQUETE ADICIONAL]:
# [PAQUETE ADICIONAL]: httr (peticiones HTTP con configuración SSL y cabeceras SDMX)
# [PAQUETE ADICIONAL]: xml2 (navegación DOM y consultas XPath para web scraping XML)
# [PAQUETE ADICIONAL]: readr (exportación de series tratadas en formato CSV UTF-8)
# [PAQUETE ADICIONAL]: lubridate (parseo y manejo estandarizado de fechas ISO-8601)
# [PAQUETE ADICIONAL]: here (resolución portable de rutas relativas a la raíz del proyecto)

library(tidyverse)
library(httr)
library(xml2)
library(lubridate)
library(here)

# 1. Configuración de parámetros y rutas ---------------------------------------
fecha_inicio <- "2020-01-01"
fecha_fin    <- "2025-10-31"

dir_raw <- here("Entregable_Talleres", "Taller_3", "Outputs", "Data", "raw")
dir.create(dir_raw, showWarnings = FALSE, recursive = TRUE)

ruta_xml_raw <- file.path(dir_raw, "ibr_raw.xml")
ruta_csv_raw <- file.path(dir_raw, "ibr_diaria_2020_2025.csv")

# 2. Descarga del feed web oficial de Banco de la República (SUAMECA / Totoro) -
url_sdmx_banrep <- paste0(
  "https://totoro.banrep.gov.co/nsi-jax-ws/rest/data/ESTAT,DF_IBR_DAILY_HIST,1.0/all/ALL/",
  "?startPeriod=2020&dimensionAtObservation=TIME_PERIOD&detail=full"
)

if (!file.exists(ruta_xml_raw) || file.size(ruta_xml_raw) < 1000000) {
  respuesta_banrep <- GET(
    url = url_sdmx_banrep,
    config = config(ssl_verifypeer = FALSE),
    add_headers(Accept = "application/vnd.sdmx.genericdata+xml;version=2.1"),
    user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
  )
  
  if (status_code(respuesta_banrep) != 200) {
    stop("Error al conectar con Banco de la República. Código HTTP: ", status_code(respuesta_banrep))
  }
  
  writeBin(content(respuesta_banrep, as = "raw"), ruta_xml_raw)
}

# 3. Web scraping y extracción directa de nodos con xml2 y XPath ---------------
doc_xml <- read_xml(ruta_xml_raw)

nodo_serie_on <- xml_find_first(
  doc_xml,
  ".//*[local-name()='Series'][.//*[local-name()='Value'][@value='IRIBRM00'] and .//*[local-name()='Value'][@value='ER']]"
)

if (is.na(nodo_serie_on)) {
  nodo_serie_on <- xml_find_first(doc_xml, ".//*[local-name()='Series']")
}

nodos_obs    <- xml_find_all(nodo_serie_on, ".//*[local-name()='Obs']")
fechas_crudo <- xml_attr(xml_find_all(nodos_obs, ".//*[local-name()='ObsDimension']"), "value")
tasas_crudo  <- xml_attr(xml_find_all(nodos_obs, ".//*[local-name()='ObsValue']"), "value")

# 4. Estructuración, tipado y tratamiento de la serie --------------------------
df_ibr <- tibble(
  fecha    = ymd(fechas_crudo),
  tasa_ibr = as.numeric(tasas_crudo)
) |>
  filter(
    !is.na(tasa_ibr),
    fecha >= ymd(fecha_inicio),
    fecha <= ymd(fecha_fin)
  ) |>
  arrange(fecha)

# 5. Exportación de la serie en CSV dentro de la carpeta raw/ -------------------
write_csv(df_ibr, ruta_csv_raw)

message("Serie IBR tratada y guardada en raw/: ", ruta_csv_raw)
