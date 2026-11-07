# =============================================================================
# Clase 9 (Parte 1): Documentos Interactivos con RMarkdown, Quarto y htmlwidgets
# Profesor: Santiago Neira Hernández
# Objetivos:
# - Entender la estructura de un documento RMarkdown (YAML, texto, chunks)
# - Integrar widgets interactivos usando htmlwidgets (plotly, DT, leaflet)
# - Conectar widgets entre sí sin servidor (crosstalk)
# - Generar un reporte HTML autocontenido que se pueda enviar por correo
# - Reconocer las diferencias entre RMarkdown y Quarto
# - Distinguir cuándo basta un documento interactivo y cuándo hace falta Shiny
#
# ARCHIVOS DE ESTA CLASE
# - 09_Clase_9_1_RMarkdown.R (este script)
# - 09_Clase_9_2_Shiny.R     (aplicaciones web con Shiny)
# - Datos/Datos_clase_9/09_Clase_9_reporte_rmarkdown.Rmd  (reporte de ejemplo completo)
# - Datos/Datos_clase_9/09_Clase_9_ejemplo2_desde_cero.Rmd (lo crea este script)
# - Datos/Datos_clase_9/09_Clase_9_reporte_quarto.qmd     (el mismo reporte en Quarto)
# - Datos/Datos_clase_9/output/                        (aquí quedan los HTML generados)
# =============================================================================


# =============================================================================
# CONFIGURACIÓN
# =============================================================================

# Si falta algún paquete, corran primero Scripts NEW/00_reinstalar_paquetes.R
# (con la sesión de R recién reiniciada). Ahí ya están todos los de esta clase.
library(dplyr)
library(ggplot2)
library(gapminder)
library(plotly)
library(DT)
library(leaflet)
library(crosstalk)
library(rmarkdown)

username <- Sys.getenv("USERNAME")

# CUIDADO: esta ruta es la de la carpeta de Santiago. Cada quien debe
# ajustarla a la ubicación de SU carpeta "Datos/Datos_clase_9".
ruta_datos <- paste0("C:/Users/", username,
                     "/OneDrive - Universidad de los andes/2026 - 2/Taller de R 2026 20/Datos/Datos_clase_9")
setwd(ruta_datos)

# Carpeta donde quedarán los reportes HTML
dir.create("output", showWarnings = FALSE)


# =============================================================================
# ¿QUÉ ES RMARKDOWN?
# =============================================================================

# Hasta ahora todo nuestro trabajo vive en scripts .R: el código está aquí,
# pero los resultados (gráficos, tablas) quedan regados en la consola, el panel
# de Plots o en archivos .png sueltos.
#
# RMarkdown (archivos .Rmd) junta en UN solo documento:
#   1. Texto narrativo (escrito en Markdown)
#   2. Código R ejecutable (en bloques llamados "chunks")
#   3. Los resultados de ese código (gráficos, tablas, números)
#
# Al "tejer" (Knit) el archivo, R ejecuta todo el código de arriba a abajo y
# produce un documento final: HTML, PDF, Word o presentaciones.
#

# ---------- Parte 1: el encabezado YAML ----------
# Va al inicio, entre dos líneas de tres guiones. Define título, autor y formato:
#
# ---
# title: "Mi Documento"
# author: "Nombre"
# output: html_document
# ---

# ---------- Parte 2: texto en Markdown ----------
# # Título grande          ## Subtítulo          ### Sub-subtítulo
# **negrilla**             *cursiva*             `código`
# - elemento de lista      1. lista numerada     [enlace](https://...)

# ---------- Parte 3: chunks de código ----------
# Un chunk empieza con ```{r} y termina con ```  (atajo: Ctrl + Alt + I)
#
# ```{r nombre-del-chunk, echo = FALSE}
# plot(1:10)
# ```
#
# Opciones de chunk más usadas:
#   echo = FALSE     -> ejecuta el código, muestra el resultado, OCULTA el código
#   include = FALSE  -> ejecuta el código pero NO muestra nada (ni código ni resultado)
#   eval = FALSE     -> muestra el código pero NO lo ejecuta
#   message = FALSE  -> oculta mensajes (p. ej. los de library())
#   warning = FALSE  -> oculta advertencias
#   fig.height = 5   -> alto del gráfico (en pulgadas)

