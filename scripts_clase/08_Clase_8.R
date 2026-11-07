# ==============================================================================
# CLASE 8: VISUALIZACIÓN AVANZADA CON GGPLOT2 Y PAQUETES ADICIONALES
# ==============================================================================
# Base de Datos: Reporte de delitos de violencia intrafamiliar (Policía Nacional)
#                y gapminder (paquete de R)
# Profesor : Santiago Neira
# Objetivos:
# - Preparar una serie de tiempo (fechas, agregación y fechas faltantes)
# - Aplicar temas prediseñados y personalizados a un gráfico
# - Crear gráficos interactivos con plotly
# - Construir un heatmap tipo calendario con geom_tile()
# - Crear gráficos animados con gganimate
# - Añadir anotaciones con ggrepel y construir gráficos de doble eje
# - Guardar gráficos estáticos, interactivos y animados
# ==============================================================================


# ==============================================================================
# CONFIGURACIÓN INICIAL DEL AMBIENTE
# ==============================================================================

# Si es la primera vez o tienen errores de versiones, NO instalen desde aquí:
# corran primero el script 00_reinstalar_paquetes.R en una sesión nueva de R.
# CUIDADO: instalar un paquete que ya está cargado (p. ej. correr
# install.packages("ggplot2") después de library(dplyr)) deja la instalación
# a medias y produce errores como "namespace 'rlang' ... is already loaded".

library(ggplot2)
library(dplyr)
library(lubridate)     # manejo de fechas
library(ggthemes)      # temas prediseñados (Stata, Excel, The Economist...)
library(plotly)        # gráficos interactivos
library(gganimate)     # animaciones
library(gifski)        # motor para exportar animaciones a GIF
library(ggrepel)       # etiquetas que no se superponen
library(gapminder)     # datos de PIB per cápita y expectativa de vida
library(scales)        # formato de números en los ejes
library(here)


# ==============================================================================
# DIRECTORIO DE TRABAJO Y CARGA DE DATOS
# ==============================================================================
# 
# username <- Sys.getenv("USERNAME")     # usuario del sistema
# 
# # CUIDADO: esta ruta es la de la carpeta de Santiago. Cada quien debe
# # ajustarla a la ubicación de SU carpeta "Datos/Datos_clase_7".
# ruta_datos <- paste0("C:/Users/", username,
#                      "/OneDrive - Universidad de los andes/2026 - 2/Taller de R 2026 20/Datos/Datos_clase_7")
# setwd(ruta_datos)
ruta_datos <- here(
  "Datos",
  "Clases",
  "Reporte_Delito_Violencia_Intrafamiliar_Polic_a_Nacional_20250309.csv"
)


# Carpeta para guardar los gráficos (si ya existe, no pasa nada)
dir.create("graficos_output", showWarnings = FALSE)

llamadas <- read.csv(ruta_datos)

str(llamadas)

# Distribución (%) por tipo de arma, de mayor a menor
sort(prop.table(table(llamadas$ARMAS.MEDIOS)) * 100, decreasing = TRUE)


# ==============================================================================
# PREPARACIÓN DE LA SERIE DE TIEMPO
# ==============================================================================

# ---------- Texto a fecha ----------
# FECHA.HECHO viene como texto ("1/01/2010"). as.Date() lo convierte a fecha
# indicando el formato: %d = día, %m = mes, %Y = año con 4 dígitos.
llamadas$FECHA.HECHO <- as.Date(llamadas$FECHA.HECHO, format = "%d/%m/%Y")

# Con lubridate, year(), month() y day() extraen partes de una fecha
llamadas <- llamadas %>%
  filter(year(FECHA.HECHO) >= 2017,
         DEPARTAMENTO %in% c("CUNDINAMARCA", "ANTIOQUIA", "CAUCA", "SANTANDER"))

range(llamadas$FECHA.HECHO)   # CUIDADO: 2024 solo llega hasta abril

# ---------- Colapsar a nivel departamento-día ----------
llamadas_dia <- llamadas %>%
  group_by(DEPARTAMENTO, FECHA.HECHO) %>%
  summarise(CANTIDAD = sum(CANTIDAD), .groups = "drop")

