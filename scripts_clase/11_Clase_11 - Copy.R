# =============================================================================
# Clase 11: Econometría en R
# Profesor: Santiago Neira Hernández
# Objetivos:
# - Construir tablas descriptivas, de balance, de correlaciones y cruzadas
# - Estimar modelos de regresión lineal (MCO) y revisar sus supuestos
# - Comparar errores estándar clásicos, robustos, bootstrap y agrupados (cluster)
# - Estimar modelos con efectos fijos e interacciones
# - Estimar efectos causales con variables instrumentales (ITT, MCO, LATE)
# - Exportar tablas de resultados a HTML y LaTeX
# - Presentar el diseño de diferencias en diferencias (DiD) con datos de panel
#
# ARCHIVOS DE ESTA CLASE
# - 11_Clase_11.R               (este script)
# - 11_Clase_11_actividad_DiD.R (actividad grupal: diferencias en diferencias)
# - 11_Clase_11_actividad_IV.R  (actividad grupal: variables instrumentales)
# - Datos/Datos_clase_11/AeioTU.csv y Martinez.csv
# - Datos/Datos_clase_11/output/ (aquí quedan las tablas exportadas)
#
# BASES DE DATOS
# ─ AeioTU.csv
#     Evaluación experimental del programa aeioTU (Colombia). aeioTU es un
#     programa de atención integral a la primera infancia que combina cuidado,
#     nutrición y estimulación cognitiva. Los hogares se asignaron AL AZAR a
#     recibir el programa (Tratamiento) o no (Control): es un experimento
#     aleatorizado (RCT).
#     Variable de resultado: cognitivo_ajust (puntaje cognitivo al final).
#     Otras variables: D (asignación), asistencia (asistió al programa),
#     cognitivo_BL (puntaje en línea de base), edad_BL, raza, sexo, riqueza_BL,
#     ninos_casa_BL, barrio. El sufijo _BL indica "medido en línea de base",
#     es decir, ANTES de que empezara el programa.
#
# ─ Martinez.csv  (Martínez, 2017, Journal of Development Economics)
#     "Transnational insurgents: Evidence from Colombia's FARC at the border
#     with Chávez's Venezuela". Panel de 1.099 municipios colombianos, 1993-2008.
#     Pregunta: ¿aumentó la violencia en los municipios colombianos cercanos a
#     Venezuela después de que Hugo Chávez llegó al poder (1999)?
# =============================================================================


# =============================================================================
# CONFIGURACIÓN
# =============================================================================

# Si falta algún paquete, corran primero Scripts NEW/00_reinstalar_paquetes.R
# (con la sesión de R recién reiniciada). Ahí ya están todos los de esta clase.
library(dplyr)
library(ggplot2)
library(modelsummary) # tablas descriptivas y de regresión
library(lmtest)       # pruebas sobre modelos lineales (bptest, coeftest)
library(sandwich)     # matrices de varianza robustas (vcovHC)
library(fixest)       # efectos fijos, errores agrupados y VI con feols()
library(AER)          # variables instrumentales con ivreg()
library(estimatr)


username <- Sys.getenv("USERNAME")

# CUIDADO: esta ruta es la de la carpeta de Santiago. Cada quien debe
# ajustarla a la ubicación de SU carpeta "Datos/Datos_clase_11".
ruta_datos <- paste0("C:/Users/", username,
                     "/OneDrive - Universidad de los andes/2026 - 2/Taller de R 2026 20/Datos/Datos_clase_11")
setwd(ruta_datos)

# Carpeta donde quedarán las tablas exportadas
dir.create("output", showWarnings = FALSE)


# =============================================================================
# CARGA Y PREPARACIÓN DE DATOS
# =============================================================================

data_AEIO <- read.csv("AeioTU.csv")
str(data_AEIO)

# D indica la asignación al tratamiento ("Tratamiento" / "Control").
# Para la regresión conviene una variable binaria: Trat = 1 si fue asignado.
data_AEIO <- data_AEIO %>%
  mutate(Trat = ifelse(D == "Tratamiento", 1, 0))

table(data_AEIO$D, data_AEIO$Trat)

# ---------- Datos faltantes ----------
# Hay NA en la línea de base y en el resultado final. lm() y feols() eliminan
# en silencio las filas con NA en las variables del modelo, así que el número
# de observaciones (N) puede cambiar de un modelo a otro.
colSums(is.na(data_AEIO[, c("cognitivo_BL", "cognitivo_ajust", "edad_BL", "raza")]))


