# ==============================================================================
# Módulo 00: Configuración de Tema Institucional (bslib) y Carga de Datos
# Archivo: R/00_tema_y_datos.R
# Propósito: Centralizar la resolución de rutas, la validación de los objetos
#            RDS pre-procesados, el tema Bootstrap 5 sobrio y componentes KPI.
# ==============================================================================

#' Localizar el directorio data_shiny desde cualquier ruta de ejecución
#' @noRd
localizar_dir_shiny <- function() {
  posibles_rutas <- c(
    file.path(getwd(), "data_shiny"),
    file.path(getwd(), "Scripts", "Punto_3", "data_shiny"),
    file.path(getwd(), "Entregable_Talleres", "Taller_3", "Scripts", "Punto_3", "data_shiny"),
    file.path(getwd(), "Entregable_Talleres", "Taller_3", "data_shiny"),
    file.path(getwd(), "..", "Punto_3", "data_shiny")
  )
  dir_valido <- posibles_rutas[dir.exists(posibles_rutas)][1]
  if (is.na(dir_valido) || !dir.exists(dir_valido)) {
    stop(
      "No se encontró el directorio 'data_shiny'. ",
      "Ejecute primero 'Scripts/Punto_1/01_procesamiento_geoespacial_idf.R' y ",
      "'Scripts/Punto_3/01_preparar_datos_shiny.R'.",
      call. = FALSE
    )
  }
  normalizePath(dir_valido)
}

#' Cargar y validar los insumos serializados para las tres pestañas del tablero
#' @noRd
cargar_datos_shiny <- function() {
  dir_data <- localizar_dir_shiny()

  shp_dpto_simp <- readRDS(file.path(dir_data, "shp_dpto_simp.rds"))
  df_deptos     <- readRDS(file.path(dir_data, "df_deptos.rds"))
  df_top3       <- readRDS(file.path(dir_data, "df_top3.rds"))
  df_rates      <- readRDS(file.path(dir_data, "df_rates.rds"))
  df_labor      <- readRDS(file.path(dir_data, "df_labor.rds"))

  # Normalización defensiva de columnas en caso de versiones previas de RDS
  if (!"n_mpios" %in% names(df_deptos) && "n_municipios" %in% names(df_deptos)) {
    df_deptos$n_mpios <- df_deptos$n_municipios
  }
  if (!"n_mpios" %in% names(shp_dpto_simp) && "n_municipios" %in% names(shp_dpto_simp)) {
    shp_dpto_simp$n_mpios <- shp_dpto_simp$n_municipios
  }

  if (!"sofr_ea" %in% names(df_rates)) {
    df_rates <- df_rates |>
      dplyr::mutate(
        sofr_raw   = sofr_on,
        ibr_raw    = ibr_on,
        falta_sofr = FALSE,
        falta_ibr  = FALSE,
        sofr_ea    = ((1 + (sofr_on / 100) / 360)^360 - 1) * 100,
        pi_directa = (((1 + ibr_on / 100) / (1 + sofr_on / 100)) - 1) * 100,
        pi_ea      = (((1 + ibr_on / 100) / (1 + sofr_ea / 100)) - 1) * 100
      )
  }

  if (!"IDF_DEPARTAMENTAL" %in% names(df_labor)) {
    df_labor <- df_labor |>
      dplyr::mutate(
        COD_DPTO = sprintf("%02d", as.integer(DPTO_NUM))
      ) |>
      dplyr::left_join(
        df_deptos |>
          dplyr::transmute(
            COD_DPTO          = sprintf("%02d", as.integer(cod_dpto)),
            IDF_DEPARTAMENTAL = round(idf_departamental, 2),
            POB_2024          = pob_dpto_2024
          ),
        by = "COD_DPTO"
      )
  }

  deptos_choices   <- df_deptos |> dplyr::arrange(nom_dpto) |> dplyr::pull(nom_dpto)
  regiones_choices <- sort(unique(df_labor$REGION))

  list(
    shp_dpto_simp    = shp_dpto_simp,
    df_deptos        = df_deptos,
    df_top3          = df_top3,
    df_rates         = df_rates,
    df_labor         = df_labor,
    deptos_choices   = deptos_choices,
    regiones_choices = regiones_choices,
    min_fecha        = min(df_rates$fecha, na.rm = TRUE),
    max_fecha        = max(df_rates$fecha, na.rm = TRUE)
  )
}

#' Construir el tema Bootstrap 5 institucional sobrio con bslib
#' @noRd
crear_tema_app <- function() {
  bslib::bs_theme(
    version      = 5,
    preset       = "shiny",
    bg           = "#ffffff",
    fg           = "#0f172a",
    primary      = "#1e3a5f",
    secondary    = "#334155",
    success      = "#1e3a5f",
    info         = "#334155",
    warning      = "#78350f",
    danger       = "#7f1d1d",
    base_font    = bslib::font_collection(
      bslib::font_google("IBM Plex Sans", wght = c(400, 500, 600, 700), local = FALSE),
      "system-ui", "-apple-system", "Segoe UI", "Roboto", "sans-serif"
    ),
    heading_font = bslib::font_collection(
      bslib::font_google("IBM Plex Sans", wght = c(600, 700), local = FALSE),
      "system-ui", "-apple-system", "Segoe UI", "sans-serif"
    ),
    code_font    = bslib::font_collection(
      bslib::font_google("IBM Plex Mono", wght = c(400, 500), local = FALSE),
      "monospace"
    ),
    "card-border-radius" = "0.375rem",
    "btn-border-radius"  = "0.25rem"
  )
}

#' Componente de tarjeta de indicador (KPI) institucional de fondo neutro
#' @param titulo_ui Texto o etiqueta HTML/LaTeX del indicador
#' @param valor_ui Output reactivo del valor principal
#' @param sub_ui Output o texto secundario opcional
#' @param acento Clase de borde lateral ("navy", "slate", "teal")
#' @noRd
kpi_card_institucional <- function(titulo_ui, valor_ui, sub_ui = NULL, acento = "navy") {
  clase_acento <- paste0("kpi-institutional kpi-accent-", acento)
  shiny::div(
    class = clase_acento,
    shiny::div(class = "kpi-label", titulo_ui),
    shiny::div(class = "kpi-value", valor_ui),
    if (!is.null(sub_ui)) shiny::div(class = "kpi-sub", sub_ui)
  )
}