# ---------- Completar las fechas faltantes ----------
# Los días sin denuncias NO aparecen en la base. Si no los agregamos, la línea
# "salta" de un día con denuncias al siguiente y oculta los ceros.

# Paso 1: secuencia con TODOS los días del periodo
fechas <- seq(min(llamadas_dia$FECHA.HECHO), max(llamadas_dia$FECHA.HECHO), by = "day")

# Paso 2: todas las combinaciones departamento x fecha
# expand.grid() crea un data frame con cada combinación posible de sus argumentos
df_full <- expand.grid(DEPARTAMENTO = unique(llamadas_dia$DEPARTAMENTO),
                       FECHA.HECHO  = fechas)

# Paso 3: pegar los datos observados (left_join, visto en la Clase 6)
df_complete <- df_full %>%
  left_join(llamadas_dia, by = c("DEPARTAMENTO", "FECHA.HECHO"))

# Paso 4: los días que no estaban en la base quedan con NA -> son 0 denuncias
df_complete$CANTIDAD[is.na(df_complete$CANTIDAD)] <- 0

# Paso 5: columnas de año, mes y día
df_complete <- df_complete %>%
  mutate(year = year(FECHA.HECHO),
         Mes  = month(FECHA.HECHO),
         dia  = day(FECHA.HECHO))

nrow(df_full) == nrow(df_complete)   # el join no debe duplicar filas


# ==============================================================================
# TEMAS Y ESTILOS
# ==============================================================================

p_basico <- ggplot(df_complete, aes(x = FECHA.HECHO, y = CANTIDAD, color = DEPARTAMENTO)) +
  geom_line() +
  labs(title    = "Evolución de denuncias de violencia intrafamiliar",
       subtitle = "Por departamento (enero 2017 - abril 2024)",
       x        = "Fecha",
       y        = "Número de denuncias",
       color    = "Departamento",
       caption  = "Fuente: Policía Nacional de Colombia")

p_basico

# ---------- Temas de ggthemes ----------
# Estilo Stata
p_basico + theme_stata()

# Estilo Excel (tema + paleta de colores)
p_basico +
  theme_excel_new() +
  scale_colour_excel_new()

# Estilo The Economist
p_basico +
  theme_economist() +
  scale_color_economist()

# ---------- Tema personalizado ----------
p_custom <- p_basico +
  theme_minimal() +
  theme(plot.title       = element_text(size = 14, face = "bold"),
        plot.subtitle    = element_text(size = 12, color = "gray50"),
        legend.position  = "bottom",
        panel.grid.minor = element_blank())

p_custom


# ==============================================================================
# GRÁFICOS INTERACTIVOS (plotly)
# ==============================================================================

# ggplotly() convierte cualquier ggplot en un gráfico interactivo:
# zoom, pasar el mouse para ver valores, ocultar series desde la leyenda...
ggplotly(p_custom)

# ---------- Tooltip personalizado ----------
# Creamos una columna de texto con lo que queremos ver al pasar el mouse
df_complete <- df_complete %>%
  mutate(text = paste0("Fecha: ", format(FECHA.HECHO, "%d/%m/%Y"),
                       "\nDepartamento: ", DEPARTAMENTO,
                       "\nDenuncias: ", CANTIDAD))

# "text" no es una estética de ggplot2: la ignora al dibujar, pero plotly la usa.
# Por eso hay que decirle a geom_line() que agrupe por departamento.
p_interactivo <- ggplot(df_complete, aes(x = FECHA.HECHO, y = CANTIDAD,
                                         color = DEPARTAMENTO, text = text)) +
  geom_line(aes(group = DEPARTAMENTO)) +
  labs(title = "Denuncias de violencia intrafamiliar (interactivo)",
       x = "Fecha", y = "Número de denuncias", color = "Departamento") +
  theme_minimal()

p_plotly <- ggplotly(p_interactivo, tooltip = "text")
p_plotly


# ==============================================================================
# HEATMAP TIPO CALENDARIO (geom_tile)
# ==============================================================================

