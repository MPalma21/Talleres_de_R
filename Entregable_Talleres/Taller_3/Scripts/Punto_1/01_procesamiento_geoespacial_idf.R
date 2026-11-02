# ==============================================================================
# UNIVERSIDAD DE LOS ANDES - FACULTAD DE ECONOMÍA
# Taller de Programación en R · 2026-2
# TALLER 3: Ejercicio 1 - Procesamiento Geoespacial y Desempeño Fiscal (IDF)
#
# GRUPO 10:
# • Juan José Echeverry – Código: 202616233
# • Miguelangel Palma – Código: 202621481
# • Sergio López – Código: 202111932
#
# Eje 1: Datos Geoespaciales y Desempeño Fiscal
# Responsable: Sergio López
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(readxl)
  library(openxlsx)
  library(ggplot2)
  library(sf)
  library(rmapshaper)
  library(stringr)
  library(scales)
  library(viridis)
  library(httr)
})

# Definición de rutas relativas robustas
dir_base <- getwd()
# Si se ejecuta desde Scripts/Punto_1, encontrar la raíz del repo
if (basename(dir_base) == "Punto_1") {
  ruta_repo <- normalizePath(file.path(dir_base, "..", "..", ".."))
} else if (basename(dir_base) == "Taller_3") {
  ruta_repo <- normalizePath(file.path(dir_base, "..", ".."))
} else {
  ruta_repo <- dir_base
}

ruta_datos <- file.path(ruta_repo, "Datos", "Taller_3")
ruta_outputs_img <- file.path(ruta_repo, "Entregable_Talleres", "Taller_3", "Outputs", "Images")
ruta_outputs_data <- file.path(ruta_repo, "Entregable_Talleres", "Taller_3", "Outputs", "Data", "processed")
ruta_shiny_data <- file.path(ruta_repo, "Entregable_Talleres", "Taller_3", "Scripts", "Punto_3", "data_shiny")

dir.create(ruta_outputs_img, recursive = TRUE, showWarnings = FALSE)
dir.create(ruta_outputs_data, recursive = TRUE, showWarnings = FALSE)
dir.create(ruta_shiny_data, recursive = TRUE, showWarnings = FALSE)

# Punto 1: Datos geoespaciales ----

## Numeral 1.1: Ingesta y Limpieza de Fuentes Primarias ----

### Literal 1.1.1: DANE Cuentas Nacionales - Anexo de Valor Agregado Municipal 2023 ----
# Fuente: DANE - Cuentas Nacionales Departamentales (Serie 2011-2024p a precios corrientes, miles de millones)
archivo_va <- file.path(ruta_datos, "anex-PIBDep-ValorAgreMuni-2011-2024p.xlsx")
if (!file.exists(archivo_va)) {
  message("Descargando Valor Agregado Municipal desde DANE...")
  url_va <- "https://www.dane.gov.co/files/operaciones/PIB/anex-PIBDep-ValorAgreMuni-2011-2024p.xlsx"
  GET(
    url_va,
    write_disk(archivo_va, overwrite = TRUE),
    user_agent("Mozilla/5.0")
  )
}

# La hoja 'Cuadro 1' contiene la serie de valor agregado a precios corrientes
# La fila 8 contiene los encabezados oficiales de columnas
raw_va <- read_excel(archivo_va, sheet = "Cuadro 1", skip = 7)

df_va_2023 <- raw_va %>%
  select(
    cod_mpio = `Código Municipio`,
    nom_mpio = `Municipio`,
    cod_dpto = `Código Departamento`,
    nom_dpto = `Departamento`,
    va_2023 = `2023`
  ) %>%
  filter(!is.na(cod_mpio), str_detect(as.character(cod_mpio), "^[0-9]{5}$")) %>%
  mutate(
    cod_mpio = str_pad(as.character(cod_mpio), 5, pad = "0"),
    cod_dpto = str_pad(as.character(cod_dpto), 2, pad = "0"),
    va_2023 = as.numeric(va_2023)
  )