# ---------- Parte 4: código en línea (inline) ----------
# Dentro del texto se puede escribir `r nrow(datos)` y en el documento final
# aparece el número calculado. Así el texto se actualiza solo si cambian los datos.
#
# CUIDADO: el documento se ejecuta en una sesión de R NUEVA y limpia.
# Uno podría pensar que, como ya cargó un paquete o creó un objeto en la
# consola, el .Rmd lo va a "ver". No es así: todo lo que el documento necesite
# (library(), lectura de datos, objetos) debe estar DENTRO de sus chunks.

# Para crear uno en RStudio se usa File > New File > R Markdown... y se escribe
# a mano. En la siguiente sección lo vamos a construir desde este script, pieza
# por pieza, para ver exactamente qué lleva un .Rmd y cómo se compila.


# =============================================================================
# EJEMPLO 2: CONSTRUIR Y COMPILAR UN RMARKDOWN DESDE CERO
# =============================================================================

# Un archivo .Rmd es solo un archivo de texto. Vamos a armarlo como un vector
# de caracteres donde CADA ELEMENTO ES UNA LÍNEA del documento, guardarlo con
# writeLines() y compilarlo con render().
#
# Usamos comillas simples ' ' por fuera porque adentro el documento lleva
# comillas dobles " " (por ejemplo, en el título).

# ---------- Pieza 1: el encabezado YAML ----------
encabezado <- c(
  '---',
  'title: "Mi primer reporte en RMarkdown"',
  'author: "Taller de R 2026-20"',
  'output: html_document',
  '---',
  ''
)

# ---------- Pieza 2: un chunk de configuración (no se ve en el documento) ----------
# include = FALSE: se ejecuta, pero no aparece ni el código ni el resultado.
chunk_setup <- c(
  '```{r setup, include = FALSE}',
  'library(dplyr)',
  'library(ggplot2)',
  'library(gapminder)',
  'datos_2007 <- gapminder %>% filter(year == 2007)',
  '```',
  ''
)

# ---------- Pieza 3: texto en Markdown con código en línea ----------
# Los `r ...` se reemplazan por el resultado al compilar.
texto_intro <- c(
  '## Introducción',
  '',
  'Este reporte usa la base **gapminder**, que ya conocemos de la clase 8.',
  '',
  'En 2007 la base tiene `r nrow(datos_2007)` países y la expectativa de vida',
  'promedio es de `r round(mean(datos_2007$lifeExp), 1)` años.',
  ''
)

# ---------- Pieza 4: un chunk que SÍ muestra código y resultado ----------
chunk_tabla <- c(
  '## Expectativa de vida por continente',
  '',
  '```{r tabla}',
  'datos_2007 %>%',
  '  group_by(continent) %>%',
  '  summarise(paises = n(), exp_vida = round(mean(lifeExp), 1))',
  '```',
  ''
)

# ---------- Pieza 5: un gráfico, ocultando el código ----------
# echo = FALSE: se ve el gráfico pero no el código que lo produce.
chunk_grafico <- c(
  '## PIB vs expectativa de vida',
  '',
  '```{r grafico, echo = FALSE, fig.height = 4}',
  'ggplot(datos_2007, aes(x = gdpPercap, y = lifeExp, color = continent)) +',
  '  geom_point() +',
  '  scale_x_log10() +',
  '  labs(x = "PIB per cápita (escala log)", y = "Expectativa de vida") +',
  '  theme_minimal()',
  '```'
)

# ---------- Unir las piezas y guardar el archivo ----------
documento <- c(encabezado, chunk_setup, texto_intro, chunk_tabla, chunk_grafico)

cat(documento, sep = "\n")    # así se ve el .Rmd que vamos a guardar

writeLines(documento, "09_Clase_9_ejemplo2_desde_cero.Rmd")
# writeLines() escribe cada elemento del vector como una línea del archivo.
# El archivo queda en Datos/Datos_clase_9. Ábranlo desde el panel Files de
# RStudio: es un .Rmd normal, igual al que escribirían a mano.

# ---------- Compilar ----------
render("09_Clase_9_ejemplo2_desde_cero.Rmd", output_dir = "output")
# render() hace lo mismo que el botón Knit: ejecuta los chunks en una sesión
# limpia, reemplaza el código en línea y arma el HTML.
# output_dir = "output" indica la carpeta donde queda el HTML.

browseURL("output/09_Clase_9_ejemplo2_desde_cero.html")   # abre el HTML en el navegador

# CUIDADO: uno podría pensar que el .Rmd "ve" los objetos de esta sesión
# (por ejemplo, documento o encabezado). No es así: render() lo ejecuta en una
# sesión NUEVA. Por eso el chunk setup vuelve a cargar los paquetes y a crear
# datos_2007. Si se borra ese chunk, la compilación falla con "object not found".
#
# CUIDADO: los ``` de cada chunk deben ir al inicio de la línea, sin espacios
# antes. Si no, RMarkdown los trata como texto y el código no se ejecuta.