# Cada cuadro es un día; el color indica cuántas denuncias hubo.
# Sirve para ver patrones por día de la semana, mes o temporada.
# Solo necesitamos ubicar cada día en una "cuadrícula":
#   eje x = semana del año (1 a 53) -> week() de lubridate
#   eje y = día de la semana        -> wday() de lubridate
# label = TRUE devuelve el nombre del día; week_start = 1 empieza en lunes.
df_calendario <- df_complete %>%
  filter(DEPARTAMENTO == "CUNDINAMARCA") %>%
  mutate(semana     = week(FECHA.HECHO),
         dia_semana = wday(FECHA.HECHO, label = TRUE, week_start = 1))

# geom_tile() dibuja un rectángulo por fila de los datos
p_calendar <- ggplot(df_calendario, aes(x = semana, y = dia_semana, fill = CANTIDAD)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "lightgreen", high = "darkred", name = "Denuncias") +
  scale_y_discrete(limits = rev) +          # lunes arriba, domingo abajo
  facet_wrap(~year, ncol = 2) +
  labs(title    = "Distribución temporal de denuncias - Cundinamarca",
       subtitle = "Vista calendario por año",
       x = "Semana del año", y = NULL) +
  theme_minimal()

p_calendar


# ==============================================================================
# ANIMACIONES (gganimate)
# ==============================================================================

# Idea: construir un ggplot normal y agregarle una "transición".
# transition_reveal(x) va revelando los datos a medida que avanza x.

# ---------- Gráfico base (estático) ----------
p_lineas <- ggplot(df_complete, aes(x = FECHA.HECHO, y = CANTIDAD, color = DEPARTAMENTO)) +
  geom_line() +
  labs(x = NULL, y = "Denuncias", color = NULL) +
  theme_stata()

p_lineas

# ---------- Revelar la línea en el tiempo ----------
# animate() "renderiza" la animación (puede tardar unos segundos).
# nframes = número de cuadros; fps = cuadros por segundo -> 100/10 = 10 segundos
# CUIDADO: es normal ver el aviso "Each group consists of only one observation".
# Sale en los primeros cuadros, cuando solo se ha revelado un día; no es un error.
anim_basico <- animate(p_lineas + transition_reveal(FECHA.HECHO),
                       nframes = 100, fps = 10, width = 800, height = 600,
                       renderer = gifski_renderer())
anim_basico

# ---------- Agregar un punto que "lidera" la línea ----------
# Con transition_reveal, geom_point() solo muestra el último dato revelado
p_puntos <- p_lineas +
  geom_point(size = 2, color = "red")

anim_puntos <- animate(p_puntos + transition_reveal(FECHA.HECHO),
                       nframes = 100, fps = 10, width = 800, height = 600,
                       renderer = gifski_renderer())
anim_puntos

# ---------- Un panel por departamento (facet_wrap, visto en la Clase 7) ----------
p_facetas <- p_puntos +
  facet_wrap(~DEPARTAMENTO) +
  theme(legend.position = "none")

anim_facetas <- animate(p_facetas + transition_reveal(FECHA.HECHO),
                        nframes = 100, fps = 10, width = 1000, height = 800,
                        renderer = gifski_renderer())
anim_facetas

# ---------- Cámara que sigue los datos ----------
# view_follow() ajusta los ejes a lo que se ha revelado hasta ese cuadro.
# fixed_y = TRUE deja el eje y fijo y solo mueve el eje x.
anim_facetas_follow <- animate(p_facetas +
                                 transition_reveal(FECHA.HECHO) +
                                 view_follow(fixed_y = TRUE),
                               nframes = 100, fps = 10, width = 1000, height = 800,
                               renderer = gifski_renderer())
anim_facetas_follow


# ==============================================================================
# ANOTACIONES CON GGREPEL
# ==============================================================================

# Día con más denuncias en cada departamento
# which.max() devuelve la POSICIÓN del valor máximo; con ella sacamos la fecha
df_picos <- df_complete %>%
  group_by(DEPARTAMENTO) %>%
  summarise(max_denuncias = max(CANTIDAD),
            fecha_max     = FECHA.HECHO[which.max(CANTIDAD)],
            .groups = "drop")