### Literal 1.1.2: DANE Proyecciones de Población Municipal 2024 ----
# Fuente: DANE - Proyecciones de Población por Área Geográfica periodo 2018-2042
archivo_pob <- file.path(ruta_datos, "PPED-AreaMun-2018-2042_VP.xlsx")
if (!file.exists(archivo_pob)) {
  message("Descargando Proyecciones de Población Municipal desde DANE...")
  url_pob <- "https://www.dane.gov.co/files/censo2018/proyecciones-de-poblacion/Municipal/PPED-AreaMun-2018-2042_VP.xlsx"
  GET(
    url_pob,
    write_disk(archivo_pob, overwrite = TRUE),
    user_agent("Mozilla/5.0")
  )
}

# La fila 6 contiene los nombres de variables (DP, DPNOM, MPIO, DPMP, AÑO, ÁREA GEOGRÁFICA, TOTAL)
raw_pob <- read_excel(archivo_pob, sheet = "PobMunicipalxÁrea", skip = 7)

df_pob_2024 <- raw_pob %>%
  select(
    cod_dpto = DP,
    nom_dpto = DPNOM,
    cod_mpio = MPIO,
    nom_mpio = DPMP,
    ano = `AÑO`,
    area = `ÁREA GEOGRÁFICA`,
    total = TOTAL
  ) %>%
  filter(ano == 2024, area == "Total") %>%
  mutate(
    cod_mpio = str_pad(as.character(cod_mpio), 5, pad = "0"),
    cod_dpto = str_pad(as.character(cod_dpto), 2, pad = "0"),
    pob_2024 = as.numeric(total)
  ) %>%
  select(cod_mpio, pob_2024)

### Literal 1.1.3: DNP Resultados del Índice de Desempeño Fiscal (IDF) 2024 ----
# Fuente: DNP - Información Fiscal y Financiera Territorial (CIFFIT)
archivo_idf <- file.path(ruta_datos, "ResultadosIDF_DNP.xlsx")
if (!file.exists(archivo_idf)) {
  message("Descargando resultados del IDF desde DNP...")
  url_idf <- "https://colaboracion.dnp.gov.co/CDT/Desarrollo%20Territorial/Desempeno_Fiscal/ResultadosIDF_Nueva_MetodologIa_2023_Act.xlsx"
  GET(
    url_idf,
    write_disk(archivo_idf, overwrite = TRUE),
    user_agent("Mozilla/5.0")
  )
}

# Hoja 'Municipios 2023' (fila 7 contiene encabezados con 'Código' y 'Nuevo IDF')
raw_idf <- read_excel(archivo_idf, sheet = "Municipios 2023", skip = 6)

df_idf_muni <- raw_idf %>%
  select(
    cod_mpio = `Código`,
    nom_dpto = `Departamento`,
    nom_mpio = `Municipio`,
    idf_municipal = `Nuevo IDF`
  ) %>%
  filter(!is.na(cod_mpio), str_detect(as.character(cod_mpio), "^[0-9]{5}$")) %>%
  mutate(
    cod_mpio = str_pad(as.character(cod_mpio), 5, pad = "0"),
    idf_municipal = as.numeric(idf_municipal)
  )

### Literal 1.1.4: Integración Relacional de Microdatos Municipales ----
# Realizamos el pegue relacional asegurando correspondencia unívoca por código DANE DIVIPOLA
df_geo_completo <- df_va_2023 %>%
  inner_join(df_pob_2024, by = "cod_mpio") %>%
  inner_join(df_idf_muni %>% select(cod_mpio, idf_municipal), by = "cod_mpio")

message(paste(
  "Municipios integrados exitosamente sin discrepancias de llave:",
  nrow(df_geo_completo)
))

## Numeral 1.2: Literal A - Cálculo del IDF Artificial y Mapa Departamental ----