# =============================================================================
# ESTADÍSTICAS DESCRIPTIVAS CON MODELSUMMARY
# =============================================================================

# Variables de interés:
#   cognitivo_BL    → puntaje cognitivo en LÍNEA DE BASE (antes del programa)
#   cognitivo_ajust → puntaje cognitivo al final (variable de resultado)
#   raza, edad_BL   → características demográficas
data_estadisticas <- data_AEIO %>%
  select(cognitivo_BL, cognitivo_ajust, raza, edad_BL)

datasummary_skim(data_estadisticas,
                 title = "Estadísticas descriptivas de variables clave")

# ---------- Tabla de balance ----------
# Compara características PRE-TRATAMIENTO entre tratados y controles.
# La asignación al azar hace que los grupos sean comparables EN PROMEDIO, así
# que en un RCT se espera que casi ninguna diferencia sea significativa.
datos_baseline <- data_AEIO %>%
  select(contains("BL"), D)

tabla_balance <- datasummary_balance(
  ~D, datos_baseline,
  title          = "Balance entre grupos de tratamiento y control",
  notes          = "Fuente: datos del programa aeioTU.",
  stars          = TRUE,
  dinm_statistic = "p.value"
)
tabla_balance

# En esta muestra NO todo está balanceado: los tratados tienen un puntaje
# cognitivo de línea de base más alto, son algo mayores (edad_BL) y asistían
# más a centros de cuidado (centrocuidadp_BL), con p < 0.01. El azar equilibra
# los grupos en promedio, no en cada muestra, y además los datos faltantes
# pueden desbalancear lo que quedó. Por eso, en la regresión, controlar por
# la línea de base va a ser importante.

# ---------- Tablas personalizadas con datasummary() ----------
# La fórmula se lee FILAS ~ COLUMNAS.
datasummary(cognitivo_BL + riqueza_BL ~ Mean + SD + N,
            data = data_AEIO)

# Invirtiendo la fórmula, las estadísticas pasan a las filas
datasummary(Mean + SD + P25 + P50 + P75 + N ~ cognitivo_BL + riqueza_BL,
            data = data_AEIO)

# El operador * cruza dimensiones: estadísticas por sexo
datasummary(Mean + SD + P25 + P50 + P75 + N ~ sexo * (cognitivo_BL + riqueza_BL),
            data = data_AEIO)

# ---------- Matriz de correlaciones ----------
# Solo usa las columnas numéricas (D, que es texto, se ignora)
datasummary_correlation(datos_baseline)

# ---------- Tabla cruzada ----------
# ¿Cuántos niños por hogar hay en cada grupo?
datasummary_crosstab(ninos_casa_BL ~ D, data = data_AEIO)


# =============================================================================
# REGRESIÓN LINEAL (MCO) CON lm()
# =============================================================================

# La sintaxis es: resultado ~ x1 + x2 + ...
# Se parte del modelo más simple y se agregan controles.
# Como la asignación fue aleatoria, el coeficiente de Trat estima el efecto
# causal de SER ASIGNADO al programa sobre el puntaje cognitivo.
modelo_simple    <- lm(cognitivo_ajust ~ Trat, data = data_AEIO)

modelo_controles <- lm(cognitivo_ajust ~ Trat + cognitivo_BL, data = data_AEIO)
modelo_completo  <- lm(cognitivo_ajust ~ Trat + cognitivo_BL + edad_BL + factor(raza),
                       data = data_AEIO)

summary(modelo_controles)

# CUIDADO: factor(raza) le dice a R que raza es una categoría y no un número.
# R crea una variable binaria por cada categoría y omite una (la base).

# ---------- Tabla de modelos ----------
modelos_basicos <- list(
  "Simple"         = modelo_simple,
  "Con controles"  = modelo_controles,
  "Completo"       = modelo_completo
)

modelsummary(
  modelos_basicos,
  statistic = "std.error",
  stars     = TRUE,
  gof_map   = c("nobs", "r.squared", "adj.r.squared")
)

