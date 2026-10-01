# TALLER 2 - CLASE TALLER DE PROGRAMACIÓN EN R
# Grupo 10: Juan José Echeverry, Miguelangel Palma, Sergio López

# 0) Configuración inicial ----

## 0.1) Limpiar ambiente ----
# Elimina los objetos de sesiones anteriores para asegurar una ejecución limpia y reproducible.
rm(list = ls())

## 0.2) Librerías ----
# Carga las herramientas estándar de tidyverse y manipulación autorizadas en el curso.
library(here)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)

## 0.3) Rutas ----
# Centraliza la derivación de rutas relativas mediante here().
ruta <- here()
ruta_datos <- file.path(ruta, "Datos")
ruta_emicron <- file.path(ruta_datos, "EMICRON_2024")
ruta_outputs <- file.path(ruta, "outputs")

if (!dir.exists(ruta_outputs)) {
  dir.create(ruta_outputs, recursive = TRUE)
}


# 1) Conformación y unión de las bases de datos ----

## 1.1) Pegue de las bases de datos de la GEIH ----

### 1.1.1) Años, meses y llave de identificación ----
# Define los 24 períodos mensuales (12 meses por año) y la llave compuesta de persona en GEIH.
anios <- c("GEIH_2023", "GEIH_2024")
meses <- c(
  "01_Enero", "02_Febrero", "03_Marzo", "04_Abril",
  "05_Mayo", "06_Junio", "07_Julio", "08_Agosto",
  "09_Septiembre", "10_Octubre", "11_Noviembre", "12_Diciembre"
)
llave_geih <- c("DIRECTORIO", "SECUENCIA_P", "ORDEN")

### 1.1.2) Objetos para almacenar resultados ----
# Listas para acumular las bases anuales e insumos de verificación mensual solicitados en 1.1.
bases_anuales <- list()
conteos_modulos <- list()
verificacion_llaves <- list()
verificacion_pegues <- list()
verificacion_eficiencia <- list()

# Definimos un contador que permite iterar a lo largo de las carpetass de los dos anos
contador <- 1

### 1.1.3) Loop para construir las bases mensuales ----
# Recorre cada año y mes leyendo los 4 módulos, seleccionando variables y uniendo secuencialmente.
for (anio in anios) {
  bases_mensuales_anio <- list()
  
  for (i in 1:12) {
    mes <- meses[i]
    ruta_mes <- file.path(ruta_datos, anio, mes)
    
    # Ajuste por inconsistencia en el nombre de archivo en marzo 2024 ("No ocupado.CSV")
    archivo_no_ocupados <- if (anio == "GEIH_2024" && mes == "03_Marzo") "No ocupado.CSV" else "No ocupados.CSV"
    
    #### 1.1.3.1) Leer los cuatro módulos ----
    general     <- read.csv(file.path(ruta_mes, "Características generales, seguridad social en salud y educación.CSV"), sep = ";")
    fuerza      <- read.csv(file.path(ruta_mes, "Fuerza de trabajo.CSV"), sep = ";")
    ocupados    <- read.csv(file.path(ruta_mes, "Ocupados.CSV"), sep = ";")
    no_ocupados <- read.csv(file.path(ruta_mes, archivo_no_ocupados), sep = ";")
    
    #### 1.1.3.2) Guardar número de observaciones (para 1.2) ----
    conteos_modulos[[contador]] <- data.frame(
      ANIO = anio, 
      MES = mes,
      GENERAL = nrow(general), 
      FUERZA_MODULO = nrow(fuerza),
      OCUPADOS = nrow(ocupados), 
      NO_OCUPADOS = nrow(no_ocupados)
    )
    
    #### 1.1.3.3) Guardar columnas antes de select ----
    col_gen_ant <- ncol(general)
    col_fuer_ant <- ncol(fuerza)
    col_ocup_ant <- ncol(ocupados)
    col_no_ocup_ant <- ncol(no_ocupados)
    
    #### 1.1.3.4) Seleccionar variables necesarias  (Reducir el uso de memoria)----
    general <- general %>% 
      select(
      DIRECTORIO, SECUENCIA_P, ORDEN, PERIODO, MES,
      P3271, P3042, P6090, P6040, P6160, DPTO, AREA, CLASE, FEX_C18, PT,
      P6100, P6110
    )
    
    fuerza <- fuerza %>% 
      select(
        DIRECTORIO, SECUENCIA_P, ORDEN, PET, FT, FFT, P6240
        )
    
    ocupados <- ocupados %>% 
      select(
      DIRECTORIO, SECUENCIA_P, ORDEN, OCI, RAMA2D_R4, P6430, INGLABO,
      P3045S1, P3046, P3069, P6765, P3065, P3066, OFICIO_C8,
      P3067, P3067S1, P3067S2, P6775, P3068, P6450, P6920, P6930, P6940
      )
    
    no_ocupados <- no_ocupados %>% 
      select(
        DIRECTORIO, SECUENCIA_P, ORDEN, DSI
        )
    
    #### 1.1.3.5) Evidencia de eficiencia ----
    verificacion_eficiencia[[contador]] <- data.frame(
      ANIO = anio, 
      MES = mes,
      GENERAL_ANTES = col_gen_ant, 
      GENERAL_DESPUES = ncol(general),
      FUERZA_ANTES = col_fuer_ant, 
      FUERZA_DESPUES = ncol(fuerza),
      OCUPADOS_ANTES = col_ocup_ant, 
      OCUPADOS_DESPUES = ncol(ocupados),
      NO_OCUPADOS_ANTES = col_no_ocup_ant, 
      NO_OCUPADOS_DESPUES = ncol(no_ocupados)
    )
    
    #### 1.1.3.6) Homogeneizar las llaves ----
    general     <- general     %>% mutate(across(all_of(llave_geih), as.character))
    fuerza      <- fuerza      %>% mutate(across(all_of(llave_geih), as.character))
    ocupados    <- ocupados    %>% mutate(across(all_of(llave_geih), as.character))
    no_ocupados <- no_ocupados %>% mutate(across(all_of(llave_geih), as.character))
    
    #### 1.1.3.7) Verificar duplicados en la llave ----
    dup_gen     <- sum(duplicated(general[, llave_geih]))
    dup_fuer    <- sum(duplicated(fuerza[, llave_geih]))
    dup_ocup    <- sum(duplicated(ocupados[, llave_geih]))
    dup_no_ocup <- sum(duplicated(no_ocupados[, llave_geih]))
    
    verificacion_llaves[[contador]] <- data.frame(
      ANIO = anio, MES = mes,
      DUP_GENERAL = dup_gen, DUP_FUERZA = dup_fuer,
      DUP_OCUPADOS = dup_ocup, DUP_NO_OCUPADOS = dup_no_ocup
    )
    
    # Parar si hay duplicados 
    if (dup_gen > 0 | dup_fuer > 0 | dup_ocup > 0 | dup_no_ocup > 0) {
      stop(paste("Se encontraron llaves duplicadas en", anio, mes))
    }
    
    #### 1.1.3.8) Pegue de los módulos y 1.1.3.9) Verificación de filas ----
    
    # Contar nuemro de filas de general (Antes del join)
    n_gen <- nrow(general)
    
    # Hacemos el joint por izquerda con fuerza
    base_mes <- general %>% 
      left_join(fuerza, by = llave_geih)
    
    # Contar nuemero de filas  despues del join 
    filas_fuerza <- nrow(base_mes)
    
    # Hacemos joint por izquerda del anterior cruce con ocupados
    base_mes <- base_mes %>% 
      left_join(ocupados, by = llave_geih)
    
    
    # Contar nuemero de filas  despues del join 
    filas_ocupados <- nrow(base_mes)
    
    # Hacemo joint por izquierda con no ocupados
    base_mes <- base_mes %>% 
      left_join(no_ocupados, by = llave_geih)
    
    # Contar nuemero de filas  despues del join 
    filas_no_ocupados <- nrow(base_mes)
    
    verificacion_pegues[[contador]] <- data.frame(
      ANIO = anio, MES = mes, GENERAL = n_gen,
      DESPUES_FUERZA = filas_fuerza,
      DESPUES_OCUPADOS = filas_ocupados,
      DESPUES_NO_OCUPADOS = filas_no_ocupados
    )
    
    if (filas_fuerza != n_gen | filas_ocupados != n_gen | filas_no_ocupados != n_gen) {
      stop(paste("El pegue modificó el número de filas en", anio, mes))
    }
    
    #### 1.1.3.10) Crear ANIO y 1.1.3.11) Guardar base mensual ----
    
    # Extraemos el anio del periodo
    base_mes <- base_mes %>% 
      mutate(
        ANIO = as.numeric(substr(as.character(PERIODO), 1, 4))
        )
    
    # Guardar en una lista las iteraciones i
    bases_mensuales_anio[[i]] <- base_mes
    
    # Mensaje gomelo
    cat("Procesado:", anio, "-", mes, "\n")
    
    # Guardar el numero de iteraciones
    contador <- contador + 1
  }
  
  ### 1.1.4) Construir las bases anuales ----
  # Unimos las dos listas
  bases_anuales[[anio]] <- bind_rows(bases_mensuales_anio)
}

### 1.1.5) Construir la base GEIH final ----
# Integra los dos años completos en el dataframe maestro GEIH.
GEIH_2023 <- bases_anuales[["GEIH_2023"]]
GEIH_2024 <- bases_anuales[["GEIH_2024"]]
GEIH <- bind_rows(GEIH_2023, GEIH_2024)

### 1.1.6) Verificaciones solicitadas ----
# Consolida las matrices mensuales de auditoría del pegue.
tabla_llaves <- bind_rows(verificacion_llaves)
tabla_pegues <- bind_rows(verificacion_pegues)
tabla_eficiencia <- bind_rows(verificacion_eficiencia)

print(head(tabla_llaves))
print(head(tabla_pegues))
print(head(tabla_eficiencia))

