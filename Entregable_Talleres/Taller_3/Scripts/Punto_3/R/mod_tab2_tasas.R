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
    fillable = FALSE,
    sidebar  = bslib::sidebar(
      title     = "Paridad de Tasas (UIP)",
      width     = 320,
      open      = "desktop",
      resizable = TRUE,
      shiny::dateInput(
        inputId  = ns("fecha_tasa"),
        label    = shiny::HTML("Fecha de valoración \\((t)\\):"),
        value    = max_fecha,
        min      = min_fecha,
        max      = max_fecha,
        format   = "yyyy-mm-dd",
        language = "es"
      ),
      shiny::tags$label(
        class = "form-label",
        "Fechas de control y auditoría:"
      ),
      shiny::div(
        class = "d-flex flex-wrap gap-1 mb-2",
        shiny::actionButton(ns("btn_base"), "Inicio (2020-01-02)", class = "btn-audit"),
        shiny::actionButton(ns("btn_pico"), "Pico IBR (2023-04-28)", class = "btn-audit"),
        shiny::actionButton(ns("btn_auditoria"), "Contraste (2024-03-15)", class = "btn-audit"),
        shiny::actionButton(ns("btn_cierre"), "Cierre (2025-10-31)", class = "btn-audit"),
        shiny::actionButton(ns("btn_fest_col"), "Festivo Col (2025-08-07)", class = "btn-audit"),
        shiny::actionButton(ns("btn_fest_us"), "Festivo EE. UU. (2024-07-04)", class = "btn-audit")
      ),
      shiny::radioButtons(
        inputId  = ns("convencion_tasa"),
        label    = "Convención de comparabilidad:",
        choices  = c(
          "Publicada en decimales (IBR E.A. y SOFR Nominal)" = "directa",
          "Homogeneizada en Efectiva Anual (% E.A., base 360)" = "ea"
        ),
        selected = "directa"
      ),
      shiny::checkboxInput(
        inputId = ns("mostrar_anotaciones"),
        label   = "Mostrar fases y anotaciones del ciclo monetario",
        value   = TRUE
      ),
      shiny::div(
        class = "method-section",
        shiny::div(class = "method-title", "Especificación Financiera"),
        shiny::p(
          class = "mb-1",
          "Bajo paridad descubierta de tasas de interés (UIP), la devaluación implícita anualizada ",
          shiny::HTML("\\(\\pi_t\\)"), " se obtiene como:"
        ),
        shiny::div(
          class = "latex-box",
          shiny::HTML("$$\\pi_t = \\frac{1 + i_{d,t}}{1 + i_{e,t}} - 1$$")
        ),
        shiny::p(
          class = "mb-1",
          "En convención Efectiva Anual homogeneizada (base Act/360), la tasa externa se capitaliza según:"
        ),
        shiny::div(
          class = "latex-box",
          shiny::HTML("$$i_{e,t}^{\\text{E.A.}} = \\left(1 + \\frac{\\text{SOFR}_t}{360}\\right)^{360} - 1$$")
        ),
        shiny::p(
          class = "mb-0 small",
          shiny::HTML("Donde \\(i_{d,t}\\) corresponde al IBR Overnight (BanRep, % E.A.) e \\(i_{e,t}\\) a la SOFR Overnight (NY Fed). El diferencial se expresa en puntos básicos: \\(\\Delta_t = (i_{d,t} - i_{e,t}) \\times 10^4\\text{ pb}\\).")
        )
      )
    ),

    shiny::uiOutput(ns("banner_alerta_fecha")),

    bslib::layout_columns(
      col_widths = bslib::breakpoints(
        xs = 12,
        sm = 6,
        md = 4,
        lg = 4
      ),
      fill = FALSE,
      kpi_card_institucional(
        titulo_ui = shiny::HTML("Tasa Doméstica \\((i_{d,t} \\text{ — IBR ON})\\)"),
        valor_ui  = shiny::textOutput(ns("vb_ibr"), inline = TRUE),
        sub_ui    = shiny::uiOutput(ns("sub_ibr"), inline = TRUE),
        acento    = "navy"
      ),
      kpi_card_institucional(
        titulo_ui = shiny::HTML("Tasa Externa \\((i_{e,t} \\text{ — SOFR ON})\\)"),
        valor_ui  = shiny::textOutput(ns("vb_sofr"), inline = TRUE),
        sub_ui    = shiny::uiOutput(ns("sub_sofr"), inline = TRUE),
        acento    = "teal"
      ),
      kpi_card_institucional(
        titulo_ui = shiny::HTML("Devaluación Implícita Anual \\((\\pi_t)\\)"),
        valor_ui  = shiny::textOutput(ns("vb_pi"), inline = TRUE),
        sub_ui    = shiny::uiOutput(ns("sub_pi"), inline = TRUE),
        acento    = "slate"
      )
    ),

    bslib::card(
      full_screen = TRUE,
      bslib::card_header(
        shiny::div(
          class = "d-flex justify-content-between align-items-baseline flex-wrap gap-2",
          shiny::span(
            class = "fw-bold",
            shiny::HTML("Dinámica Diaria de Tasas Interbancarias de Referencia Overnight: \\(\\text{SOFR}_t\\) (EE. UU.) vs. \\(\\text{IBR}_t\\) (Colombia)")
          ),
          shiny::span(
            class = "text-muted small fw-normal",
            "Muestra diaria: 2020-01-02 a 2025-10-31 (N = 1,500 días hábiles)"
          )
        )
      ),
      plotly::plotlyOutput(ns("grafico_tasas_plotly"), height = "525px"),
      bslib::card_footer(
        shiny::HTML("La línea vertical punteada y los marcadores en forma de rombo indican la fecha activa de valoración \\((t)\\) seleccionada en el panel lateral.")
      )
    ),

    bslib::accordion(
      id       = ns("acc_nota_tecnica_tab2"),
      open     = FALSE,
      multiple = TRUE,
      class    = "accordion-institutional",
      bslib::accordion_panel(
        title = "Nota Técnica y Metodológica: Fuentes Primarias, Armonización de Calendarios y Fases del Ciclo Monetario (Desplegar)",
        value = "panel_nota_tab2",
        shiny::div(
          class = "mb-2",
          shiny::tags$strong("1. Naturaleza de las series y fuentes primarias de extracción: "),
          shiny::HTML(
            "A diferencia de las tasas discrecionales de intervención fijadas en las reuniones de los bancos centrales, tanto la \\(\\text{SOFR}_t\\) como el \\(\\text{IBR}_t\\) son <b>tasas interbancarias de mercado a un día (overnight)</b> que transmiten de forma diaria la postura de política monetaria. La serie externa \\(\\text{SOFR}_t\\) (<i>Secured Overnight Financing Rate</i>, expresada como tasa nominal anualizada en convención \\(\\text{Actual}/360\\)) se extrajo programáticamente mediante peticiones HTTP GET en formato JSON desde la API REST de Mercados del <b>Federal Reserve Bank of New York</b>. La serie doméstica \\(\\text{IBR}_t\\) (<i>Indicador Bancario de Referencia Overnight</i>, serie 241 expresada en tasa Efectiva Anual \\(\\text{E.A.}\\) base 360 días) se obtuvo mediante <i>web scraping</i> estructurado sobre el servicio SDMX-XML del portal estadístico SUAMECA del <b>Banco de la República de Colombia</b>."
          )
        ),
        shiny::div(
          class = "mb-2",
          shiny::tags$strong("2. Armonización de calendarios bancarios asimétricos (criterio Forward-Fill / LOCF): "),
          shiny::HTML(
            "Los mercados interbancarios de Estados Unidos y Colombia presentan calendarios de días festivos no coincidentes (por ejemplo, el Día de la Independencia en EE. UU. el \\(4\\text{ de julio}\\) frente a la Batalla de Boyacá en Colombia el \\(7\\text{ de agosto}\\), o los lunes festivos de la Ley Emiliani). Para consolidar un panel diario continuo entre el \\(2\\text{ de enero de }2020\\) y el \\(31\\text{ de octubre de }2025\\) sin eliminar días hábiles de ninguno de los dos mercados ni introducir sesgos por interpolación lineal, se aplicó el protocolo estándar de tesorería <i>Last Observation Carried Forward</i> (<b>LOCF / forward-fill</b>): cuando un país opera en día hábil y el otro se encuentra en feriado bancario, las operaciones de fondeo a un día devengan a la última tasa oficial de cierre publicada por la autoridad monetaria correspondiente hasta la reapertura del mercado."
          )
        ),
        shiny::div(
          class = "mb-0",
          shiny::tags$strong("3. Lectura de las tres fases macroeconómicas y del doble eje de ordenadas: "),
          shiny::HTML(
            "Dado que la tasa doméstica colombiana \\(\\left(\\text{IBR}_t \\in [1.70\\%,\\; 13.26\\%]\\right)\\) presenta un nivel estructural e inflacionario superior al de la tasa en dólares \\(\\left(\\text{SOFR}_t \\in [0.01\\%,\\; 5.40\\%]\\right)\\), el gráfico dispone de dos ejes verticales independientes: el eje izquierdo cuantifica la \\(\\text{SOFR}_t\\) y el eje derecho cuantifica el \\(\\text{IBR}_t\\), permitiendo contrastar la sincronización de tres regímenes monetarios: <b>(i) Estímulo monetario por COVID-19 (2020–2021)</b>, donde la Reserva Federal llevó la SOFR a su piso técnico \\((\\approx 0.05\\%)\\) y el Banco de la República redujo el IBR a su mínimo histórico \\((1.75\\%\\text{ E.A.})\\); <b>(ii) Ciclo contractivo anti-inflacionario (2021–2023)</b>, iniciado anticipadamente en Colombia en septiembre de 2021 hasta alcanzar el máximo de \\(13.25\\%\\text{ E.A.}\\) en abril de 2023 y de \\(5.30\\%\\) en EE. UU. en julio de 2023; y <b>(iii) Fase de normalización gradual (2024–2025)</b>, que al cierre de la muestra \\((31\\text{ de octubre de }2025)\\) ubica el diferencial en \\(\\Delta_t = 503.0\\text{ pb}\\), equivalente bajo paridad descubierta de tasas de interés (UIP) a una devaluación implícita esperada de \\(\\pi_t = 4.826\\%\\text{ anual}\\) en convención publicada \\(\\left(4.736\\%\\text{ anual en convención }\\text{E.A.}\\text{ homogeneizada}\\right)\\)."
          )
        )
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
    shiny::observeEvent(input$btn_auditoria, {
      shiny::updateDateInput(session, "fecha_tasa", value = as.Date("2024-03-15"))
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
      f_sel <- as.Date(input$fecha_tasa)
      df_rates |> dplyr::filter(fecha == f_sel)
    })

    tasa_sofr_activa <- shiny::reactive({
      reg <- registro_fecha()
      if (nrow(reg) == 0) return(NA_real_)
      if (identical(input$convencion_tasa, "ea")) {
        reg$sofr_ea[1]
      } else {
        reg$sofr_on[1]
      }
    })

    output$banner_alerta_fecha <- shiny::renderUI({
      shiny::req(input$fecha_tasa)
      f_sel <- as.Date(input$fecha_tasa)
      reg   <- registro_fecha()

      if (nrow(reg) == 0) {
        dia_num <- as.integer(format(f_sel, "%u"))
        motivo  <- if (dia_num >= 6) {
          "fin de semana (sábado o domingo)"
        } else {
          "feriado simultáneo o fecha fuera del calendario hábil"
        }

        prev_rows <- df_rates |> dplyr::filter(fecha < f_sel)
        if (nrow(prev_rows) > 0) {
          ult    <- utils::tail(prev_rows, 1)
          sofr_u <- if (identical(input$convencion_tasa, "ea")) ult$sofr_ea[1] else ult$sofr_on[1]
          pi_u   <- (((1 + ult$ibr_on[1] / 100) / (1 + sofr_u / 100)) - 1) * 100
          texto_prev <- sprintf(
            "La cotización inmediatamente previa registrada corresponde al %s: \\(i_{d,t-1} = %.3f\\%%\\), \\(i_{e,t-1} = %.3f\\%%\\), \\(\\pi_{t-1} = %.3f\\%%\\) anual.",
            format(ult$fecha[1], "%Y-%m-%d"), ult$ibr_on[1], sofr_u, pi_u
          )
        } else {
          texto_prev <- "Seleccione una fecha hábil posterior al 2020-01-02."
        }

        return(
          shiny::div(
            class = "status-banner status-banner-warn",
            shiny::tags$strong("Ausencia de cotización primaria en la fecha seleccionada: "),
            shiny::HTML(sprintf(
              "El %s corresponde a %s, por lo que no existe publicación primaria de \\(\\text{IBR}_t\\) ni \\(\\text{SOFR}_t\\). %s",
              format(f_sel, "%Y-%m-%d"), motivo, texto_prev
            ))
          )
        )
      }

      falta_i <- isTRUE(reg$falta_ibr[1])
      falta_s <- isTRUE(reg$falta_sofr[1])

      if (falta_i && !falta_s) {
        return(
          shiny::div(
            class = "status-banner status-banner-warn",
            shiny::tags$strong("Asimetría de calendario (Festivo en Colombia): "),
            shiny::HTML(sprintf(
              "El %s fue hábil en EE. UU. \\((\\text{SOFR}_t = %.2f\\%%)\\), pero feriado bancario en Colombia. Bajo convención de devengo continuo (forward-fill), se conserva la última tasa oficial del Banco de la República \\((i_{d,t} = %.3f\\%%\\text{ E.A.})\\).",
              format(f_sel, "%Y-%m-%d"), reg$sofr_raw[1], reg$ibr_on[1]
            ))
          )
        )
      }

      if (!falta_i && falta_s) {
        return(
          shiny::div(
            class = "status-banner status-banner-warn",
            shiny::tags$strong("Asimetría de calendario (Festivo federal en EE. UU.): "),
            shiny::HTML(sprintf(
              "El %s fue hábil en Colombia \\((\\text{IBR}_t = %.3f\\%%\\text{ E.A.})\\), pero feriado en EE. UU. Bajo convención de devengo continuo (forward-fill), se conserva la última tasa oficial de la Reserva Federal de Nueva York \\((\\text{SOFR}_t = %.2f\\%%)\\).",
              format(f_sel, "%Y-%m-%d"), reg$ibr_raw[1], reg$sofr_on[1]
            ))
          )
        )
      }

      shiny::div(
        class = "status-banner",
        shiny::tags$strong("Cotización primaria sincronizada: "),
        shiny::HTML(sprintf(
          "En \\(t = \\text{%s}\\), tanto el Banco de la República como la Reserva Federal de Nueva York reportaron observación primaria oficial sin imputación.",
          format(f_sel, "%Y-%m-%d")
        ))
      )
    })

    output$vb_ibr <- shiny::renderText({
      reg <- registro_fecha()
      if (nrow(reg) == 0 || is.na(reg$ibr_on[1])) return("Sin observación")
      sprintf("%.3f %% E.A.", reg$ibr_on[1])
    })

    output$sub_ibr <- shiny::renderUI({
      reg <- registro_fecha()
      if (nrow(reg) == 0 || is.na(reg$ibr_on[1])) return(shiny::HTML("Fecha no hábil"))
      estado <- if (isTRUE(reg$falta_ibr[1])) "Forward-fill (festivo Col)" else "BanRep Serie 241"
      shiny::HTML(sprintf("\\(i_{d,t} = %.5f\\) (%s)", reg$ibr_on[1] / 100, estado))
    })

    output$vb_sofr <- shiny::renderText({
      reg      <- registro_fecha()
      sofr_val <- tasa_sofr_activa()
      if (nrow(reg) == 0 || is.na(sofr_val)) return("Sin observación")
      sufijo <- if (identical(input$convencion_tasa, "ea")) "%% E.A." else "%% Nominal"
      sprintf(paste0("%.3f ", sufijo), sofr_val)
    })

    output$sub_sofr <- shiny::renderUI({
      reg      <- registro_fecha()
      sofr_val <- tasa_sofr_activa()
      if (nrow(reg) == 0 || is.na(sofr_val)) return(shiny::HTML("Fecha no hábil"))
      estado <- if (isTRUE(reg$falta_sofr[1])) "Forward-fill (festivo EE. UU.)" else "NY Fed API"
      shiny::HTML(sprintf("\\(i_{e,t} = %.5f\\) (%s)", sofr_val / 100, estado))
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

    output$sub_pi <- shiny::renderUI({
      reg      <- registro_fecha()
      sofr_val <- tasa_sofr_activa()
      if (nrow(reg) == 0 || is.na(reg$ibr_on[1]) || is.na(sofr_val)) {
        return(shiny::HTML("Requiere tasas vigentes"))
      }
      id     <- reg$ibr_on[1] / 100
      ie     <- sofr_val / 100
      pi_val <- ((1 + id) / (1 + ie)) - 1
      spread <- (id - ie) * 10000
      shiny::HTML(sprintf("\\(\\pi_t = %.5f \\;\\mid\\; \\Delta_t = %.1f\\text{ pb}\\)", pi_val, spread))
    })

    output$grafico_tasas_plotly <- plotly::renderPlotly({
      f_sel <- as.Date(input$fecha_tasa)
      reg   <- registro_fecha()

      # Hitos clave idénticos a la Figura 2.c del taller
      hitos_sofr <- data.frame(
        fecha     = as.Date(c("2023-07-27", "2025-10-31")),
        valor     = c(5.30, 4.22),
        etiqueta  = c("Pico SOFR (2023-07-27): 5.30%", "Cierre SOFR (2025-10-31): 4.22%")
      )
      hitos_ibr <- data.frame(
        fecha     = as.Date(c("2023-04-28", "2025-10-31")),
        valor     = c(13.25, 9.25),
        etiqueta  = c("Pico IBR (2023-04-28): 13.25% E.A.", "Cierre IBR (2025-10-31): 9.25% E.A.")
      )

      # Construcción del gráfico replicando exactamente la estética del Taller 3 (Figura 2.c)
      fig <- plotly::plot_ly(df_rates, x = ~fecha) |>
        plotly::add_lines(
          y             = ~ibr_on,
          name          = "IBR ON (Colombia - Banco de la República) [Eje Der.]",
          line          = list(color = "#111827", width = 2.1),
          yaxis         = "y2",
          hovertemplate = "<b>IBR ON (Colombia):</b> %{y:.3f}% E.A.<extra></extra>"
        ) |>
        plotly::add_lines(
          y             = ~sofr_on,
          name          = "SOFR ON (EE. UU. - Reserva Federal) [Eje Izq.]",
          line          = list(color = "#0f766e", width = 2.1),
          yaxis         = "y",
          hovertemplate = "<b>SOFR ON (EE. UU.):</b> %{y:.2f}%<extra></extra>"
        ) |>
        plotly::add_markers(
          data          = hitos_ibr,
          x             = ~fecha,
          y             = ~valor,
          yaxis         = "y2",
          marker        = list(color = "#111827", size = 7.5),
          showlegend    = FALSE,
          hovertemplate = "<b>%{text}</b><extra></extra>",
          text          = ~etiqueta
        ) |>
        plotly::add_markers(
          data          = hitos_sofr,
          x             = ~fecha,
          y             = ~valor,
          yaxis         = "y",
          marker        = list(color = "#0f766e", size = 7.5),
          showlegend    = FALSE,
          hovertemplate = "<b>%{text}</b><extra></extra>",
          text          = ~etiqueta
        )

      # Si la fecha consultada tiene datos, resaltar puntos activos sobre ambas curvas
      if (nrow(reg) > 0 && !is.na(reg$ibr_on[1]) && !is.na(reg$sofr_on[1])) {
        fig <- fig |>
          plotly::add_markers(
            x             = reg$fecha[1],
            y             = reg$ibr_on[1],
            yaxis         = "y2",
            name          = "Fecha consultada (t)",
            marker        = list(color = "#78350f", size = 9, symbol = "diamond", line = list(color = "#ffffff", width = 1.2)),
            showlegend    = FALSE,
            hovertemplate = sprintf("<b>IBR en t (%s):</b> %.3f%% E.A.<extra></extra>", format(f_sel, "%Y-%m-%d"), reg$ibr_on[1])
          ) |>
          plotly::add_markers(
            x             = reg$fecha[1],
            y             = reg$sofr_on[1],
            yaxis         = "y",
            marker        = list(color = "#78350f", size = 9, symbol = "diamond", line = list(color = "#ffffff", width = 1.2)),
            showlegend    = FALSE,
            hovertemplate = sprintf("<b>SOFR en t (%s):</b> %.2f%%<extra></extra>", format(f_sel, "%Y-%m-%d"), reg$sofr_on[1])
          )
      }

      # Formas base: línea vertical de la fecha seleccionada
      shapes_list <- list(
        list(
          type = "line",
          x0   = f_sel,
          x1   = f_sel,
          y0   = 0,
          y1   = 1,
          yref = "paper",
          line = list(color = "#78350f", width = 1.6, dash = "dot")
        )
      )

      annotations_list <- list()

      # Franjas de régimen monetario y etiquetas idénticas a la Figura 2.c del taller
      mostrar_fases <- if (is.null(input$mostrar_anotaciones)) TRUE else isTRUE(input$mostrar_anotaciones)
      if (mostrar_fases) {
        shapes_list <- c(
          list(
            list(
              type      = "rect",
              layer     = "below",
              x0        = as.Date("2020-03-20"),
              x1        = as.Date("2021-09-30"),
              y0        = 0,
              y1        = 1,
              xref      = "x",
              yref      = "paper",
              fillcolor = "rgba(21, 128, 61, 0.075)",
              line      = list(width = 0)
            ),
            list(
              type      = "rect",
              layer     = "below",
              x0        = as.Date("2021-10-01"),
              x1        = as.Date("2023-06-30"),
              y0        = 0,
              y1        = 1,
              xref      = "x",
              yref      = "paper",
              fillcolor = "rgba(185, 28, 28, 0.075)",
              line      = list(width = 0)
            ),
            list(
              type      = "rect",
              layer     = "below",
              x0        = as.Date("2023-07-01"),
              x1        = as.Date("2025-10-31"),
              y0        = 0,
              y1        = 1,
              xref      = "x",
              yref      = "paper",
              fillcolor = "rgba(29, 78, 216, 0.065)",
              line      = list(width = 0)
            )
          ),
          shapes_list
        )

        annotations_list <- list(
          list(
            x           = as.Date("2021-02-15"),
            y           = 1.0,
            xref        = "x",
            yref        = "y",
            text        = "<b>Estímulo Monetario Sincronizado (2020–2021)</b><br>Piso Histórico de Tasas por Emergencia COVID-19<br>IBR: 1.75% E.A. | SOFR: ~0.05%",
            showarrow   = TRUE,
            arrowhead   = 2,
            arrowsize   = 0.9,
            arrowwidth  = 1.3,
            arrowcolor  = "#166534",
            ax          = 0,
            ay          = -135,
            bgcolor     = "#f0fdf4",
            bordercolor = "#166534",
            borderwidth = 1,
            borderpad   = 5,
            font        = list(size = 10.5, color = "#166534", family = "IBM Plex Sans, sans-serif"),
            align       = "center"
          ),
          list(
            x           = as.Date("2023-05-15"),
            y           = 5.35,
            xref        = "x",
            yref        = "y",
            text        = "<b>Picos del Ciclo Contractivo (2023)</b><br>Ajuste Anti-inflacionario Récord en Ambos Países<br>IBR máx: 13.25% (abr-23) | SOFR máx: 5.30% (jul-23)",
            showarrow   = TRUE,
            arrowhead   = 2,
            arrowsize   = 0.9,
            arrowwidth  = 1.3,
            arrowcolor  = "#991b1b",
            ax          = 0,
            ay          = -45,
            bgcolor     = "#fef2f2",
            bordercolor = "#991b1b",
            borderwidth = 1,
            borderpad   = 5,
            font        = list(size = 10.5, color = "#991b1b", family = "IBM Plex Sans, sans-serif"),
            align       = "center"
          ),
          list(
            x           = as.Date("2025-09-15"),
            y           = 3.65,
            xref        = "x",
            yref        = "y",
            text        = "<b>Fase de Normalización y Recortes (2025)</b><br>Diferencial de Tasas (Spread): ~503 bps<br>IBR: 9.25% E.A. | SOFR: 4.22% (31-oct-2025)",
            showarrow   = TRUE,
            arrowhead   = 2,
            arrowsize   = 0.9,
            arrowwidth  = 1.3,
            arrowcolor  = "#1e40af",
            ax          = -65,
            ay          = 78,
            bgcolor     = "#eff6ff",
            bordercolor = "#1e40af",
            borderwidth = 1,
            borderpad   = 5,
            font        = list(size = 10.5, color = "#1e40af", family = "IBM Plex Sans, sans-serif"),
            align       = "center"
          )
        )
      }

      # Factor de escala 2.5 exacto: eje izq [0, 6.8] <-> eje der [0, 17.0]
      fig |>
        plotly::layout(
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#ffffff",
          xaxis = list(
            title      = list(text = "<b>Fecha de Negociación (Frecuencia Diaria)</b>", font = list(size = 11.5, color = "#1f2937")),
            range      = c("2020-01-02", "2025-11-15"),
            dtick      = "M12",
            tick0      = "2020-01-01",
            tickformat = "%Y",
            tickfont   = list(size = 11, color = "#374151"),
            showgrid   = FALSE,
            showline   = TRUE,
            linecolor  = "#9ca3af",
            linewidth  = 1,
            ticks      = "outside",
            tickcolor  = "#9ca3af"
          ),
          yaxis = list(
            title     = list(text = "<b>Tasa SOFR Overnight (% Anualizado, Actual/360) [Eje Izquierdo]</b>", font = list(color = "#0f766e", size = 11.5)),
            tickfont  = list(color = "#0f766e", size = 11),
            side      = "left",
            range     = c(0, 6.8),
            tickvals  = seq(0, 6, by = 1),
            ticktext  = sprintf("%.1f%%", seq(0, 6, by = 1)),
            showgrid  = TRUE,
            gridcolor = "#e5e7eb",
            zeroline  = FALSE,
            showline  = TRUE,
            linecolor = "#0f766e",
            linewidth = 1,
            ticks     = "outside",
            tickcolor = "#0f766e"
          ),
          yaxis2 = list(
            title      = list(text = "<b>Tasa IBR Overnight (% E.A., base 360 días) [Eje Derecho]</b>", font = list(color = "#111827", size = 11.5)),
            tickfont   = list(color = "#111827", size = 11),
            overlaying = "y",
            side       = "right",
            range      = c(0, 17.0),
            tickvals   = seq(0, 15, by = 2.5),
            ticktext   = c("0%", "2%", "5%", "8%", "10%", "12%", "15%"),
            showgrid   = FALSE,
            zeroline   = FALSE,
            showline   = TRUE,
            linecolor  = "#111827",
            linewidth  = 1,
            ticks      = "outside",
            tickcolor  = "#111827"
          ),
          shapes      = shapes_list,
          annotations = annotations_list,
          legend      = list(
            orientation = "h",
            x           = 0.5,
            xanchor     = "center",
            y           = 1.08,
            font        = list(size = 11.5, color = "#111827")
          ),
          hovermode   = "x unified",
          autosize    = TRUE,
          margin      = list(l = 65, r = 65, t = 42, b = 52)
        ) |>
        plotly::config(responsive = TRUE, displayModeBar = "hover")
    })
  })
}
