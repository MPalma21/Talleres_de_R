# ==============================================================================
# Módulo Pestaña 3: Diseño Libre - Dualismo Laboral y Desempeño Fiscal (Plotly)
# Archivo: R/mod_tab3_libre.R
# Eje 3 (Líder: Juan José Echeverry) | Arquitectura Modular bslib
# ==============================================================================

#' UI del Módulo Pestaña 3 (Diseño Libre en Plotly)
#' @noRd
mod_tab3_libre_ui <- function(id, regiones_choices) {
  ns <- shiny::NS(id)

  bslib::layout_sidebar(
    fillable = FALSE,
    sidebar  = bslib::sidebar(
      title     = "Parámetros del Modelo",
      width     = 315,
      open      = "desktop",
      resizable = TRUE,
      shiny::selectInput(
        inputId  = ns("eje_y_var"),
        label    = shiny::HTML("Variable dependiente \\((Y_d)\\):"),
        choices  = c(
          "Mediana del Ingreso Laboral Mensual (COP)" = "INGRESO_MEDIANO",
          "Desempeño Fiscal Departamental IDF (pts)"  = "IDF_DEPARTAMENTAL"
        ),
        selected = "INGRESO_MEDIANO"
      ),
      shiny::checkboxGroupInput(
        inputId  = ns("regiones_sel"),
        label    = "Regiones geográficas incluidas:",
        choices  = regiones_choices,
        selected = regiones_choices
      ),
      shiny::actionButton(
        inputId = ns("btn_reset_filtros"),
        label   = "Restablecer muestra nacional completa",
        class   = "btn-audit w-100 mb-2"
      ),
      shiny::sliderInput(
        inputId = ns("ocupados_slider"),
        label   = shiny::HTML("Umbral mínimo de ocupados \\((L_d,\\text{ miles})\\):"),
        min     = 100,
        max     = 4000,
        value   = 100,
        step    = 100
      ),
      shiny::checkboxInput(
        inputId = ns("mostrar_tendencia"),
        label   = shiny::HTML("Estimar regresión lineal MCO \\((\\hat{Y}_d)\\)"),
        value   = TRUE
      ),
      shiny::checkboxInput(
        inputId = ns("mostrar_cuadrantes"),
        label   = shiny::HTML("Trazar umbrales medios \\((\\overline{X}, \\overline{Y})\\)"),
        value   = TRUE
      ),
      shiny::div(
        class = "method-section",
        shiny::div(class = "method-title", "Especificación Econométrica (MCO)"),
        shiny::div(
          class = "latex-box",
          shiny::HTML("$$Y_d = \\beta_0 + \\beta_1 \\,\\text{Informalidad}_d + u_d$$")
        ),
        shiny::uiOutput(ns("ecuacion_mco_latex")),
        shiny::p(
          class = "mb-0 small",
          "Fuente: Integración departamental GEIH y EMICRON 2024 (DANE) con el IDF Departamental Artificial 2024 (DNP)."
        )
      )
    ),

    bslib::layout_columns(
      col_widths = bslib::breakpoints(
        xs = 12,
        sm = 6,
        md = 4,
        lg = 4
      ),
      fill = FALSE,
      kpi_card_institucional(
        titulo_ui = shiny::HTML("Tasa de Informalidad Media \\((\\overline{X}_d)\\)"),
        valor_ui  = shiny::textOutput(ns("vb_inf_media"), inline = TRUE),
        sub_ui    = shiny::uiOutput(ns("sub_inf_media"), inline = TRUE),
        acento    = "navy"
      ),
      kpi_card_institucional(
        titulo_ui = shiny::uiOutput(ns("titulo_vb_y"), inline = TRUE),
        valor_ui  = shiny::textOutput(ns("vb_y_medio"), inline = TRUE),
        sub_ui    = shiny::textOutput(ns("sub_y_medio"), inline = TRUE),
        acento    = "teal"
      ),
      kpi_card_institucional(
        titulo_ui = shiny::HTML("Correlación Lineal de Pearson \\((r_{X,Y})\\)"),
        valor_ui  = shiny::uiOutput(ns("vb_correlacion"), inline = TRUE),
        sub_ui    = shiny::textOutput(ns("sub_ocupados"), inline = TRUE),
        acento    = "slate"
      )
    ),

    bslib::navset_card_underline(
      full_screen = TRUE,
      title       = shiny::HTML("Análisis Transversal de Dualismo Laboral y Capacidad Fiscal \\((2024)\\)"),
      bslib::nav_panel(
        title = "Dispersión y Ajuste MCO (Plotly)",
        plotly::plotlyOutput(ns("grafico_libre_plotly"), height = "525px")
      ),
      bslib::nav_panel(
        title = "Matriz de Datos Departamentales",
        DT::DTOutput(ns("tabla_laboral_dt"))
      )
    ),

    bslib::accordion(
      id       = ns("acc_nota_tecnica_tab3"),
      open     = FALSE,
      multiple = TRUE,
      class    = "accordion-institutional",
      bslib::accordion_panel(
        title = "Nota Técnica e Interpretación Económica: Dualismo Laboral y Capacidad Fiscal (Desplegar)",
        value = "panel_nota_tab3",
        shiny::p(
          "El gráfico examina la relación estructural entre la ",
          shiny::tags$strong("Tasa de Informalidad Laboral"), " ",
          shiny::HTML("\\((X_d, \\text{ en \\%})\\)"),
          " bajo la definición oficial DANE y la variable dependiente seleccionada ",
          shiny::HTML("\\((Y_d)\\)"),
          ": la ", shiny::tags$strong("Mediana del Ingreso Laboral Mensual (COP)"),
          " o el ", shiny::tags$strong("Índice de Desempeño Fiscal Departamental Artificial (puntos)"),
          ". El tamaño de cada marcador es proporcional a la población ocupada expandida ",
          shiny::HTML("\\((L_d)\\)"), "."
        ),
        shiny::p(
          class = "mb-0",
          shiny::HTML(
            "En la muestra departamental completa se verifica una asociación lineal negativa estadísticamente significativa entre informalidad e ingreso laboral mediano \\(\\left(r_{X,Y} = -0.81\\right)\\): economías con mayor densidad formal como Bogotá D. C. \\((34.6\\%)\\) y Antioquia \\((48.1\\%)\\) registran medianas salariales entre \\(\\$1,400,000\\) y \\(\\$1,500,000\\text{ COP}\\) junto con puntajes fiscales superiores a \\(69\\text{ puntos}\\), mientras que los departamentos con informalidad superior al \\(78\\%\\) exhiben menor capacidad de generación de ingresos propios y menores remuneraciones medianas."
          )
        )
      )
    )
  )
}