# Lectura de la tabla:
# - En el modelo simple, Trat = 0.77: los asignados terminan con un puntaje
#   0.77 puntos más alto que los controles.
# - Al controlar por cognitivo_BL el coeficiente cae a cerca de la mitad
#   (0.38). Es el desbalance de la tabla anterior: los tratados ya
#   empezaban con mejor puntaje, y parte de la diferencia final no se debe
#   al programa. Con el control, el modelo compara niños con el mismo
#   puntaje inicial.
# - Agregar edad y raza casi no cambia nada, y el R2 sube de 0.04 a 0.45
#   porque la línea de base explica buena parte del resultado.
# - Num.Obs. baja de 465 a 452: son las filas con NA en cognitivo_BL.


# =============================================================================
# SUPUESTOS DE MCO
# =============================================================================

# ---------- 1) Heterocedasticidad: prueba de Breusch-Pagan ----------
# H0: la varianza del error es constante (homocedasticidad).
# Si p < 0.05 se rechaza H0 y conviene usar errores estándar robustos.
bptest(modelo_controles)

# ---------- 2) Normalidad de los residuos: prueba de Shapiro-Wilk ----------
# H0: los residuos se distribuyen normal.
# CUIDADO: con muestras muy grandes esta prueba rechaza casi siempre por
# diferencias triviales; por eso se complementa con el gráfico Q-Q.
shapiro.test(resid(modelo_controles))

# ---------- 3) Residuos vs. valores ajustados ----------
# Un patrón sistemático (curva, embudo) indica mala especificación o
# heterocedasticidad.
plot(modelo_controles, which = 1)

# ---------- 4) Gráfico Q-Q ----------
# Si los residuos fueran normales, los puntos caerían sobre la diagonal.
plot(modelo_controles, which = 2)


# =============================================================================
# ERRORES ESTÁNDAR: CLÁSICOS, ROBUSTOS Y BOOTSTRAP
# =============================================================================

# Los coeficientes son los mismos; lo que cambia es cómo se calcula su
# incertidumbre:
#   classical → supone homocedasticidad (lo que reporta summary())
#   HC1       → robustos a heterocedasticidad (los "robust" de Stata)
#   bootstrap → remuestrea los datos muchas veces y mide la variación

# Con lmtest + sandwich se recalcula la tabla de coeficientes con errores robustos
coeftest(modelo_controles, vcov = vcovHC(modelo_controles, type = "HC1"))

# Con modelsummary se puede comparar el MISMO modelo con los tres tipos de error
set.seed(2026)  # el bootstrap es aleatorio: la semilla lo hace reproducible

modelos_errores <- list(
  "Clásicos"  = modelo_controles,
  "Robustos"  = modelo_controles,
  "Bootstrap" = modelo_controles
)

nombres_coef <- c("Trat" = "Tratamiento", "cognitivo_BL" = "Puntaje línea de base")

modelsummary(
  modelos_errores,
  vcov        = c("classical", "HC1", "bootstrap"),
  coef_omit   = "Intercept",
  coef_rename = nombres_coef,
  gof_map     = c("nobs", "r.squared"),
  stars       = TRUE
)

# Los coeficientes son idénticos en las tres columnas. El error estándar de
# Trat casi no cambia, pero el de cognitivo_BL se duplica con errores robustos
# o bootstrap: es la heterocedasticidad que detectó la prueba de Breusch-Pagan.

# ---------- Gráfico de coeficientes ----------
# Muestra cada coeficiente con su intervalo de confianza al 95 %
modelplot(
  modelos_basicos,
  coef_omit   = "Intercept|raza",
  coef_rename = nombres_coef
)


# =============================================================================
# EFECTOS FIJOS CON fixest
# =============================================================================

# Los efectos fijos absorben todo lo que es CONSTANTE dentro de un grupo
# (raza, barrio, evaluador...), aunque no se observe.
# En feols() la sintaxis es:  resultado ~ controles | efectos_fijos

modelo_ef <- feols(cognitivo_ajust ~ Trat + cognitivo_BL | raza, data = data_AEIO)
summary(modelo_ef)

# Un efecto fijo es lo mismo que incluir factor(grupo) en lm(): el
# coeficiente de Trat es idéntico. feols() solo evita imprimir una variable
# binaria por grupo (útil cuando hay cientos de grupos, como municipios).
coef(lm(cognitivo_ajust ~ Trat + cognitivo_BL + factor(raza), data = data_AEIO))["Trat"]
coef(modelo_ef)["Trat"]

