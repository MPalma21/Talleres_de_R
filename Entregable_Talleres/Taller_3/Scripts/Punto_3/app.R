# ==============================================================================
# Aplicativo Shiny Interactivo Modular - Taller 3
# Curso: Taller de Programación en R (2026-2)
# Facultad de Economía, Universidad de los Andes
# Grupo 10: Juan José Echeverry, Miguelangel Palma, Sergio López
#
# Arquitectura Modular en R/:
# - R/00_tema_y_datos.R : Carga defensiva de insumos RDS, tema bslib y KPIs
# - R/mod_tab1_idf.R    : Módulo Pestaña 1 (Mapa Leaflet IDF Dpto. y Top 3 Mpios)
# - R/mod_tab2_tasas.R  : Módulo Pestaña 2 (Doble eje SOFR/IBR y Paridad UIP)
# - R/mod_tab3_libre.R  : Módulo Pestaña 3 (Dualismo Laboral y Capacidad Fiscal)
# ==============================================================================

# Paquetes adicionales identificados explícitamente con [PAQUETE ADICIONAL]:
# [PAQUETE ADICIONAL]: shiny (framework de aplicaciones web interactivas, módulos NS/moduleServer y withMathJax)
# [PAQUETE ADICIONAL]: bslib (arquitectura de interfaz Bootstrap 5 y grillas responsivas)
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

# Registro de la ruta de activos estáticos (CSS institucional y controlador MathJax JS)
rutas_www <- c(
  file.path(getwd(), "www"),
  file.path(getwd(), "Scripts", "Punto_3", "www"),
  file.path(getwd(), "Entregable_Talleres", "Taller_3", "Scripts", "Punto_3", "www"),
  file.path(getwd(), "..", "Punto_3", "www")
)
dir_www <- rutas_www[dir.exists(rutas_www)][1]
if (!is.na(dir_www) && dir.exists(dir_www)) {
  shiny::addResourcePath("modern_ui", normalizePath(dir_www))
}

# Carga explícita de módulos cuando app.R se ejecuta fuera de shiny::runApp()
if (!exists("cargar_datos_shiny", mode = "function")) {
  rutas_r <- c(
    file.path(getwd(), "R"),
    file.path(getwd(), "Scripts", "Punto_3", "R"),
    file.path(getwd(), "Entregable_Talleres", "Taller_3", "Scripts", "Punto_3", "R"),
    file.path(getwd(), "..", "Punto_3", "R")
  )
  dir_r <- rutas_r[dir.exists(rutas_r)][1]
  if (!is.na(dir_r)) {
    for (f in sort(list.files(dir_r, pattern = "\\.[rR]$", full.names = TRUE))) {
      source(f, local = FALSE, encoding = "UTF-8")
    }
  }
}

# 1. Inicialización de datos y tema institucional ------------------------------
datos_app <- cargar_datos_shiny()
tema_app  <- crear_tema_app()

# 2. Interfaz de Usuario (UI) Institucional ------------------------------------
ui <- page_navbar(
  title = tags$div(
    class = "brand-wrapper",
    tags$img(
      src   = "modern_ui/img/logo_uniandes.png",
      alt   = "Universidad de los Andes",
      class = "brand-logo"
    ),
    tags$span(class = "brand-divider"),
    tags$span(
      class = "brand-text",
      "Taller 3 ",
      tags$span(class = "brand-subtitle", "| Grupo 10")
    )
  ),
  window_title    = "Taller 3 · Grupo 10 | Tablero Económico y Territorial",
  theme           = tema_app,
  fillable        = FALSE,
  fillable_mobile = FALSE,
  fluid           = TRUE,
  header          = tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1, shrink-to-fit=no"),
    shiny::withMathJax(),
    tags$link(rel = "stylesheet", type = "text/css", href = "modern_ui/css/modern_ui.css"),
    tags$script(src = "modern_ui/js/modern_ui.js")
  ),

  nav_panel(
    title = "1. Desempeño Fiscal (IDF)",
    class = "bslib-page-dashboard",
    mod_tab1_idf_ui("tab1_idf", deptos_choices = datos_app$deptos_choices)
  ),

  nav_panel(
    title = "2. Tasas y Devaluación Implícita",
    class = "bslib-page-dashboard",
    mod_tab2_tasas_ui(
      "tab2_tasas",
      min_fecha = datos_app$min_fecha,
      max_fecha = datos_app$max_fecha
    )
  ),

  nav_panel(
    title = "3. Dualismo Laboral y Capacidad Fiscal",
    class = "bslib-page-dashboard",
    mod_tab3_libre_ui("tab3_libre", regiones_choices = datos_app$regiones_choices)
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