df_picos

# geom_label_repel() es como geom_label() (Clase 7), pero mueve las etiquetas
# para que no se tapen entre sí ni tapen los puntos.
p_anotado <- ggplot(df_complete, aes(x = FECHA.HECHO, y = CANTIDAD, color = DEPARTAMENTO)) +
  geom_line(linewidth = 0.3, alpha = 0.6) +
  geom_point(data = df_picos, aes(x = fecha_max, y = max_denuncias), size = 4) +
  geom_label_repel(data = df_picos,
                   aes(x = fecha_max, y = max_denuncias,
                       label = paste0(DEPARTAMENTO, "\n", format(fecha_max, "%d/%m/%Y"),
                                      "\nMáx: ", max_denuncias)),
                   box.padding = 0.5, segment.color = "grey50", size = 3) +
  labs(title = "Picos máximos de denuncias por departamento",
       x = "Fecha", y = "Número de denuncias") +
  theme_minimal() +
  theme(legend.position = "none")

p_anotado

# ---------- Facetas con escalas libres ----------
# CUIDADO: con facet_wrap() todos los paneles comparten el eje y. Si un
# departamento tiene muchas más denuncias, los demás se ven "planos".
# scales = "free_y" deja que cada panel tenga su propio eje y.
ggplot(df_complete, aes(x = FECHA.HECHO, y = CANTIDAD)) +
  geom_line(color = "darkblue", linewidth = 0.3) +
  facet_wrap(~DEPARTAMENTO, ncol = 2, scales = "free_y") +
  labs(title    = "Análisis comparativo por departamento",
       subtitle = "Cada panel con su propio eje y",
       x = NULL, y = "Denuncias",
       caption  = "Fuente: Policía Nacional") +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"))


# ==============================================================================
# ANIMACIÓN CON GAPMINDER
# ==============================================================================

# gapminder: PIB per cápita, expectativa de vida y población de 142 países
# cada 5 años (1952-2007). Viene incluida en el paquete del mismo nombre.
str(gapminder)

# ---------- Un país = un punto ----------
p_gap <- ggplot(gapminder, aes(x = gdpPercap, y = lifeExp, size = pop, color = country)) +
  geom_point(show.legend = FALSE, alpha = 0.7) +
  scale_color_viridis_d() +
  scale_size(range = c(2, 12)) +
  scale_x_log10(labels = label_dollar()) +
  labs(x = "PIB per cápita (escala log)", y = "Expectativa de vida (años)")

p_gap   # estático: todos los años encima (difícil de leer)

# transition_time() hace un cuadro por cada valor de "year".
# {frame_time} se reemplaza en el título por el año de cada cuadro.
p_gap +
  transition_time(year) +
  labs(title = "Año: {frame_time}")

