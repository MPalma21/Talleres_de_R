# ==============================================================================
# UNIVERSIDAD DE LOS ANDES - FACULTAD DE ECONOMÍA
# Taller de Programación en R (2026-2)
# TALLER 3: Ejercicio 3 - Preparación Reproducible de Insumos para Shiny
#
# GRUPO 10:
# - Juan José Echeverry (Código: 202616233)
# - Miguelangel Palma   (Código: 202621481)
# - Sergio López        (Código: 202111932)
#
# Eje 3: Diseño Libre, Arquitectura Shiny e Integridad Reproducible
# Responsable: Juan José Echeverry
# ==============================================================================

# Paquetes adicionales identificados explícitamente con [PAQUETE ADICIONAL]:
# [PAQUETE ADICIONAL]: readr (lectura y escritura de tablas CSV con codificación UTF-8)
# [PAQUETE ADICIONAL]: stringr (normalización de códigos DIVIPOLA de dos dígitos)
# [PAQUETE ADICIONAL]: scales (formateo de escalas monetarias y porcentuales en gráficas)
# [PAQUETE ADICIONAL]: ggrepel (etiquetas de texto sin solapamiento en visualizaciones estáticas)

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(ggplot2)
  library(scales)
  library(here)
})

# 1. Localización robusta de rutas del repositorio -----------------------------
dir_taller3 <- here("Entregable_Talleres", "Taller_3")
dir_raw     <- file.path(dir_taller3, "Outputs", "Data", "raw")
dir_proc    <- file.path(dir_taller3, "Outputs", "Data", "processed")
dir_images  <- file.path(dir_taller3, "Outputs", "Images")
dir_punto3  <- file.path(dir_taller3, "Scripts", "Punto_3")
dir_shiny   <- file.path(dir_punto3, "data_shiny")

dir.create(dir_shiny, recursive = TRUE, showWarnings = FALSE)
dir.create(dir_images, recursive = TRUE, showWarnings = FALSE)

# ==============================================================================
# 2. PREPARACIÓN DE SERIES FINANCIERAS PARA PESTAÑA 2 (LITERAL 3.B)
# ==============================================================================
# El enunciado exige informar cuando falta alguna tasa en la fecha elegida y usar
# tasas en decimales con convenciones comparables. Conservamos tanto el valor
# crudo observado (sofr_raw, ibr_raw) como la serie continua por forward-fill
# (sofr_on, ibr_on) y la tasa SOFR capitalizada a Efectiva Anual base 360 (sofr_ea).

df_sofr_raw <- read_csv(
  file.path(dir_raw, "sofr_diaria_2020_2025.csv"),
  show_col_types = FALSE
) |>
  transmute(
    fecha    = as.Date(fecha),
    sofr_raw = as.numeric(tasa_sofr)
  )

df_ibr_raw <- read_csv(
  file.path(dir_raw, "ibr_diaria_2020_2025.csv"),
  show_col_types = FALSE
) |>
  transmute(
    fecha   = as.Date(fecha),
    ibr_raw = as.numeric(tasa_ibr)
  )

df_rates <- full_join(df_sofr_raw, df_ibr_raw, by = "fecha") |>
  arrange(fecha) |>
  mutate(
    sofr_on = sofr_raw,
    ibr_on  = ibr_raw
  ) |>
  fill(sofr_on, .direction = "down") |>
  fill(ibr_on, .direction = "down") |>
  filter(!is.na(sofr_on), !is.na(ibr_on)) |>
  mutate(
    falta_sofr      = is.na(sofr_raw),
    falta_ibr       = is.na(ibr_raw),
    estado_mercado  = case_when(
      !falta_sofr & !falta_ibr ~ "Día hábil simultáneo (observación primaria en ambos mercados)",
      !falta_sofr &  falta_ibr ~ "Festivo bancario en Colombia (IBR imputada por forward-fill)",
       falta_sofr & !falta_ibr ~ "Festivo federal en EE. UU. (SOFR imputada por forward-fill)",
      TRUE                     ~ "Sin cotización primaria"
    ),
    # Homogeneización de SOFR (Nominal Actual/360) a Efectiva Anual (base 360)
    sofr_ea         = ((1 + (sofr_on / 100) / 360)^360 - 1) * 100,
    spread_ibr_sofr = ibr_on - sofr_on,
    spread_ea       = ibr_on - sofr_ea,
    # Devaluación implícita pi = (1 + i_d) / (1 + i_e) - 1 en porcentaje
    pi_directa      = (((1 + ibr_on / 100) / (1 + sofr_on / 100)) - 1) * 100,
    pi_ea           = (((1 + ibr_on / 100) / (1 + sofr_ea / 100)) - 1) * 100
  )

