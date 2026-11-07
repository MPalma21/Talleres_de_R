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
    sidebar = bslib::sidebar(
      title = "Controles Interactivos",
      width = 330,
      shiny::selectInput(
        inputId  = ns("eje_y_var"),
        label    = "Variable en el eje vertical (Y):",
        choices  = c(
          "Mediana del Ingreso Laboral (COP)"        = "INGRESO_MEDIANO",
          "Desempeño Fiscal Departamental IDF (pts)" = "IDF_DEPARTAMENTAL"
        ),
        selected = "INGRESO_MEDIANO"
      ),
      shiny::checkboxGroupInput(
        inputId  = ns("regiones_sel"),
        label    = "Filtrar por región geográfica:",
        choices  = regiones_choices,
        selected = regiones_choices
      ),
      shiny::actionButton(
        inputId = ns("btn_reset_filtros"),
        label   = "Restablecer todas las regiones",
        icon    = shiny::icon("rotate-left"),
        class   = "btn-outline-primary btn-sm w-100 mb-2"
      ),
      shiny::sliderInput(
        inputId = ns("ocupados_slider"),
        label   = "Mínimo de ocupados expandidos (miles):",
        min     = 100,
        max     = 4000,
        value   = 100,
        step    = 100
      ),
      bslib::input_switch(
        id    = ns("mostrar_tendencia"),
        label = "Mostrar ajuste lineal MCO",
        value = TRUE
      ),
      bslib::input_switch(
        id    = ns("mostrar_cuadrantes"),
        label = "Mostrar cuadrantes de promedio nacional",
        value = TRUE
      ),
      shiny::hr(),
      bslib::card(
        bslib::card_header("Fuentes y Metodología"),
        shiny::p(
          shiny::tags$b("Autoría: "),
          "Grupo 10 (Juan José Echeverry, Miguelangel Palma, Sergio López)."
        ),
        shiny::p(
          class = "mb-0",
          shiny::tags$b("Datos: "),
          "Integración departamental de la GEIH 2024 y EMICRON 2024 (DANE) con el IDF Departamental Artificial 2024 (DNP), exportada en ",
          shiny::tags$code("datos_ejercicio_3c_laboral.csv"), "."
        ),
        class = "text-muted small"
      )
    ),

    bslib::layout_column_wrap(
      width = 1 / 3,
      fill  = FALSE,
      bslib::value_box(
        title    = "Informalidad Media (Selección)",
        value    = shiny::textOutput(ns("vb_inf_media")),
        shiny::p(class = "small mb-0 opacity-75", shiny::textOutput(ns("sub_inf_media"))),
        showcase = shiny::icon("briefcase"),
        theme    = "primary"
      ),
      bslib::value_box(
        title    = shiny::textOutput(ns("titulo_vb_y")),
        value    = shiny::textOutput(ns("vb_y_medio")),
        shiny::p(class = "small mb-0 opacity-75", shiny::textOutput(ns("sub_y_medio"))),
        showcase = shiny::icon("money-bill-trend-up"),
        theme    = "secondary"
      ),
      bslib::value_box(
        title    = "Correlación Lineal (r de Pearson)",
        value    = shiny::textOutput(ns("vb_correlacion")),
        shiny::p(class = "small mb-0 opacity-75", shiny::textOutput(ns("sub_ocupados"))),
        showcase = shiny::icon("braille"),
        theme    = "success"
      )
    ),

    bslib::navset_card_underline(
      full_screen = TRUE,
      title       = "Explorador de Dualismo Laboral y Capacidad Fiscal en Colombia (2024)",
      bslib::nav_panel(
        title = "Gráfico Interactivo (Plotly)",
        icon  = shiny::icon("circle-nodes"),
        plotly::plotlyOutput(ns("grafico_libre_plotly"), height = "420px")
      ),
      bslib::nav_panel(
        title = "Tabla de Auditoría Departamental",
        icon  = shiny::icon("table"),
        DT::DTOutput(ns("tabla_laboral_dt"))
      )
    ),

    bslib::card(
      bslib::card_header("Explicación Analítica de los Datos y Hallazgos (Grupo 10)"),
      shiny::p(
        "Esta visualización examina la estructura de dualismo territorial del mercado laboral colombiano a escala departamental, integrando los microdatos de la GEIH y EMICRON 2024 (DANE) construidos en los talleres previos con el Índice de Desempeño Fiscal (IDF) 2024 del Ejercicio 1. ",
        "El eje horizontal mide la ", shiny::tags$b("Tasa de Informalidad Laboral (%)"),
        " bajo la definición oficial del DANE, mientras que el eje vertical permite alternar entre la ",
        shiny::tags$b("Mediana del Ingreso Laboral Mensual (COP)"), " y el ",
        shiny::tags$b("IDF Departamental Artificial (puntos)"),
        ". El área de cada burbuja es proporcional al total de ocupados expandidos y el color distingue las seis regiones geográficas."
      ),
      shiny::p(
        class = "mb-0",
        "Los datos muestran una marcada relación negativa entre informalidad y remuneración laboral (correlación lineal r = -0.81): los mercados urbanos con mayor tejido empresarial formal, encabezados por Bogotá D.C. (34.6% de informalidad) y Antioquia (48.1%), registran ingresos laborales medianos entre $1,400,000 y $1,500,000 COP y un desempeño fiscal superior a 69 puntos. ",
        "En contraste, departamentos periféricos del Caribe y el Pacífico como Nariño (82.6%), Sucre (82.1%), Córdoba (80.5%) y La Guajira (79.4%) combinan tasas de informalidad cercanas al 80% con ingresos medianos de $800,000 a $1,000,000 COP y menor capacidad de recaudo fiscal propio."
      )
    )
  )
}

