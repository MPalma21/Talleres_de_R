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

# Paquetes no vistos en clase identificados explícitamente con [PAQUETE ADICIONAL]:
# [PAQUETE ADICIONAL]: readxl (lectura directa de hojas de cálculo Excel .xlsx sin modificar fuentes)
# [PAQUETE ADICIONAL]: readr (exportación eficiente de tablas procesadas y auditoría en CSV UTF-8)
# [PAQUETE ADICIONAL]: sf (lectura, unión espacial y transformación de coordenadas Simple Features)
# [PAQUETE ADICIONAL]: rmapshaper (simplificación topológica Visvalingam-Whyatt para el Bono 1)
# [PAQUETE ADICIONAL]: stringr (estandarización de llaves DIVIPOLA con ceros a la izquierda)
# [PAQUETE ADICIONAL]: scales (reescalado de paletas cromáticas por cuantiles y formateo numérico)
# [PAQUETE ADICIONAL]: httr (descarga programática de respaldos oficiales desde portales DANE/DNP)

# Definición de rutas relativas robustas desde cualquier directorio de ejecución
dir_base <- getwd()
if (basename(dir_base) == "Punto_1") {
  ruta_repo <- normalizePath(file.path(dir_base, "..", "..", ".."))
} else if (basename(dir_base) == "Scripts") {
  ruta_repo <- normalizePath(file.path(dir_base, "..", ".."))
} else if (basename(dir_base) == "Taller_3" || basename(dir_base) == "Notebooks") {
  ruta_repo <- normalizePath(file.path(dir_base, "..", ".."))
  if (!dir.exists(file.path(ruta_repo, "Datos"))) {
    ruta_repo <- normalizePath(file.path(dir_base, "..", "..", ".."))
  }
} else {
  ruta_repo <- dir_base
}

if (dir.exists(file.path(ruta_repo, "librerias"))) {
  .libPaths(c(file.path(ruta_repo, "librerias"), .libPaths()))
}

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(readxl)
  library(ggplot2)
  library(sf)
  library(rmapshaper)
  library(stringr)
  library(scales)
  library(httr)
})

ruta_datos        <- file.path(ruta_repo, "Datos", "Taller_3")
ruta_outputs_img  <- file.path(ruta_repo, "Entregable_Talleres", "Taller_3", "Outputs", "Images")
ruta_outputs_data <- file.path(ruta_repo, "Entregable_Talleres", "Taller_3", "Outputs", "Data", "processed")
ruta_shiny_data   <- file.path(ruta_repo, "Entregable_Talleres", "Taller_3", "Scripts", "Punto_3", "data_shiny")

dir.create(ruta_outputs_img, recursive = TRUE, showWarnings = FALSE)
dir.create(ruta_outputs_data, recursive = TRUE, showWarnings = FALSE)
dir.create(ruta_shiny_data, recursive = TRUE, showWarnings = FALSE)

# Tema visual institucional armonizado con el informe Quarto del Grupo 10
tema_mapa_institucional <- theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13.5, color = "#111827", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.5, color = "#4b5563", margin = margin(b = 10)),
    plot.caption = element_text(size = 8, color = "#6b7280", hjust = 0, margin = margin(t = 10), lineheight = 1.15),
    legend.position = "right",
    legend.title = element_text(face = "bold", size = 9.5, color = "#1f2937"),
    legend.text = element_text(size = 8.8, color = "#374151"),
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    plot.background = element_rect(fill = "#ffffff", color = NA),
    panel.background = element_rect(fill = "#ffffff", color = NA),
    plot.margin = margin(t = 12, r = 14, b = 10, l = 12)
  )

# ==============================================================================
# 1. INGESTA Y LIMPIEZA DE LAS CUATRO FUENTES PRIMARIAS (SIN MODIFICAR ORIGINALES)
# ==============================================================================

## 1.1 DANE PIB por departamento: Anexo de Valor Agregado Municipal (Selección 2023) ----
# Fuente: DANE - Cuentas Nacionales Departamentales (Serie 2011-2024p a precios corrientes, miles de millones de pesos)
archivo_va <- file.path(ruta_datos, "anex-PIBDep-ValorAgreMuni-2011-2024p.xlsx")
if (!file.exists(archivo_va)) {
  message("Descargando Anexo de Valor Agregado Municipal desde DANE...")
  url_va <- "https://www.dane.gov.co/files/operaciones/PIB/anex-PIBDep-ValorAgreMuni-2011-2024p.xlsx"
  GET(url_va, write_disk(archivo_va, overwrite = TRUE), user_agent("Mozilla/5.0"))
}