# ---------- Varios efectos fijos y errores robustos ----------
# Se separan con +. El argumento vcov = "hetero" pide errores robustos.
modelo_ef2 <- feols(cognitivo_ajust ~ Trat + cognitivo_BL | raza + centrocuidadp_BL,
                    vcov = "hetero", data = data_AEIO)
summary(modelo_ef2)

# ---------- Errores agrupados (cluster) ----------
# Si las observaciones de un mismo grupo comparten choques (niños del mismo
# barrio, o un municipio observado muchos años), sus errores están
# correlacionados y los errores clásicos subestiman la incertidumbre.
# Agrupar (cluster) permite esa correlación dentro de cada grupo.
modelo_cluster <- feols(cognitivo_ajust ~ Trat + cognitivo_BL | raza,
                        cluster = ~barrio, data = data_AEIO)
summary(modelo_cluster)

# CUIDADO: aquí solo hay 4 barrios, y con tan pocos grupos los errores
# agrupados no son confiables (la regla práctica pide decenas de grupos).
# El ejemplo solo ilustra la sintaxis. En un panel de municipios, como el de
# Martínez (2017), lo usual es agrupar por municipio: cluster = ~codmpio.

modelos_ef <- list(
  "MCO"              = modelo_controles,
  "EF raza"          = modelo_ef,
  "EF raza + centro" = modelo_ef2,
  "EF + cluster"     = modelo_cluster
)

modelsummary(
  modelos_ef,
  stars       = TRUE,
  coef_rename = c(nombres_coef, "(Intercept)" = "Intercepto"),
  gof_map     = c("nobs", "r.squared")
)


# =============================================================================
# INTERACCIONES: EFECTOS HETEROGÉNEOS
# =============================================================================

# ¿El programa funciona igual para niñas y niños?
# Trat * sexo incluye Trat, sexo y su interacción Trat:sexo.
#   Coef. de Trat             → efecto en la categoría base (Femenino)
#   Coef. de Trat:sexoMasculino → cuánto CAMBIA el efecto para los niños
modelo_interaccion <- lm(cognitivo_ajust ~ Trat * sexo + cognitivo_BL, data = data_AEIO)
summary(modelo_interaccion)

# Resultado: para las niñas el efecto es 0.67 y para los niños es
# 0.67 - 0.55 = 0.12. La interacción es significativa (p ≈ 0.03): hay
# evidencia de que el programa beneficia más a las niñas.
# Este mismo tipo de término (producto de dos variables binarias) es el
# corazón del diseño de diferencias en diferencias del final del script.


# =============================================================================
# VARIABLES INSTRUMENTALES (VI)
# =============================================================================

# El sorteo decidió quién podía entrar al programa, pero NO todos los
# asignados asistieron y algunos controles sí asistieron (incumplimiento).
table(Asignacion = data_AEIO$D, Asistio = data_AEIO$asistencia)

# Tres formas de estimar "el efecto del programa":
#   1) ITT (intención de tratar): resultado ~ Trat
#      Efecto de SER ASIGNADO. Es causal, pero diluido por el incumplimiento.
#   2) MCO con asistencia: resultado ~ asistencia
#      Sesgado: quienes deciden asistir pueden ser distintos (más motivados,
#      con más recursos...) y eso también afecta el puntaje.
#   3) VI: usar Trat como INSTRUMENTO de asistencia.
#      Estima el LATE: el efecto de asistir para los "cumplidores" (quienes
#      asisten si y solo si son asignados).
#
# Un instrumento válido debe cumplir:
#   - Relevancia: Trat predice asistencia (se verifica con la primera etapa).
#   - Exclusión: Trat afecta el puntaje SOLO a través de la asistencia
#     (no se puede verificar con datos; se argumenta).

modelo_itt <- lm(cognitivo_ajust ~ Trat + cognitivo_BL, data = data_AEIO)
modelo_mco <- lm(cognitivo_ajust ~ asistencia + cognitivo_BL, data = data_AEIO)

# ---------- Primera etapa ----------
primera_etapa <- lm(asistencia ~ Trat + cognitivo_BL, data = data_AEIO)
summary(primera_etapa)

# Fuerza del instrumento: con UN instrumento, el estadístico F relevante es
# el t del instrumento al cuadrado. Regla práctica: F > 10.
# CUIDADO: el F que imprime summary() al final es el de TODAS las variables
# juntas, no el del instrumento.
t_instrumento <- summary(primera_etapa)$coefficients["Trat", "t value"]
t_instrumento^2