#' Servidor del Módulo Pestaña 3 (Diseño Libre en Plotly)
#' @noRd
mod_tab3_libre_server <- function(id, df_labor, regiones_choices) {
  shiny::moduleServer(id, function(input, output, session) {

    shiny::observeEvent(input$btn_reset_filtros, {
      shiny::updateCheckboxGroupInput(
        session, "regiones_sel", selected = regiones_choices
      )
      shiny::updateSliderInput(session, "ocupados_slider", value = 100)
    })

    datos_filtrados <- shiny::reactive({
      shiny::req(input$regiones_sel)
      min_ocup <- input$ocupados_slider * 1000
      df_labor |>
        dplyr::filter(
          REGION %in% input$regiones_sel,
          OCUPADOS_EXP >= min_ocup
        )
    })

    output$vb_inf_media <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("Sin datos")
      sprintf("%.1f %%", mean(d$TASA_INFORMALIDAD, na.rm = TRUE))
    })

    output$sub_inf_media <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("Ajuste los filtros")
      pond <- stats::weighted.mean(d$TASA_INFORMALIDAD, w = d$OCUPADOS_EXP, na.rm = TRUE)
      sprintf("Ponderada por ocupados: %.1f%% (%d dptos.)", pond, nrow(d))
    })

    output$titulo_vb_y <- shiny::renderText({
      if (identical(input$eje_y_var, "IDF_DEPARTAMENTAL")) {
        "IDF Departamental Medio"
      } else {
        "Ingreso Mediano Promedio"
      }
    })

    output$vb_y_medio <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("Sin datos")
      if (identical(input$eje_y_var, "IDF_DEPARTAMENTAL")) {
        sprintf("%.2f pts", mean(d$IDF_DEPARTAMENTAL, na.rm = TRUE))
      } else {
        paste0("$", format(round(mean(d$INGRESO_MEDIANO, na.rm = TRUE)), big.mark = ","), " COP")
      }
    })

    output$sub_y_medio <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("Ajuste los filtros")
      if (identical(input$eje_y_var, "IDF_DEPARTAMENTAL")) {
        sprintf("Rango selección: %.1f a %.1f pts", min(d$IDF_DEPARTAMENTAL), max(d$IDF_DEPARTAMENTAL))
      } else {
        sprintf(
          "Rango: $%s a $%s",
          format(round(min(d$INGRESO_MEDIANO)), big.mark = ","),
          format(round(max(d$INGRESO_MEDIANO)), big.mark = ",")
        )
      }
    })

    output$vb_correlacion <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) < 3) return("n < 3")
      y_vec <- d[[input$eje_y_var]]
      r_val <- stats::cor(d$TASA_INFORMALIDAD, y_vec, use = "complete.obs")
      sprintf("r = %.2f", r_val)
    })

    output$sub_ocupados <- shiny::renderText({
      d <- datos_filtrados()
      if (nrow(d) == 0) return("0 ocupados")
      sprintf(
        "Ocupados representados: %s M",
        format(round(sum(d$OCUPADOS_EXP, na.rm = TRUE) / 1e6, 2), big.mark = ",")
      )
    })

    output$grafico_libre_plotly <- plotly::renderPlotly({
      df_plot <- datos_filtrados()
      if (nrow(df_plot) == 0) return(NULL)

      es_idf      <- identical(input$eje_y_var, "IDF_DEPARTAMENTAL")
      df_plot$y_v <- df_plot[[input$eje_y_var]]
      etiqueta_y  <- if (es_idf) {
        "IDF Departamental Artificial 2024 (puntos)"
      } else {
        "Ingreso Laboral Mediano Mensual (COP)"
      }

      prom_x <- mean(df_labor$TASA_INFORMALIDAD, na.rm = TRUE)
      prom_y <- mean(df_labor[[input$eje_y_var]], na.rm = TRUE)
      df_plot$tam_burbuja <- scales::rescale(
        sqrt(df_plot$OCUPADOS_EXP),
        to   = c(14, 48),
        from = sqrt(range(df_labor$OCUPADOS_EXP, na.rm = TRUE))
      )

      fig <- plotly::plot_ly(
        data        = df_plot,
        x           = ~TASA_INFORMALIDAD,
        y           = ~y_v,
        type        = "scatter",
        mode        = "markers+text",
        color       = ~REGION,
        colors      = "Set2",
        marker      = list(
          size     = ~tam_burbuja,
          sizemode = "diameter",
          opacity  = 0.84,
          line     = list(width = 1.2, color = "#1e293b")
        ),
        text         = ~NOMBRE_DPTO,
        textposition = "top center",
        hoverinfo    = "text",
        hovertext    = ~paste0(
          "<b>", NOMBRE_DPTO, "</b> (", REGION, ")<br>",
          "• Informalidad laboral: ", sprintf("%.1f%%", TASA_INFORMALIDAD), "<br>",
          "• Ingreso laboral mediano: $", format(round(INGRESO_MEDIANO), big.mark = ","), " COP<br>",
          "• IDF Departamental 2024: ", sprintf("%.2f pts", IDF_DEPARTAMENTAL), "<br>",
          "• Ocupados expandidos: ", format(round(OCUPADOS_EXP), big.mark = ",")
        )
      )

      if (isTRUE(input$mostrar_tendencia) && nrow(df_plot) >= 3) {
        modelo_mco <- stats::lm(y_v ~ TASA_INFORMALIDAD, data = df_plot)
        x_seq      <- seq(min(df_plot$TASA_INFORMALIDAD), max(df_plot$TASA_INFORMALIDAD), length.out = 50)
        y_pred     <- stats::predict(modelo_mco, newdata = data.frame(TASA_INFORMALIDAD = x_seq))

        fig <- fig |>
          plotly::add_lines(
            x          = x_seq,
            y          = y_pred,
            name       = "Tendencia MCO",
            inherit    = FALSE,
            line       = list(color = "#334155", width = 2, dash = "dash"),
            hoverinfo  = "skip",
            showlegend = TRUE
          )
      }

      shapes_list <- list()
      if (isTRUE(input$mostrar_cuadrantes)) {
        shapes_list <- list(
          list(
            type = "line", x0 = prom_x, x1 = prom_x, y0 = 0, y1 = 1, yref = "paper",
            line = list(color = "#94a3b8", width = 1.2, dash = "dot")
          ),
          list(
            type = "line", x0 = 0, x1 = 1, xref = "paper", y0 = prom_y, y1 = prom_y,
            line = list(color = "#94a3b8", width = 1.2, dash = "dot")
          )
        )
      }

      fig |>
        plotly::layout(
          xaxis = list(
            title      = "Tasa de Informalidad Laboral (%)",
            zeroline   = FALSE,
            ticksuffix = "%"
          ),
          yaxis = list(
            title      = etiqueta_y,
            zeroline   = FALSE,
            tickformat = if (es_idf) ".1f" else "$,.0f"
          ),
          shapes = shapes_list,
          legend = list(title = list(text = "<b>Región</b>")),
          margin = list(l = 65, r = 25, t = 30, b = 50)
        )
    })

    output$tabla_laboral_dt <- DT::renderDT({
      d <- datos_filtrados()
      if (nrow(d) == 0) return(NULL)
      tabla_mostrar <- d |>
        dplyr::arrange(TASA_INFORMALIDAD) |>
        dplyr::transmute(
          `Cód.`                   = COD_DPTO,
          `Departamento`           = NOMBRE_DPTO,
          `Región`                 = REGION,
          `Informalidad (%)`       = sprintf("%.1f%%", TASA_INFORMALIDAD),
          `Ingreso Mediano (COP)`  = paste0("$", format(round(INGRESO_MEDIANO), big.mark = ",")),
          `IDF Dpto. 2024 (pts)`   = sprintf("%.2f", IDF_DEPARTAMENTAL),
          `Ocupados Expandidos`    = format(round(OCUPADOS_EXP), big.mark = ",")
        )

      DT::datatable(
        tabla_mostrar,
        rownames = FALSE,
        options  = list(pageLength = 10, scrollX = TRUE, dom = "tip")
      )
    })
  })
}