# Detección dinámica de la fila de encabezado en 'Cuadro 1' (serie a precios corrientes)
raw_va_all <- suppressMessages(read_excel(archivo_va, sheet = "Cuadro 1", col_names = FALSE, .name_repair = "minimal"))
fila_hdr_va <- which(str_detect(as.character(raw_va_all[[1]]), "C[oó]digo\\s+Municipio"))[1]
nombres_va <- str_trim(as.character(unlist(raw_va_all[fila_hdr_va, ])))
raw_va <- raw_va_all[(fila_hdr_va + 1):nrow(raw_va_all), ]
names(raw_va) <- make.unique(ifelse(is.na(nombres_va) | nombres_va == "", "col_na", nombres_va))

df_va_2023 <- raw_va %>%
  select(
    cod_mpio = `Código Municipio`,
    nom_mpio = `Municipio`,
    cod_dpto = `Código Departamento`,
    nom_dpto = `Departamento`,
    va_2023  = `2023`
  ) %>%
  mutate(
    cod_mpio = str_pad(str_trim(as.character(cod_mpio)), 5, pad = "0"),
    cod_dpto = str_pad(str_trim(as.character(cod_dpto)), 2, pad = "0"),
    va_2023  = as.numeric(va_2023)
  ) %>%
  filter(!is.na(cod_mpio), str_detect(cod_mpio, "^[0-9]{5}$"), !is.na(va_2023))

## 1.2 DANE Proyecciones de Población: Población Municipal de 2024 ----
# Fuente: DANE - Proyecciones de Población Municipal por Área (2018-2042)
archivo_pob <- file.path(ruta_datos, "PPED-AreaMun-2018-2042_VP.xlsx")
if (!file.exists(archivo_pob)) {
  message("Descargando Proyecciones de Población Municipal desde DANE...")
  url_pob <- "https://www.dane.gov.co/files/censo2018/proyecciones-de-poblacion/Municipal/PPED-AreaMun-2018-2042_VP.xlsx"
  GET(url_pob, write_disk(archivo_pob, overwrite = TRUE), user_agent("Mozilla/5.0"))
}

hoja_pob <- excel_sheets(archivo_pob)[str_detect(excel_sheets(archivo_pob), "PobMunicipal")][1]
raw_pob_all <- suppressMessages(read_excel(archivo_pob, sheet = hoja_pob, col_names = FALSE, .name_repair = "minimal"))
fila_hdr_pob <- which(str_detect(as.character(raw_pob_all[[1]]), "^DP$"))[1]
nombres_pob <- str_trim(as.character(unlist(raw_pob_all[fila_hdr_pob, ])))
raw_pob <- raw_pob_all[(fila_hdr_pob + 1):nrow(raw_pob_all), ]
names(raw_pob) <- make.unique(ifelse(is.na(nombres_pob) | nombres_pob == "", "col_na", nombres_pob))

df_pob_2024 <- raw_pob %>%
  select(
    cod_dpto = DP,
    nom_dpto_pob = DPNOM,
    cod_mpio = MPIO,
    nom_mpio_pob = DPMP,
    ano      = `AÑO`,
    area     = `ÁREA GEOGRÁFICA`,
    total    = TOTAL
  ) %>%
  filter(as.character(ano) == "2024", area == "Total") %>%
  mutate(
    cod_mpio = str_pad(str_trim(as.character(cod_mpio)), 5, pad = "0"),
    cod_dpto = str_pad(str_trim(as.character(cod_dpto)), 2, pad = "0"),
    pob_2024 = as.numeric(total)
  ) %>%
  filter(!is.na(cod_mpio), str_detect(cod_mpio, "^[0-9]{5}$"), !is.na(pob_2024)) %>%
  select(cod_mpio, pob_2024)

