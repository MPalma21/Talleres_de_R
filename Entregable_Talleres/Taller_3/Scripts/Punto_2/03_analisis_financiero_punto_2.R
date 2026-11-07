# ==============================================================================
# Taller 3 - Punto 2: Integración de Series Macroeconómicas y Financieras
# Script: 03_analisis_financiero_punto_2.R
# Propósito: Leer las series individuales tratadas en CSV desde la carpeta raw/,
#            unirlas en una base continua, tratar festivos cruzados con forward-fill,
#            derivar el spread, exportar el archivo final único en processed/ y graficar.
# ==============================================================================

# Paquetes adicionales identificados explícitamente con [PAQUETE ADICIONAL]:
# [PAQUETE ADICIONAL]: scales (formateo porcentual y escalas secundarias en ggplot2)
# [PAQUETE ADICIONAL]: readr (lectura y escritura de series temporales en CSV)

# 1. Carga de librerías --------------------------------------------------------
library(tidyverse)
library(scales)
library(lubridate)
library(here)

# 2. Configuración de parámetros y rutas ---------------------------------------
dir_raw    <- here("Entregable_Talleres", "Taller_3", "Outputs", "Data", "raw")
dir_proc   <- here("Entregable_Talleres", "Taller_3", "Outputs", "Data", "processed")
dir_images <- here("Entregable_Talleres", "Taller_3", "Outputs", "Images")

dir.create(dir_proc, showWarnings = FALSE, recursive = TRUE)
dir.create(dir_images, showWarnings = FALSE, recursive = TRUE)

ruta_sofr_csv  <- file.path(dir_raw, "sofr_diaria_2020_2025.csv")
ruta_ibr_csv   <- file.path(dir_raw, "ibr_diaria_2020_2025.csv")
ruta_final_csv <- file.path(dir_proc, "series_financieras_ibr_sofr.csv")

# 3. Lectura de las series tratadas desde raw/ ---------------------------------
df_sofr <- read_csv(ruta_sofr_csv, show_col_types = FALSE) |>
  mutate(fecha = as.Date(fecha))

df_ibr <- read_csv(ruta_ibr_csv, show_col_types = FALSE) |>
  mutate(fecha = as.Date(fecha))

# 4. Integración y tratamiento de calendarios cruzados (EE. UU. vs Colombia) ----
# Unificación continua mediante 'full_join' y 'forward-fill' (fill()), respetando
# la convención de devengo de intereses en días feriados locales.
df_consolidado <- full_join(df_sofr, df_ibr, by = "fecha") |>
  arrange(fecha) |>
  fill(tasa_sofr, .direction = "down") |>
  fill(tasa_ibr, .direction = "down") |>
  filter(!is.na(tasa_sofr), !is.na(tasa_ibr)) |>
  mutate(
    spread_ibr_sofr = tasa_ibr - tasa_sofr
  )

# Exportación del archivo final procesado (único archivo final en processed/)
write_csv(df_consolidado, ruta_final_csv)

message("Archivo final generado exitosamente en: ", ruta_final_csv)

# 6. Tema visual institucional base --------------------------------------------
tema_institucional <- theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13, color = "#111827", margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.3, color = "#4b5563", margin = margin(b = 10)),
    plot.caption = element_text(size = 8, color = "#6b7280", hjust = 0, margin = margin(t = 10), lineheight = 1.15),
    axis.title.x = element_text(face = "bold", size = 9.5, color = "#1f2937", margin = margin(t = 6)),
    axis.title.y = element_text(face = "bold", size = 9.5, color = "#1f2937", margin = margin(r = 6)),
    axis.text = element_text(size = 8.8, color = "#374151"),
    axis.line.x = element_line(color = "#9ca3af", linewidth = 0.5),
    axis.ticks.x = element_line(color = "#9ca3af", linewidth = 0.4),
    panel.grid.major.y = element_line(color = "#e5e7eb", linewidth = 0.45),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "#ffffff", color = NA),
    panel.background = element_rect(fill = "#ffffff", color = NA),
    plot.margin = margin(t = 12, r = 14, b = 10, l = 12)
  )

# 7. Literal 2.a: Gráfico de la serie diaria IBR ON (2020-2025) ----------------
color_ibr       <- "#0f4c81" # Azul institucional para referencias y contrastes
color_linea_ibr <- "#111827" # Línea principal en negro profesional

# Identificación de los 3 puntos clave para destacar en la serie
pt_min_ibr   <- df_ibr |> filter(fecha == as.Date("2020-09-30"))
pt_pico_ibr  <- df_ibr |> filter(fecha == as.Date("2023-04-28"))
pt_final_ibr <- df_ibr |> filter(fecha == as.Date("2025-10-31"))

