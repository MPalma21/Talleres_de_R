# ==============================================================================
# Aplicativo Shiny Interactivo Modular - Taller 3
# Curso: Taller de Programación en R (2026-2)
# Facultad de Economía, Universidad de los Andes
# Grupo 10: Juan José Echeverry, Miguelangel Palma, Sergio López
#
# Arquitectura Modular en R/:
# - R/00_tema_y_datos.R : Carga defensiva de insumos RDS y tema bslib Bootstrap 5
# - R/mod_tab1_idf.R    : Módulo Pestaña 1 (Mapa Leaflet IDF Dpto. y Top 3 Mpios)
# - R/mod_tab2_tasas.R  : Módulo Pestaña 2 (Doble eje SOFR/IBR y Calculadora π)
# - R/mod_tab3_libre.R  : Módulo Pestaña 3 (Diseño libre en Plotly: Dualismo e IDF)
# ==============================================================================

# Paquetes adicionales identificados explícitamente con [PAQUETE ADICIONAL]:
# [PAQUETE ADICIONAL]: shiny (framework de aplicaciones web interactivas y módulos NS/moduleServer)
# [PAQUETE ADICIONAL]: bslib (arquitectura de interfaz Bootstrap 5, tarjetas, value_box y modo oscuro)
# [PAQUETE ADICIONAL]: leaflet (cartografía web interactiva para polígonos espaciales)
# [PAQUETE ADICIONAL]: plotly (gráficos interactivos con zoom, hover y doble eje)
# [PAQUETE ADICIONAL]: DT (tablas interactivas paginadas para auditoría de datos)
# [PAQUETE ADICIONAL]: sf (manejo de capas vectoriales Simple Features)
# [PAQUETE ADICIONAL]: scales (formateo de escalas numéricas y monetarias)

posibles_libs <- c(
  file.path(getwd(), "librerias"),
  file.path(getwd(), "..", "..", "..", "librerias")
)
dir_lib <- posibles_libs[dir.exists(posibles_libs)][1]
if (!is.na(dir_lib)) {
  .libPaths(c(normalizePath(dir_lib), .libPaths()))
}

library(shiny)
library(bslib)
library(leaflet)
library(plotly)
library(DT)
library(dplyr)
library(sf)
library(readr)
library(scales)

# Carga explícita de módulos cuando app.R se ejecuta fuera de shiny::runApp()
if (!exists("cargar_datos_shiny", mode = "function")) {
  rutas_r <- c(
    file.path(getwd(), "R"),
    file.path(getwd(), "Entregable_Talleres", "Taller_3", "Scripts", "Punto_3", "R")
  )
  dir_r <- rutas_r[dir.exists(rutas_r)][1]
  if (!is.na(dir_r)) {
    for (f in sort(list.files(dir_r, pattern = "\\.[rR]$", full.names = TRUE))) {
      source(f, local = FALSE, encoding = "UTF-8")
    }
  }
}

# 1. Inicialización de datos y tema visual -------------------------------------
datos_app <- cargar_datos_shiny()
tema_app  <- crear_tema_app()

# 2. Interfaz de Usuario (UI) --------------------------------------------------
ui <- page_navbar(
  title    = "Taller 3 · Grupo 10 | Tablero Económico y Territorial",
  theme    = tema_app,
  fillable = TRUE,

  nav_panel(
    title = "1. Desempeño Fiscal (IDF)",
    icon  = icon("map-location-dot"),
    class = "bslib-page-dashboard",
    mod_tab1_idf_ui("tab1_idf", deptos_choices = datos_app$deptos_choices)
  ),

  nav_panel(
    title = "2. Tasas y Devaluación (π)",
    icon  = icon("chart-line"),
    class = "bslib-page-dashboard",
    mod_tab2_tasas_ui(
      "tab2_tasas",
      min_fecha = datos_app$min_fecha,
      max_fecha = datos_app$max_fecha
    )
  ),

  nav_panel(
    title = "3. Diseño Libre (Plotly)",
    icon  = icon("chart-pie"),
    class = "bslib-page-dashboard",
    mod_tab3_libre_ui("tab3_libre", regiones_choices = datos_app$regiones_choices)
  ),

  nav_spacer(),
  nav_item(
    input_dark_mode(id = "modo_color", mode = "light")
  )
)

# 3. Servidor Principal (Orquestador de Módulos) -------------------------------
server <- function(input, output, session) {
  mod_tab1_idf_server(
    id             = "tab1_idf",
    shp_dpto_simp  = datos_app$shp_dpto_simp,
    df_deptos      = datos_app$df_deptos,
    df_top3        = datos_app$df_top3,
    deptos_choices = datos_app$deptos_choices
  )

  mod_tab2_tasas_server(
    id       = "tab2_tasas",
    df_rates = datos_app$df_rates
  )

  mod_tab3_libre_server(
    id               = "tab3_libre",
    df_labor         = datos_app$df_labor,
    regiones_choices = datos_app$regiones_choices
  )
}

shinyApp(ui = ui, server = server)