## 1.3 DNP Información Fiscal y Financiera: Resultados del IDF Municipal, Vigencia 2024 ----
# Fuente: DNP - Subdirección de Fortalecimiento Fiscal Territorial (CIFFIT - Resultados IDF Vigencia 2024)
# Nota de compatibilidad: El lector detecta automáticamente tanto el formato oficial exportado de
# DNP-CIFFIT Vigencia 2024 ('Hoja1', columnas 'Código Entidad' e 'IDF') como el formato multipágina
# ('Municipios 2024' / 'Municipios 2023', columnas 'Código' y 'Nuevo IDF').
archivo_idf <- file.path(ruta_datos, "ResultadosIDF_DNP.xlsx")
if (!file.exists(archivo_idf)) {
  stop("No se encontró 'Datos/Taller_3/ResultadosIDF_DNP.xlsx'. Verifique la carpeta Datos/Taller_3.")
}

leer_idf_dnp <- function(ruta_xlsx) {
  hojas <- excel_sheets(ruta_xlsx)
  hoja_obj <- hojas[1]
  for (h in hojas) {
    if (str_detect(tolower(h), "municip|hoja1|idf|2024")) {
      hoja_obj <- h
      break
    }
  }
  raw_all <- suppressMessages(read_excel(ruta_xlsx, sheet = hoja_obj, col_names = FALSE, .name_repair = "minimal"))
  fila_hdr <- which(str_detect(as.character(raw_all[[1]]), "^C[oó]digo"))[1]
  if (is.na(fila_hdr)) {
    stop("No se identificó la fila de encabezados ('Código' / 'Código Entidad') en el archivo del IDF.")
  }
  nombres_col <- str_trim(as.character(unlist(raw_all[fila_hdr, ])))
  datos <- raw_all[(fila_hdr + 1):nrow(raw_all), ]
  names(datos) <- make.unique(ifelse(is.na(nombres_col) | nombres_col == "", "col_na", nombres_col))

  col_cod  <- names(datos)[str_detect(names(datos), "^C[oó]digo(\\s+Entidad)?$")][1]
  col_mpio <- names(datos)[str_detect(names(datos), "^(Municipio|Entidad)$")][1]
  col_dpto <- names(datos)[str_detect(names(datos), "^Departamento$")][1]
  col_idf  <- names(datos)[str_detect(names(datos), "^(IDF|Nuevo\\s+IDF)$")][1]
  col_rng  <- names(datos)[str_detect(names(datos), "^(Rango|Rango\\s+IDF)")][1]

  datos %>%
    transmute(
      cod_mpio      = str_pad(str_trim(as.character(.data[[col_cod]])), 5, pad = "0"),
      nom_dpto_idf  = str_trim(as.character(.data[[col_dpto]])),
      nom_mpio_idf  = str_trim(as.character(.data[[col_mpio]])),
      idf_municipal = as.numeric(.data[[col_idf]]),
      rango_idf     = if (!is.na(col_rng)) str_trim(as.character(.data[[col_rng]])) else NA_character_
    ) %>%
    filter(!is.na(cod_mpio), str_detect(cod_mpio, "^[0-9]{5}$"), !is.na(idf_municipal))
}

df_idf_muni <- leer_idf_dnp(archivo_idf)

## 1.4 DANE Geoportal: Shapefiles Departamental y Municipal (MGN) ----
archivo_shp_dpto <- file.path(ruta_datos, "shapefiles", "MGN_DPTO_POLITICO.shp")
archivo_shp_mpio <- file.path(ruta_datos, "shapefiles", "MGN_MPIO_POLITICO.shp")

shp_dpto_raw <- st_read(archivo_shp_dpto, quiet = TRUE)
shp_mpio_raw <- st_read(archivo_shp_mpio, quiet = TRUE)

# Función auxiliar para compatibilidad de nombres de columnas entre versiones del MGN DANE
estandarizar_llaves_shp_dpto <- function(sf_obj) {
  nms <- names(sf_obj)
  col_dpto <- nms[str_detect(toupper(nms), "^DPTO_CCDGO$")][1]
  col_nom  <- nms[str_detect(toupper(nms), "^DPTO_CNMBR$")][1]
  sf_obj %>%
    mutate(
      cod_dpto_shp = str_pad(str_trim(as.character(.data[[col_dpto]])), 2, pad = "0"),
      nom_dpto_shp = as.character(.data[[col_nom]])
    )
}

