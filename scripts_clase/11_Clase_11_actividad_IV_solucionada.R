# ==============================================================================
# ACTIVIDAD GRUPAL: Clase 11, variables instrumentales
# Taller de R 2026-20
# Tiempo: 40 minutos
# Grupo: 10 (Juan José Echeverry, Miguelangel Palma, Sergio López)
# ==============================================================================
#
# CONTEXTO
#   Un programa de transferencias condicionadas (PTC) define la ELEGIBILIDAD de
#   los hogares con un índice de pobreza: los hogares con índice >= 50 son
#   elegibles. Pero participar es VOLUNTARIO, y los hogares que deciden
#   participar pueden ser distintos a los que no (endogeneidad).
#   Pregunta: ¿cuánto aumenta el gasto en educación de un hogar por participar
#   en el programa?
#
# ANTES DE EMPEZAR
# - Corran la sección "CONFIGURACIÓN" de 11_Clase_11.R (paquetes cargados).
#   Esta actividad no usa archivos de datos: los datos se simulan aquí.
# - Solo usen lo visto hasta la Clase 11 (dplyr, lm, ivreg, feols, modelsummary).
# - Reemplacen cada ____ y cada línea "# COMPLETAR". Lo demás ya funciona.
# - Cada parte tiene un CHEQUEO con el resultado esperado.
#
# ENTREGABLES
#   1. Este script corriendo sin errores (renómbrenlo 11_Actividad_IV_Grupo_XX.R)
#   2. output/resultados_iv_grupo_XX.html (tabla de la Parte 3)
#   3. Respuestas a las preguntas en los comentarios
# ==============================================================================

# Paquetes requeridos para la actividad (vistos en Clase 11)
library(dplyr)
library(modelsummary)
library(AER)
library(fixest)


# ==============================================================================
# PARTE 0: GENERAR LOS DATOS (NO modificar)
# ==============================================================================

set.seed(2038)
n <- 700

datos <- data.frame(
  id         = 1:n,
  region     = sample(c("Andina", "Caribe", "Pacifica"), n, TRUE, c(.5, .3, .2)),
  sexo       = sample(c("Mujer", "Hombre"), n, TRUE, c(.52, .48)),
  educacion  = pmax(0, round(rnorm(n, 8, 3))),
  indice_pob = round(rnorm(n, 48, 12))
) %>%
  mutate(
    elegible       = as.integer(indice_pob >= 50),
    u              = rnorm(n),   # característica NO observada (p. ej. motivación)
    participacion  = as.integer(plogis(-1.2 + 1.9 * elegible + u) > runif(n)),
    gasto_edu_pre  = 80 + 2 * educacion + ifelse(region == "Andina", 10, 0) + rnorm(n, 0, 15),
    efecto         = 18 + ifelse(sexo == "Mujer", 10, 0) + ifelse(educacion < 8, 5, 0),
    gasto_edu_post = gasto_edu_pre + efecto * participacion + 1.5 * educacion +
                     6 * u + rnorm(n, 0, 12)
  ) %>%
  select(-u, -efecto)   # en la vida real estas dos columnas no se observan

dir.create("output", showWarnings = FALSE)

# CHEQUEO: 700 filas y 9 columnas
dim(datos)


# ==============================================================================
# PARTE 1 (~8 min): BALANCE Y CUMPLIMIENTO
# ==============================================================================

# 1.1 Tabla de balance entre elegibles y no elegibles
datos_bal <- datos %>%
  mutate(Elegible = factor(elegible, labels = c("No elegible", "Elegible"))) %>%
  select(educacion, gasto_edu_pre, sexo, Elegible)

datasummary_balance(~Elegible, data = datos_bal,          # COMPLETAR
                    stars = TRUE, dinm_statistic = "p.value",
                    title = "Balance en línea de base")

# CHEQUEO: ninguna diferencia en educacion ni gasto_edu_pre es significativa
# (p > 0.1).

# 1.2 Tasa de participación por grupo de elegibilidad
datos %>%
  group_by(elegible) %>%
  summarise(n          = n(),
            tasa_part  = mean(participacion),   # COMPLETAR
            gasto_post = mean(gasto_edu_post))