saveRDS(df_rates, file.path(dir_shiny, "df_rates.rds"))
message(sprintf(
  "df_rates.rds actualizado (%d días hábiles combinados | %d festivos Col | %d festivos EE. UU.).",
  nrow(df_rates),
  sum(df_rates$falta_ibr),
  sum(df_rates$falta_sofr)
))

# ==============================================================================
# 3. PREPARACIÓN DE LA BASE DEPARTAMENTAL PARA PESTAÑA 3 (LITERAL 3.C)
# ==============================================================================
# Integramos los indicadores departamentales de informalidad e ingreso laboral
# mediano (GEIH + EMICRON 2024, Taller 2) con el Índice de Desempeño Fiscal
# departamental ponderado y el Valor Agregado per cápita 2024 (Ejercicio 1, Taller 3).

ruta_taller2_dpto <- here("outputs", "4_1_tabla_departamental.csv")
ruta_csv_3c       <- file.path(dir_punto3, "datos_ejercicio_3c_laboral.csv")

if (file.exists(ruta_taller2_dpto)) {
  df_labor_base <- read_csv(ruta_taller2_dpto, show_col_types = FALSE) |>
    select(
      DPTO_NUM, OCUPADOS_EXP, INFORMALES_EXP,
      TASA_INFORMALIDAD, INGRESO_MEDIANO, NOMBRE_DPTO, REGION
    )
} else {
  df_labor_base <- read_csv(ruta_csv_3c, show_col_types = FALSE) |>
    select(
      DPTO_NUM, OCUPADOS_EXP, INFORMALES_EXP,
      TASA_INFORMALIDAD, INGRESO_MEDIANO, NOMBRE_DPTO, REGION
    )
}

df_idf_dpto <- read_csv(
  file.path(dir_proc, "idf_departamental_2024.csv"),
  show_col_types = FALSE
)

df_labor <- df_labor_base |>
  mutate(
    DPTO_NUM = as.integer(DPTO_NUM),
    COD_DPTO = str_pad(as.character(DPTO_NUM), width = 2, side = "left", pad = "0"),
    NOMBRE_DPTO = case_when(
      DPTO_NUM == 8  ~ "Atlántico",
      DPTO_NUM == 11 ~ "Bogotá D.C.",
      DPTO_NUM == 13 ~ "Bolívar",
      DPTO_NUM == 15 ~ "Boyacá",
      DPTO_NUM == 18 ~ "Caquetá",
      DPTO_NUM == 23 ~ "Córdoba",
      DPTO_NUM == 27 ~ "Chocó",
      DPTO_NUM == 52 ~ "Nariño",
      DPTO_NUM == 63 ~ "Quindío",
      TRUE           ~ NOMBRE_DPTO
    ),
    REGION = case_when(
      str_detect(REGION, "Pac")   ~ "Pacífica",
      str_detect(REGION, "Amaz")  ~ "Amazonía/Orinoquía",
      str_detect(REGION, "Bogot") ~ "Bogotá D.C.",
      TRUE                        ~ REGION
    )
  ) |>
  left_join(
    df_idf_dpto |>
      transmute(
        COD_DPTO          = str_pad(as.character(cod_dpto), 2, pad = "0"),
        IDF_DEPARTAMENTAL = round(idf_departamental, 2),
        N_MPIOS           = n_mpios,
        POB_2024          = pob_dpto_2024,
        VA_2024_PROJ      = round(va_dpto_2024_proj, 2),
        VA_PC_2024        = round((va_dpto_2024_proj * 1e3) / pob_dpto_2024, 2)
      ),
    by = "COD_DPTO"
  ) |>
  arrange(DPTO_NUM)

write_csv(df_labor, ruta_csv_3c)
saveRDS(df_labor, file.path(dir_shiny, "df_labor.rds"))
message(sprintf(
  "datos_ejercicio_3c_laboral.csv y df_labor.rds actualizados (%d departamentos con cruce GEIH 2024 + IDF 2024).",
  nrow(df_labor)
))

# ==============================================================================
# 4. FIGURA ESTÁTICA DE RESPALDO PARA EL INFORME QUARTO (PDF Y HTML)
# ==============================================================================
prom_inf <- mean(df_labor$TASA_INFORMALIDAD, na.rm = TRUE)
prom_ing <- mean(df_labor$INGRESO_MEDIANO, na.rm = TRUE) / 1e6

paleta_regiones <- c(
  "Bogotá D.C."        = "#1d4ed8",
  "Central"            = "#0f766e",
  "Oriental"           = "#15803d",
  "Caribe"             = "#d97706",
  "Pacífica"           = "#b91c1c",
  "Amazonía/Orinoquía" = "#7c3aed"
)

p_dualismo <- ggplot(
  df_labor,
  aes(x = TASA_INFORMALIDAD, y = INGRESO_MEDIANO / 1e6)
) +
  geom_vline(
    xintercept = prom_inf,
    linetype = "dashed",
    color = "#9ca3af",
    linewidth = 0.5
  ) +
  geom_hline(
    yintercept = prom_ing,
    linetype = "dashed",
    color = "#9ca3af",
    linewidth = 0.5
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = TRUE,
    color = "#1e293b",
    fill = "#cbd5e1",
    alpha = 0.25,
    linewidth = 0.75
  ) +
  geom_point(
    aes(size = OCUPADOS_EXP / 1e3, fill = REGION),
    shape = 21,
    color = "#111827",
    stroke = 0.5,
    alpha = 0.85
  ) +
  {
    if (requireNamespace("ggrepel", quietly = TRUE)) {
      ggrepel::geom_text_repel(
        aes(label = NOMBRE_DPTO),
        size = 2.75,
        fontface = "bold",
        color = "#1f2937",
        box.padding = 0.35,
        point.padding = 0.4,
        segment.color = "#6b7280",
        segment.size = 0.3,
        max.overlaps = 30,
        seed = 10
      )
    } else {
      geom_text(
        aes(label = NOMBRE_DPTO),
        size = 2.65,
        fontface = "bold",
        color = "#1f2937",
        vjust = -1.2,
        check_overlap = TRUE
      )
    }
  } +
  scale_fill_manual(values = paleta_regiones, name = "Región") +
  scale_size_continuous(
    name = "Ocupados (miles)",
    range = c(3, 13),
    labels = label_number(big.mark = ",")
  ) +
  scale_x_continuous(
    labels = label_percent(scale = 1, accuracy = 1),
    limits = c(30, 88),
    breaks = seq(30, 85, by = 10)
  ) +
  scale_y_continuous(
    labels = label_dollar(prefix = "$", suffix = " M", accuracy = 0.1),
    limits = c(0.72, 1.62),
    breaks = seq(0.8, 1.6, by = 0.2)
  ) +
  labs(
    title = "Dualismo Territorial en Colombia: Informalidad Laboral vs. Ingreso Mediano (2024)",
    subtitle = "Relación departamental ponderada por tamaño de población ocupada expandida y región geográfica",
    x = "Tasa de Informalidad Laboral DANE (%)",
    y = "Mediana del Ingreso Laboral Mensual (Millones de COP)",
    caption = paste0(
      "Fuente: Elaboración Grupo 10 a partir de microdatos GEIH 2024 y EMICRON 2024 (DANE), cruzados con IDF 2024 (DNP).\n",
      "Nota: Las líneas punteadas indican el promedio departamental (Informalidad = ",
      sprintf("%.1f%%", prom_inf),
      ", Ingreso mediano = $",
      sprintf("%.2f M", prom_ing),
      "). Ajuste lineal MCO en gris."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12.8, color = "#111827", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.3, color = "#4b5563", margin = margin(b = 10)),
    plot.caption = element_text(size = 8, color = "#6b7280", hjust = 0, margin = margin(t = 10), lineheight = 1.15),
    axis.title.x = element_text(face = "bold", size = 9.5, color = "#1f2937", margin = margin(t = 6)),
    axis.title.y = element_text(face = "bold", size = 9.5, color = "#1f2937", margin = margin(r = 6)),
    legend.position = "right",
    legend.title = element_text(face = "bold", size = 9),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#ffffff", color = NA),
    panel.background = element_rect(fill = "#ffffff", color = NA)
  ) +
  guides(fill = guide_legend(override.aes = list(size = 4.2)))

ggsave(
  filename = file.path(dir_images, "3_c_dualismo_laboral_idf.png"),
  plot = p_dualismo,
  width = 9.8,
  height = 5.8,
  dpi = 300
)
message("Figura estática exportada a Outputs/Images/3_c_dualismo_laboral_idf.png")