estandarizar_llaves_shp_mpio <- function(sf_obj) {
  nms <- names(sf_obj)
  col_cdpmp <- nms[str_detect(toupper(nms), "^MPIO_CDPMP$")][1]
  col_dpto  <- nms[str_detect(toupper(nms), "^DPTO_CCDGO$")][1]
  col_mpio  <- nms[str_detect(toupper(nms), "^MPIO_CCDGO$")][1]
  if (!is.na(col_cdpmp)) {
    sf_obj %>%
      mutate(
        cod_mpio = str_pad(str_trim(as.character(.data[[col_cdpmp]])), 5, pad = "0"),
        cod_dpto_shp = substr(cod_mpio, 1, 2)
      )
  } else {
    sf_obj %>%
      mutate(
        cod_dpto_shp = str_pad(str_trim(as.character(.data[[col_dpto]])), 2, pad = "0"),
        cod_mpio_3   = str_pad(str_trim(as.character(.data[[col_mpio]])), 3, pad = "0"),
        cod_mpio     = ifelse(nchar(cod_mpio_3) == 5, cod_mpio_3, paste0(cod_dpto_shp, cod_mpio_3))
      )
  }
}

shp_dpto <- suppressWarnings(
  estandarizar_llaves_shp_dpto(shp_dpto_raw) %>%
    st_make_valid() %>%
    st_collection_extract("POLYGON") %>%
    st_cast("MULTIPOLYGON")
)

shp_mpio <- suppressWarnings(
  estandarizar_llaves_shp_mpio(shp_mpio_raw) %>%
    st_make_valid() %>%
    st_collection_extract("POLYGON") %>%
    st_cast("MULTIPOLYGON")
)

# ==============================================================================
# 2. REVISIÓN Y AUDITORÍA DE LLAVES ANTES DE UNIR LAS BASES
# ==============================================================================
# El enunciado exige revisar las llaves antes de unir las bases, explicar las
# correcciones realizadas e incluir evidencia de una unión revisada.

# 2.1 Verificación de unicidad de llave primaria (cod_mpio de 5 dígitos DIVIPOLA)
stopifnot(
  "Duplicados en VA 2023"        = anyDuplicated(df_va_2023$cod_mpio) == 0,
  "Duplicados en Población 2024" = anyDuplicated(df_pob_2024$cod_mpio) == 0,
  "Duplicados en IDF 2024"       = anyDuplicated(df_idf_muni$cod_mpio) == 0
)

# 2.2 Diagnóstico de diferencias de cobertura entre las fuentes (anti_join)
diff_va_pob <- setdiff(df_va_2023$cod_mpio, df_pob_2024$cod_mpio)
diff_pob_va <- setdiff(df_pob_2024$cod_mpio, df_va_2023$cod_mpio)

# Territorios en DANE (VA / Población: 1.123 registros) que no están en DNP (IDF Municipal: 1.103 registros)
df_no_evaluados_idf <- df_va_2023 %>%
  inner_join(df_pob_2024, by = "cod_mpio") %>%
  anti_join(df_idf_muni, by = "cod_mpio") %>%
  mutate(
    motivo_exclusion_dnp = case_when(
      cod_mpio == "88001" ~ "San Andrés Isla reporta en CUIPO-DNP como departamento, no como municipio (solo se evalúa Providencia 88564 a nivel municipal)",
      cod_mpio == "27493" ~ "Municipio de reciente creación (Nuevo Belén de Bajirá, Ord. 180 de 2023) sin serie histórica completa en corte previo",
      cod_mpio == "94663" ~ "Antiguo corregimiento Mapiripana (Guainía) integrado territorialmente con VA = 0",
      TRUE                ~ "Área No Municipalizada (ANM / corregimiento departamental) en Amazonas, Guainía o Vaupés no sujeta al régimen municipal Ley 617/2000"
    )
  )

message(sprintf(
  "Auditoría de llaves DIVIPOLA completada:\n - Registros VA 2023 (DANE): %d | Población 2024 (DANE): %d (Discrepancia VA vs. Pob: %d)\n - Municipios evaluados en IDF 2024 (DNP): %d\n - Territorios DANE sin medición de IDF municipal (ANMs y San Andrés 88001): %d",
  nrow(df_va_2023), nrow(df_pob_2024), length(diff_va_pob) + length(diff_pob_va),
  nrow(df_idf_muni), nrow(df_no_evaluados_idf)
))