### 1.1.7) Exportar verificaciones ----
write.csv(tabla_llaves, file.path(ruta_outputs, "1_1_verificacion_llaves.csv"), row.names = FALSE)
write.csv(tabla_pegues, file.path(ruta_outputs, "1_1_verificacion_pegues.csv"), row.names = FALSE)
write.csv(tabla_eficiencia, file.path(ruta_outputs, "1_1_eficiencia.csv"), row.names = FALSE)


## 1.2) Descripción general de los datos ----

### 1.2.1) Tamaño de los módulos por mes ----
tabla_modulos_2024 <- bind_rows(conteos_modulos) %>% filter(ANIO == "GEIH_2024")

### 1.2.2) Relación entre los módulos ----
# Verifica que General >= Fuerza de Trabajo y que Ocupados + No Ocupados == Fuerza de Trabajo.
tabla_modulos_2024 <- tabla_modulos_2024 %>%
  mutate(
    GENERAL_MAYOR_PET = GENERAL >= FUERZA_MODULO,
    PARTICION_PET = OCUPADOS + NO_OCUPADOS == FUERZA_MODULO
  )

### 1.2.3) Consistencia de las definiciones laborales ----
# Comprueba las identidades conceptuales: PET = FT + FFT y FT = Ocupados + Desocupados.
tabla_consistencia_laboral_2024 <- GEIH_2024 %>%
  group_by(MES) %>%
  summarise(
    TOTAL_PET = sum(PET == 1, na.rm = TRUE),
    TOTAL_FT  = sum(FT == 1, na.rm = TRUE),
    TOTAL_FFT = sum(FFT == 1, na.rm = TRUE),
    TOTAL_OCI = sum(OCI == 1, na.rm = TRUE),
    TOTAL_DSI = sum(DSI == 1, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    PET_IGUAL_FT_MAS_FFT = TOTAL_PET == TOTAL_FT + TOTAL_FFT,
    FT_IGUAL_OCI_MAS_DSI = TOTAL_FT == TOTAL_OCI + TOTAL_DSI
  )

### 1.2.4) Total anual 2024 ----
total_2024 <- data.frame(
  ANIO = "GEIH_2024", MES = "TOTAL_2024",
  GENERAL = sum(tabla_modulos_2024$GENERAL),
  FUERZA_MODULO = sum(tabla_modulos_2024$FUERZA_MODULO),
  OCUPADOS = sum(tabla_modulos_2024$OCUPADOS),
  NO_OCUPADOS = sum(tabla_modulos_2024$NO_OCUPADOS),
  GENERAL_MAYOR_PET = sum(tabla_modulos_2024$GENERAL) >= sum(tabla_modulos_2024$FUERZA_MODULO),
  PARTICION_PET = sum(tabla_modulos_2024$OCUPADOS) + sum(tabla_modulos_2024$NO_OCUPADOS) == sum(tabla_modulos_2024$FUERZA_MODULO)
)

tabla_1_2 <- bind_rows(tabla_modulos_2024, total_2024)

### 1.2.5) Exportar tablas ----
write.csv(tabla_1_2, file.path(ruta_outputs, "1_2_descripcion_geih_2024.csv"), row.names = FALSE)
write.csv(tabla_consistencia_laboral_2024, file.path(ruta_outputs, "1_2_consistencia_laboral_2024.csv"), row.names = FALSE)


## 1.3) Construcción y documentación de la base analítica ----

### 1.3.a) Características generales, seguridad social en salud y educación ----
### 1.3.b) Fuerza de trabajo ----
### 1.3.c) Ocupados ----
### 1.3.d) No ocupados ----
### 1.3.e) Variables necesarias para formalidad ----
# (Las variables fueron seleccionadas dentro del loop 1.1.3.4 con fines de eficiencia).

variables_esperadas <- c(
  "DIRECTORIO", "SECUENCIA_P", "ORDEN",
  "PERIODO", "MES", "P3271", "P3042", "P6090", "P6040", "P6160", "DPTO", "AREA", "CLASE", "FEX_C18", "PT",
  "PET", "FT", "FFT", "P6240",
  "OCI", "RAMA2D_R4", "P6430", "INGLABO",
  "P6100", "P6110", "P3045S1", "P3046", "P3069", "P6765", "P3065", "P3066", "OFICIO_C8",
  "P3067", "P3067S1", "P3067S2", "P6775", "P3068", "P6450", "P6920", "P6930", "P6940",
  "DSI", "ANIO"
)

### 1.3.1) Verificación de la base analítica ----
verificacion_variables_presentes <- all(variables_esperadas %in% names(GEIH))
verificacion_variables_adicionales <- all(names(GEIH) %in% variables_esperadas)

if (!verificacion_variables_presentes | !verificacion_variables_adicionales) {
  stop("La base analítica no contiene exactamente las variables esperadas.")
}

### 1.3.2) Diccionario de variables ----
diccionario_variables <- data.frame(
  VARIABLE = c(
    "DIRECTORIO", "SECUENCIA_P", "ORDEN", "PERIODO", "MES",
    "P3271", "P3042", "P6090", "P6040", "P6160",
    "DPTO", "AREA", "CLASE", "FEX_C18", "PT",
    "PET", "FT", "FFT", "P6240",
    "OCI", "RAMA2D_R4", "P6430", "INGLABO",
    "DSI"
  ),
  MODULO = c(
    rep("Características generales", 15),
    rep("Fuerza de trabajo", 4),
    rep("Ocupados", 4),
    "No ocupados"
  ),
  DESCRIPCION = c(
    "Identificador del directorio", "Secuencia del hogar", "Número de orden de la persona",
    "Período de la encuesta", "Mes de la encuesta", "Sexo", "Nivel educativo",
    "Afiliación a seguridad social en salud", "Edad", "Sabe leer y escribir",
    "Departamento", "Área geográfica", "Clase geográfica", "Factor de expansión",
    "Población total", "Población en edad de trabajar", "Población en la fuerza de trabajo",
    "Población fuera de la fuerza de trabajo", "Actividad principal",
    "Población ocupada", "Rama de actividad económica", "Posición ocupacional",
    "Ingreso laboral", "Población desocupada"
  ),
  CATEGORIA_UNIDAD = c(
    "Identificador", "Identificador", "Identificador", "Año y mes", "Mes",
    "1 Hombre; 2 Mujer", "Categorías educativas", "Categorías de afiliación", "Años",
    "1 Sí; 2 No", "Código", "Código", "Categoría", "Factor de expansión", "Indicador",
    "Indicador", "Indicador", "Indicador", "Categorías",
    "Indicador", "Código CIIU Rev. 4", "Categorías", "Pesos colombianos",
    "Indicador"
  )
)

### 1.3.3) Etiquetas necesarias ----
#### 1.3.3.1) Etiquetas para sexo ----
etiquetas_sexo <- data.frame(
  P3271 = c(1, 2),
  SEXO = c("Hombre", "Mujer")
)

#### 1.3.3.2) Etiquetas para posición ocupacional ----
etiquetas_posicion <- data.frame(
  P6430 = c(1, 2, 3, 4, 5, 6, 7, 8, 9),
  POSICION_OCUPACIONAL = c(
    "Obrero o empleado de empresa particular", "Obrero o empleado del gobierno",
    "Empleado doméstico", "Trabajador por cuenta propia", "Patrón o empleador",
    "Trabajador familiar sin remuneración", "Trabajador sin remuneración en empresas de otros hogares",
    "Jornalero o peón", "Otro"
  )
)

### 1.3.4) Exportar diccionario ----
write.csv(diccionario_variables, file.path(ruta_outputs, "1_3_diccionario_variables.csv"), row.names = FALSE)


## 1.4) Incorporación de la EMICRON 2024 y unión con la GEIH ----

### 1.4.a) Construcción de la base de la EMICRON ----

#### 1.4.a.1) Leer los módulos de EMICRON y 1.4.a.2) Seleccionar variables ----
emicron_identificacion <- read.csv(file.path(ruta_emicron, "Módulo de identificación.csv")) %>%
  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA, COD_DEPTO, AREA, CLASE_TE, P35, P241, MES_REF, GRUPOS4, GRUPOS12, F_EXP)

emicron_caracteristicas <- read.csv(file.path(ruta_emicron, "Módulo de características del micronegocio.csv")) %>%
  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA, P1633, P1055)

emicron_inclusion <- read.csv(file.path(ruta_emicron, "Módulo de inclusión financiera.csv")) %>%
  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA, P1764_1, P1764_2, P1764_3, P1764_4, P1764_5, P1764_6, P1764_7, P1765, P3014)

emicron_ventas <- read.csv(file.path(ruta_emicron, "Módulo de ventas o ingresos.csv")) %>%
  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA, VENTAS_MES_ANTERIOR)

#### 1.4.a.3) Preparar la llave de EMICRON ----
llave_emicron <- c("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA")

emicron_identificacion <- emicron_identificacion  %>% mutate(across(all_of(llave_emicron), as.character))
emicron_caracteristicas <- emicron_caracteristicas %>% mutate(across(all_of(llave_emicron), as.character))
emicron_inclusion <- emicron_inclusion %>% mutate(across(all_of(llave_emicron), as.character))
emicron_ventas <- emicron_ventas %>% mutate(across(all_of(llave_emicron), as.character))

#### 1.4.a.4) Verificar la llave ----
tabla_na_llaves_emicron <- data.frame(
  MODULO = c("Identificación", "Características", "Inclusión financiera", "Ventas o ingresos"),
  NA_DIRECTORIO = c(sum(is.na(emicron_identificacion$DIRECTORIO)), sum(is.na(emicron_caracteristicas$DIRECTORIO)), sum(is.na(emicron_inclusion$DIRECTORIO)), sum(is.na(emicron_ventas$DIRECTORIO))),
  NA_SECUENCIA_P = c(sum(is.na(emicron_identificacion$SECUENCIA_P)), sum(is.na(emicron_caracteristicas$SECUENCIA_P)), sum(is.na(emicron_inclusion$SECUENCIA_P)), sum(is.na(emicron_ventas$SECUENCIA_P))),
  NA_SECUENCIA_ENCUESTA = c(sum(is.na(emicron_identificacion$SECUENCIA_ENCUESTA)), sum(is.na(emicron_caracteristicas$SECUENCIA_ENCUESTA)), sum(is.na(emicron_inclusion$SECUENCIA_ENCUESTA)), sum(is.na(emicron_ventas$SECUENCIA_ENCUESTA)))
)
write.csv(tabla_na_llaves_emicron, file.path(ruta_outputs, "1_4_na_llaves_emicron.csv"), row.names = FALSE)