p_ibr <- ggplot(df_ibr, aes(x = fecha, y = tasa_ibr)) +
  # Franjas sutiles de contexto de política monetaria
  annotate("rect", xmin = as.Date("2020-03-27"), xmax = as.Date("2021-09-30"),
           ymin = 0, ymax = Inf, fill = "#15803d", alpha = 0.07) +
  annotate("rect", xmin = as.Date("2021-10-01"), xmax = as.Date("2023-04-30"),
           ymin = 0, ymax = Inf, fill = "#b91c1c", alpha = 0.06) +
  annotate("rect", xmin = as.Date("2023-05-01"), xmax = as.Date("2025-10-31"),
           ymin = 0, ymax = Inf, fill = "#1d4ed8", alpha = 0.04) +
  
  # Líneas de referencia punteadas en niveles clave
  geom_hline(yintercept = 1.75, linetype = "dotted", color = "#166534", linewidth = 0.45) +
  geom_hline(yintercept = 13.25, linetype = "dotted", color = "#991b1b", linewidth = 0.45) +
  
  # Curva principal de la serie en color negro
  geom_line(color = color_linea_ibr, linewidth = 0.95) +
  
  # Puntos destacados sobre la curva
  geom_point(data = pt_min_ibr, aes(x = fecha, y = tasa_ibr), color = "#166534", size = 2.8) +
  geom_point(data = pt_pico_ibr, aes(x = fecha, y = tasa_ibr), color = "#991b1b", size = 2.8) +
  geom_point(data = pt_final_ibr, aes(x = fecha, y = tasa_ibr), color = color_linea_ibr, size = 2.8) +
  
  # Etiqueta 1: Mínimo histórico (ubicada en la meseta baja de 2021, sin tapar la caída de 2020)
  annotate("label", x = as.Date("2021-04-15"), y = 5.2,
           label = "Mínimo Histórico: 1.75% E.A.\nFase de Estímulo y Alivio COVID-19\n(30 de septiembre de 2020)",
           size = 2.85, fontface = "bold", color = "#166534", fill = "#f0fdf4",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2021-02-15"), y = 4.2,
           xend = as.Date("2020-10-15"), yend = 1.95,
           curvature = 0.18, arrow = arrow(length = unit(1.8, "mm")),
           color = "#166534", linewidth = 0.5) +
  
  # Etiqueta 2: Pico contractivo (flota en espacio superior despejado sobre la meseta de 2023)
  annotate("label", x = as.Date("2023-07-01"), y = 15.0,
           label = "Pico Contractivo: 13.25% E.A.\nMáximo Ciclo Anti-inflacionario\n(28 de abril de 2023)",
           size = 2.85, fontface = "bold", color = "#991b1b", fill = "#fef2f2",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2023-05-15"), y = 14.3,
           xend = as.Date("2023-04-28"), yend = 13.45,
           curvature = 0.15, arrow = arrow(length = unit(1.8, "mm")),
           color = "#991b1b", linewidth = 0.5) +
  
  # Etiqueta 3: Cierre de observación (ubicada en el cuadrante inferior derecho, sin tapar la bajada)
  annotate("label", x = as.Date("2025-03-15"), y = 5.2,
           label = "Cierre de Observación: 9.25% E.A.\nFase de Normalización y Recortes\n(31 de octubre de 2025)",
           size = 2.85, fontface = "bold", color = "#1e3a8a", fill = "#eff6ff",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2025-06-15"), y = 5.9,
           xend = as.Date("2025-10-25"), yend = 9.0,
           curvature = -0.18, arrow = arrow(length = unit(1.8, "mm")),
           color = "#1e3a8a", linewidth = 0.5) +
  
  # Ejes ceñidos a los límites de la serie con espacio vertical superior adecuado
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y",
    limits = c(as.Date("2020-01-02"), as.Date("2025-10-31")),
    expand = expansion(mult = c(0.005, 0.005))
  ) +
  scale_y_continuous(
    labels = label_percent(scale = 1, accuracy = 1),
    breaks = seq(0, 16, by = 2),
    limits = c(0, 16.0),
    expand = expansion(mult = c(0.005, 0.02))
  ) +
  labs(
    title = "Indicador Bancario de Referencia (IBR Overnight - ON) en Colombia",
    subtitle = "Evolución diaria de la tasa de política e interbancaria (2020–2025) | Tasa Efectiva Anual (% E.A., base 360 días)",
    x = "Fecha de Negociación (Frecuencia Diaria)",
    y = "Tasa de Interés IBR Overnight (% E.A.)",
    caption = "Fuente: Banco de la República de Colombia (Sistema SUAMECA - Serie Oficial IRIBRM00 ER).\nElaboración propia con base en registros oficiales del mercado monetario interbancario."
  ) +
  tema_institucional