# =============================================================================
# ESTÁTICO vs INTERACTIVO
# =============================================================================

# ┌─────────────────────────────────────────────────────────────────────────┐
# │                    ¿Cómo agregar interactividad?                        │
# │                                                                         │
# │  OPCIÓN A: htmlwidgets              OPCIÓN B: Shiny                     │
# │  ─────────────────────              ───────────────                     │
# │  • Archivo HTML estático            • Requiere un servidor R activo     │
# │  • Se puede enviar por correo       • NO se puede enviar por correo     │
# │  • No necesita R para verlo         • Necesita R corriendo              │
# │  • Interactividad del LADO CLIENTE  • Interactividad del LADO SERVIDOR  │
# │    (JavaScript en el navegador)       (R recalcula en vivo)             │
# │  • Datos fijos al generar el HTML   • Puede hacer CUALQUIER cosa en R   │
# │  • Ideal para: reportes, informes   • Ideal para: dashboards, apps      │
# └─────────────────────────────────────────────────────────────────────────┘
#
# En esta parte de la clase nos enfocamos en la OPCIÓN A (htmlwidgets).
# Shiny se ve en 09_Clase_9_2_Shiny.R.
#
# Nota: existe un punto intermedio. Si en el YAML de un .Rmd se agrega la
# línea "runtime: shiny", el documento puede usar sliders y selectores de Shiny,
# pero pierde la ventaja de la Opción A: ya necesita un servidor R corriendo.


# =============================================================================
# HTMLWIDGETS EN ACCIÓN: PLOTLY
# =============================================================================

# plotly convierte gráficos de ggplot2 en interactivos con UNA línea de código.
# El usuario puede hacer zoom, pasar el mouse para ver datos, ocultar series, etc.

# ---------- Ejemplo 1: de ggplot2 estático a plotly interactivo ----------

# Gráfico estático (ya lo conocen de las clases 7 y 8)
p_estatico <- ggplot(gapminder %>% filter(year == 2007),
                     aes(x = gdpPercap, y = lifeExp,
                         size = pop, color = continent)) +
  geom_point(alpha = 0.7) +
  scale_x_log10() +
  labs(title = "PIB vs Expectativa de Vida (2007)",
       x = "PIB per cápita", y = "Expectativa de vida") +
  theme_minimal()

p_estatico

# Versión interactiva: una sola línea
ggplotly(p_estatico)

# ---------- Ejemplo 2: tooltips personalizados ----------

# El tooltip por defecto muestra los aesthetics. Podemos personalizarlo con
# una columna de texto (<b> es negrilla y <br> es salto de línea en HTML):
datos_2007 <- gapminder %>%
  filter(year == 2007) %>%
  mutate(tooltip_texto = paste0(
    "<b>", country, "</b><br>",
    "Continente: ", continent, "<br>",
    "PIB per cápita: $", format(round(gdpPercap), big.mark = ","), "<br>",
    "Expectativa de vida: ", round(lifeExp, 1), " años<br>",
    "Población: ", format(pop, big.mark = ",")
  ))

p_tooltip <- ggplot(datos_2007,
                    aes(x = gdpPercap, y = lifeExp,
                        size = pop, color = continent,
                        text = tooltip_texto)) +
  geom_point(alpha = 0.7) +
  scale_x_log10() +
  labs(x = "PIB per cápita", y = "Expectativa de vida") +
  theme_minimal()

ggplotly(p_tooltip, tooltip = "text")

# ---------- Ejemplo 3: plotly nativo (sin pasar por ggplot) ----------

# plotly tiene su propia sintaxis. Las variables se escriben con ~
datos_colombia <- gapminder %>% filter(country == "Colombia")

plot_ly(datos_colombia, x = ~year, y = ~lifeExp,
        type = "scatter", mode = "lines+markers",
        line = list(color = "steelblue", width = 2),
        marker = list(size = 8),
        hovertemplate = paste(
          "<b>Año:</b> %{x}<br>",
          "<b>Expectativa:</b> %{y:.1f} años<br>",
          "<extra></extra>"
        )) %>%
  layout(title = "Expectativa de vida en Colombia",
         xaxis = list(title = "Año"),
         yaxis = list(title = "Expectativa de vida (años)"))


# =============================================================================
# HTMLWIDGETS EN ACCIÓN: DT (DataTables)
# =============================================================================