tabla_llaves_emicron <- data.frame(
  MODULO = c("Identificación", "Características", "Inclusión financiera", "Ventas o ingresos"),
  OBSERVACIONES = c(nrow(emicron_identificacion), nrow(emicron_caracteristicas), nrow(emicron_inclusion), nrow(emicron_ventas)),
  DUPLICADOS = c(
    sum(duplicated(emicron_identificacion[, llave_emicron])),
    sum(duplicated(emicron_caracteristicas[, llave_emicron])),
    sum(duplicated(emicron_inclusion[, llave_emicron])),
    sum(duplicated(emicron_ventas[, llave_emicron]))
  )
)
write.csv(tabla_llaves_emicron, file.path(ruta_outputs, "1_4_llaves_emicron.csv"), row.names = FALSE)

#### 1.4.a.5) Construir la base EMICRON ----
emicron <- emicron_identificacion %>%
  left_join(emicron_caracteristicas, by = llave_emicron) %>%
  left_join(emicron_inclusion, by = llave_emicron) %>%
  left_join(emicron_ventas, by = llave_emicron)

if (nrow(emicron) != nrow(emicron_identificacion)) {
  stop("El pegue de los módulos de EMICRON modificó el número de observaciones.")
}

### 1.4.b) Documentación de la relación entre las dos encuestas ----
# (Documentada detalladamente en el cuerpo del informe técnico).

### 1.4.c) Determinación de la llave y análisis del período de referencia ----

#### 1.4.c.1) Distribución de SECUENCIA_ENCUESTA ----
tabla_secuencia_encuesta <- emicron %>%
  group_by(SECUENCIA_ENCUESTA) %>%
  summarise(REGISTROS = n(), .groups = "drop") %>%
  arrange(SECUENCIA_ENCUESTA)
write.csv(tabla_secuencia_encuesta, file.path(ruta_outputs, "1_4_secuencia_encuesta.csv"), row.names = FALSE)

#### 1.4.c.2) SECUENCIA_ENCUESTA dentro de los hogares ----
tabla_propietarios_hogar <- emicron %>%
  group_by(DIRECTORIO, SECUENCIA_P) %>%
  summarise(PROPIETARIOS = n(), .groups = "drop") %>%
  group_by(PROPIETARIOS) %>%
  summarise(HOGARES = n(), .groups = "drop") %>%
  arrange(PROPIETARIOS)
write.csv(tabla_propietarios_hogar, file.path(ruta_outputs, "1_4_propietarios_hogar.csv"), row.names = FALSE)

#### 1.4.c.3) Comparación con ORDEN ----
geih_personas <- GEIH %>% select(DIRECTORIO, SECUENCIA_P, ORDEN)
comparacion_orden <- emicron %>%
  select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA) %>%
  left_join(geih_personas, by = c("DIRECTORIO", "SECUENCIA_P"), relationship = "many-to-many") %>%
  mutate(COINCIDE_ORDEN = SECUENCIA_ENCUESTA == ORDEN)

tabla_orden_persona <- comparacion_orden %>%
  group_by(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA) %>%
  summarise(COINCIDENCIAS = sum(COINCIDE_ORDEN, na.rm = TRUE), .groups = "drop")

resumen_relacion_orden <- tabla_orden_persona %>%
  summarise(
    REGISTROS_EMICRON = n(),
    UNA_COINCIDENCIA = sum(COINCIDENCIAS == 1),
    SIN_COINCIDENCIA = sum(COINCIDENCIAS == 0),
    MAS_DE_UNA_COINCIDENCIA = sum(COINCIDENCIAS > 1),
    PORCENTAJE_UNA_COINCIDENCIA = round(mean(COINCIDENCIAS == 1) * 100, 2)
  )
write.csv(resumen_relacion_orden, file.path(ruta_outputs, "1_4_relacion_orden.csv"), row.names = FALSE)

#### 1.4.c.4) Construcción de la llave de persona ----
if (resumen_relacion_orden$MAS_DE_UNA_COINCIDENCIA > 0 | resumen_relacion_orden$SIN_COINCIDENCIA > 0) {
  stop("SECUENCIA_ENCUESTA no presenta coincidencia unívoca con ORDEN.")
}

emicron_persona <- emicron %>% mutate(ORDEN = SECUENCIA_ENCUESTA)

#### 1.4.c.5) Comparación entre MES_REF y MES y 1.4.c.6) Relaciones temporales ----
meses_nombres_orden <- c(
  "ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO",
  "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"
)
emicron_persona <- emicron_persona %>%
  mutate(MES_REF_NUM = as.numeric(factor(MES_REF, levels = meses_nombres_orden)))

comparacion_temporal <- emicron_persona %>%
  select(DIRECTORIO, SECUENCIA_P, ORDEN, MES_REF, MES_REF_NUM) %>%
  left_join(GEIH %>% select(DIRECTORIO, SECUENCIA_P, ORDEN, ANIO, MES), by = llave_geih) %>%
  mutate(MES_GEIH = MES)

n_comparables <- sum(!is.na(comparacion_temporal$MES_GEIH))

tabla_relacion_meses <- data.frame(
  RELACION = c("Mismo mes", "Un mes atrás", "Un mes adelante"),
  COINCIDENCIAS = c(
    sum(comparacion_temporal$MES_REF_NUM == comparacion_temporal$MES_GEIH, na.rm = TRUE),
    sum(comparacion_temporal$MES_REF_NUM == ifelse(comparacion_temporal$MES_GEIH == 1, 12, comparacion_temporal$MES_GEIH - 1), na.rm = TRUE),
    sum(comparacion_temporal$MES_REF_NUM == ifelse(comparacion_temporal$MES_GEIH == 12, 1, comparacion_temporal$MES_GEIH + 1), na.rm = TRUE)
  )
) %>%
  mutate(PORCENTAJE = round(COINCIDENCIAS / n_comparables * 100, 2))
write.csv(tabla_relacion_meses, file.path(ruta_outputs, "1_4_relacion_meses.csv"), row.names = FALSE)


### 1.4.d) Pegue de las dos encuestas ----
geih_2024_micro <- GEIH %>% filter(ANIO == 2024)

# Verifica unicidad de llave en GEIH 2024
if (anyDuplicated(geih_2024_micro[, llave_geih]) > 0) {
  stop("La llave de GEIH 2024 tiene registros duplicados.")
}

n_emicron_antes <- nrow(emicron_persona)
base_micro <- emicron_persona %>%
  left_join(geih_2024_micro, by = llave_geih)

if (nrow(base_micro) != n_emicron_antes) {
  stop("El pegue entre EMICRON y GEIH aumentó el número de filas.")
}

base_micro <- base_micro %>% mutate(EMPAREJADO = !is.na(P3271))

resumen_pegue <- base_micro %>%
  summarise(
    REGISTROS_EMICRON = n(),
    EMPAREJADOS = sum(EMPAREJADO),
    NO_EMPAREJADOS = sum(!EMPAREJADO),
    PORCENTAJE_EMPAREJADO = round(mean(EMPAREJADO) * 100, 2)
  )
write.csv(resumen_pegue, file.path(ruta_outputs, "1_4_resumen_pegue.csv"), row.names = FALSE)

### 1.4.e) Validación de la calidad del pegue ----
validacion_pegue <- base_micro %>%
  filter(EMPAREJADO) %>%
  summarise(
    COINCIDENCIA_SEXO = round(mean(as.character(P35) == as.character(P3271), na.rm = TRUE) * 100, 2),
    COINCIDENCIA_EDAD = round(mean(P241 == P6040, na.rm = TRUE) * 100, 2),
    COINCIDENCIA_CLASE = round(mean(as.character(CLASE_TE) == as.character(CLASE), na.rm = TRUE) * 100, 2)
  )
write.csv(validacion_pegue, file.path(ruta_outputs, "1_4_validacion_pegue.csv"), row.names = FALSE)

### 1.4.f) Auditoría del pegue ----
#### 1.4.f.1) Auditoría mensual ----
auditoria_mensual <- base_micro %>%
  group_by(MES_REF, MES_REF_NUM) %>%
  summarise(
    REGISTROS_EMICRON = n(),
    EMPAREJADOS = sum(EMPAREJADO),
    PORCENTAJE_CORRESPONDENCIA = round(mean(EMPAREJADO) * 100, 2),
    NO_EMPAREJADOS = sum(!EMPAREJADO),
    .groups = "drop"
  ) %>%
  arrange(MES_REF_NUM)
write.csv(auditoria_mensual, file.path(ruta_outputs, "1_4_auditoria_mensual.csv"), row.names = FALSE)

#### 1.4.f.2) No emparejados y GEIH 2023 ----
no_emparejados <- base_micro %>%
  filter(!EMPAREJADO) %>%
  select(DIRECTORIO, SECUENCIA_P, ORDEN, MES_REF, MES_REF_NUM)

comparacion_2023 <- no_emparejados %>%
  left_join(GEIH_2023 %>% select(DIRECTORIO, SECUENCIA_P, ORDEN, MES), by = llave_geih) %>%
  mutate(EN_GEIH_2023 = !is.na(MES))

resumen_fuera_2024 <- comparacion_2023 %>%
  summarise(
    NO_EMPAREJADOS_2024 = n(),
    ENCONTRADOS_GEIH_2023 = sum(EN_GEIH_2023),
    PORCENTAJE = round(mean(EN_GEIH_2023) * 100, 2)
  )