# CHEQUEO: no elegibles ≈ 0.22 de participación; elegibles ≈ 0.67

# PREGUNTA 1: Hay no elegibles que participan y elegibles que no participan.
# ¿Por qué eso impide estimar el efecto comparando simplemente a quienes
# participan con quienes no?
# RESPUESTA:
# Porque la decision de participar es endogena. Como senalo James Heckman (Nobel 2000),
# cuando los individuos eligen entrar voluntariamente a un programa, se autoseleccionan
# segun factores no observables (motivacion, interes o red de apoyo, capturados en 'u').
# Comparar directo a participantes contra no participantes confunde el efecto del
# programa con el sesgo de seleccion de Heckman: los participantes ya tenian una
# predisposicion a invertir mas en educacion aun sin el subsidio.


# ==============================================================================
# PARTE 2 (~17 min): ITT, MCO Y VI
# ==============================================================================

# 2.1 ITT: efecto de SER ELEGIBLE
m_itt <- lm(gasto_edu_post ~ elegible + gasto_edu_pre + educacion + sexo,   # COMPLETAR
            data = datos)

# 2.2 MCO "endógeno": efecto de PARTICIPAR, sin corregir la autoselección
m_mco <- lm(gasto_edu_post ~ participacion + gasto_edu_pre + educacion + sexo,   # COMPLETAR
            data = datos)

# 2.3 Primera etapa: ¿la elegibilidad predice la participación?
primera_etapa <- lm(participacion ~ elegible + gasto_edu_pre + educacion + sexo,   # COMPLETAR
                    data = datos)
summary(primera_etapa)

# Estadístico F del instrumento = t del instrumento al cuadrado
summary(primera_etapa)$coefficients["elegible", "t value"]^2

# CHEQUEO: coeficiente de elegible ≈ 0.46 y F ≈ 191

# 2.4 MC2E con ivreg()
#     Sintaxis: resultado ~ endógena + controles | instrumento + controles
m_iv <- ivreg(gasto_edu_post ~ participacion + gasto_edu_pre + educacion + sexo |
                elegible + gasto_edu_pre + educacion + sexo,   # COMPLETAR
              data = datos)
summary(m_iv, diagnostics = TRUE)

# 2.5 Tabla comparativa
modelsummary(list("ITT"           = m_itt,
                  "MCO endógeno"  = m_mco,
                  "LATE (MC2E)"   = m_iv),
             stars       = TRUE,
             coef_omit   = "Intercept",
             coef_rename = c("elegible"      = "Elegible",
                             "participacion" = "Participación",
                             "gasto_edu_pre" = "Gasto previo",
                             "educacion"     = "Educación",
                             "sexoMujer"     = "Mujer"),
             gof_map     = c("nobs", "r.squared"),
             title       = "PTC: ITT vs. MCO vs. LATE")

# CHEQUEO: ITT ≈ 11.8 < LATE ≈ 25.6 < MCO ≈ 30.4

# PREGUNTA 2: Verifiquen que LATE ≈ ITT / (coeficiente de la primera etapa).
# Expliquen con sus palabras por qué el ITT es menor que el LATE.
# RESPUESTA:
# Verificacion: 11.7634 / 0.4600 = 25.5726, que coincide con el LATE (25.5711).
# Siguiendo el marco de Angrist e Imbens (Nobel 2021) sobre variables instrumentales
# con cumplimiento imperfecto, el ITT mide el impacto promedio de la intencion de tratar
# diluido entre toda la poblacion elegible (cumplidores y no cumplidores). El estimador
# de Wald escala el ITT dividiendolo por la proporcion de cumplidores (primera etapa, ~46%),
# aislando el efecto local promedio (LATE) exclusivamente sobre quienes modifican su
# participacion debido al incentivo de elegibilidad (compliers).