# DT convierte data.frames en tablas interactivas con búsqueda,
# ordenamiento y paginación. Perfecto para reportes con muchos datos.

# ---------- Ejemplo 1: tabla básica ----------

datatable(datos_2007 %>% select(country, continent, lifeExp, gdpPercap, pop))

# ---------- Ejemplo 2: tabla personalizada ----------

datatable(
  datos_2007 %>%
    select(country, continent, lifeExp, gdpPercap, pop) %>%
    arrange(desc(lifeExp)),

  options = list(
    pageLength = 10,           # filas por página
    language = list(           # interfaz en español
      search = "Buscar:",
      lengthMenu = "Mostrar _MENU_ registros",
      info = "Mostrando _START_ a _END_ de _TOTAL_ registros",
      paginate = list(first = "Primero", last = "Último",
                      `next` = "Siguiente", previous = "Anterior")
    )
  ),
  colnames = c("País", "Continente", "Exp. Vida", "PIB p.c.", "Población"),
  filter = "top",              # filtros por columna
  caption = "Datos Gapminder 2007"
) %>%
  # Barra de color según la expectativa de vida
  formatStyle("lifeExp",
              background = styleColorBar(range(datos_2007$lifeExp), "lightblue"),
              backgroundSize = "98% 88%",
              backgroundRepeat = "no-repeat",
              backgroundPosition = "center") %>%
  formatCurrency("gdpPercap", currency = "$", digits = 0) %>%
  formatRound("pop", digits = 0)

# CUIDADO: dentro de formatStyle() y formatCurrency() las columnas se llaman
# por su nombre ORIGINAL ("lifeExp"), no por el que se puso en colnames.


# =============================================================================
# HTMLWIDGETS EN ACCIÓN: LEAFLET (MAPAS)
# =============================================================================

# leaflet crea mapas interactivos. En la Semana 13 (datos geoespaciales) lo
# usaremos a fondo; aquí solo vemos lo básico.

# ---------- Ejemplo 1: mapa básico centrado en Colombia ----------

leaflet() %>%
  addProviderTiles(providers$Esri.WorldStreetMap) %>%   # capa base (el "fondo")
  setView(lng = -74.07, lat = 4.71, zoom = 6)

# CUIDADO: en muchos tutoriales verán addTiles() en vez de addProviderTiles().
# addTiles() usa los servidores de OpenStreetMap, que desde 2024 BLOQUEAN las
# peticiones que no dicen desde qué página web vienen. Cuando el HTML se abre
# como archivo local (doble clic), el mapa sale gris o con "Access blocked".
# Lo mismo pasa con CartoDB (CartoDB.Positron): muestra "API KEY REQUIRED".
# Los mapas base de Esri (Esri.WorldStreetMap, Esri.WorldImagery) sí funcionan.
# Dentro del Viewer de RStudio suelen verse bien, así que el problema casi
# siempre aparece cuando alguien abre el HTML que le enviamos.

# ---------- Ejemplo 2: mapa con marcadores ----------

ciudades <- data.frame(
  ciudad = c("Bogotá", "Medellín", "Cali", "Barranquilla", "Cartagena",
             "Bucaramanga"),
  lat = c(4.711, 6.244, 3.451, 10.964, 10.391, 7.120),
  lng = c(-74.072, -75.574, -76.532, -74.796, -75.514, -73.123),
  poblacion = c(7181469, 2569007, 2227642, 1274250, 1028736, 581130)
)

leaflet(ciudades) %>%
  addProviderTiles(providers$Esri.WorldStreetMap) %>%
  addCircleMarkers(
    lng = ~lng, lat = ~lat,
    radius = ~sqrt(poblacion) / 300,           # tamaño proporcional a la población
    color = "darkred",
    fillOpacity = 0.6,
    popup = ~paste0("<b>", ciudad, "</b><br>",  # aparece al hacer clic
                    "Población: ", format(poblacion, big.mark = ",")),
    label = ~ciudad                             # aparece al pasar el mouse
  )


# =============================================================================
# CROSSTALK: WIDGETS QUE SE COMUNICAN ENTRE SÍ
# =============================================================================

# crosstalk permite que VARIOS htmlwidgets se conecten sin Shiny:
# seleccionar datos en un widget filtra los otros automáticamente.

# Paso 1: crear un SharedData (datos compartidos entre widgets)
datos_compartidos <- SharedData$new(
  datos_2007 %>% select(country, continent, lifeExp, gdpPercap, pop),
  key = ~country     # columna que identifica cada observación
)