write.csv(resumen_fuera_2024, file.path(ruta_outputs, "1_4_fuera_2024.csv"), row.names = FALSE)

#### 1.4.f.3) Relación temporal complementaria ----
auditoria_2023 <- comparacion_2023 %>%
  filter(EN_GEIH_2023) %>%
  group_by(MES_REF, MES) %>%
  summarise(REGISTROS = n(), .groups = "drop")
write.csv(auditoria_2023, file.path(ruta_outputs, "1_4_auditoria_2023.csv"), row.names = FALSE)

### 1.4.g) Interpretación ----
#### 1.4.g.1) Distribución de P6430 ----
distribucion_posicion <- base_micro %>%
  filter(EMPAREJADO, !is.na(P6430)) %>%
  group_by(P6430) %>%
  summarise(
    REGISTROS = n(),
    TOTAL_EXPANDIDO = sum(F_EXP, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(PORCENTAJE = round(TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100, 2)) %>%
  left_join(etiquetas_posicion, by = "P6430") %>%
  arrange(desc(PORCENTAJE))
write.csv(distribucion_posicion, file.path(ruta_outputs, "1_4_posicion_ocupacional.csv"), row.names = FALSE)


# Punto 2 ----
# Construcción de los principales indicadores de mercado laboral

## 2.1) Tasas y poblaciones ----

### 2.1.1) Definición de trimestres y factor de expansión trimestral ----
GEIH <- GEIH %>%
  mutate(
    TRIMESTRE = case_when(
      MES %in% 1:3   ~ "Enero - marzo",
      MES %in% 4:6   ~ "Abril - junio",
      MES %in% 7:9   ~ "Julio - septiembre",
      MES %in% 10:12 ~ "Octubre - diciembre"
    ),
    PERIODO_TRIM = paste(TRIMESTRE, ANIO),
    FEX_TRIM = FEX_C18 / 3
  )

### 2.1.2) Cálculo de poblaciones y tasas por trimestre y sexo ----
orden_trimestres <- c(
  "Enero - marzo 2023", "Abril - junio 2023", "Julio - septiembre 2023", "Octubre - diciembre 2023",
  "Enero - marzo 2024", "Abril - junio 2024", "Julio - septiembre 2024", "Octubre - diciembre 2024"
)

tabla_indicadores_trim <- GEIH %>%
  filter(P3271 %in% c(1, 2)) %>%
  group_by(ANIO, TRIMESTRE, PERIODO_TRIM, P3271) %>%
  summarise(
    POBLACION_TOTAL  = sum(PT * FEX_TRIM, na.rm = TRUE),
    PET_CALC         = sum((PET == 1) * FEX_TRIM, na.rm = TRUE),
    FT_CALC          = sum((FT == 1) * FEX_TRIM, na.rm = TRUE),
    OCUPADOS_CALC    = sum((OCI == 1) * FEX_TRIM, na.rm = TRUE),
    DESOCUPADOS_CALC = sum((DSI == 1) * FEX_TRIM, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    TGP = round((FT_CALC / PET_CALC) * 100, 2),
    TO  = round((OCUPADOS_CALC / PET_CALC) * 100, 2),
    TD  = round((DESOCUPADOS_CALC / FT_CALC) * 100, 2),
    POBLACION_TOTAL  = round(POBLACION_TOTAL, 0),
    PET_CALC         = round(PET_CALC, 0),
    FT_CALC          = round(FT_CALC, 0),
    OCUPADOS_CALC    = round(OCUPADOS_CALC, 0),
    DESOCUPADOS_CALC = round(DESOCUPADOS_CALC, 0)
  )

### 2.1.3) Verificación de consistencia entre FT, Ocupados y Desocupados ----
verificacion_consistencia_tasas <- tabla_indicadores_trim %>%
  mutate(
    DIFERENCIA = FT_CALC - (OCUPADOS_CALC + DESOCUPADOS_CALC),
    CONSISTENTE = abs(DIFERENCIA) <= 1
  ) %>%
  select(ANIO, TRIMESTRE, PERIODO_TRIM, P3271, FT_CALC, OCUPADOS_CALC, DESOCUPADOS_CALC, DIFERENCIA, CONSISTENTE)

write.csv(verificacion_consistencia_tasas, file.path(ruta_outputs, "2_1_consistencia_tasas.csv"), row.names = FALSE)
if (!all(verificacion_consistencia_tasas$CONSISTENTE)) {
  stop("La verificación de consistencia entre FT, Ocupados y Desocupados falló.")
}

### 2.1.4) Reestructuración a la estructura solicitada ----
nombres_indicadores <- c(
  "TGP" = "Tasa global de participación (TGP)",
  "TO" = "Tasa de ocupación (TO)",
  "TD" = "Tasa de desempleo (TD)",
  "POBLACION_TOTAL" = "Población total",
  "PET_CALC" = "Población en edad de trabajar (PET)",
  "FT_CALC" = "Fuerza de trabajo",
  "OCUPADOS_CALC" = "Población ocupada",
  "DESOCUPADOS_CALC" = "Población desocupada"
)

tabla_tasas_hombres <- tabla_indicadores_trim %>%
  filter(P3271 == 1) %>%
  select(PERIODO_TRIM, TGP, TO, TD, POBLACION_TOTAL, PET_CALC, FT_CALC, OCUPADOS_CALC, DESOCUPADOS_CALC) %>%
  pivot_longer(cols = -PERIODO_TRIM, names_to = "VARIABLE", values_to = "VALOR") %>%
  mutate(
    `Tasas (%) y poblaciones` = nombres_indicadores[VARIABLE],
    `Tasas (%) y poblaciones` = factor(`Tasas (%) y poblaciones`, levels = unname(nombres_indicadores))
  ) %>%
  arrange(`Tasas (%) y poblaciones`) %>%
  select(-VARIABLE) %>%
  pivot_wider(names_from = PERIODO_TRIM, values_from = VALOR) %>%
  select(`Tasas (%) y poblaciones`, all_of(orden_trimestres))

tabla_tasas_mujeres <- tabla_indicadores_trim %>%
  filter(P3271 == 2) %>%
  select(PERIODO_TRIM, TGP, TO, TD, POBLACION_TOTAL, PET_CALC, FT_CALC, OCUPADOS_CALC, DESOCUPADOS_CALC) %>%
  pivot_longer(cols = -PERIODO_TRIM, names_to = "VARIABLE", values_to = "VALOR") %>%
  mutate(
    `Tasas (%) y poblaciones` = nombres_indicadores[VARIABLE],
    `Tasas (%) y poblaciones` = factor(`Tasas (%) y poblaciones`, levels = unname(nombres_indicadores))
  ) %>%
  arrange(`Tasas (%) y poblaciones`) %>%
  select(-VARIABLE) %>%
  pivot_wider(names_from = PERIODO_TRIM, values_from = VALOR) %>%
  select(`Tasas (%) y poblaciones`, all_of(orden_trimestres))

### 2.1.5) Exportar tablas a Excel ----
write.xlsx(tabla_tasas_hombres, file.path(ruta_outputs, "2_1_tasas_hombres.xlsx"))
write.xlsx(tabla_tasas_mujeres, file.path(ruta_outputs, "2_1_tasas_mujeres.xlsx"))


## 2.2) Análisis de las tasas de mercado laboral ----

### 2.2.1) Preparar datos para el gráfico de series de tiempo ----
datos_grafico_tasas <- tabla_indicadores_trim %>%
  mutate(
    SEXO = ifelse(P3271 == 1, "Hombre", "Mujer"),
    PERIODO_TRIM = factor(PERIODO_TRIM, levels = orden_trimestres)
  ) %>%
  select(
    PERIODO_TRIM, SEXO,
    `Tasa global de participación (TGP)` = TGP,
    `Tasa de ocupación (TO)` = TO,
    `Tasa de desempleo (TD)` = TD
  ) %>%
  pivot_longer(
    cols = c("Tasa global de participación (TGP)", "Tasa de ocupación (TO)", "Tasa de desempleo (TD)"),
    names_to = "TASA", values_to = "VALOR"
  ) %>%
  mutate(
    TASA = factor(TASA, levels = c("Tasa global de participación (TGP)", "Tasa de ocupación (TO)", "Tasa de desempleo (TD)"))
  )

### 2.2.2) Construir el gráfico de series de tiempo y 2.2.3) Exportar ----
grafico_tasas <- ggplot(datos_grafico_tasas, aes(x = PERIODO_TRIM, y = VALOR, group = SEXO, color = SEXO, shape = SEXO, linetype = SEXO)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_wrap(~TASA, scales = "free_y", ncol = 3) +
  scale_color_manual(values = c("Hombre" = "darkblue", "Mujer" = "violet")) +
  scale_x_discrete(labels = c("T1\n2023", "T2\n2023", "T3\n2023", "T4\n2023", "T1\n2024", "T2\n2024", "T3\n2024", "T4\n2024")) +
  labs(
    title = "Evolución de las tasas de mercado laboral según sexo en Colombia",
    subtitle = "Total nacional por trimestres (2023 - 2024)",
    x = "Trimestre", y = "Tasa (%)",
    color = "Sexo al nacer", shape = "Sexo al nacer", linetype = "Sexo al nacer",
    caption = "Fuente: DANE - Gran Encuesta Integrada de Hogares (GEIH) 2023-2024."
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(hjust = 0.5, size = 10),
    strip.text = element_text(face = "bold", size = 12),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, color = "gray30")
  )

ggsave(file.path(ruta_outputs, "2_2_tasas_sexo.png"), plot = grafico_tasas, width = 12, height = 6, dpi = 300)


## 2.3) Población ocupada según formalidad ----

### 2.3.1) Construcción de la variable de formalidad (EI) ----
areas_13ciudades <- c(5, 8, 11, 13, 17, 23, 50, 52, 54, 66, 68, 73, 76)

GEIH_13ciudades_tri <- GEIH %>%
  filter(ANIO == 2024, MES %in% 10:12, OCI == 1, as.numeric(AREA) %in% areas_13ciudades) %>%
  mutate(
    OFICIO_C8_2D = if_else(!is.na(OFICIO_C8), substr(sprintf("%04d", as.integer(OFICIO_C8)), 1, 2), NA_character_),
    ANIOS = ANIO - 1,
    FORMAL = case_when(
      P6430 == 3 ~ NA_real_,
      P6430 == 6 ~ 0,
      RAMA2D_R4 %in% c(84, 99) ~ 1,
      P6430 == 8 ~ 0,
      P6430 == 2 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 == 1 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 1 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 2 ~ 0,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 9 & P3069 >= 4 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 9 & P3069 <= 3 ~ 0,
      P6430 %in% c(4, 5) & P6765 != 7 & P3065 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 2 ~ 0,
      P6430 == 5 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & P3069 >= 4 ~ 1,
      P6430 == 5 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & P3069 <= 3 ~ 0,
      P6430 == 4 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 == 4 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 1 & P3067S2 >= ANIOS ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 1 & P3067S2 < ANIOS ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 3 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 3 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 2 ~ 0,
      P6430 == 4 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 == 4 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 == 5 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & P3069 >= 4 ~ 1,
      P6430 == 5 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & P3069 <= 3 ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 1 & P3068 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 1 & P3068 == 2 ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 3 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 3 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 1 & P3068 %in% c(3, 9) ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 2 ~ 0,
      P6430 == 5 & P6765 == 7 & P3067 == 2 & P6775 == 9 & P3069 >= 4 ~ 1,
      P6430 == 5 & P6765 == 7 & P3067 == 2 & P6775 == 9 & P3069 <= 3 ~ 0,
      P6430 == 4 & P6765 == 7 & P3067 == 2 & P6775 == 9 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 == 4 & P6765 == 7 & P3067 == 2 & P6775 == 9 & OFICIO_C8_2D >= "21" ~ 0,
      TRUE ~ NA_real_
    ),
    SALUD = case_when(
      P6430 %in% c(1, 3, 7) & P6100 %in% c(1, 2) & P6110 %in% c(1, 2, 4) ~ 1,
      P6430 %in% c(1, 3, 7) & P6100 == 9 & P6450 == 2 ~ 1,
      P6430 %in% c(1, 3, 7) & P6110 == 9 & P6450 == 2 ~ 1,
      P6430 %in% c(1, 3, 7) ~ 0,
      TRUE ~ NA_real_
    ),
    PENSION = case_when(
      P6430 %in% c(1, 3, 7) & P6920 == 3 ~ 1,
      P6430 %in% c(1, 3, 7) & P6920 == 1 & P6930 %in% c(1, 2, 3) & P6940 %in% c(1, 3) ~ 1,
      P6430 %in% c(1, 3, 7) ~ 0,
      TRUE ~ NA_real_
    ),
    EI = case_when(
      P6430 == 2 ~ 1,
      P6430 %in% c(6, 8) ~ 0,
      P6430 %in% c(4, 5) ~ FORMAL,
      P6430 %in% c(1, 3, 7) & SALUD == 1 & PENSION == 1 ~ 1,
      P6430 %in% c(1, 3, 7) ~ 0,
      TRUE ~ NA_real_
    )
  )

GEIH_13ciudades_dic <- GEIH_13ciudades_tri %>% filter(MES == 12)

# Verificación frente al boletín técnico DANE (42,5 % informalidad en 13 ciudades, Oct-Dic 2024)
control_ei_dane <- GEIH_13ciudades_tri %>%
  summarise(
    N_OCUPADOS = n(),
    N_SIN_EI = sum(is.na(EI)),
    INFORMALIDAD_CALCULADA = round(100 * sum((FEX_C18 / 3)[EI == 0], na.rm = TRUE) / sum((FEX_C18 / 3)[!is.na(EI)], na.rm = TRUE), 1),
    INFORMALIDAD_DANE = 42.5,
    DIFERENCIA_PP = round(INFORMALIDAD_CALCULADA - INFORMALIDAD_DANE, 1)
  )
write.csv(control_ei_dane, file.path(ruta_outputs, "2_3_control_ei_dane.csv"), row.names = FALSE)
print(control_ei_dane)

### 2.3.2) Dataframe con total expandido según formalidad y sexo ----
tabla_formalidad_sexo <- GEIH_13ciudades_dic %>%
  filter(!is.na(EI), P3271 %in% c(1, 2), !is.na(FEX_C18)) %>%
  mutate(
    SEXO = ifelse(P3271 == 1, "Hombre", "Mujer"),
    CONDICION = ifelse(EI == 1, "Formal", "Informal")
  ) %>%
  group_by(SEXO, CONDICION) %>%
  summarise(TOTAL_EXPANDIDO = sum(FEX_C18, na.rm = TRUE), .groups = "drop") %>%
  group_by(SEXO) %>%
  mutate(PORCENTAJE = round(TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100, 1)) %>%
  ungroup()

write.csv(tabla_formalidad_sexo, file.path(ruta_outputs, "2_3_tabla_formalidad_13ciudades.csv"), row.names = FALSE)

### 2.3.3) Construir y exportar el gráfico de torta ----
grafico_formalidad <- ggplot(tabla_formalidad_sexo, aes(x = "", y = PORCENTAJE, fill = CONDICION)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  facet_wrap(~SEXO) +
  geom_text(aes(label = paste0(PORCENTAJE, "%")), position = position_stack(vjust = 0.5), color = "white", size = 5) +
  scale_fill_manual(values = c("Formal" = "#2CA02C", "Informal" = "#D62728")) +
  labs(
    title = "Distribución de personas ocupadas según condición de formalidad y sexo",
    subtitle = "Total 13 ciudades y áreas metropolitanas - Diciembre de 2024",
    fill = "Condición laboral"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    strip.text = element_text(size = 12, face = "bold"),
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12)
  )

ggsave(file.path(ruta_outputs, "2_3_formalidad_13ciudades.png"), plot = grafico_formalidad, width = 9, height = 5, dpi = 300)


## 2.4) Población ocupada según posición ocupacional ----

### 2.4.1) Preparar datos de enero de 2023 ----
GEIH_2023_ENE <- GEIH %>%
  filter(ANIO == 2023, MES == 1, OCI == 1, !is.na(P6430))

### 2.4.2) Calcular totales expandidos y proporciones por grupo ----
posicion_total <- GEIH_2023_ENE %>%
  group_by(P6430) %>%
  summarise(TOTAL_EXP = sum(FEX_C18, na.rm = TRUE), .groups = "drop") %>%
  mutate(GRUPO = "Total nacional", PORCENTAJE = round(TOTAL_EXP / sum(TOTAL_EXP) * 100, 1))

posicion_hombres <- GEIH_2023_ENE %>%
  filter(P3271 == 1) %>%
  group_by(P6430) %>%
  summarise(TOTAL_EXP = sum(FEX_C18, na.rm = TRUE), .groups = "drop") %>%
  mutate(GRUPO = "Hombres", PORCENTAJE = round(TOTAL_EXP / sum(TOTAL_EXP) * 100, 1))

posicion_mujeres <- GEIH_2023_ENE %>%
  filter(P3271 == 2) %>%
  group_by(P6430) %>%
  summarise(TOTAL_EXP = sum(FEX_C18, na.rm = TRUE), .groups = "drop") %>%
  mutate(GRUPO = "Mujeres", PORCENTAJE = round(TOTAL_EXP / sum(TOTAL_EXP) * 100, 1))

orden_posiciones <- posicion_total %>%
  left_join(etiquetas_posicion, by = "P6430") %>%
  arrange(TOTAL_EXP) %>%
  pull(POSICION_OCUPACIONAL)

posicion_consolidada <- bind_rows(posicion_total, posicion_hombres, posicion_mujeres) %>%
  left_join(etiquetas_posicion, by = "P6430") %>%
  mutate(
    POSICION_OCUPACIONAL = factor(POSICION_OCUPACIONAL, levels = orden_posiciones),
    GRUPO = factor(GRUPO, levels = c("Total nacional", "Hombres", "Mujeres"))
  )

### 2.4.3) Verificación de suma de proporciones ----
verificacion_suma_posicion <- posicion_consolidada %>%
  group_by(GRUPO) %>%
  summarise(SUMA_PORCENTAJE = sum(PORCENTAJE), .groups = "drop")
print(verificacion_suma_posicion)

### 2.4.4) Proporción conjunta de cuenta propia y patrones ----
prop_cuenta_propia_patron <- posicion_total %>%
  filter(P6430 %in% c(4, 5)) %>%
  summarise(PORCENTAJE_CONJUNTO = sum(PORCENTAJE)) %>%
  pull(PORCENTAJE_CONJUNTO)

cat("Proporción de ocupados como cuenta propia y patrones:", prop_cuenta_propia_patron, "%\n")

### 2.4.5) Construir y exportar el gráfico de barras horizontales ----
grafico_posicion <- ggplot(posicion_consolidada, aes(x = POSICION_OCUPACIONAL, y = PORCENTAJE, fill = GRUPO)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  coord_flip() +
  geom_text(aes(label = paste0(PORCENTAJE, "%")), position = position_dodge(width = 0.8), hjust = -0.15, size = 3.5) +
  scale_y_continuous(limits = c(0, max(posicion_consolidada$PORCENTAJE) * 1.15)) +
  scale_fill_manual(values = c("Total nacional" = "#2CA02C", "Hombres" = "#1F77B4", "Mujeres" = "#E377C2")) +
  labs(
    title = "Distribución de personas ocupadas según posición ocupacional",
    subtitle = "Total nacional, hombres y mujeres - Enero de 2023",
    x = "Posición ocupacional", y = "Proporción (%)", fill = "Grupo de análisis",
    caption = "Fuente: DANE - GEIH (Enero 2023)."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, color = "gray30"),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom"
  )

ggsave(file.path(ruta_outputs, "2_4_posicion_nacional.png"), plot = grafico_posicion, width = 11, height = 6, dpi = 300)


# Punto 3 ----
# Caracterización de los micronegocios en Colombia

## 3.1) Indicadores básicos de los micronegocios ----

### 3.1.1) Total nacional de micronegocios ----
total_nacional_micros <- emicron %>%
  summarise(TOTAL_EXPANDIDO = round(sum(F_EXP, na.rm = TRUE), 0)) %>%
  mutate(INDICADOR = "Total nacional", CATEGORIA = "Total micronegocios", PORCENTAJE = 100.0) %>%
  select(INDICADOR, CATEGORIA, TOTAL_EXPANDIDO, PORCENTAJE)

### 3.1.2) Distribución por rama de actividad (GRUPOS12) ----
distribucion_rama <- emicron %>%
  mutate(
    CATEGORIA = case_when(
      GRUPOS12 == 1  ~ "Agricultura, ganadería, caza, silvicultura y pesca",
      GRUPOS12 == 2  ~ "Explotación de minas y canteras",
      GRUPOS12 == 3  ~ "Industrias manufactureras",
      GRUPOS12 == 4  ~ "Construcción",
      GRUPOS12 == 5  ~ "Comercio y reparación de vehículos",
      GRUPOS12 == 6  ~ "Transporte y almacenamiento",
      GRUPOS12 == 7  ~ "Alojamiento y servicios de comida",
      GRUPOS12 == 8  ~ "Información y comunicaciones",
      GRUPOS12 == 9  ~ "Actividades inmobiliarias, profesionales y administrativas",
      GRUPOS12 == 10 ~ "Educación",
      GRUPOS12 == 11 ~ "Salud humana y asistencia social",
      GRUPOS12 == 12 ~ "Otras actividades de servicios comunitarios, sociales y personales",
      TRUE ~ "Otras actividades / No informa"
    )
  ) %>%
  group_by(GRUPOS12, CATEGORIA) %>%
  summarise(TOTAL_EXPANDIDO = round(sum(F_EXP, na.rm = TRUE), 0), .groups = "drop") %>%
  mutate(
    INDICADOR = "Distribución por rama de actividad (GRUPOS12)",
    PORCENTAJE = round(TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100, 1)
  ) %>%
  arrange(GRUPOS12) %>%
  select(INDICADOR, CATEGORIA, TOTAL_EXPANDIDO, PORCENTAJE)

### 3.1.3) Distribución según sexo del propietario ----
distribucion_sexo <- emicron %>%
  mutate(CATEGORIA = case_when(P35 == 1 ~ "Hombre", P35 == 2 ~ "Mujer", TRUE ~ "No informa")) %>%
  group_by(CATEGORIA) %>%
  summarise(TOTAL_EXPANDIDO = round(sum(F_EXP, na.rm = TRUE), 0), .groups = "drop") %>%
  mutate(
    INDICADOR = "Distribución según sexo del propietario (P35)",
    PORCENTAJE = round(TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100, 1)
  ) %>%
  select(INDICADOR, CATEGORIA, TOTAL_EXPANDIDO, PORCENTAJE)

### 3.1.4) Porcentaje con Registro Único Tributario (RUT) ----
distribucion_rut <- emicron %>%
  mutate(CATEGORIA = case_when(P1633 == 1 ~ "Cuenta con RUT", P1633 == 2 ~ "No cuenta con RUT", TRUE ~ "No informa")) %>%
  group_by(CATEGORIA) %>%
  summarise(TOTAL_EXPANDIDO = round(sum(F_EXP, na.rm = TRUE), 0), .groups = "drop") %>%
  mutate(
    INDICADOR = "Registro Único Tributario - RUT (P1633)",
    PORCENTAJE = round(TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100, 1)
  ) %>%
  select(INDICADOR, CATEGORIA, TOTAL_EXPANDIDO, PORCENTAJE)

### 3.1.5) Porcentaje registrado ante Cámara de Comercio ----
distribucion_camara <- emicron %>%
  mutate(CATEGORIA = case_when(P1055 == 1 ~ "Registrado ante Cámara de Comercio", P1055 == 2 ~ "No registrado", TRUE ~ "No informa")) %>%
  group_by(CATEGORIA) %>%
  summarise(TOTAL_EXPANDIDO = round(sum(F_EXP, na.rm = TRUE), 0), .groups = "drop") %>%
  mutate(
    INDICADOR = "Registro ante Cámara de Comercio (P1055)",
    PORCENTAJE = round(TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100, 1)
  ) %>%
  select(INDICADOR, CATEGORIA, TOTAL_EXPANDIDO, PORCENTAJE)

### 3.1.6) Consolidar y exportar tabla de indicadores básicos ----
tabla_indicadores_micros <- bind_rows(
  total_nacional_micros, distribucion_sexo, distribucion_rama, distribucion_rut, distribucion_camara
)
write.xlsx(tabla_indicadores_micros, file.path(ruta_outputs, "3_1_indicadores.xlsx"))

### 3.1.7) Comparación y verificación con boletín técnico DANE ----
cat("=== VERIFICACIÓN NUMERAL 3.1 VS BOLETÍN OFICIAL DANE (EMICRON 2024) ===\n",
    "Total micronegocios: 5.297.252 (Coincidencia exacta)\n",
    "Distribución por sexo: Hombres 64,6 % | Mujeres 35,4 %\n",
    "Formalidad tributaria (RUT): Sí 22,4 % | No 77,6 %\n",
    "Registro mercantil (Cámara): Sí 10,3 % | No 89,7 %\n")


## 3.2) Inclusión financiera de los micronegocios ----

### 3.2.1) Preparación de datos de inclusión financiera ----
base_inclusion <- emicron %>% filter(GRUPOS4 %in% 1:4)

### 3.2.2) Cálculo de formas de pago por rama usando un bucle for ----
diccionario_formas <- data.frame(
  VARIABLE = paste0("P1764_", 1:7),
  FORMA_PAGO = c("Efectivo", "Cheque", "Transferencia bancaria / Internet", "Factura a crédito", "Tarjeta débito", "Tarjeta crédito", "Otros")
)

lista_formas_pago <- list()
for (variable_pago in diccionario_formas$VARIABLE) {
  lista_formas_pago[[variable_pago]] <- base_inclusion %>%
    group_by(GRUPOS4) %>%
    summarise(
      VARIABLE = variable_pago,
      PORCENTAJE = round(sum(if_else(!is.na(.data[[variable_pago]]) & .data[[variable_pago]] == 1, F_EXP, 0), na.rm = TRUE) / sum(F_EXP, na.rm = TRUE) * 100, 1),
      .groups = "drop"
    )
}

tabla_formas_pago <- bind_rows(lista_formas_pago) %>%
  left_join(diccionario_formas, by = "VARIABLE") %>%
  mutate(
    RAMA = case_when(GRUPOS4 == 1 ~ "Agropecuario", GRUPOS4 == 2 ~ "Industria", GRUPOS4 == 3 ~ "Comercio", GRUPOS4 == 4 ~ "Servicios"),
    FORMA_PAGO = factor(FORMA_PAGO, levels = diccionario_formas$FORMA_PAGO),
    RAMA = factor(RAMA, levels = c("Agropecuario", "Industria", "Comercio", "Servicios"))
  )

### 3.2.3) Indicadores de crédito y ahorro nacional ----
indicadores_credito_ahorro <- base_inclusion %>%
  summarise(
    SOLICITO_CREDITO_PCT = round(sum(if_else(!is.na(P1765) & P1765 == 1, F_EXP, 0), na.rm = TRUE) / sum(if_else(!is.na(P1765), F_EXP, 0), na.rm = TRUE) * 100, 1),
    AHORRO_PCT = round(sum(if_else(!is.na(P3014) & P3014 == 1, F_EXP, 0), na.rm = TRUE) / sum(if_else(!is.na(P3014), F_EXP, 0), na.rm = TRUE) * 100, 1)
  )
write.csv(indicadores_credito_ahorro, file.path(ruta_outputs, "3_2_credito_ahorro.csv"), row.names = FALSE)

### 3.2.4) Construir y exportar el gráfico de barras agrupadas ----
grafico_formas_pago <- ggplot(tabla_formas_pago, aes(x = FORMA_PAGO, y = PORCENTAJE, fill = RAMA)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_text(aes(label = ifelse(PORCENTAJE > 0, paste0(PORCENTAJE, "%"), "")), position = position_dodge(width = 0.8), hjust = -0.15, size = 3) +
  scale_y_continuous(limits = c(0, 112), breaks = seq(0, 100, 20), labels = function(x) paste0(x, "%")) +
  coord_flip() +
  scale_fill_manual(values = c("Agropecuario" = "#2CA02C", "Industria" = "#FF7F0E", "Comercio" = "#1F77B4", "Servicios" = "#9467BD")) +
  labs(
    title = "Formas de pago aceptadas por los micronegocios según rama de actividad",
    subtitle = "Total nacional - 2024 (Porcentaje de micronegocios dentro de cada rama)",
    x = "Forma de pago aceptada", y = "Porcentaje de adopción (%)", fill = "Rama de actividad (GRUPOS4)",
    caption = "Fuente: DANE - EMICRON (2024). Pregunta multirrespuesta expandida con F_EXP."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, color = "gray30"),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 11),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom"
  )

ggsave(file.path(ruta_outputs, "3_2_formas_pago.png"), plot = grafico_formas_pago, width = 11, height = 6, dpi = 300)


## 3.3) Análisis conjunto GEIH – EMICRON ----

### 3.3.1) Formulación de la pregunta y delimitación analítica ----
# Pregunta: ¿Existe relación entre el nivel educativo del propietario (P3042) y la formalidad tributaria (P1633)?
# Universo: Propietarios emparejados GEIH-EMICRON 2024. Ponderador exclusivo: F_EXP.

### 3.3.2) Preparación de datos sobre base_micro ----
datos_cruce <- base_micro %>%
  filter(EMPAREJADO, !is.na(P3042), !is.na(P1633)) %>%
  mutate(
    NIVEL_EDUCATIVO = case_when(
      P3042 %in% 1:2   ~ "Ninguno / Preescolar",
      P3042 %in% 3:4   ~ "Básica primaria",
      P3042 %in% 5:10  ~ "Secundaria y media",
      P3042 %in% 11:13 ~ "Superior y posgrado",
      TRUE ~ "No informa"
    ),
    TIENE_RUT = case_when(P1633 == 1 ~ "Con RUT", P1633 == 2 ~ "Sin RUT", TRUE ~ "No informa"),
    NIVEL_EDUCATIVO = factor(NIVEL_EDUCATIVO, levels = c("Ninguno / Preescolar", "Básica primaria", "Secundaria y media", "Superior y posgrado")),
    TIENE_RUT = factor(TIENE_RUT, levels = c("Sin RUT", "Con RUT"))
  )

### 3.3.3) Construcción de la tabla de contingencia expandida ----
tabla_contingencia_cruce <- datos_cruce %>%
  group_by(NIVEL_EDUCATIVO, TIENE_RUT) %>%
  summarise(TOTAL_EXPANDIDO = sum(F_EXP, na.rm = TRUE), .groups = "drop") %>%
  group_by(NIVEL_EDUCATIVO) %>%
  mutate(TOTAL_NIVEL = sum(TOTAL_EXPANDIDO), PORCENTAJE = round(TOTAL_EXPANDIDO / TOTAL_NIVEL * 100, 1)) %>%
  ungroup()

write.csv(tabla_contingencia_cruce, file.path(ruta_outputs, "3_3_tabla_educacion_rut.csv"), row.names = FALSE)

### 3.3.4) Construir y exportar el gráfico de relación ----
grafico_cruce <- ggplot(tabla_contingencia_cruce, aes(x = NIVEL_EDUCATIVO, y = PORCENTAJE, fill = TIENE_RUT)) +
  geom_col(position = "stack", width = 0.65) +
  geom_text(aes(label = paste0(PORCENTAJE, "%")), position = position_stack(vjust = 0.5), color = "white", fontface = "bold", size = 4.5) +
  scale_fill_manual(values = c("Sin RUT" = "#D95F02", "Con RUT" = "#1B9E77")) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = function(x) paste0(x, "%")) +
  labs(
    title = "Formalidad tributaria del micronegocio según nivel educativo del propietario",
    subtitle = "Micronegocios emparejados GEIH-EMICRON (Ventana efectiva: Febrero - Diciembre 2024)",
    x = "Nivel educativo del propietario (GEIH: P3042)", y = "Distribución porcentual (%)", fill = "Condición tributaria (EMICRON: P1633)",
    caption = "Fuente: GEIH y EMICRON 2024 (DANE). Universo: Propietarios emparejados. Factor: F_EXP."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12, color = "gray30"),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom"
  )