ggsave(
  filename = file.path(dir_images, "2_a_tasa_ibr_diaria.png"),
  plot = p_ibr,
  width = 9.5,
  height = 5.2,
  dpi = 300
)

# 8. Literal 2.b: Gráfico de la serie diaria SOFR ON (2020-2025) ---------------
color_linea_sofr <- "#111827" # Línea principal en negro institucional
color_acento_sofr <- "#0f766e" # Tono petróleo para detalles y anotaciones

# Puntos representativos de la serie SOFR
pt_min_sofr   <- df_sofr |> filter(fecha == as.Date("2021-03-01"))
pt_pico_sofr  <- df_sofr |> filter(fecha == as.Date("2023-07-27"))
pt_final_sofr <- df_sofr |> filter(fecha == as.Date("2025-10-31"))

p_sofr <- ggplot(df_sofr, aes(x = fecha, y = tasa_sofr)) +
  # Franjas de contexto macroeconómico estadounidense
  annotate("rect", xmin = as.Date("2020-03-15"), xmax = as.Date("2022-03-15"),
           ymin = 0, ymax = Inf, fill = "#0284c7", alpha = 0.08) +
  annotate("rect", xmin = as.Date("2022-03-16"), xmax = as.Date("2023-07-26"),
           ymin = 0, ymax = Inf, fill = "#b91c1c", alpha = 0.07) +
  annotate("rect", xmin = as.Date("2023-07-27"), xmax = as.Date("2025-10-31"),
           ymin = 0, ymax = Inf, fill = "#0f766e", alpha = 0.05) +
  
  # Líneas de referencia punteadas en niveles clave
  geom_hline(yintercept = 0.05, linetype = "dotted", color = "#0369a1", linewidth = 0.45) +
  geom_hline(yintercept = 5.30, linetype = "dotted", color = "#991b1b", linewidth = 0.45) +
  
  # Curva principal de la serie en color negro
  geom_line(color = color_linea_sofr, linewidth = 0.95) +
  
  # Puntos destacados sobre la curva
  geom_point(data = pt_min_sofr, aes(x = fecha, y = tasa_sofr), color = "#0369a1", size = 2.8) +
  geom_point(data = pt_pico_sofr, aes(x = fecha, y = tasa_sofr), color = "#991b1b", size = 2.8) +
  geom_point(data = pt_final_sofr, aes(x = fecha, y = tasa_sofr), color = color_linea_sofr, size = 2.8) +
  
  # Etiqueta 1: Piso ZIRP (ubicada en meseta baja de 2021, sin tapar la caída de 2020)
  annotate("label", x = as.Date("2021-04-15"), y = 2.2,
           label = "Piso Histórico ZIRP: ~0.05%\nPolítica de Tasa Cero COVID-19\n(Período 2020–2022)",
           size = 2.85, fontface = "bold", color = "#0369a1", fill = "#f0f9ff",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2021-02-15"), y = 1.65,
           xend = as.Date("2020-11-15"), yend = 0.2,
           curvature = 0.18, arrow = arrow(length = unit(1.8, "mm")),
           color = "#0369a1", linewidth = 0.5) +
  
  # Etiqueta 2: Pico Fed Funds (flota en espacio superior despejado sobre la meseta de 2023)
  annotate("label", x = as.Date("2023-09-15"), y = 6.2,
           label = "Pico Contractivo Fed: 5.30%\nMáximo Rango Objetivo (5.25%–5.50%)\n(27 de julio de 2023)",
           size = 2.85, fontface = "bold", color = "#991b1b", fill = "#fef2f2",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2023-07-15"), y = 5.85,
           xend = as.Date("2023-07-27"), yend = 5.42,
           curvature = 0.15, arrow = arrow(length = unit(1.8, "mm")),
           color = "#991b1b", linewidth = 0.5) +
  
  # Etiqueta 3: Cierre de observación (cuadrante inferior derecho despejado, sin tapar bajada)
  annotate("label", x = as.Date("2025-03-15"), y = 2.0,
           label = "Cierre de Observación: 4.22%\nFase de Flexibilización Monetaria\n(31 de octubre de 2025)",
           size = 2.85, fontface = "bold", color = color_acento_sofr, fill = "#f0fdfa",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2025-06-15"), y = 2.4,
           xend = as.Date("2025-10-25"), yend = 4.10,
           curvature = -0.18, arrow = arrow(length = unit(1.8, "mm")),
           color = color_acento_sofr, linewidth = 0.5) +
  
  # Ajuste ceñido de ejes con margen superior amplio
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y",
    limits = c(as.Date("2020-01-02"), as.Date("2025-10-31")),
    expand = expansion(mult = c(0.005, 0.005))
  ) +
  scale_y_continuous(
    labels = label_percent(scale = 1, accuracy = 0.5),
    breaks = seq(0, 6, by = 1),
    limits = c(0, 6.8),
    expand = expansion(mult = c(0.005, 0.02))
  ) +
  labs(
    title = "Secured Overnight Financing Rate (SOFR Overnight - ON) en Estados Unidos",
    subtitle = "Evolución diaria de la tasa de fondeo colateralizada con bonos del Tesoro (2020–2025) | Base Actual/360",
    x = "Fecha de Transacción (Frecuencia Diaria)",
    y = "Tasa SOFR Overnight Anualizada (% Actual/360)",
    caption = "Fuente: Federal Reserve Bank of New York (Markets Data API Oficial).\nElaboración propia con base en transacciones efectivas del mercado monetario repo tripartito."
  ) +
  tema_institucional

