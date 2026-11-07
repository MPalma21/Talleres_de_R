# ==============================================================================
# Módulo Pestaña 1: Datos Geoespaciales - IDF Departamental y Top 3 Municipios
# Archivo: R/mod_tab1_idf.R
# Eje 1 (Líder: Sergio López) | Arquitectura Modular bslib (Juan José Echeverry)
# ==============================================================================

#' UI del Módulo Pestaña 1 (Desempeño Fiscal Territorial)
#' @noRd
mod_tab1_idf_ui <- function(id, deptos_choices) {
  ns <- shiny::NS(id)

  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      title = "Control Territorial",
      width = 320,
      shiny::selectInput(
        inputId  = ns("depto_sel"),
        label    = "Seleccione un departamento:",
        choices  = deptos_choices,
        selected = if ("Antioquia" %in% deptos_choices) "Antioquia" else deptos_choices[1]
      ),
      shiny::actionButton(
        inputId = ns("btn_vista_nacional"),
        label   = "Restablecer vista nacional",
        icon    = shiny::icon("earth-americas"),
        class   = "btn-outline-primary btn-sm w-100 mb-2"
      ),
      shiny::hr(),
      bslib::card(
        bslib::card_header("Diferenciación de Indicadores"),
        shiny::p(
          shiny::tags$b("Índice Departamental (Artificial): "),
          "Media ponderada de los municipios evaluados del departamento usando ",
          shiny::tags$code("w_i = (L_i * VA_i) / Σ(L_k * VA_k)"),
          ", con población 2024 (L) y valor agregado proyectado a 2024 (g = 8,27%)."
        ),
        shiny::p(
          class = "mb-0",
          shiny::tags$b("Índice Municipal (Vigencia 2024): "),
          "Calificación oficial directa asignada por el DNP a cada municipio en la escala de 0 a 100 puntos."
        ),
        class = "text-muted small"
      )
    ),

    bslib::layout_column_wrap(
      width = 1 / 3,
      fill  = FALSE,
      bslib::value_box(
        title    = "IDF Departamental (Artificial)",
        value    = shiny::textOutput(ns("vb_idf_depto")),
        showcase = shiny::icon("landmark"),
        theme    = "primary"
      ),
      bslib::value_box(
        title    = "Municipios Evaluados (DNP)",
        value    = shiny::textOutput(ns("vb_n_mpios")),
        showcase = shiny::icon("city"),
        theme    = "info"
      ),
      bslib::value_box(
        title    = "Municipio Líder en el Dpto.",
        value    = shiny::textOutput(ns("vb_lider_mpio")),
        showcase = shiny::icon("trophy"),
        theme    = "success"
      )
    ),

    bslib::layout_columns(
      col_widths = c(7, 5),
      bslib::card(
        full_screen = TRUE,
        bslib::card_header("Mapa Interactivo del IDF Departamental Artificial (Vigencia 2024)"),
        leaflet::leafletOutput(ns("mapa_leaflet"), height = "500px"),
        bslib::card_footer(
          class = "text-muted small",
          "Haga clic sobre cualquier polígono departamental para actualizar el Top 3 municipal."
        )
      ),
      bslib::card(
        full_screen = TRUE,
        bslib::card_header("Top 3 Municipios con Mayor IDF Municipal (Vigencia 2024)"),
        shiny::tableOutput(ns("tabla_top3")),
        shiny::uiOutput(ns("nota_top3_depto")),
        bslib::card_footer(
          class = "text-muted small",
          "El ponderador w_i mide la participación demográfica y productiva del municipio dentro de su departamento (Σ w_i = 1)."
        )
      )
    )
  )
}