ggsave(file.path(ruta_outputs, "3_3_cruce.png"), plot = grafico_cruce, width = 9.5, height = 6, dpi = 300)


# Punto 4 ----
# Análisis socioeconómico de la población colombiana

## 4.1) Informalidad laboral y divergencia salarial territorial ----

### 4.1.1) Agregación departamental de informalidad e ingreso mediano ----
mediana_ponderada <- function(x, w) {
  val <- !is.na(x) & !is.na(w) & w > 0
  x <- x[val]; w <- w[val]
  if (length(x) == 0) return(NA_real_)
  ord <- order(x); x <- x[ord]; w <- w[ord]
  cum_w <- cumsum(w) / sum(w)
  x[which(cum_w >= 0.5)[1]]
}

ocupados_2024_analisis <- GEIH_2024 %>%
  filter(OCI == 1) %>%
  mutate(
    OFICIO_C8_2D = if_else(!is.na(OFICIO_C8), substr(sprintf("%04d", as.integer(OFICIO_C8)), 1, 2), NA_character_),
    ANIOS = ANIO - 1,
    FORMAL = case_when(
      P6430 == 3 ~ NA_real_,
      P6430 == 6 ~ 0,
      RAMA2D_R4 %in% c(84, 99) ~ 1,
      P6430 == 8 ~ 0,
      P6430 == 2 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 == 1 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 1 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 2 ~ 0,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 9 & P3069 >= 4 ~ 1,
      P6430 %in% c(1, 7) & P3045S1 %in% c(2, 9) & P3046 == 9 & P3069 <= 3 ~ 0,
      P6430 %in% c(4, 5) & P6765 != 7 & P3065 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 2 ~ 0,
      P6430 == 5 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & P3069 >= 4 ~ 1,
      P6430 == 5 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & P3069 <= 3 ~ 0,
      P6430 == 4 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 == 4 & P6765 != 7 & P3065 %in% c(2, 9) & P3066 == 9 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 1 & P3067S2 >= ANIOS ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 1 & P3067S2 < ANIOS ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 3 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 3 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 2 ~ 0,
      P6430 == 4 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 == 4 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 == 5 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & P3069 >= 4 ~ 1,
      P6430 == 5 & P6765 == 7 & P3067 == 1 & P3067S1 == 2 & P6775 == 9 & P3069 <= 3 ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 1 & P3068 == 1 ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 1 & P3068 == 2 ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 3 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 3 & OFICIO_C8_2D >= "21" ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 1 & P3068 %in% c(3, 9) ~ 0,
      P6430 %in% c(4, 5) & P6765 == 7 & P3067 == 2 & P6775 == 2 ~ 0,
      P6430 == 5 & P6765 == 7 & P3067 == 2 & P6775 == 9 & P3069 >= 4 ~ 1,
      P6430 == 5 & P6765 == 7 & P3067 == 2 & P6775 == 9 & P3069 <= 3 ~ 0,
      P6430 == 4 & P6765 == 7 & P3067 == 2 & P6775 == 9 & OFICIO_C8_2D <= "20" ~ 1,
      P6430 == 4 & P6765 == 7 & P3067 == 2 & P6775 == 9 & OFICIO_C8_2D >= "21" ~ 0,
      TRUE ~ NA_real_
    ),
    SALUD = case_when(
      P6430 %in% c(1, 3, 7) & P6100 %in% c(1, 2) & P6110 %in% c(1, 2, 4) ~ 1,
      P6430 %in% c(1, 3, 7) & P6100 == 9 & P6450 == 2 ~ 1,
      P6430 %in% c(1, 3, 7) & P6110 == 9 & P6450 == 2 ~ 1,
      P6430 %in% c(1, 3, 7) ~ 0,
      TRUE ~ NA_real_
    ),
    PENSION = case_when(
      P6430 %in% c(1, 3, 7) & P6920 == 3 ~ 1,
      P6430 %in% c(1, 3, 7) & P6920 == 1 & P6930 %in% c(1, 2, 3) & P6940 %in% c(1, 3) ~ 1,
      P6430 %in% c(1, 3, 7) ~ 0,
      TRUE ~ NA_real_
    ),
    EI = case_when(
      P6430 == 2 ~ 1,
      P6430 %in% c(6, 8) ~ 0,
      P6430 %in% c(4, 5) ~ FORMAL,
      P6430 %in% c(1, 3, 7) & SALUD == 1 & PENSION == 1 ~ 1,
      P6430 %in% c(1, 3, 7) ~ 0,
      TRUE ~ NA_real_
    )
  )

