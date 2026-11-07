# ==============================================================================
# Módulo Pestaña 2: Series Financieras (SOFR, IBR y Devaluación Implícita)
# Archivo: R/mod_tab2_tasas.R
# Eje 2 (Líder: Miguelangel Palma) | Arquitectura Modular bslib (Juan José Echeverry)
# ==============================================================================

#' UI del Módulo Pestaña 2 (Tasas Overnight y Calculadora de Devaluación Implícita)
#' @noRd
mod_tab2_tasas_ui <- function(id, min_fecha, max_fecha) {
  ns <- shiny::NS(id)

  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      title = "Calculadora de Paridad (π)",
      width = 350,
      shiny::dateInput(
        inputId  = ns("fecha_tasa"),
        label    = "Digite o seleccione una fecha:",
        value    = max_fecha,
        min      = min_fecha,
        max      = max_fecha,
        format   = "yyyy-mm-dd",
        language = "es"
      ),
      shiny::tags$label(
        class = "form-label small fw-semibold text-muted mb-1",
        "Fechas de control y prueba rápida:"
      ),
      shiny::div(
        class = "d-flex flex-wrap gap-1 mb-3",
        shiny::actionButton(
          ns("btn_base"),
          "Base (02/01/20)",
          class = "btn-outline-secondary btn-sm"
        ),
        shiny::actionButton(
          ns("btn_pico"),
          "Pico IBR (28/04/23)",
          class = "btn-outline-secondary btn-sm"
        ),
        shiny::actionButton(
          ns("btn_cierre"),
          "Cierre (31/10/25)",
          class = "btn-outline-primary btn-sm"
        ),
        shiny::actionButton(
          ns("btn_fest_col"),
          "Festivo Col (07/08/25)",
          class = "btn-outline-warning btn-sm"
        ),
        shiny::actionButton(
          ns("btn_fest_us"),
          "Festivo EE.UU. (04/07/24)",
          class = "btn-outline-warning btn-sm"
        )
      ),
      shiny::radioButtons(
        inputId  = ns("convencion_tasa"),
        label    = "Convención de comparabilidad:",
        choices  = c(
          "Tasas publicadas en decimales (IBR E.A. y SOFR Nominal)" = "directa",
          "Homogeneizada en Efectiva Anual (% E.A., base 360)"      = "ea"
        ),
        selected = "directa"
      ),
      shiny::hr(),
      bslib::card(
        bslib::card_header("Instrucciones de Uso y Unidades"),
        shiny::p(
          "1. Ingrese cualquier fecha entre ",
          shiny::tags$b("2020-01-02"), " y ", shiny::tags$b("2025-10-31"),
          " o use los botones de prueba rápida."
        ),
        shiny::p(
          "2. El aplicativo consulta ",
          shiny::tags$code("i_d"), " (IBR Overnight, Colombia) e ",
          shiny::tags$code("i_e"), " (SOFR Overnight, EE. UU.) en decimales y calcula la ",
          shiny::tags$b("tasa de devaluación implícita anualizada (π):")
        ),
        shiny::div(
          class = "formula-box mb-2",
          "π = (1 + i_d) / (1 + i_e) - 1"
        ),
        shiny::p(
          class = "mb-0",
          shiny::tags$b("Unidad del resultado: "),
          "Porcentaje efectivo anualizado (% anual). Si falta alguna tasa en la fuente primaria para la fecha elegida (fin de semana o festivo local), el banner superior lo informa explícitamente."
        ),
        class = "text-muted small"
      )
    ),

    shiny::uiOutput(ns("banner_alerta_fecha")),

    bslib::layout_column_wrap(
      width = 1 / 3,
      fill  = FALSE,
      bslib::value_box(
        title    = "Tasa Doméstica: IBR ON (i_d)",
        value    = shiny::textOutput(ns("vb_ibr")),
        shiny::p(class = "small mb-0 opacity-75", shiny::textOutput(ns("sub_ibr"))),
        showcase = shiny::icon("building-columns"),
        theme    = "primary"
      ),
      bslib::value_box(
        title    = "Tasa Externa: SOFR ON (i_e)",
        value    = shiny::textOutput(ns("vb_sofr")),
        shiny::p(class = "small mb-0 opacity-75", shiny::textOutput(ns("sub_sofr"))),
        showcase = shiny::icon("dollar-sign"),
        theme    = "secondary"
      ),
      bslib::value_box(
        title    = "Devaluación Implícita (π)",
        value    = shiny::textOutput(ns("vb_pi")),
        shiny::p(class = "small mb-0 opacity-75", shiny::textOutput(ns("sub_pi"))),
        showcase = shiny::icon("scale-balanced"),
        theme    = "success"
      )
    ),

    bslib::card(
      full_screen = TRUE,
      bslib::card_header(
        "Serie Diaria Interactiva de Doble Eje: SOFR ON (Eje Izq.) vs. IBR ON (Eje Der.) [2020-2025]"
      ),
      plotly::plotlyOutput(ns("grafico_tasas_plotly"), height = "440px"),
      bslib::card_footer(
        class = "text-muted small",
        "La línea vertical punteada señala la fecha seleccionada en la calculadora. Use los botones 6M, 1A, 3A o el deslizador inferior para hacer zoom temporal."
      )
    )
  )
}

