# ==============================================================================
# Módulo Pestaña 1: Datos Geoespaciales - IDF Departamental y Top 3 Municipios
# Archivo: R/mod_tab1_idf.R
# Eje 1 (Líder: Sergio López) | Arquitectura Modular bslib (Juan José Echeverry)
# ==============================================================================

#' UI del Módulo Pestaña 1 (Desempeño Fiscal Territorial)
#' @noRd
mod_tab1_idf_ui <- function(id, deptos_choices) {
  ns <- shiny::NS(id)

  choices_territorio <- c(
    "Total Nacional (Colombia)" = "NACIONAL",
    stats::setNames(deptos_choices, deptos_choices)
  )

  bslib::layout_sidebar(
    fillable = FALSE,
    sidebar  = bslib::sidebar(
      title     = "Control Territorial",
      width     = 315,
      open      = "desktop",
      resizable = TRUE,
      shiny::selectizeInput(
        inputId  = ns("depto_sel"),
        label    = "Nivel territorial o departamento:",
        choices  = choices_territorio,
        selected = if ("Antioquia" %in% deptos_choices) "Antioquia" else "NACIONAL",
        options  = list(placeholder = "Escriba o seleccione un territorio...")
      ),
      shiny::actionButton(
        inputId = ns("btn_vista_nacional"),
        label   = "Restablecer encuadre y resumen nacional",
        class   = "btn-audit w-100 mb-2"
      ),
      shiny::div(
        class = "method-section",
        shiny::div(class = "method-title", "Especificación Metodológica"),
        shiny::p(
          class = "mb-1",
          shiny::tags$strong("Índice Departamental Artificial:"),
          " media ponderada de los municipios evaluados ",
          shiny::HTML("\\((i = 1, \\dots, n_j)\\)"), ":"
        ),
        shiny::div(
          class = "latex-box",
          shiny::HTML("$$\\text{IDF}_j^{\\text{Dpto}} = \\sum_{i=1}^{n_j} w_i \\cdot \\text{IDF}_i$$")
        ),
        shiny::p(
          class = "mb-1",
          "donde el ponderador demográfico-económico ",
          shiny::HTML("\\(w_i\\)"), " se define como:"
        ),
        shiny::div(
          class = "latex-box",
          shiny::HTML("$$w_i = \\frac{L_i \\cdot \\text{VA}_i}{\\sum_{k=1}^{n_j} (L_k \\cdot \\text{VA}_k)}, \\quad \\sum_{i=1}^{n_j} w_i = 1$$")
        ),
        shiny::p(
          class = "mb-0 small",
          "Con población DANE 2024 ", shiny::HTML("\\((L_i)\\)"),
          " y Valor Agregado municipal proyectado a precios corrientes de 2024 ",
          shiny::HTML("\\(\\text{VA}_{i,2024} = \\text{VA}_{i,2023}(1+g)\\)"),
          " con ", shiny::HTML("\\(g = 8.27\\%\\)"), ". ",
          shiny::tags$strong("Índice Municipal (Vigencia 2024):"),
          " calificación oficial directa del DNP en escala ",
          shiny::HTML("\\([0, 100]\\)"), "."
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
        titulo_ui = shiny::uiOutput(ns("titulo_vb_idf"), inline = TRUE),
        valor_ui  = shiny::textOutput(ns("vb_idf_depto"), inline = TRUE),
        sub_ui    = shiny::uiOutput(ns("sub_idf_depto"), inline = TRUE),
        acento    = "navy"
      ),
      kpi_card_institucional(
        titulo_ui = shiny::uiOutput(ns("titulo_vb_mpios"), inline = TRUE),
        valor_ui  = shiny::textOutput(ns("vb_n_mpios"), inline = TRUE),
        sub_ui    = shiny::textOutput(ns("sub_pob_depto"), inline = TRUE),
        acento    = "slate"
      ),
      kpi_card_institucional(
        titulo_ui = shiny::uiOutput(ns("titulo_vb_lider"), inline = TRUE),
        valor_ui  = shiny::textOutput(ns("vb_lider_mpio"), inline = TRUE),
        sub_ui    = shiny::uiOutput(ns("sub_lider_mpio"), inline = TRUE),
        acento    = "teal"
      )
    ),

    bslib::layout_columns(
      col_widths = bslib::breakpoints(
        xs = c(12, 12),
        lg = c(7, 5)
      ),
      fill = FALSE,
      bslib::card(
        full_screen = TRUE,
        class       = "card-equal-height",
        bslib::card_header(
          shiny::HTML("Cartografía del Índice de Desempeño Fiscal Departamental Artificial \\((\\text{IDF}_j^{\\text{Dpto}}, \\text{ Vigencia 2024})\\)")
        ),
        leaflet::leafletOutput(ns("mapa_leaflet"), height = "500px"),
        bslib::card_footer(
          "Seleccione un polígono departamental sobre el mapa o utilice el botón lateral para alternar entre el desglose departamental y el resumen nacional."
        )
      ),
      bslib::card(
        full_screen = TRUE,
        class       = "card-equal-height",
        bslib::card_header(
          shiny::uiOutput(ns("titulo_card_top3"), inline = TRUE)
        ),
        shiny::uiOutput(ns("tabla_top3_academic")),
        shiny::uiOutput(ns("nota_top3_depto")),
        bslib::card_footer(
          shiny::HTML("El peso relativo \\(w_i\\) cuantifica la participación conjunta demográfica y productiva del municipio dentro de su departamento \\((\\sum_{i=1}^{n_j} w_i = 1)\\).")
        )
      )
    ),

    bslib::accordion(
      id       = ns("acc_nota_tecnica_tab1"),
      open     = FALSE,
      multiple = TRUE,
      class    = "accordion-institutional",
      bslib::accordion_panel(
        title = "Nota Técnica y Metodológica: Construcción del IDF Departamental Artificial vs. IDF Municipal Oficial DNP (Desplegar)",
        value = "panel_nota_tab1",
        shiny::div(
          class = "mb-2",
          shiny::tags$strong("1. Diferenciación conceptual entre el indicador municipal (oficial) y el departamental (artificial): "),
          shiny::HTML(
            "La calificación municipal \\(\\text{IDF}_i \\in [0, 100]\\) proviene directamente de los Resultados de Gestión y Sostenibilidad Financiera publicados por el <b>Departamento Nacional de Planeación (DNP, Vigencia 2024)</b> para los \\(N = 1,103\\) municipios evaluados. Por su parte, dado que el enunciado del Taller 3 solicita construir un índice sintético de agregación territorial a partir de la base municipal, el indicador departamental \\(\\text{IDF}_j^{\\text{Dpto}} = \\sum_{i=1}^{n_j} w_i \\cdot \\text{IDF}_i\\) constituye una media ponderada demográfico-económica cuyos pesos \\(w_i\\) suman la unidad dentro de cada jurisdicción \\(\\left(\\sum_{i=1}^{n_j} w_i = 1\\right)\\)."
          )
        ),
        shiny::div(
          class = "mb-0",
          shiny::tags$strong("2. Insumos de ponderación DANE y actualización a precios corrientes de 2024: "),
          shiny::HTML(
            "El ponderador municipal \\(w_i = (L_i \\cdot \\text{VA}_i) / \\sum_{k=1}^{n_j} (L_k \\cdot \\text{VA}_k)\\) articula la población total proyectada por el DANE para 2024 \\((L_i)\\) con el Valor Agregado municipal \\((\\text{VA}_i)\\) de las Cuentas Nacionales Departamentales del DANE (corte 2023 a precios corrientes), actualizado nominalmente a precios corrientes de 2024 mediante la tasa de crecimiento del PIB nominal nacional \\(g = 8.27\\%\\) reportada por el DANE \\(\\left(\\text{VA}_{i,2024} = \\text{VA}_{i,2023}(1+g)\\right)\\)."
          )
        )
      )
    )
  )
}

#' Servidor del Módulo Pestaña 1 (Desempeño Fiscal Territorial)
#' @noRd
mod_tab1_idf_server <- function(id, shp_dpto_simp, df_deptos, df_top3, deptos_choices) {
  shiny::moduleServer(id, function(input, output, session) {

    es_nacional <- shiny::reactive({
      is.null(input$depto_sel) || identical(input$depto_sel, "NACIONAL") || !nzchar(input$depto_sel)
    })

    depto_actual <- shiny::reactive({
      shiny::req(input$depto_sel)
      if (es_nacional()) return(df_deptos)
      df_deptos |> dplyr::filter(nom_dpto == input$depto_sel)
    })

    top3_actual <- shiny::reactive({
      shiny::req(input$depto_sel)
      if (es_nacional()) {
        df_top3 |>
          dplyr::arrange(dplyr::desc(idf_municipal)) |>
          dplyr::slice_head(n = 3) |>
          dplyr::mutate(ranking_vista = dplyr::row_number())
      } else {
        df_top3 |>
          dplyr::filter(nom_dpto == input$depto_sel) |>
          dplyr::arrange(ranking_mpio) |>
          dplyr::mutate(ranking_vista = as.integer(ranking_mpio))
      }
    })

    formatear_num_wi <- function(w) {
      if (is.na(w)) return("N/D")
      if (w < 0.001) sprintf("%.5f", w) else sprintf("%.4f", w)
    }

    formatear_pct_wi <- function(w) {
      if (is.na(w)) return("N/D")
      if (w < 0.001) sprintf("%.3f%%", w * 100) else sprintf("%.2f%%", w * 100)
    }

    formatear_aporte <- function(c_val) {
      if (is.na(c_val)) return("N/D")
      if (c_val < 0.05) sprintf("%.4f", c_val) else sprintf("%.2f", c_val)
    }

    # --- Títulos dinámicos de los 3 KPIs superiores ---
    output$titulo_vb_idf <- shiny::renderUI({
      if (es_nacional()) {
        shiny::HTML("IDF Departamental Promedio Nacional \\((\\overline{\\text{IDF}}^{\\text{Dpto}})\\)")
      } else {
        shiny::HTML("IDF Departamental Artificial \\((\\text{IDF}_j^{\\text{Dpto}})\\)")
      }
    })

    output$titulo_vb_mpios <- shiny::renderUI({
      if (es_nacional()) {
        shiny::HTML("Total Municipios Evaluados DNP \\((\\sum n_j)\\)")
      } else {
        shiny::HTML("Municipios Evaluados DNP \\((n_j)\\)")
      }
    })

    output$titulo_vb_lider <- shiny::renderUI({
      if (es_nacional()) {
        shiny::HTML("Municipio Líder Nacional \\((\\max_{i} \\text{IDF}_i)\\)")
      } else {
        shiny::HTML("Municipio Líder en el Dpto. \\((\\max_{i \\in j} \\text{IDF}_i)\\)")
      }
    })

    output$titulo_card_top3 <- shiny::renderUI({
      if (es_nacional()) {
        shiny::HTML("Top 3 Nacional de Municipios según Calificación Oficial DNP \\((\\text{IDF}_i, \\text{ Vigencia 2024})\\)")
      } else {
        shiny::HTML(sprintf(
          "Top 3 Municipal en %s según Calificación Oficial DNP \\((\\text{IDF}_i, \\text{ 2024})\\)",
          input$depto_sel
        ))
      }
    })

    # --- Valores y subtítulos de los 3 KPIs superiores ---
    output$vb_idf_depto <- shiny::renderText({
      d <- depto_actual()
      if (nrow(d) == 0) return("N/D")
      if (es_nacional()) {
        sprintf("%.2f puntos (Media Nal.)", mean(d$idf_departamental, na.rm = TRUE))
      } else {
        sprintf("%.2f puntos", d$idf_departamental[1])
      }
    })

    output$sub_idf_depto <- shiny::renderUI({
      d <- depto_actual()
      if (nrow(d) == 0) return(NULL)
      if (es_nacional()) {
        pond_nal <- stats::weighted.mean(
          d$idf_departamental,
          d$pob_dpto_2024 * d$va_dpto_2024_proj,
          na.rm = TRUE
        )
        shiny::HTML(sprintf(
          "Media ponderada \\((L_j \\cdot \\text{VA}_j)\\): %.2f pts · 33 dptos.",
          pond_nal
        ))
      } else {
        shiny::HTML(sprintf(
          "Departamento: %s (Cód. DIVIPOLA %s)",
          d$nom_dpto[1], sprintf("%02d", as.integer(d$cod_dpto[1]))
        ))
      }
    })

    output$vb_n_mpios <- shiny::renderText({
      d <- depto_actual()
      if (nrow(d) == 0) return("N/D")
      tot_m <- sum(d$n_mpios, na.rm = TRUE)
      sprintf(
        "%s %s",
        format(tot_m, big.mark = ","),
        ifelse(tot_m == 1, "municipio", "municipios")
      )
    })

    output$sub_pob_depto <- shiny::renderText({
      d <- depto_actual()
      if (nrow(d) == 0 || !"pob_dpto_2024" %in% names(d)) return("Cobertura oficial DNP 2024")
      tot_pob <- sum(d$pob_dpto_2024, na.rm = TRUE)
      sprintf("Población evaluada 2024: %s hab.", format(round(tot_pob), big.mark = ","))
    })

    output$vb_lider_mpio <- shiny::renderText({
      t3 <- top3_actual()
      if (nrow(t3) == 0) return("N/D")
      if (es_nacional()) {
        sprintf("%s, %s (%.2f pts)", t3$nom_mpio[1], t3$nom_dpto[1], t3$idf_municipal[1])
      } else {
        sprintf("%s (%.2f pts)", t3$nom_mpio[1], t3$idf_municipal[1])
      }
    })

    output$sub_lider_mpio <- shiny::renderUI({
      t3 <- top3_actual()
      if (nrow(t3) == 0) return(NULL)
      rango_txt <- if ("rango_idf" %in% names(t3) && !is.na(t3$rango_idf[1])) t3$rango_idf[1] else "Líder"
      shiny::HTML(sprintf(
        "Peso dpto. \\(w_i = %s\\) (%s) · %s",
        formatear_num_wi(t3$w_i[1]),
        formatear_pct_wi(t3$w_i[1]),
        rango_txt
      ))
    })

    # --- Tabla Académica Booktabs del Top 3 (Nacional o Departamental) ---
    output$tabla_top3_academic <- shiny::renderUI({
      t3 <- top3_actual()
      d  <- depto_actual()
      if (nrow(t3) == 0) return(shiny::p("Sin registros municipales disponibles."))

      filas_html <- lapply(seq_len(nrow(t3)), function(i) {
        contrib <- t3$w_i[i] * t3$idf_municipal[i]
        rango_sub <- if ("rango_idf" %in% names(t3) && !is.na(t3$rango_idf[i])) {
          paste0("DIVIPOLA: ", t3$cod_mpio[i], " · ", t3$rango_idf[i])
        } else {
          paste0("DIVIPOLA: ", t3$cod_mpio[i])
        }
        nombre_mostrar <- if (es_nacional()) {
          paste0(t3$nom_mpio[i], " (", t3$nom_dpto[i], ")")
        } else {
          t3$nom_mpio[i]
        }

        shiny::tags$tr(
          shiny::tags$td(class = "text-center fw-semibold", as.integer(t3$ranking_vista[i])),
          shiny::tags$td(
            shiny::div(class = "fw-semibold", nombre_mostrar),
            shiny::div(class = "text-muted", style = "font-size: 0.74rem;", rango_sub)
          ),
          shiny::tags$td(class = "num-col", sprintf("%.2f", t3$idf_municipal[i])),
          shiny::tags$td(
            class = "num-col",
            sprintf("%s (%s)", formatear_num_wi(t3$w_i[i]), formatear_pct_wi(t3$w_i[i]))
          ),
          shiny::tags$td(class = "num-col fw-semibold", formatear_aporte(contrib))
        )
      })

      if (es_nacional()) {
        prom_top3 <- mean(t3$idf_municipal, na.rm = TRUE)
        pie_tabla <- shiny::tags$tfoot(
          shiny::tags$tr(
            shiny::tags$td(colspan = "2", shiny::HTML("Promedio Top 3 Nacional / Media Dptos. \\((\\overline{\\text{IDF}}^{\\text{Dpto}})\\)")),
            shiny::tags$td(class = "num-col", sprintf("%.2f", prom_top3)),
            shiny::tags$td(class = "num-col", "Escala nacional"),
            shiny::tags$td(class = "num-col", sprintf("%.2f pts", mean(d$idf_departamental, na.rm = TRUE)))
          )
        )
      } else {
        sum_w   <- sum(t3$w_i, na.rm = TRUE)
        sum_c   <- sum(t3$w_i * t3$idf_municipal, na.rm = TRUE)
        idf_tot <- if (nrow(d) > 0) sprintf("%.2f", d$idf_departamental[1]) else "N/D"
        pie_tabla <- shiny::tags$tfoot(
          shiny::tags$tr(
            shiny::tags$td(colspan = "3", shiny::HTML("Subtotal Top 3 / Total \\(\\text{IDF}_j^{\\text{Dpto}}\\)")),
            shiny::tags$td(class = "num-col", sprintf("%s (%s)", formatear_num_wi(sum_w), formatear_pct_wi(sum_w))),
            shiny::tags$td(class = "num-col", sprintf("%s / %s", formatear_aporte(sum_c), idf_tot))
          )
        )
      }

      shiny::tags$div(
        class = "table-responsive",
        shiny::tags$table(
          class = "table-academic",
          shiny::tags$thead(
            shiny::tags$tr(
              shiny::tags$th(class = "text-center", "Pos."),
              shiny::tags$th(if (es_nacional()) "Municipio (Dpto.)" else "Municipio"),
              shiny::tags$th(class = "num-col", shiny::HTML("\\(\\text{IDF}_i\\) (pts)")),
              shiny::tags$th(class = "num-col", shiny::HTML("Ponderador \\(w_i\\)")),
              shiny::tags$th(class = "num-col", shiny::HTML("Aporte \\(w_i \\cdot \\text{IDF}_i\\)"))
            )
          ),
          shiny::tags$tbody(filas_html),
          pie_tabla
        )
      )
    })

    output$nota_top3_depto <- shiny::renderUI({
      t3 <- top3_actual()
      d  <- depto_actual()
      if (nrow(t3) == 0 || nrow(d) == 0) return(NULL)

      if (es_nacional()) {
        top_dptos <- d |>
          dplyr::arrange(dplyr::desc(idf_departamental)) |>
          dplyr::slice_head(n = 3)
        return(
          shiny::div(
            class = "status-banner",
            shiny::tags$strong("Síntesis del agregado nacional (Colombia, 2024): "),
            shiny::HTML(sprintf(
              "A escala nacional se evaluaron \\(\\sum n_j = %s\\) municipios en las 33 entidades territoriales. Los 3 mayores puntajes en el índice departamental artificial \\((\\text{IDF}_j^{\\text{Dpto}})\\) corresponden a <b>%s</b> (%.2f pts), <b>%s</b> (%.2f pts) y <b>%s</b> (%.2f pts).",
              format(sum(d$n_mpios, na.rm = TRUE), big.mark = ","),
              top_dptos$nom_dpto[1], top_dptos$idf_departamental[1],
              top_dptos$nom_dpto[2], top_dptos$idf_departamental[2],
              top_dptos$nom_dpto[3], top_dptos$idf_departamental[3]
            ))
          )
        )
      }

      n_ev   <- d$n_mpios[1]
      sum_w3 <- sum(t3$w_i, na.rm = TRUE) * 100

      if (n_ev < 3) {
        shiny::div(
          class = "status-banner",
          shiny::tags$strong("Nota político-administrativa: "),
          shiny::HTML(sprintf(
            "%s registra \\(n_j = %d\\) %s en la medición municipal del IDF 2024 del DNP (el resto de la jurisdicción corresponde a Áreas No Municipalizadas o régimen especial), concentrando el %.2f%% del ponderador \\((\\sum w_i = 1)\\).",
            d$nom_dpto[1],
            n_ev,
            ifelse(n_ev == 1, "municipio evaluado", "municipios evaluados"),
            sum_w3
          ))
        )
      } else {
        shiny::div(
          class = "status-banner",
          shiny::tags$strong("Síntesis de concentración territorial: "),
          shiny::HTML(sprintf(
            "Los 3 municipios con mayor calificación directa \\((\\text{IDF}_i)\\) concentran el %.2f%% del ponderador demográfico-productivo \\(w_i\\) entre los \\(n_j = %d\\) municipios evaluados de %s, cuyo índice agregado es \\(\\text{IDF}_j^{\\text{Dpto}} = %.2f\\) puntos.",
            sum_w3, n_ev, d$nom_dpto[1], d$idf_departamental[1]
          ))
        )
      }
    })

    output$mapa_leaflet <- leaflet::renderLeaflet({
      pal <- leaflet::colorNumeric(
        palette  = "viridis",
        domain   = shp_dpto_simp$idf_departamental,
        na.color = "#cbd5e1"
      )

      leaflet::leaflet(shp_dpto_simp) |>
        leaflet::addProviderTiles(
          leaflet::providers$Esri.WorldGrayCanvas,
          group = "Cartografía base institucional (Esri)"
        ) |>
        leaflet::addProviderTiles(
          leaflet::providers$OpenStreetMap.Mapnik,
          group = "OpenStreetMap estándar"
        ) |>
        leaflet::addLayersControl(
          baseGroups = c("Cartografía base institucional (Esri)", "OpenStreetMap estándar"),
          options    = leaflet::layersControlOptions(collapsed = TRUE),
          position   = "topright"
        ) |>
        leaflet::setView(lng = -74.297333, lat = 4.570868, zoom = 5) |>
        leaflet::addPolygons(
          layerId          = ~nom_dpto,
          fillColor        = ~pal(idf_departamental),
          fillOpacity      = 0.85,
          color            = "#ffffff",
          weight           = 1.2,
          highlightOptions = leaflet::highlightOptions(
            weight       = 2.5,
            color        = "#1e3a5f",
            fillOpacity  = 0.95,
            bringToFront = TRUE
          ),
          label = ~paste0(nom_dpto, ": ", sprintf("%.2f pts", idf_departamental)),
          popup = ~paste0(
            "<b>Departamento: </b>", nom_dpto, "<br>",
            "<b>IDF Departamental (Artificial): </b>", sprintf("%.2f puntos", idf_departamental), "<br>",
            "<b>Municipios evaluados (n_j): </b>", n_mpios
          )
        ) |>
        leaflet::addLegend(
          pal      = pal,
          values   = ~idf_departamental,
          position = "bottomright",
          title    = "IDF Dpto. 2024<br>(Artificial, pts)",
          opacity  = 0.9
        )
    })

    shiny::observeEvent(input$mapa_leaflet_shape_click, {
      click_id <- input$mapa_leaflet_shape_click$id
      if (!is.null(click_id) && click_id %in% deptos_choices && !identical(click_id, input$depto_sel)) {
        shiny::updateSelectizeInput(session, "depto_sel", selected = click_id)
      }
    })

    shiny::observeEvent(input$depto_sel, {
      shiny::req(input$depto_sel)
      if (identical(input$depto_sel, "NACIONAL")) {
        leaflet::leafletProxy("mapa_leaflet") |>
          leaflet::clearGroup("seleccion_activa") |>
          leaflet::setView(lng = -74.297333, lat = 4.570868, zoom = 5)
        return()
      }

      poly_sel <- shp_dpto_simp |> dplyr::filter(nom_dpto == input$depto_sel)
      if (nrow(poly_sel) > 0) {
        bbox <- sf::st_bbox(poly_sel)
        leaflet::leafletProxy("mapa_leaflet") |>
          leaflet::clearGroup("seleccion_activa") |>
          leaflet::addPolylines(
            data    = poly_sel,
            group   = "seleccion_activa",
            color   = "#0f172a",
            weight  = 3,
            opacity = 1
          ) |>
          leaflet::flyToBounds(
            lng1 = as.numeric(bbox["xmin"]),
            lat1 = as.numeric(bbox["ymin"]),
            lng2 = as.numeric(bbox["xmax"]),
            lat2 = as.numeric(bbox["ymax"])
          )
      }
    }, ignoreInit = TRUE)

    shiny::observeEvent(input$btn_vista_nacional, {
      shiny::updateSelectizeInput(session, "depto_sel", selected = "NACIONAL")
      leaflet::leafletProxy("mapa_leaflet") |>
        leaflet::clearGroup("seleccion_activa") |>
        leaflet::setView(lng = -74.297333, lat = 4.570868, zoom = 5)
    })
  })
}