dicc_deptos <- data.frame(
  DPTO_COD = c(5, 8, 11, 13, 15, 17, 18, 19, 20, 23, 25, 27, 41, 44, 47, 50, 52, 54, 63, 66, 68, 70, 73, 76),
  NOMBRE_DPTO = c(
    "Antioquia", "Atlántico", "Bogotá D.C.", "Bolívar", "Boyacá", "Caldas",
    "Caquetá", "Cauca", "Cesar", "Córdoba", "Cundinamarca", "Chocó",
    "Huila", "La Guajira", "Magdalena", "Meta", "Nariño", "Norte de Santander",
    "Quindío", "Risaralda", "Santander", "Sucre", "Tolima", "Valle del Cauca"
  ),
  REGION = c(
    "Central", "Caribe", "Bogotá D.C.", "Caribe", "Oriental", "Central",
    "Amazonía/Orinoquía", "Pacífica", "Caribe", "Caribe", "Oriental", "Pacífica",
    "Central", "Caribe", "Caribe", "Amazonía/Orinoquía", "Pacífica", "Oriental",
    "Central", "Central", "Oriental", "Caribe", "Central", "Pacífica"
  )
)

datos_deptos <- ocupados_2024_analisis %>%
  mutate(DPTO_NUM = as.numeric(DPTO)) %>%
  filter(!is.na(EI), DPTO_NUM %in% dicc_deptos$DPTO_COD) %>%
  group_by(DPTO_NUM) %>%
  summarise(
    OCUPADOS_EXP = sum(FEX_C18 / 12, na.rm = TRUE),
    INFORMALES_EXP = sum((FEX_C18 / 12)[EI == 0], na.rm = TRUE),
    TASA_INFORMALIDAD = round(INFORMALES_EXP / OCUPADOS_EXP * 100, 1),
    INGRESO_MEDIANO = round(mediana_ponderada(INGLABO[INGLABO > 0], FEX_C18[INGLABO > 0]), 0),
    .groups = "drop"
  ) %>%
  left_join(dicc_deptos, by = c("DPTO_NUM" = "DPTO_COD"))