#' Servidor del Módulo Pestaña 3 (Diseño Libre en Plotly)
#' @noRd
mod_tab3_libre_server <- function(id, df_labor, regiones_choices) {
  shiny::moduleServer(id, function(input, output, session) {

    shiny::observeEvent(input$btn_reset_filtros, {
      shiny::updateCheckboxGroupInput(session, "regiones_sel", selected = regiones_choices)
      shiny::updateSliderInput(session, "ocupados_slider", value = 100)
      shiny::updateCheckboxInput(session, "mostrar_tendencia", value = TRUE)
      shiny::updateCheckboxInput(session, "mostrar_cuadrantes", value = TRUE)
    })

    datos_filtrados <- shiny::reactive({
      if (is.null(input$regiones_sel) || length(input$regiones_sel) == 0) {
        return(df_labor[0, ])
      }
      df_labor |>
        dplyr::filter(
          REGION %in% input$regiones_sel,
          OCUPADOS_EXP >= (input$ocupados_slider * 1000)
        )
    })

    output$ecuacion_mco_latex <- shiny::renderUI({
      d <- datos_filtrados()
      if (nrow(d) < 3) {
        return(shiny::p(class = "small text-muted mb-1", "Seleccione al menos 3 departamentos para estimar MCO."))
      }
      es_idf <- identical(input$eje_y_var, "IDF_DEPARTAMENTAL")
      y_vals <- if (es_idf) d$IDF_DEPARTAMENTAL else d$INGRESO_MEDIANO
      mod    <- stats::lm(y_vals ~ d$TASA_INFORMALIDAD)
      coefs  <- stats::coef(mod)
      r2     <- summary(mod)$r.squared

      if (es_idf) {
        eq_str <- sprintf(
          "$$\\widehat{\\text{IDF}}_d = %.2f %s %.3f\\,X_d \\quad (R^2 = %.3f,\\; N = %d)$$",
          coefs[1], ifelse(coefs[2] >= 0, "+", "-"), abs(coefs[2]), r2, nrow(d)
        )
      } else {
        eq_str <- sprintf(
          "$$\\widehat{W}_d = %s %s %s\\,X_d \\quad (R^2 = %.3f,\\; N = %d)$$",
          format(round(coefs[1]), big.mark = ","),
          ifelse(coefs[2] >= 0, "+", "-"),
          format(round(abs(coefs[2])), big.mark = ","),
          r2, nrow(d)
        )
      }

      shiny::div(class = "latex-box", shiny::HTML(eq_str))
    })

    output$vb_inf_media <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("Sin datos")
      sprintf("%.1f %%", mean(d$TASA_INFORMALIDAD, na.rm = TRUE))
    })

    output$sub_inf_media <- shiny::renderUI({
      d <- datos_filtrados()
      if (nrow(d) == 0) return(shiny::HTML("Seleccione al menos una región"))
      shiny::HTML(sprintf("Submuestra activa: \\(N = %d\\) de \\(%d\\) departamentos", nrow(d), nrow(df_labor)))
    })

    output$titulo_vb_y <- shiny::renderUI({
      if (identical(input$eje_y_var, "IDF_DEPARTAMENTAL")) {
        shiny::HTML("Media del IDF Departamental \\((\\overline{Y}_d)\\)")
      } else {
        shiny::HTML("Ingreso Mediano Promedio \\((\\overline{Y}_d)\\)")
      }
    })

    output$vb_y_medio <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("Sin datos")
      if (identical(input$eje_y_var, "IDF_DEPARTAMENTAL")) {
        sprintf("%.2f puntos", mean(d$IDF_DEPARTAMENTAL, na.rm = TRUE))
      } else {
        paste0("$", format(round(mean(d$INGRESO_MEDIANO, na.rm = TRUE)), big.mark = ","), " COP")
      }
    })

    output$sub_y_medio <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("")
      if (identical(input$eje_y_var, "IDF_DEPARTAMENTAL")) {
        sprintf("Rango muestral: [%.1f, %.1f] pts", min(d$IDF_DEPARTAMENTAL, na.rm = TRUE), max(d$IDF_DEPARTAMENTAL, na.rm = TRUE))
      } else {
        sprintf(
          "Rango: $%s a $%s",
          format(round(min(d$INGRESO_MEDIANO, na.rm = TRUE)), big.mark = ","),
          format(round(max(d$INGRESO_MEDIANO, na.rm = TRUE)), big.mark = ",")
        )
      }
    })

    output$vb_correlacion <- shiny::renderUI({
      d <- datos_filtrados()
      if (nrow(d) < 3) return(shiny::HTML("\\(N < 3\\)"))
      y_vals <- if (identical(input$eje_y_var, "IDF_DEPARTAMENTAL")) d$IDF_DEPARTAMENTAL else d$INGRESO_MEDIANO
      r_val  <- stats::cor(d$TASA_INFORMALIDAD, y_vals, use = "complete.obs")
      shiny::HTML(sprintf("\\(r = %.3f \\; (R^2 = %.3f)\\)", r_val, r_val^2))
    })

    output$sub_ocupados <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("0 ocupados")
      tot_oc <- sum(d$OCUPADOS_EXP, na.rm = TRUE) / 1e6
      sprintf("Población ocupada representada: %.2f millones", tot_oc)
    })

    output$grafico_libre_plotly <- plotly::renderPlotly({
      d <- datos_filtrados()
      if (nrow(d) == 0) {
        return(
          plotly::plot_ly() |>
            plotly::layout(
              title = list(
                text = "Seleccione al menos una región geográfica o reduzca el umbral de ocupados",
                font = list(size = 13, color = "#475569")
              )
            )
        )
      }

      es_idf     <- identical(input$eje_y_var, "IDF_DEPARTAMENTAL")
      df_plot    <- d
      df_plot$yv <- if (es_idf) df_plot$IDF_DEPARTAMENTAL else df_plot$INGRESO_MEDIANO
      etiqueta_y <- if (es_idf) {
        "<b>IDF Departamental Artificial 2024 (Puntos)</b>"
      } else {
        "<b>Mediana del Ingreso Laboral Mensual (COP)</b>"
      }

      prom_x <- mean(df_labor$TASA_INFORMALIDAD, na.rm = TRUE)
      prom_y <- if (es_idf) {
        mean(df_labor$IDF_DEPARTAMENTAL, na.rm = TRUE)
      } else {
        mean(df_labor$INGRESO_MEDIANO, na.rm = TRUE)
      }

      # Diámetro de burbuja escalado por raíz cuadrada de ocupados expandidos
      df_plot$tam_burbuja <- scales::rescale(
        sqrt(df_plot$OCUPADOS_EXP),
        to   = c(15, 50),
        from = sqrt(range(df_labor$OCUPADOS_EXP, na.rm = TRUE))
      )

      # Posición inteligente de etiquetas para evitar colisiones en valores empatados
      df_plot$pos_texto <- dplyr::case_when(
        df_plot$NOMBRE_DPTO %in% c("Risaralda", "Meta", "Bolívar", "Cauca", "La Guajira") ~ "bottom center",
        df_plot$NOMBRE_DPTO %in% c("Caldas", "Cundinamarca", "Atlántico", "Chocó")        ~ "middle left",
        df_plot$NOMBRE_DPTO %in% c("Quindío", "Boyacá", "Norte de Santander", "Sucre")    ~ "middle right",
        TRUE                                                                              ~ "top center"
      )

      # Paleta institucional alineada exactamente con los valores de REGION en df_labor.rds
      paleta_reg <- c(
        "Bogotá D.C."        = "#1e3a5f",
        "Central"            = "#2563eb",
        "Oriental"           = "#4f46e5",
        "Caribe"             = "#0f766e",
        "Pacífica"           = "#b45309",
        "Amazonía/Orinoquía" = "#15803d"
      )

      fig <- plotly::plot_ly(
        data         = df_plot,
        x            = ~TASA_INFORMALIDAD,
        y            = ~yv,
        color        = ~REGION,
        colors       = paleta_reg,
        type         = "scatter",
        mode         = "markers+text",
        text         = ~NOMBRE_DPTO,
        textposition = ~pos_texto,
        textfont     = list(size = 10.5, color = "#1e293b", family = "IBM Plex Sans, sans-serif"),
        marker       = list(
          size     = ~tam_burbuja,
          sizemode = "diameter",
          opacity  = 0.85,
          line     = list(width = 1.4, color = "#0f172a")
        ),
        hoverinfo    = "text",
        hovertext    = ~paste0(
          "<b>", NOMBRE_DPTO, "</b> (", REGION, ")<br>",
          "Informalidad laboral (X_d): ", sprintf("%.1f%%", TASA_INFORMALIDAD), "<br>",
          "Ingreso laboral mediano: $", format(round(INGRESO_MEDIANO), big.mark = ","), " COP<br>",
          "IDF Departamental 2024: ", sprintf("%.2f puntos", IDF_DEPARTAMENTAL), "<br>",
          "Ocupados expandidos (L_d): ", format(round(OCUPADOS_EXP), big.mark = ",")
        )
      )

      if (isTRUE(input$mostrar_tendencia) && nrow(df_plot) >= 3) {
        modelo_mco <- stats::lm(yv ~ TASA_INFORMALIDAD, data = df_plot)
        x_seq      <- seq(min(df_plot$TASA_INFORMALIDAD), max(df_plot$TASA_INFORMALIDAD), length.out = 80)
        pred_df    <- as.data.frame(
          stats::predict(
            modelo_mco,
            newdata  = data.frame(TASA_INFORMALIDAD = x_seq),
            interval = "confidence",
            level    = 0.95
          )
        )
        pred_df$x  <- x_seq

        fig <- fig |>
          plotly::add_ribbons(
            data       = pred_df,
            x          = ~x,
            ymin       = ~lwr,
            ymax       = ~upr,
            name       = "IC 95% (MCO)",
            inherit    = FALSE,
            fillcolor  = "rgba(30, 58, 95, 0.10)",
            line       = list(color = "rgba(30, 58, 95, 0.22)", width = 0.8),
            hoverinfo  = "skip",
            showlegend = TRUE
          ) |>
          plotly::add_lines(
            data       = pred_df,
            x          = ~x,
            y          = ~fit,
            name       = "Ajuste lineal MCO",
            inherit    = FALSE,
            line       = list(color = "#0f172a", width = 2.2, dash = "dash"),
            hoverinfo  = "skip",
            showlegend = TRUE
          )
      }

      shapes_list      <- list()
      annotations_list <- list()
      y_min_plot       <- if (es_idf) 38 else 720000
      y_max_plot       <- if (es_idf) 82 else 1590000

      if (isTRUE(input$mostrar_cuadrantes)) {
        shapes_list <- list(
          list(
            type      = "rect",
            layer     = "below",
            x0        = 30,
            x1        = prom_x,
            y0        = prom_y,
            y1        = y_max_plot,
            xref      = "x",
            yref      = "y",
            fillcolor = "rgba(15, 118, 110, 0.045)",
            line      = list(width = 0)
          ),
          list(
            type      = "rect",
            layer     = "below",
            x0        = prom_x,
            x1        = 87,
            y0        = y_min_plot,
            y1        = prom_y,
            xref      = "x",
            yref      = "y",
            fillcolor = "rgba(180, 83, 9, 0.045)",
            line      = list(width = 0)
          ),
          list(
            type = "line", x0 = prom_x, x1 = prom_x, y0 = 0, y1 = 1, yref = "paper",
            line = list(color = "#64748b", width = 1.3, dash = "dot")
          ),
          list(
            type = "line", x0 = 0, x1 = 1, xref = "paper", y0 = prom_y, y1 = prom_y,
            line = list(color = "#64748b", width = 1.3, dash = "dot")
          )
        )

        annotations_list <- list(
          list(
            x           = 31.2,
            y           = if (es_idf) 80.2 else 1565000,
            xref        = "x",
            yref        = "y",
            text        = if (es_idf) {
              "<b>Cuadrante I: Mayor Formalidad y Desempeño Fiscal</b>"
            } else {
              "<b>Cuadrante I: Mayor Formalidad y Remuneración Mediana</b>"
            },
            showarrow   = FALSE,
            xanchor     = "left",
            yanchor     = "top",
            bgcolor     = "rgba(240, 253, 250, 0.90)",
            bordercolor = "#0f766e",
            borderwidth = 1,
            borderpad   = 4,
            font        = list(size = 10, color = "#0f766e", family = "IBM Plex Sans, sans-serif")
          ),
          list(
            x           = 85.8,
            y           = if (es_idf) 39.8 else 745000,
            xref        = "x",
            yref        = "y",
            text        = if (es_idf) {
              "<b>Cuadrante IV: Alta Informalidad y Rezago Fiscal</b>"
            } else {
              "<b>Cuadrante IV: Alta Informalidad y Rezago de Ingresos</b>"
            },
            showarrow   = FALSE,
            xanchor     = "right",
            yanchor     = "bottom",
            bgcolor     = "rgba(255, 251, 235, 0.92)",
            bordercolor = "#b45309",
            borderwidth = 1,
            borderpad   = 4,
            font        = list(size = 10, color = "#b45309", family = "IBM Plex Sans, sans-serif")
          ),
          list(
            x         = prom_x + 0.5,
            y         = if (es_idf) 40.2 else 750000,
            xref      = "x",
            yref      = "y",
            text      = sprintf("Media X: %.1f%%", prom_x),
            showarrow = FALSE,
            xanchor   = "left",
            font      = list(size = 9.5, color = "#475569")
          )
        )
      }

      fig |>
        plotly::layout(
          paper_bgcolor = "#ffffff",
          plot_bgcolor  = "#ffffff",
          xaxis = list(
            title      = list(text = "<b>Tasa de Informalidad Laboral DANE (X_d, %)</b>", font = list(size = 11.5, color = "#1e293b")),
            range      = c(30, 87),
            zeroline   = FALSE,
            ticksuffix = "%",
            showgrid   = TRUE,
            gridcolor  = "#e2e8f0",
            showline   = TRUE,
            linecolor  = "#94a3b8"
          ),
          yaxis = list(
            title      = list(text = etiqueta_y, font = list(size = 11.5, color = "#1e293b")),
            range      = c(y_min_plot, y_max_plot),
            zeroline   = FALSE,
            tickformat = if (es_idf) ".1f" else "$,.0f",
            showgrid   = TRUE,
            gridcolor  = "#e2e8f0",
            showline   = TRUE,
            linecolor  = "#94a3b8"
          ),
          shapes      = shapes_list,
          annotations = annotations_list,
          autosize    = TRUE,
          legend      = list(
            title       = list(text = "<b>Región DANE y Ajuste</b>", font = list(size = 11)),
            font        = list(size = 10.5, color = "#1e293b"),
            bgcolor     = "rgba(248, 250, 252, 0.85)",
            bordercolor = "#cbd5e1",
            borderwidth = 1
          ),
          margin      = list(l = 75, r = 25, t = 28, b = 52)
        ) |>
        plotly::config(responsive = TRUE, displayModeBar = "hover")
    })

    output$tabla_laboral_dt <- DT::renderDT({
      d <- datos_filtrados()
      if (nrow(d) == 0) return(NULL)
      tabla_mostrar <- d |>
        dplyr::arrange(TASA_INFORMALIDAD) |>
        dplyr::transmute(
          `Cód. Dpto.`            = COD_DPTO,
          `Departamento`          = NOMBRE_DPTO,
          `Región`                = REGION,
          `Informalidad (%)`      = sprintf("%.1f%%", TASA_INFORMALIDAD),
          `Ingreso Mediano (COP)` = paste0("$", format(round(INGRESO_MEDIANO), big.mark = ",")),
          `IDF Dpto. 2024 (pts)`  = sprintf("%.2f", IDF_DEPARTAMENTAL),
          `Ocupados Expandidos`   = format(round(OCUPADOS_EXP), big.mark = ",")
        )

      DT::datatable(
        tabla_mostrar,
        rownames = FALSE,
        class    = "table table-hover table-sm align-middle",
        options  = list(
          pageLength = 10,
          scrollX    = TRUE,
          dom        = "tip",
          language   = list(
            info      = "Mostrando _START_ a _END_ de _TOTAL_ departamentos",
            infoEmpty = "Sin registros",
            paginate  = list(previous = "Anterior", `next` = "Siguiente")
          )
        )
      )
    })
  })
}