# 2.3 Unión relacional sobre el universo de municipios evaluados en el IDF (1.103 municipios)
# Al realizar inner_join sobre los municipios con IDF válido antes de calcular w_i, garantizamos que
# la suma de los ponderadores Σ w_i recorra exactamente los n_j municipios evaluados del departamento j y sume 1.
df_geo_completo <- df_va_2023 %>%
  inner_join(df_pob_2024, by = "cod_mpio") %>%
  inner_join(df_idf_muni %>% select(cod_mpio, idf_municipal, rango_idf), by = "cod_mpio")

message(paste("Municipios integrados exitosamente con llave unívoca cod_mpio:", nrow(df_geo_completo)))

# ==============================================================================
# 3. LITERAL A: PROYECCIÓN DEL VA 2023 -> 2024, PONDERADORES Y MAPA DEPARTAMENTAL
# ==============================================================================

## 3.1 Proyección del Valor Agregado de 2023 a 2024 ----
# Revisión de precios y justificación de la tasa elegida:
# • En el 'Cuadro 1' del anexo oficial del DANE, el Valor Agregado municipal está expresado
#   a PRECIOS CORRIENTES (miles de millones de pesos corrientes).
# • Conforme a las Cuentas Nacionales Anuales del DANE para 2024, el crecimiento del PIB nominal
#   (y del Valor Agregado agregado a precios corrientes: 1.550.974 / 1.432.558 - 1 = 8,2661%) fue de 8,27%
#   (mientras que el crecimiento real del PIB en volumen encadenado fue de 1,70%).
# • Para preservar la consistencia de unidades nominales con la serie en precios corrientes, aplicamos
#   la tasa porcentual redondeada a dos decimales: g = 8,27%.
# • Propiedad analítica (homogeneidad de grado cero): En w_i = (L_i * VA_i,2024) / Σ(L_k * VA_k,2024),
#   como VA_i,2024 = VA_i,2023 * (1 + g), el factor escalar común (1 + g) se factoriza y cancela entre
#   numerador y denominador, dejando los ponderadores w_i invariantes ante la tasa agregada elegida.
tasa_pib_2024 <- 8.27

df_geo_weighted <- df_geo_completo %>%
  mutate(
    va_2024_proj = va_2023 * (1 + tasa_pib_2024 / 100),
    l_va_pondera = pob_2024 * va_2024_proj
  ) %>%
  group_by(cod_dpto) %>%
  mutate(
    w_i          = l_va_pondera / sum(l_va_pondera, na.rm = TRUE),
    weighted_idf = idf_municipal * w_i
  ) %>%
  ungroup()

## 3.2 Agregación Departamental y Doble Comprobación (Σ w_i = 1 y Procedimiento Alternativo) ----
df_idf_departamental <- df_geo_weighted %>%
  group_by(cod_dpto, nom_dpto) %>%
  summarise(
    n_mpios              = n(),
    n_municipios         = n(),
    pob_dpto_2024        = sum(pob_2024, na.rm = TRUE),
    va_dpto_2023         = sum(va_2023, na.rm = TRUE),
    va_dpto_2024_proj    = sum(va_2024_proj, na.rm = TRUE),
    suma_ponderadores    = sum(w_i, na.rm = TRUE),
    idf_departamental    = sum(weighted_idf, na.rm = TRUE),
    # Segundo procedimiento de comprobación: weighted.mean directo con L_i * VA_i,2023 sin proyectar
    idf_proc_alternativo = stats::weighted.mean(idf_municipal, w = pob_2024 * va_2023, na.rm = TRUE),
    diff_procedimientos  = abs(idf_departamental - idf_proc_alternativo),
    .groups              = "drop"
  ) %>%
  arrange(desc(idf_departamental))

# Comprobación 1: Todos los ponderadores departamentales suman exactamente 1
stopifnot(all(abs(df_idf_departamental$suma_ponderadores - 1.0) < 1e-10))
# Comprobación 2: Coincidencia exacta con el procedimiento alternativo (weighted.mean sobre VA 2023)
stopifnot(max(df_idf_departamental$diff_procedimientos) < 1e-12)

message("Comprobación doble superada: Σ w_i = 1 en los 33 departamentos y diferencia máxima entre procedimientos = 0.")