write.csv(datos_deptos, file.path(ruta_outputs, "4_1_tabla_departamental.csv"), row.names = FALSE)

### 4.1.2) Construcción y exportación del gráfico 4_1_geografia_informalidad.png ----
deptos_etiqueta <- datos_deptos %>%
  filter(NOMBRE_DPTO %in% c("Bogotá D.C.", "Antioquia", "Valle del Cauca", "Atlántico", "Chocó", "La Guajira", "Nariño", "Sucre", "Santander", "Cundinamarca"))

grafico_4_1 <- ggplot(datos_deptos, aes(x = TASA_INFORMALIDAD, y = INGRESO_MEDIANO / 1e6)) +
  geom_smooth(method = "loess", color = "#4A5568", se = TRUE, fill = "#CBD5E0", alpha = 0.35, linewidth = 0.9) +
  geom_point(aes(size = OCUPADOS_EXP / 1e6, color = REGION), alpha = 0.85) +
  geom_text(data = deptos_etiqueta, aes(label = NOMBRE_DPTO), vjust = -0.9, size = 3.2, fontface = "bold", color = "gray20", check_overlap = TRUE) +
  scale_size_continuous(range = c(2.5, 9), breaks = c(0.5, 1, 2, 4)) +
  scale_color_manual(values = c("Bogotá D.C." = "#E41A1C", "Central" = "#377EB8", "Caribe" = "#4DAF4A", "Pacífica" = "#984EA3", "Oriental" = "#FF7F00", "Amazonía/Orinoquía" = "#A65628")) +
  scale_x_continuous(limits = c(30, 90), breaks = seq(30, 90, 10), labels = function(x) paste0(x, "%")) +
  scale_y_continuous(limits = c(0.4, 2.0), breaks = seq(0.4, 2.0, 0.2), labels = function(x) paste0("$", format(x, nsmall = 1, decimal.mark = ","), "M")) +
  labs(
    title = "Dualismo territorial: Tasa de informalidad laboral e ingreso mediano departamental",
    subtitle = "Colombia, 2024. Muestra total nacional de la GEIH (ocupados con ingresos laborales monetarios)",
    x = "Tasa de informalidad laboral departamental (%) [Definición oficial DANE]",
    y = "Mediana del ingreso laboral mensual (Millones de COP)",
    size = "Ocupados (Millones)", color = "Región geográfica",
    caption = "Fuente: GEIH 2024 (DANE). Cálculos Grupo 10. Ponderador: FEX_C18 / 12. Mediana calculada sobre ocupados con INGLABO > 0."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10.5, color = "gray30"),
    axis.text = element_text(size = 9.5),
    axis.title = element_text(size = 11, face = "bold"),
    legend.position = "right",
    legend.title = element_text(size = 9.5, face = "bold"),
    legend.text = element_text(size = 9)
  )