# PREGUNTA 3: ¿Por qué el MCO SOBREestima el efecto? Piensen en la variable
# u de la Parte 0: ¿cómo afecta la participación y cómo afecta el gasto?
# RESPUESTA:
# Por la formula clasica de sesgo por variable omitida (Angrist y Pischke, 'Mostly Harmless
# Econometrics'): el sesgo de MCO es igual al efecto de la variable omitida 'u' sobre 'y'
# multiplicado por la regresion de 'u' sobre la participacion. En este caso, 'u' aumenta la
# probabilidad de participar (+1.0) y a la vez eleva el gasto educativo (+6.0), por lo que
# Cov(participacion, u) > 0. MCO le atribuye a la transferencia monetaria lo que en realidad
# es fruto de la mayor motivacion y habilidad intrinseca del hogar.


# ==============================================================================
# PARTE 3 (~12 min): EFECTOS HETEROGÉNEOS Y EXPORTACIÓN
# ==============================================================================

# 3.1 ¿El efecto de participar es distinto para mujeres y hombres?
#     Estimen el LATE por separado con feols(), con efectos fijos de región.
#     Sintaxis: resultado ~ controles | efectos_fijos | endógena ~ instrumento
iv_mujeres <- feols(gasto_edu_post ~ gasto_edu_pre + educacion | region | participacion ~ elegible,   # COMPLETAR
                    data = filter(datos, sexo == "Mujer"))

iv_hombres <- feols(gasto_edu_post ~ gasto_edu_pre + educacion | region | participacion ~ elegible,   # COMPLETAR
                    data = filter(datos, sexo == "Hombre"))

# 3.2 Tabla final y exportación (cambien XX por su número de grupo)
modelsummary(list("LATE (todos)"   = m_iv,
                  "LATE (mujeres)" = iv_mujeres,
                  "LATE (hombres)" = iv_hombres),
             stars       = TRUE,
             coef_omit   = "Intercept",
             coef_rename = c("participacion"     = "Participación",
                             "fit_participacion" = "Participación",
                             "gasto_edu_pre"     = "Gasto previo",
                             "educacion"         = "Educación",
                             "sexoMujer"         = "Mujer"),
             gof_map     = c("nobs", "r.squared"),
             title       = "Efecto del PTC por sexo",
             notes       = c("VI: elegibilidad (índice >= 50) como instrumento de la participación.",
                             "Columnas 2 y 3: efectos fijos de región."),
             output      = "output/resultados_iv_grupo_10.html")

# CHEQUEO: LATE mujeres ≈ 31.2; LATE hombres ≈ 18.6

# PREGUNTA 4: ¿Para quién es mayor el efecto? ¿Se les ocurre una razón
# económica por la que un PTC aumentaría más el gasto educativo cuando la
# participante es mujer?
# RESPUESTA:
# El efecto es sustancialmente mayor para las mujeres (LATE ≈ 31.2 frente a 18.6 en hombres).
# Esto coincide con los hallazgos de Esther Duflo (Nobel 2019) y los modelos de negociacion
# colectiva intra-hogar: al incrementarse el poder de decision de las mujeres, aumenta la
# inversion en capital humano infantil (salud, nutricion y educacion) en comparacion con los
# hombres. Por esta razon, programas pioneros de transferencias condicionadas como Progresa/
# Oportunidades y Familias en Accion designan deliberadamente a las madres como titulares.


# ==============================================================================
# PREGUNTA FINAL (~3 min de discusión)
# ==============================================================================

# El supuesto de EXCLUSIÓN exige que la elegibilidad afecte el gasto en
# educación SOLO a través de la participación en el programa.
# Mencionen UN canal por el cual ser elegible (tener índice >= 50) podría
# afectar el gasto educativo aunque el hogar no participe.
# RESPUESTA:
# La restriccion de exclusion (formalizada por Angrist, Imbens y Rubin, JASA 1996) exige
# que el instrumento Z no tenga efecto directo sobre Y salvo a traves de D. Un canal que
# violaria esto es la multifocalizacion de la politica social: si el mismo indice de
# pobreza (indice >= 50, tipo SISBEN) es utilizado por el gobierno local para asignar
# exenciones de matricula escolar, alimentacion del PAE o subsidios de transporte, el hogar
# elegible experimenta un choque positivo de ingreso o reduccion de costos educativos aun
# si decide no participar en el PTC, alterando su gasto educativo post por una via alterna.