# Exportar bases procesadas y tabla de auditoría de unión revisada (Medellín 05001, Bogotá 11001, Barranquilla 08001, Samacá 15646)
write_csv(df_idf_departamental, file.path(ruta_outputs_data, "idf_departamental_2024.csv"))
write_csv(df_geo_weighted, file.path(ruta_outputs_data, "idf_municipal_ponderado_2024.csv"))

df_auditoria_ej1 <- df_geo_weighted %>%
  filter(cod_mpio %in% c("05001", "11001", "08001", "15646", "76001")) %>%
  left_join(
    df_idf_departamental %>% select(cod_dpto, n_mpios, suma_ponderadores, idf_departamental, idf_proc_alternativo),
    by = "cod_dpto"
  ) %>%
  select(
    cod_mpio, nom_mpio, cod_dpto, nom_dpto,
    va_2023, va_2024_proj, pob_2024, idf_municipal, rango_idf,
    w_i, weighted_idf, n_mpios, suma_ponderadores,
    idf_departamental, idf_proc_alternativo
  )
write_csv(df_auditoria_ej1, file.path(ruta_outputs_data, "auditoria_llaves_ejercicio_1.csv"))

## 3.3 Construcción y Exportación del Mapa Departamental (1_1_mapa_idf_departamental.png) ----
mapa_dpto_sf <- shp_dpto %>%
  left_join(df_idf_departamental, by = c("cod_dpto_shp" = "cod_dpto"))

# Reescalado cromático no lineal basado en cuantiles para maximizar el contraste visual
# entre los 33 departamentos (rango observado: 42,11 pts en Caquetá a 77,04 pts en Bogotá D.C.)
rango_dpto <- range(mapa_dpto_sf$idf_departamental, na.rm = TRUE)
lim_dpto   <- c(floor(rango_dpto[1] / 5) * 5, ceiling(rango_dpto[2] / 5) * 5)
cuantiles_dpto <- unique(as.numeric(quantile(
  mapa_dpto_sf$idf_departamental,
  probs = c(0, 0.10, 0.25, 0.50, 0.75, 0.90, 1.0),
  na.rm = TRUE
)))
valores_reescalados_dpto <- scales::rescale(c(lim_dpto[1], cuantiles_dpto, lim_dpto[2]))

# Selección de departamentos destacados (Top 4 y Bottom 3) para etiquetas de referencia en el mapa
cods_etiquetas <- c(
  head(df_idf_departamental$cod_dpto, 4),
  tail(df_idf_departamental$cod_dpto, 3)
)
pts_etiquetas_dpto <- suppressWarnings(
  mapa_dpto_sf %>%
    filter(cod_dpto_shp %in% cods_etiquetas) %>%
    st_point_on_surface()
) %>%
  mutate(
    coords = st_coordinates(geometry),
    x = coords[, 1],
    y = coords[, 2],
    etiqueta = sprintf("%s\n(%.1f)", nom_dpto, idf_departamental)
  )

p_mapa_dpto <- ggplot(mapa_dpto_sf) +
  geom_sf(aes(fill = idf_departamental), color = "#ffffff", linewidth = 0.35) +
  geom_label(
    data = pts_etiquetas_dpto,
    aes(x = x, y = y, label = etiqueta),
    size = 2.4,
    fontface = "bold",
    color = "#111827",
    fill = alpha("#ffffff", 0.82),
    linewidth = 0.2,
    label.padding = unit(0.16, "lines")
  ) +
  scale_fill_viridis_c(
    option = "viridis",
    name = "IDF Departamental\nArtificial (pts)",
    limits = lim_dpto,
    breaks = seq(lim_dpto[1], lim_dpto[2], by = 5),
    values = valores_reescalados_dpto,
    na.value = "grey85",
    direction = 1,
    guide = guide_colorbar(
      barheight = unit(5.2, "cm"),
      barwidth = unit(0.48, "cm"),
      frame.colour = "#374151",
      ticks.colour = "#374151"
    )
  ) +
  labs(
    title = "Índice de Desempeño Fiscal (IDF) Artificial por Departamento en Colombia (2024)",
    subtitle = "Media ponderada del IDF municipal (Vigencia 2024) por Población 2024 y Valor Agregado Proyectado 2024 (g = 8,27%)",
    caption = paste0(
      "Fuente: Elaboración Grupo 10 con datos del DNP (IDF Municipal Vigencia 2024) y DANE (Cuentas Nacionales 2023, Proyecciones de Población 2024 y MGN).\n",
      "Nota: Etiquetas destacan los departamentos con mayor desempeño ponderado (Bogotá D.C., Atlántico, Antioquia, Córdoba) y menor puntaje (Caquetá, Vichada, La Guajira)."
    )
  ) +
  tema_mapa_institucional

