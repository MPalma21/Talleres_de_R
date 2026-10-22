# ==============================================================================
# ACTIVIDAD GRUPAL: Clase 11, diferencias en diferencias
# Taller de R 2026-20
# Tiempo: 40 minutos
# ==============================================================================
#
# PREGUNTA GUÍA
#   ¿Aumentó la violencia en los municipios colombianos cercanos a Venezuela
#   después de que Hugo Chávez llegó al poder en 1999?
#   Datos: Martínez (2017), "Transnational insurgents: Evidence from Colombia's
#   FARC at the border with Chávez's Venezuela", Journal of Development
#   Economics 126: 138-153.
#
# ANTES DE EMPEZAR
# - Corran la sección "CONFIGURACIÓN" de 11_Clase_11.R (paquetes y ruta a
#   Datos/Datos_clase_11). Lean también la sección final de ese script
#   ("DIFERENCIAS EN DIFERENCIAS: CONTEXTO"), que explica el diseño.
# - Solo usen lo visto hasta la Clase 11 (dplyr, lm, feols, modelsummary).
# - Reemplacen cada ____ y cada línea "# COMPLETAR". Lo demás ya funciona.
# - Cada parte tiene un CHEQUEO con el resultado esperado.
#
# ENTREGABLES
#   1. Este script corriendo sin errores (renómbrenlo 11_Actividad_DiD_Grupo_XX.R)
#   2. output/resultados_did_grupo_XX.html (tabla de la Parte 4)
#   3. Respuestas a las preguntas en los comentarios
# ==============================================================================


# ==============================================================================
# PARTE 0: PREPARAR LOS DATOS (NO modificar)
# ==============================================================================

martinez <- read.csv("Martinez.csv", na.strings = c("", "NA", ".")) %>%
  select(codmpio, year, murder_rate, farc_events_count,
         d_chavez, d_border, d_onefromborder, near_venezuela,
         chavez_border, chavez_onefromborder,
         unmet_basic_needs_93, oil_price)

dir.create("output", showWarnings = FALSE)

# CHEQUEO: 17338 filas y 12 columnas
dim(martinez)


# ==============================================================================
# PARTE 1 (~8 min): EL TRATAMIENTO Y LA DiD "A MANO"
# ==============================================================================

# 1.1 Construyan la variable de tratamiento: vale 1 solo para municipios
#     cercanos a Venezuela EN los años de Chávez.
martinez <- martinez %>%
  mutate(trat_did = ____ * ____)   # COMPLETAR (dos variables de la base)

# CHEQUEO: debe salir TRUE (trat_did es la suma de las dos variables que ya
# venían construidas) y 769 municipio-años tratados.
all(martinez$trat_did == martinez$chavez_border + martinez$chavez_onefromborder)
sum(martinez$trat_did)

# 1.2 Tabla 2x2 de promedios de la tasa de homicidios
medias <- martinez %>%
  group_by(near_venezuela, d_chavez) %>%
  summarise(homicidios = ____(murder_rate),   # COMPLETAR
            n          = n(),
            .groups    = "drop")
medias

# 1.3 DiD = (cambio en los cercanos) - (cambio en los lejanos)
#     Las filas de `medias` están en este orden:
#       1: lejos-antes   2: lejos-después   3: cerca-antes   4: cerca-después
cambio_cerca <- medias$homicidios[____] - medias$homicidios[____]   # COMPLETAR
cambio_lejos <- medias$homicidios[____] - medias$homicidios[____]   # COMPLETAR
did_a_mano   <- cambio_cerca - cambio_lejos
did_a_mano

# CHEQUEO: cambio_cerca ≈ 9.60, cambio_lejos ≈ -8.91, did_a_mano ≈ 18.51

# PREGUNTA 1: En el resto del país los homicidios BAJARON después de 1999.
# Si solo comparáramos a los municipios cercanos antes vs. después,
# ¿cuál sería el "efecto Chávez" estimado? ¿Por qué esa cifra está sesgada?
# RESPUESTA:


# ==============================================================================
# PARTE 2 (~12 min): LA DiD CON REGRESIONES
# ==============================================================================

# 2.1 MCO ingenuo: solo compara cercanos vs. lejanos (todos los años juntos)
m_ingenuo <- lm(murder_rate ~ near_venezuela, data = martinez)

# 2.2 DiD con lm(): la interacción near_venezuela × d_chavez es el estimador DiD
m_did_lm <- lm(murder_rate ~ ____ * ____, data = martinez)   # COMPLETAR

# 2.3 DiD con efectos fijos de municipio y de año, errores agrupados por municipio
m_did_ef <- feols(murder_rate ~ trat_did | ____ + ____,      # COMPLETAR
                  cluster = ~codmpio, data = martinez)