#' Servidor del Módulo Pestaña 2 (Tasas Overnight y Calculadora de Devaluación Implícita)
#' @noRd
mod_tab2_tasas_server <- function(id, df_rates) {
  shiny::moduleServer(id, function(input, output, session) {

    shiny::observeEvent(input$btn_base, {
      shiny::updateDateInput(session, "fecha_tasa", value = as.Date("2020-01-02"))
    })
    shiny::observeEvent(input$btn_pico, {
      shiny::updateDateInput(session, "fecha_tasa", value = as.Date("2023-04-28"))
    })
    shiny::observeEvent(input$btn_cierre, {
      shiny::updateDateInput(session, "fecha_tasa", value = as.Date("2025-10-31"))
    })
    shiny::observeEvent(input$btn_fest_col, {
      shiny::updateDateInput(session, "fecha_tasa", value = as.Date("2025-08-07"))
    })
    shiny::observeEvent(input$btn_fest_us, {
      shiny::updateDateInput(session, "fecha_tasa", value = as.Date("2024-07-04"))
    })

    registro_fecha <- shiny::reactive({
      shiny::req(input$fecha_tasa)
      df_rates |> dplyr::filter(fecha == as.Date(input$fecha_tasa))
    })

    # Tasa externa activa según convención elegida (publicada vs Efectiva Anual base 360)
    tasa_sofr_activa <- shiny::reactive({
      reg <- registro_fecha()
      if (nrow(reg) == 0) return(NA_real_)
      if (identical(input$convencion_tasa, "ea")) reg$sofr_ea[1] else reg$sofr_on[1]
    })

    output$banner_alerta_fecha <- shiny::renderUI({
      shiny::req(input$fecha_tasa)
      f_sel <- as.Date(input$fecha_tasa)
      reg   <- registro_fecha()

      if (nrow(reg) == 0) {
        prev_df <- df_rates |> dplyr::filter(fecha < f_sel)
        ult_hab <- if (nrow(prev_df) > 0) format(max(prev_df$fecha), "%Y-%m-%d") else "N/D"
        return(
          shiny::div(
            class = "alert alert-warning py-2 px-3 mb-2 small",
            shiny::icon("triangle-exclamation"), " ",
            shiny::tags$b("Fecha sin observaciones en ambos mercados: "),
            sprintf(
              "El día %s corresponde a fin de semana o feriado bancario simultáneo en Colombia y Estados Unidos; no existen tasas publicadas para esta fecha. Seleccione un día hábil (último hábil previo: %s).",
              format(f_sel, "%Y-%m-%d"), ult_hab
            )
          )
        )
      }

      if (isTRUE(reg$falta_ibr[1]) && !isTRUE(reg$falta_sofr[1])) {
        return(
          shiny::div(
            class = "alert alert-info py-2 px-3 mb-2 small",
            shiny::icon("circle-info"), " ",
            shiny::tags$b("Aviso: Falta observación primaria de IBR ON en esta fecha (festivo en Colombia). "),
            sprintf(
              "El %s fue hábil en EE. UU. (SOFR observada = %.2f%%), pero festivo bancario en Colombia. Aplicando la convención de devengo continuo (forward-fill), se emplea la última IBR oficial vigente (%.3f%% E.A.).",
              format(f_sel, "%Y-%m-%d"), reg$sofr_raw[1], reg$ibr_on[1]
            )
          )
        )
      }

      if (isTRUE(reg$falta_sofr[1]) && !isTRUE(reg$falta_ibr[1])) {
        return(
          shiny::div(
            class = "alert alert-info py-2 px-3 mb-2 small",
            shiny::icon("circle-info"), " ",
            shiny::tags$b("Aviso: Falta observación primaria de SOFR ON en esta fecha (festivo en EE. UU.). "),
            sprintf(
              "El %s fue hábil en Colombia (IBR observada = %.3f%% E.A.), pero feriado federal en EE. UU. Aplicando la convención de devengo continuo (forward-fill), se emplea la última SOFR oficial vigente (%.2f%%).",
              format(f_sel, "%Y-%m-%d"), reg$ibr_raw[1], reg$sofr_on[1]
            )
          )
        )
      }

      shiny::div(
        class = "alert alert-success py-1 px-3 mb-2 small",
        shiny::icon("circle-check"), " ",
        shiny::tags$b("Cotización primaria verificada: "),
        sprintf(
          "Ambos bancos centrales reportaron tasa oficial el %s.",
          format(f_sel, "%Y-%m-%d")
        )
      )
    })

    output$vb_ibr <- shiny::renderText({
      reg <- registro_fecha()
      if (nrow(reg) == 0 || is.na(reg$ibr_on[1])) return("Sin observación")
      sprintf("%.3f %% E.A.", reg$ibr_on[1])
    })

    output$sub_ibr <- shiny::renderText({
      reg <- registro_fecha()
      if (nrow(reg) == 0 || is.na(reg$ibr_on[1])) return("Feriado / Fin de semana")
      estado <- if (isTRUE(reg$falta_ibr[1])) "Forward-fill (festivo Col)" else "BanRep SUAMECA"
      sprintf("En decimal: i_d = %.5f (%s)", reg$ibr_on[1] / 100, estado)
    })

    output$vb_sofr <- shiny::renderText({
      reg      <- registro_fecha()
      sofr_val <- tasa_sofr_activa()
      if (nrow(reg) == 0 || is.na(sofr_val)) return("Sin observación")
      sufijo <- if (identical(input$convencion_tasa, "ea")) "%% E.A." else "%% APR"
      sprintf(paste0("%.3f ", sufijo), sofr_val)
    })

    output$sub_sofr <- shiny::renderText({
      reg      <- registro_fecha()
      sofr_val <- tasa_sofr_activa()
      if (nrow(reg) == 0 || is.na(sofr_val)) return("Feriado / Fin de semana")
      estado <- if (isTRUE(reg$falta_sofr[1])) "Forward-fill (festivo EE. UU.)" else "NY Fed API"
      sprintf("En decimal: i_e = %.5f (%s)", sofr_val / 100, estado)
    })

    output$vb_pi <- shiny::renderText({
      reg      <- registro_fecha()
      sofr_val <- tasa_sofr_activa()
      if (nrow(reg) == 0 || is.na(reg$ibr_on[1]) || is.na(sofr_val)) return("No calculable")

      id     <- reg$ibr_on[1] / 100
      ie     <- sofr_val / 100
      pi_val <- ((1 + id) / (1 + ie)) - 1
      sprintf("%.3f %% anual", pi_val * 100)
    })

    output$sub_pi <- shiny::renderText({
      reg      <- registro_fecha()
      sofr_val <- tasa_sofr_activa()
      if (nrow(reg) == 0 || is.na(reg$ibr_on[1]) || is.na(sofr_val)) {
        return("Requiere tasas vigentes")
      }
      id      <- reg$ibr_on[1] / 100
      ie      <- sofr_val / 100
      pi_val  <- ((1 + id) / (1 + ie)) - 1
      spread  <- (id - ie) * 10000
      sprintf("En decimal: π = %.5f | Spread: %.1f pb", pi_val, spread)
    })

    output$grafico_tasas_plotly <- plotly::renderPlotly({
      f_sel <- as.Date(input$fecha_tasa)

      plotly::plot_ly(df_rates, x = ~fecha) |>
        plotly::add_lines(
          y             = ~sofr_on,
          name          = "SOFR ON (EE. UU.) [Eje Izq.]",
          line          = list(color = "#0f766e", width = 2),
          yaxis         = "y",
          hovertemplate = "<b>SOFR ON:</b> %{y:.2f}%<extra></extra>"
        ) |>
        plotly::add_lines(
          y             = ~ibr_on,
          name          = "IBR ON (Colombia) [Eje Der.]",
          line          = list(color = "#1e3d59", width = 2.1),
          yaxis         = "y2",
          hovertemplate = "<b>IBR ON:</b> %{y:.3f}% E.A.<extra></extra>"
        ) |>
        plotly::layout(
          xaxis = list(
            title       = "Fecha de negociación (frecuencia diaria)",
            rangeslider = list(visible = TRUE),
            rangeselector = list(
              buttons = list(
                list(count = 6, label = "6M", step = "month", stepmode = "backward"),
                list(count = 1, label = "1A", step = "year", stepmode = "backward"),
                list(count = 3, label = "3A", step = "year", stepmode = "backward"),
                list(step = "all", label = "Todo")
              )
            )
          ),
          yaxis = list(
            title     = "SOFR ON (% Anualizado, Actual/360) [Eje Izquierdo]",
            titlefont = list(color = "#0f766e"),
            tickfont  = list(color = "#0f766e"),
            side      = "left",
            range     = c(0, 6.8)
          ),
          yaxis2 = list(
            title      = "IBR ON (% E.A., base 360) [Eje Derecho]",
            titlefont  = list(color = "#1e3d59"),
            tickfont   = list(color = "#1e3d59"),
            overlaying = "y",
            side       = "right",
            range      = c(0, 15.5)
          ),
          shapes = list(
            list(
              type = "line",
              x0   = f_sel,
              x1   = f_sel,
              y0   = 0,
              y1   = 1,
              yref = "paper",
              line = list(color = "#d97706", width = 1.6, dash = "dot")
            )
          ),
          legend    = list(orientation = "h", x = 0.15, y = 1.13),
          hovermode = "x unified",
          margin    = list(l = 60, r = 60, t = 40, b = 40)
        )
    })
  })
}