ggsave(
  filename = file.path(dir_images, "2_b_tasa_sofr_diaria.png"),
  plot = p_sofr,
  width = 9.5,
  height = 5.2,
  dpi = 300
)

# 9. Literal 2.c: Gráfico conjunto con doble eje (SOFR izq. e IBR der.) ---------
factor_escala <- 2.5
color_sofr_doble <- "#0f766e" # Verde petróleo institucional para SOFR
color_ibr_doble  <- "#111827" # Negro profesional para IBR (consistencia con Figura 1)

# Puntos clave para el gráfico doble eje
pt_pico_ibr_c  <- tibble(fecha = as.Date("2023-04-28"), y_plot = 13.250 / factor_escala)
pt_pico_sofr_c <- tibble(fecha = as.Date("2023-07-27"), y_plot = 5.300)
pt_final_ibr_c <- tibble(fecha = as.Date("2025-10-31"), y_plot = 9.250 / factor_escala)
pt_final_sofr_c<- tibble(fecha = as.Date("2025-10-31"), y_plot = 4.220)

p_doble_eje <- ggplot(df_consolidado, aes(x = fecha)) +
  # Franjas de contexto macroeconómico global conjunto
  annotate("rect", xmin = as.Date("2020-03-20"), xmax = as.Date("2021-09-30"),
           ymin = 0, ymax = Inf, fill = "#15803d", alpha = 0.05) +
  annotate("rect", xmin = as.Date("2021-10-01"), xmax = as.Date("2023-06-30"),
           ymin = 0, ymax = Inf, fill = "#b91c1c", alpha = 0.05) +
  annotate("rect", xmin = as.Date("2023-07-01"), xmax = as.Date("2025-10-31"),
           ymin = 0, ymax = Inf, fill = "#1d4ed8", alpha = 0.04) +
  
  # Curvas de las tasas
  geom_line(aes(y = tasa_sofr, color = "SOFR ON (EE. UU. - Reserva Federal) [Eje Izq.]"), linewidth = 0.95) +
  geom_line(aes(y = tasa_ibr / factor_escala, color = "IBR ON (Colombia - Banco de la República) [Eje Der.]"), linewidth = 0.95) +
  
  # Puntos destacados en picos y cierres
  geom_point(data = pt_pico_sofr_c, aes(x = fecha, y = y_plot), color = color_sofr_doble, size = 2.6) +
  geom_point(data = pt_pico_ibr_c, aes(x = fecha, y = y_plot), color = color_ibr_doble, size = 2.6) +
  geom_point(data = pt_final_sofr_c, aes(x = fecha, y = y_plot), color = color_sofr_doble, size = 2.4) +
  geom_point(data = pt_final_ibr_c, aes(x = fecha, y = y_plot), color = color_ibr_doble, size = 2.4) +
  
  # Etiqueta 1: Fase de Alivio Sincronizado (cuadrante superior izquierdo despejado)
  annotate("label", x = as.Date("2021-02-15"), y = 5.6,
           label = "Estímulo Monetario Sincronizado (2020–2021)\nPiso Histórico de Tasas por Emergencia COVID-19\nIBR: 1.75% E.A. | SOFR: ~0.05%",
           size = 2.8, fontface = "bold", color = "#166534", fill = "#f0fdf4",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2021-02-15"), y = 4.8,
           xend = as.Date("2021-02-15"), yend = 1.0,
           curvature = 0.15, arrow = arrow(length = unit(1.8, "mm")),
           color = "#166534", linewidth = 0.5) +
  
  # Etiqueta 2: Picos del Ciclo Contractivo (flota arriba de los techos en 2023)
  annotate("label", x = as.Date("2023-06-01"), y = 6.25,
           label = "Picos del Ciclo Contractivo (2023)\nAjuste Anti-inflacionario Récord en Ambos Países\nIBR máx: 13.25% (abr-23) | SOFR máx: 5.30% (jul-23)",
           size = 2.8, fontface = "bold", color = "#991b1b", fill = "#fef2f2",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2023-05-15"), y = 5.8,
           xend = as.Date("2023-05-15"), yend = 5.4,
           curvature = 0.15, arrow = arrow(length = unit(1.8, "mm")),
           color = "#991b1b", linewidth = 0.5) +
  
  # Etiqueta 3: Normalización y Spread (cuadrante inferior derecho despejado)
  annotate("label", x = as.Date("2025-01-15"), y = 1.6,
           label = "Fase de Normalización y Recortes (2025)\nDiferencial de Tasas (Spread): ~503 bps\nIBR: 9.25% E.A. | SOFR: 4.22% (31-oct-2025)",
           size = 2.8, fontface = "bold", color = "#1e40af", fill = "#eff6ff",
           label.padding = unit(0.28, "lines"), linewidth = 0.3) +
  annotate("curve", x = as.Date("2025-04-15"), y = 2.2,
           xend = as.Date("2025-09-15"), yend = 3.6,
           curvature = -0.15, arrow = arrow(length = unit(1.8, "mm")),
           color = "#1e40af", linewidth = 0.5) +

  scale_color_manual(
    name = NULL,
    values = c(
      "SOFR ON (EE. UU. - Reserva Federal) [Eje Izq.]" = color_sofr_doble,
      "IBR ON (Colombia - Banco de la República) [Eje Der.]" = color_ibr_doble
    )
  ) +
  scale_x_date(
    date_breaks = "1 year",
    date_labels = "%Y",
    limits = c(as.Date("2020-01-02"), as.Date("2025-10-31")),
    expand = expansion(mult = c(0.005, 0.005))
  ) +
  scale_y_continuous(
    name = "Tasa SOFR Overnight (% Anualizado, Actual/360) [Eje Izquierdo]",
    labels = label_percent(scale = 1, accuracy = 0.5),
    limits = c(0, 6.8),
    breaks = seq(0, 6, by = 1),
    expand = expansion(mult = c(0.005, 0.02)),
    sec.axis = sec_axis(
      transform = ~ . * factor_escala,
      name = "Tasa IBR Overnight (% E.A., base 360 días) [Eje Derecho]",
      labels = label_percent(scale = 1, accuracy = 1),
      breaks = seq(0, 15, by = 2.5)
    )
  ) +
  labs(
    title = "Comparación de Tasas de Política Monetaria: SOFR (EE. UU.) vs. IBR (Colombia)",
    subtitle = "Dinámica diaria sincronizada con doble eje independiente (2020–2025) | Armonización continua de calendarios bancarios",
    x = "Fecha de Negociación (Frecuencia Diaria)",
    caption = "Fuentes: Federal Reserve Bank of New York (API Markets) y Banco de la República de Colombia (Web Scraping SDMX).\nTratamiento de festivos: Calendario continuo consolidado vía forward-fill (locf). Elaboración propia."
  ) +
  tema_institucional +
  theme(
    axis.title.y.left = element_text(face = "bold", size = 9.5, color = color_sofr_doble, margin = margin(r = 6)),
    axis.title.y.right = element_text(face = "bold", size = 9.5, color = color_ibr_doble, margin = margin(l = 6)),
    axis.text.y.left = element_text(color = color_sofr_doble, face = "bold"),
    axis.text.y.right = element_text(color = color_ibr_doble, face = "bold"),
    axis.line.y.left = element_line(color = color_sofr_doble, linewidth = 0.5),
    axis.line.y.right = element_line(color = color_ibr_doble, linewidth = 0.5),
    axis.ticks.y.left = element_line(color = color_sofr_doble, linewidth = 0.4),
    axis.ticks.y.right = element_line(color = color_ibr_doble, linewidth = 0.4),
    legend.position = "top",
    legend.justification = "center",
    legend.text = element_text(size = 9.5, face = "bold"),
    legend.margin = margin(b = 6)
  )

ggsave(
  filename = file.path(dir_images, "2_c_doble_eje_ibr_sofr.png"),
  plot = p_doble_eje,
  width = 10.5,
  height = 5.8,
  dpi = 300
)