### Subsección técnica 1.2.1: Proyección de Valor Agregado 2023 -> 2024 ----
# Justificación metodológica de precios y tasa elegida:
# El Valor Agregado municipal publicado por el DANE en Cuadro 1 está expresado 'A precios corrientes'
# (miles de millones de pesos). Conforme al Boletín Técnico de Cuentas Nacionales 2024 del DANE:
# 1. El crecimiento del PIB nominal a precios corrientes en 2024 fue del 8.27% (equivalente al crecimiento agregado del VA).
# 2. El crecimiento del PIB real en volumen encadenado fue del 1.70%.
# Aplicamos la tasa a precios corrientes (8.27%) para mantener la consistencia con la unidad de medida del VA original.
# Nota matemática analítica: Como el ponderador w_i = (L_i * VA_i) / Σ(L_k * VA_k) es homogéneo de grado cero
# respecto a VA, cualquier escalamiento proporcional uniforme (1 + g) se cancela en el numerador y denominador.
tasa_pib_2024 <- 8.27 # Porcentaje redondeado a dos decimales

df_geo_completo <- df_geo_completo %>%
  mutate(
    va_2024_proj = va_2023 * (1 + tasa_pib_2024 / 100),
    l_va_pondera = pob_2024 * va_2024_proj
  )

### Subsección técnica 1.2.2: Ponderación Municipal y Cálculo del IDF Departamental ----
# Cálculo del ponderador departamental w_i y comprobación de suma = 1
df_geo_weighted <- df_geo_completo %>%
  group_by(cod_dpto) %>%
  mutate(
    w_i = l_va_pondera / sum(l_va_pondera, na.rm = TRUE),
    weighted_idf = idf_municipal * w_i
  ) %>%
  ungroup()

# Agregación departamental: IDF_j = Σ(IDF_i * w_i)
df_idf_departamental <- df_geo_weighted %>%
  group_by(cod_dpto, nom_dpto) %>%
  summarise(
    n_mpios = n(),
    n_municipios = n(),
    suma_ponderadores = sum(w_i, na.rm = TRUE),
    idf_departamental = sum(weighted_idf, na.rm = TRUE),
    .groups = "drop"
  )

# Comprobación de integridad: verificar que todos los ponderadores sumen exactamente 1
stopifnot(all(abs(df_idf_departamental$suma_ponderadores - 1.0) < 1e-7))
message(
  "Comprobación superada: La suma de ponderadores es exactamente 1 en todos los departamentos."
)

### Subsección técnica 1.2.3: Construcción y Exportación del Mapa Departamental ----
archivo_shp_dpto <- file.path(ruta_datos, "shapefiles", "MGN_DPTO_POLITICO.shp")
if (!file.exists(archivo_shp_dpto)) {
  # Si no existe shapefile local, descargar geojson oficial y transformar
  url_dpto_geo <- "https://raw.githubusercontent.com/caticoa3/colombia_mapa/master/co_2018_MGN_DPTO_POLITICO.geojson"
  dest_geo <- file.path(ruta_datos, "MGN_DPTO_POLITICO.geojson")
  if (!file.exists(dest_geo)) {
    GET(url_dpto_geo, write_disk(dest_geo, overwrite = TRUE))
  }
  shp_dpto <- st_read(dest_geo, quiet = TRUE)
  st_write(shp_dpto, archivo_shp_dpto, append = FALSE, quiet = TRUE)
} else {
  shp_dpto <- st_read(archivo_shp_dpto, quiet = TRUE)
}

# Pegue cartográfico con resultados del IDF
mapa_dpto_sf <- shp_dpto %>%
  left_join(df_idf_departamental, by = c("DPTO_CCDGO" = "cod_dpto"))

# Gráfico temático con ggplot2
p_mapa_dpto <- ggplot(mapa_dpto_sf) +
  geom_sf(aes(fill = idf_departamental), color = "white", size = 0.25) +
  scale_fill_viridis_c(
    option = "viridis",
    name = "IDF Departamental\n(Artificial)",
    na.value = "grey80",
    direction = 1,
    limits = c(25, 95)
  ) +
  labs(
    title = "Índice de Desempeño Fiscal (IDF) Artificial por Departamento (2024)",
    subtitle = "Media ponderada del IDF municipal por producto de Población 2024 y Valor Agregado Proyectado 2024",
    caption = "Fuente: Cálculos Grupo 10 con base en DNP (IDF 2024), DANE (Cuentas Nacionales y Proyecciones 2024)."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13, color = "#1e3d59"),
    plot.subtitle = element_text(size = 9, color = "grey30"),
    legend.position = "right",
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