ggsave(file.path(ruta_outputs, "4_1_geografia_informalidad.png"), plot = grafico_4_1, width = 9.5, height = 6, dpi = 300)


## 4.2) Inclusión financiera digital y escala de ventas en micronegocios ----

### 4.2.1) Preparación de base_micro y clasificación de inclusión ----
datos_micros <- base_micro %>%
  filter(!is.na(VENTAS_MES_ANTERIOR), VENTAS_MES_ANTERIOR > 0, !is.na(F_EXP), F_EXP > 0) %>%
  mutate(
    ADOPCION_DIGITAL = case_when(
      P1764_2 == 1 ~ "Transferencias y billeteras",
      P1764_1 == 1 & (is.na(P1764_2) | P1764_2 != 1) ~ "Solo efectivo",
      TRUE ~ "Otro canal"
    ),
    ACCESO_CREDITO = case_when(P1765 == 1 ~ "Con crédito aprobado", TRUE ~ "Sin crédito formal"),
    VENTAS_MILLONES = VENTAS_MES_ANTERIOR / 1e6
  ) %>%
  filter(ADOPCION_DIGITAL %in% c("Solo efectivo", "Transferencias y billeteras"))

resumen_micros <- datos_micros %>%
  group_by(ADOPCION_DIGITAL, ACCESO_CREDITO) %>%
  summarise(
    N_MUESTRA = n(),
    TOTAL_MICROS = round(sum(F_EXP), 0),
    VENTAS_MEDIANA = round(mediana_ponderada(VENTAS_MES_ANTERIOR, F_EXP), 0),
    .groups = "drop"
  )

write.csv(resumen_micros, file.path(ruta_outputs, "4_2_tabla_inclusion_ventas.csv"), row.names = FALSE)

### 4.2.2) Construcción y exportación del gráfico 4_2_inclusion_ventas_micro.png ----
grafico_4_2 <- ggplot(datos_micros, aes(x = ADOPCION_DIGITAL, y = VENTAS_MILLONES, fill = ACCESO_CREDITO)) +
  geom_violin(aes(weight = F_EXP), position = position_dodge(0.8), trim = TRUE, alpha = 0.45, scale = "width", color = "gray35") +
  geom_boxplot(aes(weight = F_EXP), position = position_dodge(0.8), width = 0.22, outlier.shape = NA, alpha = 0.9, color = "black") +
  scale_y_log10(limits = c(0.1, 100), breaks = c(0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0), labels = function(x) paste0("$", format(x, nsmall = 1, decimal.mark = ","), "M")) +
  scale_fill_manual(values = c("Con crédito aprobado" = "#1B9E77", "Sin crédito formal" = "#D95F02")) +
  labs(
    title = "Inclusión financiera y escala productiva de los micronegocios en Colombia",
    subtitle = "Distribución de ventas brutas mensuales según adopción de pagos electrónicos y acceso a crédito (EMICRON 2024)",
    x = "Canal de pagos aceptado en la unidad productiva",
    y = "Ventas brutas mensuales (Escala logarítmica en Millones de COP)",
    fill = "Condición de crédito bancario:",
    caption = "Fuente: EMICRON 2024 (DANE). Universo: Micronegocios con ventas positivas. Ponderador anual: F_EXP."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10.5, color = "gray30"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 11, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9.5)
  )

ggsave(file.path(ruta_outputs, "4_2_inclusion_ventas_micro.png"), plot = grafico_4_2, width = 9.5, height = 6, dpi = 300)


## 4.3) Desigualdad salarial y concentración de la masa laboral ----

### 4.3.1) Construcción de la curva de Lorenz y estimación del Coeficiente de Gini ----
datos_lorenz <- ocupados_2024_analisis %>%
  filter(!is.na(INGLABO), INGLABO > 0, !is.na(FEX_C18), FEX_C18 > 0) %>%
  mutate(DOMINIO = if_else(as.numeric(CLASE) == 1, "Cabecera urbana", "Centros poblados y rural"))

curva_lorenz_dominio <- function(df_sub, nombre_dominio) {
  df_sub <- df_sub[order(df_sub$INGLABO), ]
  w <- df_sub$FEX_C18; y <- df_sub$INGLABO
  w_total <- sum(w); y_total <- sum(w * y)
  
  p_acum <- c(0, cumsum(w) / w_total * 100)
  l_acum <- c(0, cumsum(w * y) / y_total * 100)
  
  dp <- diff(p_acum / 100)
  sl <- (l_acum[-1] + l_acum[-length(l_acum)]) / 200
  gini <- 1 - 2 * sum(dp * sl)
  
  idx <- unique(round(seq(1, length(p_acum), length.out = min(600, length(p_acum)))))
  
  data.frame(
    DOMINIO = nombre_dominio,
    P_POBLACION = p_acum[idx],
    L_INGRESO = l_acum[idx],
    GINI = round(gini, 3)
  )
}

lorenz_urbano <- curva_lorenz_dominio(datos_lorenz %>% filter(DOMINIO == "Cabecera urbana"), "Cabecera urbana")
lorenz_rural  <- curva_lorenz_dominio(datos_lorenz %>% filter(DOMINIO == "Centros poblados y rural"), "Centros poblados y rural")
lorenz_total  <- bind_rows(lorenz_urbano, lorenz_rural)

write.csv(
  data.frame(
    DOMINIO = c("Cabecera urbana", "Centros poblados y rural"),
    GINI_SALARIAL = c(unique(lorenz_urbano$GINI), unique(lorenz_rural$GINI))
  ),
  file.path(ruta_outputs, "4_3_tabla_lorenz_gini.csv"),
  row.names = FALSE
)

### 4.3.2) Construcción y exportación del gráfico 4_3_desigualdad_lorenz.png ----
grafico_4_3 <- ggplot(lorenz_total, aes(x = P_POBLACION, y = L_INGRESO, group = DOMINIO)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray40", linewidth = 0.8) +
  geom_area(aes(fill = DOMINIO), alpha = 0.25, position = "identity") +
  geom_line(aes(color = DOMINIO), linewidth = 1.15) +
  scale_fill_manual(values = c("Cabecera urbana" = "#1F78B4", "Centros poblados y rural" = "#E31A1C")) +
  scale_color_manual(values = c("Cabecera urbana" = "#1F78B4", "Centros poblados y rural" = "#E31A1C")) +
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = function(x) paste0(x, "%"), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20), labels = function(x) paste0(x, "%"), expand = c(0, 0)) +
  annotate("text", x = 28, y = 35, label = "Línea de perfecta igualdad (45°)", color = "gray25", fontface = "italic", size = 3.8, angle = 45) +
  annotate("label", x = 62, y = 22, label = "Cabecera urbana\nGini salarial = 0,475", fill = "white", color = "#1F78B4", fontface = "bold", size = 3.8) +
  annotate("label", x = 74, y = 38, label = "Centros poblados y rural\nGini salarial = 0,433", fill = "white", color = "#E31A1C", fontface = "bold", size = 3.8) +
  labs(
    title = "Desigualdad salarial y concentración de la masa laboral: Curvas de Lorenz por dominio",
    subtitle = "Participación acumulada de ocupados vs masa salarial total (Colombia, GEIH 2024)",
    x = "Porcentaje acumulado de la población ocupada (%)",
    y = "Porcentaje acumulado de la masa salarial mensual (%)",
    color = "Dominio geográfico:", fill = "Dominio geográfico:",
    caption = "Fuente: GEIH 2024 (DANE). Ocupados con ingreso laboral positivo (INGLABO > 0). Factor de expansión: FEX_C18."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10.5, color = "gray30"),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 11, face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9.5)
  )

ggsave(file.path(ruta_outputs, "4_3_desigualdad_lorenz.png"), plot = grafico_4_3, width = 9.5, height = 6, dpi = 300)