#' Servidor del Módulo Pestaña 1 (Desempeño Fiscal Territorial)
#' @noRd
mod_tab1_idf_server <- function(id, shp_dpto_simp, df_deptos, df_top3, deptos_choices) {
  shiny::moduleServer(id, function(input, output, session) {

    depto_actual <- shiny::reactive({
      shiny::req(input$depto_sel)
      df_deptos |> dplyr::filter(nom_dpto == input$depto_sel)
    })

    top3_actual <- shiny::reactive({
      shiny::req(input$depto_sel)
      df_top3 |> dplyr::filter(nom_dpto == input$depto_sel)
    })

    output$vb_idf_depto <- shiny::renderText({
      d <- depto_actual()
      if (nrow(d) == 0) return("N/D")
      sprintf("%.2f pts", d$idf_departamental[1])
    })

    output$vb_n_mpios <- shiny::renderText({
      d <- depto_actual()
      if (nrow(d) == 0) return("N/D")
      sprintf("%d municipios", d$n_mpios[1])
    })

    output$vb_lider_mpio <- shiny::renderText({
      t3 <- top3_actual()
      if (nrow(t3) == 0) return("N/D")
      sprintf("%s (%.2f pts)", t3$nom_mpio[1], t3$idf_municipal[1])
    })

    output$tabla_top3 <- shiny::renderTable({
      t3 <- top3_actual()
      if (nrow(t3) == 0) return(NULL)
      t3 |>
        dplyr::transmute(
          `#`              = ranking_mpio,
          `Municipio`      = nom_mpio,
          `IDF Municipal`  = sprintf("%.2f pts", idf_municipal),
          `Ponderador w_i` = sprintf("%.4f (%.2f%%)", w_i, w_i * 100)
        )
    }, striped = TRUE, hover = TRUE, bordered = TRUE, align = "clrr", width = "100%")

    output$nota_top3_depto <- shiny::renderUI({
      t3 <- top3_actual()
      d  <- depto_actual()
      if (nrow(t3) == 0 || nrow(d) == 0) return(NULL)

      n_ev   <- d$n_mpios[1]
      sum_w3 <- sum(t3$w_i, na.rm = TRUE) * 100

      if (n_ev < 3) {
        shiny::div(
          class = "alert alert-info py-2 px-3 mb-2 small",
          shiny::tags$b("Nota político-administrativa: "),
          sprintf(
            "%s registra %d %s en la medición municipal del IDF 2024 del DNP (el resto del territorio corresponde a Áreas No Municipalizadas o régimen departamental especial), concentrando el %.2f%% del ponderador departamental.",
            d$nom_dpto[1],
            n_ev,
            ifelse(n_ev == 1, "municipio evaluado", "municipios evaluados"),
            sum_w3
          )
        )
      } else {
        shiny::div(
          class = "p-2 mb-2 rounded border small bg-body-tertiary",
          shiny::tags$b("Concentración en el Top 3: "),
          sprintf(
            "Estos 3 municipios reúnen el %.2f%% del ponderador demográfico-económico (w_i) entre los %d municipios evaluados de %s. El IDF Departamental Artificial es %.2f puntos.",
            sum_w3, n_ev, d$nom_dpto[1], d$idf_departamental[1]
          )
        )
      }
    })

    output$mapa_leaflet <- leaflet::renderLeaflet({
      pal <- leaflet::colorNumeric(
        palette  = "viridis",
        domain   = shp_dpto_simp$idf_departamental,
        na.color = "#cccccc"
      )

      leaflet::leaflet(shp_dpto_simp) |>
        leaflet::addProviderTiles(
          leaflet::providers$Esri.WorldGrayCanvas,
          group = "Cartografía base (Esri)"
        ) |>
        leaflet::addProviderTiles(
          leaflet::providers$OpenStreetMap.Mapnik,
          group = "OpenStreetMap"
        ) |>
        leaflet::addLayersControl(
          baseGroups = c("Cartografía base (Esri)", "OpenStreetMap"),
          options    = leaflet::layersControlOptions(collapsed = TRUE),
          position   = "topright"
        ) |>
        leaflet::setView(lng = -74.297333, lat = 4.570868, zoom = 5) |>
        leaflet::addPolygons(
          layerId          = ~nom_dpto,
          fillColor        = ~pal(idf_departamental),
          fillOpacity      = 0.82,
          color            = "#ffffff",
          weight           = 1.2,
          highlightOptions = leaflet::highlightOptions(
            weight       = 3,
            color        = "#ffdd59",
            fillOpacity  = 0.95,
            bringToFront = TRUE
          ),
          label = ~paste0(nom_dpto, ": ", round(idf_departamental, 2), " pts"),
          popup = ~paste0(
            "<b>Departamento: </b>", nom_dpto, "<br>",
            "<b>IDF Departamental (Artificial): </b>", sprintf("%.2f pts", idf_departamental), "<br>",
            "<b>Municipios evaluados: </b>", n_mpios
          )
        ) |>
        leaflet::addLegend(
          pal      = pal,
          values   = ~idf_departamental,
          position = "bottomright",
          title    = "IDF Departamental<br>(Artificial, pts)",
          opacity  = 0.9
        )
    })

    shiny::observeEvent(input$mapa_leaflet_shape_click, {
      click_id <- input$mapa_leaflet_shape_click$id
      if (!is.null(click_id) && click_id %in% deptos_choices) {
        shiny::updateSelectInput(session, "depto_sel", selected = click_id)
      }
    })

    shiny::observeEvent(input$depto_sel, {
      shiny::req(input$depto_sel)
      pol_sel <- shp_dpto_simp |> dplyr::filter(nom_dpto == input$depto_sel)
      if (nrow(pol_sel) > 0) {
        bb <- as.numeric(sf::st_bbox(pol_sel))
        leaflet::leafletProxy("mapa_leaflet") |>
          leaflet::clearGroup("depto_seleccionado") |>
          leaflet::addPolygons(
            data    = pol_sel,
            group   = "depto_seleccionado",
            fill    = FALSE,
            color   = "#f59e0b",
            weight  = 3.5,
            opacity = 1
          ) |>
          leaflet::flyToBounds(
            lng1 = bb[1] - 0.25,
            lat1 = bb[2] - 0.25,
            lng2 = bb[3] + 0.25,
            lat2 = bb[4] + 0.25
          )
      }
    }, ignoreInit = TRUE)

    shiny::observeEvent(input$btn_vista_nacional, {
      leaflet::leafletProxy("mapa_leaflet") |>
        leaflet::setView(lng = -74.297333, lat = 4.570868, zoom = 5)
    })
  })
}