# ---------- Por continente y con línea de tendencia ----------
p_gap_tend <- ggplot(gapminder, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(aes(size = pop, color = continent), alpha = 0.7) +
  geom_smooth(method = "lm", formula = y ~ x, color = "black",
              linewidth = 1, se = TRUE, alpha = 0.2) +
  scale_color_viridis_d() +
  scale_size(range = c(2, 12), guide = "none") +
  scale_x_log10(labels = label_dollar()) +
  labs(x = "PIB per cápita (escala log)", y = "Expectativa de vida (años)",
       color = "Continente")

p_gap_tend

# La recta se recalcula en cada cuadro con los datos de ese año
anim_gapminder <- animate(p_gap_tend +
                            transition_time(year) +
                            labs(title = "Año: {frame_time}"),
                          nframes = 100, fps = 10, width = 800, height = 600,
                          renderer = gifski_renderer())
anim_gapminder

# ==============================================================================
# GRÁFICOS DE DOBLE EJE Y
# ==============================================================================

# ggplot2 solo dibuja un eje y "de verdad". El truco: transformar la segunda
# variable para que quepa en la escala de la primera, y luego crear un eje
# secundario que deshaga esa transformación.
#
# Usamos una transformación MIN-MAX: el mínimo de la población se ubica en el
# mínimo de la expectativa de vida y el máximo en el máximo. Es una recta:
#   y = min_vida + (pop - min_pop) * pendiente
# y el eje secundario aplica la inversa:
#   pop = min_pop + (y - min_vida) / pendiente

colombia <- gapminder %>%
  filter(country == "Colombia")

min_vida  <- min(colombia$lifeExp)
min_pop   <- min(colombia$pop)
pendiente <- (max(colombia$lifeExp) - min_vida) / (max(colombia$pop) - min_pop)

colombia <- colombia %>%
  mutate(pop_escalada = min_vida + (pop - min_pop) * pendiente)

p_doble_eje <- ggplot(colombia, aes(x = year)) +
  geom_line(aes(y = lifeExp, color = "Expectativa de vida"), linewidth = 1.5) +
  geom_point(aes(y = lifeExp, color = "Expectativa de vida"), size = 3) +
  geom_line(aes(y = pop_escalada, color = "Población"), linewidth = 1.5) +
  geom_point(aes(y = pop_escalada, color = "Población"), size = 3) +
  scale_y_continuous(name = "Expectativa de vida (años)",
                     sec.axis = sec_axis(~ min_pop + (. - min_vida) / pendiente,
                                         name   = "Población",
                                         labels = label_number(big.mark = ","))) +
  scale_color_manual(values = c("Expectativa de vida" = "forestgreen",
                                "Población"           = "darkblue")) +
  labs(title    = "Colombia: expectativa de vida y población (1952-2007)",
       caption  = "Fuente: gapminder",
       x = "Año", color = NULL) +
  theme_minimal() +
  theme(legend.position    = "bottom",
        axis.title.y.left  = element_text(color = "forestgreen"),
        axis.title.y.right = element_text(color = "darkblue"),
        plot.title         = element_text(face = "bold"))

p_doble_eje

# CUIDADO: con min-max las dos líneas SIEMPRE empiezan y terminan en el mismo
# punto, porque así lo forzamos. Uno podría pensar que los cruces o la
# distancia entre líneas significan algo, pero dependen solo de la
# transformación escogida. Lo que sí se puede leer es la FORMA de cada línea
# (la vida crece rápido y luego se desacelera; la población crece casi lineal).
# Los gráficos de doble eje se prestan para engañar; úsenlos con moderación.

# ==============================================================================
# GUARDADO DE GRÁFICOS
# ==============================================================================

# ---------- Estáticos (ggsave) ----------
# PNG: imagen en píxeles, ideal para presentaciones
ggsave(filename = "graficos_output/evolucion_denuncias.png", plot = p_custom,
       width = 10, height = 6, units = "in", dpi = 300)

# PDF: vectorial (no se pixela al hacer zoom), ideal para documentos
ggsave(filename = "graficos_output/evolucion_denuncias.pdf", plot = p_custom,
       width = 10, height = 6, units = "in")

# Tamaños para redes sociales (en píxeles)
ggsave(filename = "graficos_output/grafico_instagram.png", plot = p_anotado,
       width = 1080, height = 1080, units = "px", dpi = 150)

ggsave(filename = "graficos_output/grafico_twitter.png", plot = p_anotado,
       width = 1200, height = 675, units = "px", dpi = 150)

# ---------- Interactivos (HTML) ----------
# El archivo se abre en cualquier navegador, sin necesidad de R
htmlwidgets::saveWidget(widget = p_plotly,
                        file = "graficos_output/grafico_interactivo.html",
                        selfcontained = TRUE)

# ---------- Animaciones (GIF) ----------
# Como ya renderizamos con animate(), anim_save() solo escribe el archivo.
# CUIDADO: el tamaño y la velocidad se definen en animate(), no en anim_save().
anim_save("graficos_output/animacion_basica.gif",  animation = anim_basico)
anim_save("graficos_output/animacion_puntos.gif",  animation = anim_puntos)
anim_save("graficos_output/animacion_facetas.gif", animation = anim_facetas)
anim_save("graficos_output/gapminder_animado.gif", animation = anim_gapminder)

list.files("graficos_output")