ggsave(
  file.path(ruta_outputs_img, "1_1_mapa_idf_departamental.png"),
  p_mapa_dpto,
  width = 8.8,
  height = 9.5,
  dpi = 300
)
message("Mapa departamental exportado a Outputs/Images/1_1_mapa_idf_departamental.png")

# ==============================================================================
# 4. LITERAL B: MAPA MUNICIPAL Y DIAGNÓSTICO COMPUTACIONAL (BONO 1)
# ==============================================================================
# Diagnóstico de problemas computacionales al graficar el nivel municipal (~1.122 polígonos):
# 1. Sobrecarga de vértices en dispositivos vectoriales: La cartografía oficial del MGN municipal del DANE
#    contiene cientos de miles de coordenadas que definen ríos y costas detalladas. Su trazado directo en
#    motores gráficos (grid/Cairo/PDF) satura la memoria RAM, eleva la latencia de dibujo y produce archivos
#    pesados difíciles de renderizar.
# 2. Corrupción topológica con simplificación aislada (sf::st_simplify): El algoritmo estándar de Douglas-Peucker
#    simplifica cada polígono por separado, rompiendo las fronteras colindantes y creando grietas (slivers/gaps)
#    o solapamientos entre municipios vecinos.
# 3. Solución técnica implementada (Bono 1): Se emplea rmapshaper::ms_simplify(..., keep_shapes = TRUE) basado
#    en el algoritmo topológico de Visvalingam-Whyatt, ajustando la fracción de retención (keep) de manera
#    adaptativa según la densidad inicial de vértices del shapefile para preservar la fidelidad geométrica
#    sin deformar polígonos ni eliminar municipios pequeños.

shp_mpio_joined <- shp_mpio %>%
  left_join(
    df_geo_weighted %>% select(cod_mpio, idf_municipal, w_i),
    by = "cod_mpio"
  )

t0_simp <- Sys.time()
n_vert_orig <- nrow(st_coordinates(shp_mpio_joined))
mem_orig_mb <- as.numeric(object.size(shp_mpio_joined)) / (1024^2)

# Simplificación adaptativa: si el shapefile es el MGN completo de alta densidad (>100.000 vértices)
# retiene 8% (keep = 0.08); si ya viene pre-simplificado, retiene 85% (keep = 0.85) para evitar triangulación.
keep_factor <- ifelse(n_vert_orig > 100000, 0.08, 0.85)
shp_mpio_opt <- suppressWarnings(
  ms_simplify(shp_mpio_joined, keep = keep_factor, keep_shapes = TRUE) %>%
    st_make_valid() %>%
    st_collection_extract("POLYGON") %>%
    st_cast("MULTIPOLYGON")
)

n_vert_opt <- nrow(st_coordinates(shp_mpio_opt))
mem_opt_mb <- as.numeric(object.size(shp_mpio_opt)) / (1024^2)
t_simp_seg <- as.numeric(difftime(Sys.time(), t0_simp, units = "secs"))

message(sprintf(
  "Diagnóstico Bono 1 (Mapa Municipal):\n - Polígonos MGN municipales: %d (con IDF evaluado: %d | ANMs y San Andrés sin IDF municipal: %d)\n - Vértices originales: %s -> Vértices optimizados (keep = %.2f): %s\n - Memoria objeto sf: %.2f MB -> %.2f MB (Tiempo: %.2f s)",
  nrow(shp_mpio_opt), sum(!is.na(shp_mpio_opt$idf_municipal)), sum(is.na(shp_mpio_opt$idf_municipal)),
  format(n_vert_orig, big.mark = ".", decimal.mark = ","), keep_factor, format(n_vert_opt, big.mark = ".", decimal.mark = ","),
  mem_orig_mb, mem_opt_mb, t_simp_seg
))