modelsummary(list("MCO ingenuo" = m_ingenuo,
                  "DiD (lm)"    = m_did_lm,
                  "DiD (EF)"    = m_did_ef),
             stars = TRUE, gof_map = c("nobs", "r.squared"))

# CHEQUEO:
#   MCO ingenuo: near_venezuela ≈ 18.52
#   DiD (lm):    near_venezuela × d_chavez ≈ 18.51 (¡igual a did_a_mano!)
#   DiD (EF):    trat_did ≈ 18.16, error estándar ≈ 6.41

# PREGUNTA 2: El MCO ingenuo y la DiD dan casi el mismo número (≈ 18.5), pero
# miden cosas distintas. ¿Qué compara cada uno? (Pista: miren el coeficiente
# de near_venezuela en la columna DiD (lm): ¿qué significa?)
# RESPUESTA:

# PREGUNTA 3: ¿Qué absorben los efectos fijos de municipio? ¿Y los de año?
# ¿Por qué se agrupan los errores por municipio?
# RESPUESTA:


# ==============================================================================
# PARTE 3 (~7 min): ¿Y LOS CONTROLES?
# ==============================================================================

# Agreguen dos controles a la especificación 2.3:
#   unmet_basic_needs_93 → necesidades básicas insatisfechas del municipio (1993)
#   oil_price            → precio internacional del petróleo del año
m_did_controles <- feols(murder_rate ~ trat_did + ____ + ____ | codmpio + year,   # COMPLETAR
                         cluster = ~codmpio, data = martinez)
m_did_controles

# CHEQUEO: R imprime "The variables 'unmet_basic_needs_93' and 'oil_price'
# have been removed because of collinearity" y trat_did sigue en ≈ 18.16.

# PREGUNTA 4: ¿Por qué feols() elimina las dos variables? Piensen en qué
# varía cada una (¿entre municipios?, ¿entre años?) y en qué absorbe cada
# efecto fijo. ¿Qué tipo de variable SÍ podría usarse como control aquí?
# RESPUESTA:


# ==============================================================================
# PARTE 4 (~10 min): EL RESULTADO DEL ARTÍCULO: ACCIONES DE LA FARC
# ==============================================================================

# Martínez (2017) mide la violencia con las acciones de la FARC.
# 4.1 Misma DiD con efectos fijos, ahora con farc_events_count
m_farc <- feols(____ ~ trat_did | codmpio + year,   # COMPLETAR
                cluster = ~codmpio, data = martinez)

# 4.2 Separen la distancia: municipios fronterizos vs. a un municipio de distancia
m_farc_dist <- feols(farc_events_count ~ ____ + ____ | codmpio + year,   # COMPLETAR
                     cluster = ~codmpio, data = martinez)

# 4.3 Tabla final y exportación (cambien XX por su número de grupo)
modelsummary(list("Homicidios"          = m_did_ef,
                  "FARC"                = m_farc,
                  "FARC por distancia"  = m_farc_dist),
             stars       = TRUE,
             coef_rename = c("trat_did"             = "Chávez × Cerca de Venezuela",
                             "chavez_border"        = "Chávez × Frontera",
                             "chavez_onefromborder" = "Chávez × A un municipio"),
             gof_map     = c("nobs", "r.squared"),
             title       = "Efecto de la llegada de Chávez sobre la violencia en Colombia",
             notes       = c("Efectos fijos de municipio y año.",
                             "Errores estándar agrupados por municipio."),
             output      = "output/resultados_did_grupo_XX.html")

# CHEQUEO:
#   FARC: trat_did ≈ 1.87 (p < 0.05). Antes de 1999 los municipios cercanos
#         tenían en promedio ≈ 1.25 acciones por año.
#   FARC por distancia: frontera ≈ 2.50 (p < 0.05); a un municipio ≈ 1.31 (no signif.)

# PREGUNTA 5: Un aumento de 1.87 acciones por año, ¿es grande o pequeño?
# Compárenlo con el promedio antes de 1999 en los municipios cercanos.
# RESPUESTA:

# PREGUNTA 6: El efecto sobre la FARC es mayor justo en la frontera y se
# diluye un municipio más adentro. ¿Es eso coherente con la hipótesis del
# artículo (Venezuela como refugio de la FARC, que operaba con armas de corto
# alcance y sin transporte mecanizado)?
# RESPUESTA:


# ==============================================================================
# PREGUNTA FINAL (~3 min de discusión)
# ==============================================================================

# La DiD supone TENDENCIAS PARALELAS: sin Chávez, la violencia en los
# municipios cercanos habría evolucionado igual que en el resto del país.
# Miren los gráficos de la sección final de 11_Clase_11.R.
#   a) ¿Se ve razonable ese supuesto antes de 1999?
#   b) Mencionen UN evento distinto a Chávez, ocurrido después de 1999, que
#      pudiera afectar más a la zona de frontera y sesgar el resultado.
# RESPUESTA:
