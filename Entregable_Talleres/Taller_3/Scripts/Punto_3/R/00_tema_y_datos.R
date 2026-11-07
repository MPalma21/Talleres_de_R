# ==============================================================================
# Módulo 00: Configuración de Tema Visual (bslib) y Carga Defensiva de Datos
# Archivo: R/00_tema_y_datos.R
# Propósito: Centralizar la resolución de rutas, la validación de los objetos
#            RDS pre-procesados y la definición del tema Bootstrap 5 del tablero.
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

#' Construir el tema Bootstrap 5 personalizado con bslib
#' @noRd
crear_tema_app <- function() {
  bslib::bs_theme(
    version      = 5,
    preset       = "shiny",
    primary      = "#1e3d59",
    secondary    = "#0f766e",
    success      = "#15803d",
    info         = "#0284c7",
    warning      = "#d97706",
    danger       = "#b91c1c",
    base_font    = bslib::font_collection(
      bslib::font_google("Nunito Sans", local = FALSE),
      "system-ui", "-apple-system", "Segoe UI", "Roboto", "sans-serif"
    ),
    heading_font = bslib::font_collection(
      bslib::font_google("Montserrat", wght = c(600, 700), local = FALSE),
      "system-ui", "-apple-system", "Segoe UI", "sans-serif"
    ),
    code_font    = bslib::font_collection(
      bslib::font_google("Fira Code", local = FALSE),
      "monospace"
    ),
    "card-border-radius" = "0.65rem",
    "btn-border-radius"  = "0.45rem"
  ) |>
    bslib::bs_add_rules("
      .card {
        box-shadow: 0 2px 10px rgba(15, 23, 42, 0.05);
      }
      .card-header {
        font-weight: 600;
        letter-spacing: 0.01em;
      }
      .bslib-value-box .value-box-title {
        font-weight: 600;
        font-size: 0.82rem;
        text-transform: uppercase;
        letter-spacing: 0.03em;
      }
      .bslib-value-box .value-box-value {
        font-weight: 700;
        font-size: 1.45rem;
      }
      .formula-box {
        text-align: center;
        font-weight: 700;
        padding: 8px 10px;
        background-color: var(--bs-tertiary-bg);
        border: 1px solid var(--bs-border-color);
        border-radius: 6px;
      }
    ")
}