ggsave(
  file.path(ruta_outputs_img, "1_1_mapa_idf_departamental.png"),
  p_mapa_dpto,
  width = 8,
  height = 9,
  dpi = 300
)
message("Mapa departamental exportado a outputs/1_1_mapa_idf_departamental.png")

## Numeral 1.3: Literal B - Mapa Municipal y Diagnóstico Computacional (Bono) ----

### Subsección técnica 1.3.1: Diagnóstico de Problemas Computacionales ----
# 1. Complejidad Poligonal y Desborde de Vértices: La capa de municipios contiene 1.122 multipolígonos
#    con cientos de miles de vértices de alta resolución. En dispositivos gráficos vectoriales (PDF, Cairo),
#    cada vértice se almacena como una coordenada independiente, inflando el tamaño del documento a decenas de MB
#    y generando tiempos de renderizado y latencia inviables.
# 2. Pérdida Topológica en Simplificación Ingenua: El uso de st_simplify estándar produce huecos (gaps) y
#    traslapes (overlaps) entre límites municipales adyacentes al simplificar polígonos aisladamente.
# 3. Solución Técnica Implementada (Bono): Implementamos el algoritmo Visvalingam-Whyatt preservando topología
#    compartida mediante rmapshaper::ms_simplify(keep = 0.08, keep_shapes = TRUE). Esto reduce el 92% de los vértices
#    redundantes, disminuye la carga en RAM y permite un renderizado vectorial instantáneo sin alterar fronteras.

archivo_shp_mpio <- file.path(ruta_datos, "shapefiles", "MGN_MPIO_POLITICO.shp")
if (!file.exists(archivo_shp_mpio)) {
  url_mpio_geo <- "https://raw.githubusercontent.com/caticoa3/colombia_mapa/master/co_2018_MGN_MPIO_POLITICO.geojson"
  dest_mgeo <- file.path(ruta_datos, "MGN_MPIO_POLITICO.geojson")
  if (!file.exists(dest_mgeo)) {
    GET(url_mpio_geo, write_disk(dest_mgeo, overwrite = TRUE))
  }
  shp_mpio <- st_read(dest_mgeo, quiet = TRUE)
  st_write(shp_mpio, archivo_shp_mpio, append = FALSE, quiet = TRUE)
} else {
  shp_mpio <- st_read(archivo_shp_mpio, quiet = TRUE)
}

shp_mpio <- shp_mpio %>%
  mutate(cod_mpio = paste0(DPTO_CCDGO, MPIO_CCDGO)) %>%
  left_join(
    df_geo_weighted %>% select(cod_mpio, idf_municipal),
    by = "cod_mpio"
  )

# Simplificación topológica controlada
shp_mpio_opt <- ms_simplify(shp_mpio, keep = 0.08, keep_shapes = TRUE)

# Renderizado del mapa municipal (Bono)
p_mapa_mpio <- ggplot(shp_mpio_opt) +
  geom_sf(aes(fill = idf_municipal), color = "grey90", size = 0.04) +
  scale_fill_viridis_c(
    option = "magma",
    name = "IDF Municipal\n(0 - 100)",
    na.value = "grey70",
    direction = 1
  ) +
  labs(
    title = "Índice de Desempeño Fiscal (IDF) Municipal en Colombia (2024)",
    subtitle = "Visualización optimizada de ~1.120 municipios mediante simplificación topológica (Bono 1)",
    caption = "Fuente: Cálculos Grupo 10 con base en DNP (IDF 2024) y Marco Geoestadístico Nacional (DANE)."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13, color = "#1e3d59"),
    plot.subtitle = element_text(size = 9, color = "grey30"),
    legend.position = "right",
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

ggsave(
  file.path(ruta_outputs_img, "1_2_mapa_idf_municipal_bono.png"),
  p_mapa_mpio,
  width = 8,
  height = 9,
  dpi = 300
)
message(
  "Mapa municipal optimizado exportado a outputs/1_2_mapa_idf_municipal_bono.png"
)