# Paso 2: crear widgets que usen ESOS datos compartidos
p_cross <- plot_ly(datos_compartidos,
                   x = ~gdpPercap, y = ~lifeExp,
                   color = ~continent, text = ~country,
                   type = "scatter", mode = "markers",
                   hoverinfo = "text") %>%
  layout(xaxis = list(type = "log", title = "PIB per cápita"),
         yaxis = list(title = "Expectativa de vida"),
         dragmode = "select")

tabla_cross <- datatable(datos_compartidos,
                         options = list(pageLength = 8),
                         colnames = c("País", "Continente", "Exp. Vida",
                                      "PIB p.c.", "Población"))

# Paso 3: ponerlos lado a lado con bscols() (el ancho total es 12)
bscols(widths = c(7, 5), p_cross, tabla_cross)

# CUIDADO: si se ven por separado (p_cross o tabla_cross solos), la conexión
# no se nota. Deben mostrarse juntos, en bscols() o en el mismo documento.


# =============================================================================
# GENERAR EL REPORTE HTML
# =============================================================================

# Ya sabemos construir y compilar un .Rmd (Ejemplo 2). Ahora compilamos el
# reporte de ejemplo completo, que junta todos los widgets de esta clase:
# Datos/Datos_clase_9/09_Clase_9_reporte_rmarkdown.Rmd
#
# Forma 1: abrir el .Rmd en RStudio y presionar el botón "Knit".
#          El HTML queda en la misma carpeta del .Rmd.
#
# Forma 2: desde un script, con rmarkdown::render(). Permite escoger la
#          carpeta de salida:

render("09_Clase_9_reporte_rmarkdown.Rmd", output_dir = "output")

# Resultado: output/09_Clase_9_reporte_rmarkdown.html
# Ese HTML se abre en cualquier navegador SIN tener R instalado.


# =============================================================================
# QUARTO: LA NUEVA GENERACIÓN DE RMARKDOWN
# =============================================================================

# Quarto (archivos .qmd) es el sucesor de RMarkdown, creado por el mismo equipo
# (Posit). Ya viene incluido en RStudio: no hay que instalar nada extra.
#
# La buena noticia: el código R y los widgets son EXACTAMENTE los mismos.
# Solo cambian el encabezado y la forma de escribir las opciones:
#
#   ┌──────────────────────────┬────────────────────────────┬──────────────────────────────┐
#   │                          │ RMarkdown (.Rmd)           │ Quarto (.qmd)                │
#   ├──────────────────────────┼────────────────────────────┼──────────────────────────────┤
#   │ Formato en el YAML       │ output: html_document      │ format: html                 │
#   │ Opciones de un chunk     │ {r, echo = FALSE}          │ #| echo: false               │
#   │ Opciones generales       │ knitr::opts_chunk$set()    │ execute: (en el YAML)        │
#   │ HTML en un solo archivo  │ Sí, por defecto            │ Solo con embed-resources     │
#   │ Botón en RStudio         │ Knit                       │ Render                       │
#   └──────────────────────────┴────────────────────────────┴──────────────────────────────┘
#
# El archivo 09_Clase_9_reporte_quarto.qmd es el mismo reporte de ejemplo
# escrito en Quarto: al abrirlo junto al .Rmd se ven exactamente estas diferencias.
# En RStudio se genera con el botón "Render".
#
# CUIDADO: uno podría pensar que, igual que con RMarkdown, el HTML de Quarto
# siempre queda en un solo archivo. Por defecto NO: Quarto crea el HTML más una
# carpeta "_files" con los archivos de JavaScript. Si se envía solo el HTML,
# los gráficos interactivos no se ven. Por eso el .qmd de la clase incluye
# en el YAML la línea:   embed-resources: true
#
# ¿Cuál usar? Para este curso ambos sirven. RMarkdown tiene más ejemplos y
# tutoriales en internet; Quarto es hacia donde se está moviendo la comunidad
# (y también funciona con Python).
#
# Para generar el reporte de Quarto desde un script (opcional), se usa el
# paquete quarto. El HTML queda junto al .qmd; luego lo copiamos a output/:

quarto::quarto_render("09_Clase_9_reporte_quarto.qmd")
file.copy("09_Clase_9_reporte_quarto.html", "output/", overwrite = TRUE)
file.remove("09_Clase_9_reporte_quarto.html")

# CUIDADO: Quarto tiene una opción "--output-dir" para escoger la carpeta de
# salida, pero con un solo archivo BORRA todo lo que haya en esa carpeta antes
# de escribir. Por eso aquí copiamos el HTML en vez de usarla.