# ---------- Mínimos cuadrados en dos etapas (MC2E) con ivreg() ----------
# Sintaxis: resultado ~ endógena + controles | instrumento + controles
modelo_vi <- ivreg(cognitivo_ajust ~ asistencia + cognitivo_BL | Trat + cognitivo_BL,
                   data = data_AEIO)
summary(modelo_vi, diagnostics = TRUE)
# "Weak instruments" es la prueba F de la primera etapa (valor alto = fuerte)

# Intuición: el LATE es el ITT dividido por el efecto de Trat en la asistencia
coef(modelo_itt)["Trat"] / coef(primera_etapa)["Trat"]
coef(modelo_vi)["asistencia"]
# (La división coincide aproximadamente; la diferencia viene de que los NA
#  hacen que cada regresión use filas ligeramente distintas.)

# ---------- La misma estimación con feols() ----------
# Sintaxis: resultado ~ controles | efectos_fijos | endógena ~ instrumento
# Si no hay efectos fijos, se escribe 0 en su lugar.
modelo_vi_fe <- feols(cognitivo_ajust ~ cognitivo_BL | raza | asistencia ~ Trat,
                      vcov = "hetero", data = data_AEIO)
summary(modelo_vi_fe)

# feols() le pone el prefijo "fit_" a la variable instrumentada
modelos_vi <- list(
  "ITT"           = modelo_itt,
  "MCO (sesgado)" = modelo_mco,
  "VI (ivreg)"    = modelo_vi,
  "VI + EF raza"  = modelo_vi_fe
)

tabla_vi <- modelsummary(
  modelos_vi,
  stars       = TRUE,
  coef_omit   = "Intercept",
  coef_rename = c("Trat"           = "Asignación (ITT)",
                  "asistencia"     = "Asistencia",
                  "fit_asistencia" = "Asistencia",
                  "cognitivo_BL"   = "Puntaje línea de base"),
  gof_map     = c("nobs", "r.squared")
)
tabla_vi

# Lectura:
# - ITT ≈ 0.38: efecto de ser asignado.
#   probabilidad de asistir.
# - LATE ≈ 0.81 ≈ 0.38 / 0.45: efecto de asistir para los cumplidores. Es
#   mayor que el ITT porque el ITT "diluye" el efecto entre todos los
#   asignados, incluidos los que no cambiaron su asistencia por el sorteo.
# - MCO ≈ 0.25: no tiene interpretación causal porque la asistencia es una
#   decisión del hogar; aquí además queda lejos del LATE.


# =============================================================================
# EXPORTAR RESULTADOS
# =============================================================================

# ---------- Guardar los objetos de los modelos ----------
save(modelos_basicos, modelos_ef, modelos_vi,
     file = "output/modelos_aeio.RData")

# ---------- Tabla en HTML (para abrir en el navegador o pegar en Word) ----------
modelsummary(
  modelos_vi,
  stars       = TRUE,
  coef_omit   = "Intercept",
  coef_rename = c("Trat"           = "Asignación (ITT)",
                  "asistencia"     = "Asistencia",
                  "fit_asistencia" = "Asistencia",
                  "cognitivo_BL"   = "Puntaje línea de base"),
  gof_map     = c("nobs", "r.squared"),
  title       = "Efecto del programa aeioTU sobre el desarrollo cognitivo",
  output      = "output/resultados_aeio.html"
)

# ---------- Tablas en LaTeX (para un documento o una presentación Beamer) ----------
modelsummary(
  modelos_ef,
  stars       = TRUE,
  coef_rename = c(nombres_coef, "(Intercept)" = "Intercepto"),
  gof_map     = c("nobs", "r.squared"),
  title       = "Efecto del programa con distintos efectos fijos",
  notes       = "Errores estándar en paréntesis.",
  output      = "output/tabla_modelos_ef.tex"
)

datasummary_balance(
  ~D, datos_baseline,
  title  = "Balance de características entre grupos",
  stars  = TRUE,
  output = "output/tabla_balance.tex"
)

datasummary_skim(data_estadisticas,
                 title  = "Estadísticas descriptivas de variables clave",
                 output = "output/tabla_descriptivas.tex")