rango_mpio <- range(shp_mpio_opt$idf_municipal, na.rm = TRUE)
lim_mpio   <- c(25, 85)
cuantiles_mpio <- unique(as.numeric(quantile(
  shp_mpio_opt$idf_municipal,
  probs = c(0, 0.05, 0.25, 0.50, 0.75, 0.95, 1.0),
  na.rm = TRUE
)))
valores_reescalados_mpio <- scales::rescale(c(lim_mpio[1], cuantiles_mpio, lim_mpio[2]))

p_mapa_mpio <- ggplot() +
  geom_sf(
    data = shp_mpio_opt,
    aes(fill = idf_municipal),
    color = "#e5e7eb",
    linewidth = 0.05
  ) +
  geom_sf(
    data = shp_dpto,
    fill = NA,
    color = "#ffffff",
    linewidth = 0.32
  ) +
  scale_fill_viridis_c(
    option = "magma",
    name = "IDF Municipal\nVigencia 2024 (pts)",
    limits = lim_mpio,
    breaks = seq(30, 80, by = 10),
    values = valores_reescalados_mpio,
    na.value = "#d1d5db",
    direction = 1,
    guide = guide_colorbar(
      barheight = unit(5.2, "cm"),
      barwidth = unit(0.48, "cm"),
      frame.colour = "#374151",
      ticks.colour = "#374151"
    )
  ) +
  labs(
    title = "Índice de Desempeño Fiscal (IDF) Municipal en Colombia (Vigencia 2024)",
    subtitle = "Cobertura cartográfica MGN (1.102 polígonos evaluados y 20 territorios no municipalizados - Bono 1)",
    caption = paste0(
      "Fuente: Elaboración Grupo 10 con base en DNP (IDF Municipal Vigencia 2024: 1.103 municipios, incl. Nuevo Belén de Bajirá) y MGN DANE.\n",
      "Nota: Los polígonos en gris claro en Amazonas, Guainía y Vaupés corresponden a las Áreas No Municipalizadas (ANM), no sujetas a medición municipal."
    )
  ) +
  tema_mapa_institucional

ggsave(
  file.path(ruta_outputs_img, "1_2_mapa_idf_municipal_bono.png"),
  p_mapa_mpio,
  width = 8.8,
  height = 9.5,
  dpi = 300
)
message("Mapa municipal optimizado (Bono 1) exportado a Outputs/Images/1_2_mapa_idf_municipal_bono.png")

# ==============================================================================
# 5. SERIALIZACIÓN DE INSUMOS PARA LA PESTAÑA 1 DEL APLICATIVO SHINY
# ==============================================================================
# Preservamos una geometría departamental nítida en WGS84 (EPSG:4326) para Leaflet
keep_dpto_shiny <- ifelse(nrow(st_coordinates(shp_dpto)) > 50000, 0.15, 0.90)
shp_dpto_simp <- suppressWarnings(
  ms_simplify(shp_dpto, keep = keep_dpto_shiny, keep_shapes = TRUE) %>%
    st_make_valid() %>%
    st_collection_extract("POLYGON") %>%
    st_cast("MULTIPOLYGON") %>%
    mutate(DPTO_CCDGO = cod_dpto_shp) %>%
    left_join(df_idf_departamental, by = c("cod_dpto_shp" = "cod_dpto")) %>%
    st_transform(crs = 4326)
)

# Tabla Top 3 municipios con mayor IDF municipal dentro de cada departamento
df_top3 <- df_geo_weighted %>%
  group_by(cod_dpto, nom_dpto) %>%
  arrange(desc(idf_municipal), desc(w_i)) %>%
  slice_head(n = 3) %>%
  mutate(ranking_mpio = row_number()) %>%
  ungroup() %>%
  select(
    cod_dpto, nom_dpto, ranking_mpio, cod_mpio, nom_mpio,
    idf_municipal, rango_idf, w_i, pob_2024, va_2023, va_2024_proj
  )

saveRDS(shp_dpto_simp, file.path(ruta_shiny_data, "shp_dpto_simp.rds"))
saveRDS(df_idf_departamental, file.path(ruta_shiny_data, "df_deptos.rds"))
saveRDS(df_top3, file.path(ruta_shiny_data, "df_top3.rds"))

message("Insumos espaciales para Shiny actualizados en Scripts/Punto_3/data_shiny/ (shp_dpto_simp.rds, df_deptos.rds, df_top3.rds).")