cat("Archivos exportados en:", file.path(ruta_datos, "output"), "\n")
list.files("output")


# =============================================================================
# DIFERENCIAS EN DIFERENCIAS: CONTEXTO (MARTINEZ, 2017)
# =============================================================================

# Martínez (2017) estudia si la FARC aprovechó a la Venezuela de Chávez como
# refugio. Si fue así, la violencia debió aumentar DESPUÉS de 1999 y SOLO en
# los municipios colombianos CERCANOS a la frontera.
#
# DISEÑO: Diferencias en Diferencias (DiD)
#   Dimensión temporal:   antes (1993-1998) vs. después (1999-2008) de Chávez
#   Dimensión geográfica: municipios cercanos vs. lejanos a Venezuela
#
#   Comparar solo antes vs. después mezcla el efecto Chávez con todo lo que
#   cambió en Colombia en esos años. Comparar solo cercanos vs. lejanos mezcla
#   el efecto con diferencias permanentes entre regiones. La DiD resta ambas:
#   el cambio en los cercanos MENOS el cambio en los lejanos.
#
# Variables clave (ya vienen construidas):
#   murder_rate       → homicidios por cada 100.000 habitantes
#   farc_events_count → número de acciones de la FARC en el municipio-año
#   d_chavez          → 1 desde 1999 (Chávez en el poder)
#   d_border          → 1 si el municipio limita con Venezuela
#   d_onefromborder   → 1 si limita con un municipio fronterizo
#   near_venezuela    → 1 si d_border = 1 o d_onefromborder = 1
#   chavez_border     → d_chavez × d_border
#   chavez_onefromborder → d_chavez × d_onefromborder
#
# Esta sección presenta los datos; la estimación se hace en la actividad
# 11_Clase_11_actividad_DiD.R.

martinez <- read.csv("Martinez.csv", na.strings = c("", "NA", "."))

# El archivo trae 520 columnas (muchas son variables auxiliares del artículo).
# Para la clase solo hacen falta unas pocas.
martinez <- martinez %>%
  select(codmpio, year, murder_rate, farc_events_count,
         d_chavez, d_border, d_onefromborder, near_venezuela,
         chavez_border, chavez_onefromborder,
         unmet_basic_needs_93, oil_price)

length(unique(martinez$codmpio))  # municipios
range(martinez$year)              # años
table(martinez$year, martinez$d_chavez)

# ---------- Descriptivas ----------
datasummary_skim(martinez %>% select(-codmpio, -year),
                 title = "Estadísticas descriptivas: municipios de Colombia")

# CUIDADO: murder_rate tiene valores extremos (máximo > 2.000 por 100.000)
# porque en municipios muy pequeños unos pocos homicidios disparan la tasa.

# ---------- Gráfico de tendencias ----------
# Si el efecto existe, las líneas deberían moverse en paralelo antes de 1999
# y separarse después.
tendencias <- martinez %>%
  mutate(grupo = ifelse(near_venezuela == 1, "Cerca de Venezuela", "Resto del país")) %>%
  group_by(year, grupo) %>%
  summarise(homicidios = mean(murder_rate),
            farc       = mean(farc_events_count),
            .groups    = "drop")

ggplot(tendencias, aes(x = year, y = homicidios, color = grupo)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 1998.5, linetype = "dashed") +
  annotate("text", x = 1999, y = 105, label = "Chávez asume (1999)", hjust = 0) +
  labs(title    = "Homicidios: municipios cercanos a Venezuela vs. resto del país",
       x = "Año", y = "Tasa de homicidios (por 100.000 hab.)", color = NULL,
       caption  = "Fuente: Martínez (2017, JDE).") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

ggplot(tendencias, aes(x = year, y = farc, color = grupo)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 1998.5, linetype = "dashed") +
  annotate("text", x = 1999, y = 6, label = "Chávez asume (1999)", hjust = 0) +
  labs(title    = "Acciones de la FARC: cercanos a Venezuela vs. resto del país",
       x = "Año", y = "Acciones de la FARC por municipio", color = NULL,
       caption  = "Fuente: Martínez (2017, JDE).") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")

# En ambos gráficos la brecha entre los dos grupos es pequeña y estable antes
# de 1999 y se abre después. Ese patrón es la motivación visual de la DiD;
# la actividad estima su magnitud y su significancia.
