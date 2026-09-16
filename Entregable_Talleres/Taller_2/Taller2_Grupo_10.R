# TALLER 2 -  CLASE TALLER DE PROGRAMACIÓN EN R
# Grupo 10

# REQUISITOS GENERALES

# El script debe estar organizado por puntos y subpuntos y debe ejecutarse
# completamente desde una sesión limpia de R.

# Debe utilizar una única ruta base declarada al inicio. Todo el código deberá
# funcionar modificando únicamente esa ruta.

# Los microdatos deben estar organizados en las carpetas GEIH_2023, GEIH_2024
# y EMICRON_2024. Solo deben utilizarse los archivos CSV y no deben cambiarse
# sus nombres.

# La carpeta outputs debe contener todas las tablas y gráficas exportadas desde
# R. Los nombres de los archivos deben corresponder al numeral del‘ taller.


# 0) Configuración inicial ----


## 0.1) Limpiar ambiente ----

rm(list = ls())


## 0.2) Librerías ----

library(here)
library(dplyr)


## 0.3) Rutas ----

# Única ruta base

ruta <- here()


# Rutas derivadas

ruta_datos <- paste0(
  ruta,
  "/Datos"
)

ruta_emicron <- paste0(
  ruta_datos,
  "/EMICRON_2024"
)

ruta_outputs <- paste0(
  ruta,
  "/outputs"
)


# Crear carpeta outputs si no existe

if (!dir.exists(ruta_outputs)) {
  dir.create(ruta_outputs)
}


# Verificar ruta

print(ruta)


# 1) Solución ----


## 1.1) Pegue de las bases GEIH ----


### 1.1.1) Años y meses ----

anios <- c(
  "GEIH_2023",
  "GEIH_2024"
)


meses <- c(
  "01_Enero",
  "02_Febrero",
  "03_Marzo",
  "04_Abril",
  "05_Mayo",
  "06_Junio",
  "07_Julio",
  "08_Agosto",
  "09_Septiembre",
  "10_Octubre",
  "11_Noviembre",
  "12_Diciembre"
)


# Llave de identificación de GEIH

llave_geih <- c(
  "DIRECTORIO",
  "SECUENCIA_P",
  "ORDEN"
)


### 1.1.2) Objetos para almacenar resultados ----

bases_anuales <- list()

conteos_modulos <- list()

verificacion_llaves <- list()

verificacion_pegues <- list()

verificacion_eficiencia <- list()

contador <- 1


### 1.1.3) Loop para construir las bases mensuales ----

for (anio in anios) {
  
  bases_mensuales_anio <- list()
  
  
  for (i in 1:12) {
    
    mes <- meses[i]
    
    
    # Ruta correspondiente al año y mes
    
    ruta_mes <- paste0(
      ruta_datos,
      "/",
      anio,
      "/",
      mes
    )
    
    
    # Marzo de 2024 tiene el archivo en singular
    
    archivo_no_ocupados <- "No ocupados.CSV"
    
    if (anio == "GEIH_2024" & mes == "03_Marzo") {
      
      archivo_no_ocupados <- "No ocupado.CSV"
      
    }
    
    
    #### 1.1.3.1) Leer los módulos ----
    
    general <- read.csv(
      paste0(
        ruta_mes,
        "/Características generales, seguridad social en salud y educación.CSV"
      ),
      sep = ";"
    )
    
    
    fuerza <- read.csv(
      paste0(
        ruta_mes,
        "/Fuerza de trabajo.CSV"
      ),
      sep = ";"
    )
    
    
    ocupados <- read.csv(
      paste0(
        ruta_mes,
        "/Ocupados.CSV"
      ),
      sep = ";"
    )
    
    
    no_ocupados <- read.csv(
      paste0(
        ruta_mes,
        "/",
        archivo_no_ocupados
      ),
      sep = ";"
    )
    
    
    #### 1.1.3.2) Guardar número de observaciones ----
    
    conteos_modulos[[contador]] <- data.frame(
      
      ANIO = anio,
      
      MES = mes,
      
      GENERAL = nrow(general),
      
      FUERZA_MODULO = nrow(fuerza),
      
      OCUPADOS = nrow(ocupados),
      
      NO_OCUPADOS = nrow(no_ocupados)
      
    )
    
    
    #### 1.1.3.3) Guardar número original de columnas ----
    
    columnas_general_antes <- ncol(general)
    
    columnas_fuerza_antes <- ncol(fuerza)
    
    columnas_ocupados_antes <- ncol(ocupados)
    
    columnas_no_ocupados_antes <- ncol(no_ocupados)
    
    
    #### 1.1.3.4) Seleccionar variables necesarias ----
    
    # Características generales
    
    general <- general %>%
      select(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN,
        PERIODO,
        MES,
        P3271,
        P3042,
        P6090,
        P6040,
        P6160,
        DPTO,
        AREA,
        CLASE,
        FEX_C18,
        PT,
        
        # Variables adicionales necesarias para formalidad
        P6100,
        P6110
      )
    
    
    # Fuerza de trabajo
    
    fuerza <- fuerza %>%
      select(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN,
        PET,
        FT,
        FFT,
        P6240
      )
    
    
    # Ocupados
    
    ocupados <- ocupados %>%
      select(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN,
        OCI,
        RAMA2D_R4,
        P6430,
        INGLABO,
        P3045S1,
        P3046,
        P3069,
        P6765,
        P3065,
        P3066,
        OFICIO_C8,
        P3067,
        P3067S1,
        P3067S2,
        P6775,
        P3068,
        P6450,
        P6920,
        P6930,
        P6940
      )
    
    
    # No ocupados
    
    no_ocupados <- no_ocupados %>%
      select(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN,
        DSI
      )
    
    
    #### 1.1.3.5) Evidencia de eficiencia ----
    
    verificacion_eficiencia[[contador]] <- data.frame(
      
      ANIO = anio,
      
      MES = mes,
      
      GENERAL_ANTES = columnas_general_antes,
      
      GENERAL_DESPUES = ncol(general),
      
      FUERZA_ANTES = columnas_fuerza_antes,
      
      FUERZA_DESPUES = ncol(fuerza),
      
      OCUPADOS_ANTES = columnas_ocupados_antes,
      
      OCUPADOS_DESPUES = ncol(ocupados),
      
      NO_OCUPADOS_ANTES = columnas_no_ocupados_antes,
      
      NO_OCUPADOS_DESPUES = ncol(no_ocupados)
      
    )
    
    
    #### 1.1.3.6) Homogeneizar las llaves ----
    
    general <- general %>%
      mutate(
        DIRECTORIO = as.character(DIRECTORIO),
        SECUENCIA_P = as.character(SECUENCIA_P),
        ORDEN = as.character(ORDEN)
      )
    
    
    fuerza <- fuerza %>%
      mutate(
        DIRECTORIO = as.character(DIRECTORIO),
        SECUENCIA_P = as.character(SECUENCIA_P),
        ORDEN = as.character(ORDEN)
      )
    
    
    ocupados <- ocupados %>%
      mutate(
        DIRECTORIO = as.character(DIRECTORIO),
        SECUENCIA_P = as.character(SECUENCIA_P),
        ORDEN = as.character(ORDEN)
      )
    
    
    no_ocupados <- no_ocupados %>%
      mutate(
        DIRECTORIO = as.character(DIRECTORIO),
        SECUENCIA_P = as.character(SECUENCIA_P),
        ORDEN = as.character(ORDEN)
      )
    
    
    #### 1.1.3.7) Verificar duplicados ----
    
    duplicados_general <- general %>%
      group_by(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN
      ) %>%
      summarise(
        n = n(),
        .groups = "drop"
      ) %>%
      filter(
        n > 1
      )
    
    
    duplicados_fuerza <- fuerza %>%
      group_by(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN
      ) %>%
      summarise(
        n = n(),
        .groups = "drop"
      ) %>%
      filter(
        n > 1
      )
    
    
    duplicados_ocupados <- ocupados %>%
      group_by(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN
      ) %>%
      summarise(
        n = n(),
        .groups = "drop"
      ) %>%
      filter(
        n > 1
      )
    
    
    duplicados_no_ocupados <- no_ocupados %>%
      group_by(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN
      ) %>%
      summarise(
        n = n(),
        .groups = "drop"
      ) %>%
      filter(
        n > 1
      )
    
    
    verificacion_llaves[[contador]] <- data.frame(
      
      ANIO = anio,
      
      MES = mes,
      
      DUP_GENERAL = nrow(duplicados_general),
      
      DUP_FUERZA = nrow(duplicados_fuerza),
      
      DUP_OCUPADOS = nrow(duplicados_ocupados),
      
      DUP_NO_OCUPADOS = nrow(duplicados_no_ocupados)
      
    )
    
    
    if (
      nrow(duplicados_general) > 0 |
      nrow(duplicados_fuerza) > 0 |
      nrow(duplicados_ocupados) > 0 |
      nrow(duplicados_no_ocupados) > 0
    ) {
      
      stop(
        paste(
          "Se encontraron llaves duplicadas en",
          anio,
          mes
        )
      )
      
    }
    
    
    #### 1.1.3.8) Pegue de los módulos ----
    
    # Características generales es la base del pegue
    
    n_general <- nrow(general)
    
    
    # Pegar fuerza de trabajo
    
    base_mes <- general %>%
      left_join(
        fuerza,
        by = llave_geih
      )
    
    filas_despues_fuerza <- nrow(base_mes)
    
    
    # Pegar ocupados
    
    base_mes <- base_mes %>%
      left_join(
        ocupados,
        by = llave_geih
      )
    
    filas_despues_ocupados <- nrow(base_mes)
    
    
    # Pegar no ocupados
    
    base_mes <- base_mes %>%
      left_join(
        no_ocupados,
        by = llave_geih
      )
    
    filas_despues_no_ocupados <- nrow(base_mes)
    
    
    #### 1.1.3.9) Verificar que los pegues no aumenten filas ----
    
    verificacion_pegues[[contador]] <- data.frame(
      
      ANIO = anio,
      
      MES = mes,
      
      GENERAL = n_general,
      
      DESPUES_FUERZA = filas_despues_fuerza,
      
      DESPUES_OCUPADOS = filas_despues_ocupados,
      
      DESPUES_NO_OCUPADOS = filas_despues_no_ocupados
      
    )
    
    
    if (
      filas_despues_fuerza != n_general |
      filas_despues_ocupados != n_general |
      filas_despues_no_ocupados != n_general
    ) {
      
      stop(
        paste(
          "El pegue modificó el número de filas en",
          anio,
          mes
        )
      )
      
    }
    
    
    #### 1.1.3.10) Crear ANIO ----
    
    base_mes <- base_mes %>%
      mutate(
        ANIO = as.numeric(
          substr(
            as.character(PERIODO),
            1,
            4
          )
        )
      )
    
    
    #### 1.1.3.11) Guardar base mensual ----
    
    bases_mensuales_anio[[i]] <- base_mes
    
    
    cat(
      "Procesado:",
      anio,
      "-",
      mes,
      "\n"
    )
    
    
    contador <- contador + 1
    
  }
  
  
  ### 1.1.4) Construir base anual ----
  
  bases_anuales[[anio]] <- bind_rows(
    bases_mensuales_anio
  )
  
}


### 1.1.5) Construir bases GEIH finales ----

GEIH_2023 <- bases_anuales[["GEIH_2023"]]

GEIH_2024 <- bases_anuales[["GEIH_2024"]]


GEIH <- bind_rows(
  GEIH_2023,
  GEIH_2024
)


# Revisar dimensiones

dim(GEIH_2023)

dim(GEIH_2024)

dim(GEIH)


# Revisar observaciones por año

table(GEIH$ANIO)


### 1.1.6) Tablas de verificación ----

tabla_llaves <- bind_rows(
  verificacion_llaves
)

tabla_pegues <- bind_rows(
  verificacion_pegues
)

tabla_eficiencia <- bind_rows(
  verificacion_eficiencia
)


tabla_llaves

tabla_pegues

tabla_eficiencia


### 1.1.7) Exportar verificaciones ----

write.csv(
  tabla_llaves,
  paste0(
    ruta_outputs,
    "/1_1_verificacion_llaves.csv"
  ),
  row.names = FALSE
)


write.csv(
  tabla_pegues,
  paste0(
    ruta_outputs,
    "/1_1_verificacion_pegues.csv"
  ),
  row.names = FALSE
)


write.csv(
  tabla_eficiencia,
  paste0(
    ruta_outputs,
    "/1_1_eficiencia.csv"
  ),
  row.names = FALSE
)


## 1.2) Descripción general de los datos ----


### 1.2.1) Observaciones por módulo en 2024 ----

tabla_modulos <- bind_rows(
  conteos_modulos
)


tabla_modulos_2024 <- tabla_modulos %>%
  filter(
    ANIO == "GEIH_2024"
  )


tabla_modulos_2024


### 1.2.2) Verificar relación entre módulos ----

# Características generales contiene a todas las personas.
# Fuerza de trabajo contiene a la población en edad de trabajar.
# Ocupados y no ocupados deben dividir esa población.


tabla_modulos_2024 <- tabla_modulos_2024 %>%
  mutate(
    
    GENERAL_MAYOR_PET =
      GENERAL >= FUERZA_MODULO,
    
    PARTICION_PET =
      OCUPADOS + NO_OCUPADOS == FUERZA_MODULO
    
  )


tabla_modulos_2024


### 1.2.3) Verificar relaciones conceptuales del mercado laboral ----

# Conceptualmente:
# PET = Fuerza de trabajo + Fuera de la fuerza de trabajo
# Fuerza de trabajo = Ocupados + Desocupados


tabla_consistencia_laboral_2024 <- GEIH_2024 %>%
  group_by(
    MES
  ) %>%
  summarise(
    
    TOTAL_PET =
      sum(
        PET == 1,
        na.rm = TRUE
      ),
    
    TOTAL_FT =
      sum(
        FT == 1,
        na.rm = TRUE
      ),
    
    TOTAL_FFT =
      sum(
        FFT == 1,
        na.rm = TRUE
      ),
    
    TOTAL_OCI =
      sum(
        OCI == 1,
        na.rm = TRUE
      ),
    
    TOTAL_DSI =
      sum(
        DSI == 1,
        na.rm = TRUE
      ),
    
    .groups = "drop"
    
  ) %>%
  mutate(
    
    PET_IGUAL_FT_MAS_FFT =
      TOTAL_PET == TOTAL_FT + TOTAL_FFT,
    
    FT_IGUAL_OCI_MAS_DSI =
      TOTAL_FT == TOTAL_OCI + TOTAL_DSI
    
  )


tabla_consistencia_laboral_2024


### 1.2.4) Total anual 2024 ----

total_2024 <- data.frame(
  
  ANIO = "GEIH_2024",
  
  MES = "TOTAL_2024",
  
  GENERAL =
    sum(
      tabla_modulos_2024$GENERAL
    ),
  
  FUERZA_MODULO =
    sum(
      tabla_modulos_2024$FUERZA_MODULO
    ),
  
  OCUPADOS =
    sum(
      tabla_modulos_2024$OCUPADOS
    ),
  
  NO_OCUPADOS =
    sum(
      tabla_modulos_2024$NO_OCUPADOS
    ),
  
  GENERAL_MAYOR_PET =
    sum(
      tabla_modulos_2024$GENERAL
    ) >=
    sum(
      tabla_modulos_2024$FUERZA_MODULO
    ),
  
  PARTICION_PET =
    sum(
      tabla_modulos_2024$OCUPADOS
    ) +
    sum(
      tabla_modulos_2024$NO_OCUPADOS
    ) ==
    sum(
      tabla_modulos_2024$FUERZA_MODULO
    )
  
)


tabla_1_2 <- bind_rows(
  tabla_modulos_2024,
  total_2024
)


tabla_1_2


### 1.2.5) Exportar tablas ----

write.csv(
  tabla_1_2,
  paste0(
    ruta_outputs,
    "/1_2_descripcion_geih_2024.csv"
  ),
  row.names = FALSE
)


write.csv(
  tabla_consistencia_laboral_2024,
  paste0(
    ruta_outputs,
    "/1_2_consistencia_laboral_2024.csv"
  ),
  row.names = FALSE
)


## 1.3) Construcción y documentación de la base analítica ----


### 1.3.1) Variables esperadas ----

variables_esperadas <- c(
  
  # Llave
  
  "DIRECTORIO",
  "SECUENCIA_P",
  "ORDEN",
  
  # Características generales
  
  "PERIODO",
  "MES",
  "P3271",
  "P3042",
  "P6090",
  "P6040",
  "P6160",
  "DPTO",
  "AREA",
  "CLASE",
  "FEX_C18",
  "PT",
  
  # Fuerza de trabajo
  
  "PET",
  "FT",
  "FFT",
  "P6240",
  
  # Ocupados
  
  "OCI",
  "RAMA2D_R4",
  "P6430",
  "INGLABO",
  
  # Variables necesarias para formalidad
  
  "P6100",
  "P6110",
  "P3045S1",
  "P3046",
  "P3069",
  "P6765",
  "P3065",
  "P3066",
  "OFICIO_C8",
  "P3067",
  "P3067S1",
  "P3067S2",
  "P6775",
  "P3068",
  "P6450",
  "P6920",
  "P6930",
  "P6940",
  
  # No ocupados
  
  "DSI",
  
  # Variable construida
  
  "ANIO"
  
)


### 1.3.2) Verificar variables de la base ----

verificacion_variables_presentes <- all(
  variables_esperadas %in% names(GEIH)
)


verificacion_variables_adicionales <- all(
  names(GEIH) %in% variables_esperadas
)


verificacion_variables_presentes

verificacion_variables_adicionales


if (
  !verificacion_variables_presentes |
  !verificacion_variables_adicionales
) {
  
  stop(
    "La base analítica no contiene exactamente las variables esperadas."
  )
  
}


### 1.3.3) Diccionario de variables ----

diccionario_variables <- data.frame(
  
  VARIABLE = c(
    
    "DIRECTORIO",
    "SECUENCIA_P",
    "ORDEN",
    "PERIODO",
    "MES",
    "P3271",
    "P3042",
    "P6090",
    "P6040",
    "P6160",
    "DPTO",
    "AREA",
    "CLASE",
    "FEX_C18",
    "PT",
    
    "PET",
    "FT",
    "FFT",
    "P6240",
    
    "OCI",
    "RAMA2D_R4",
    "P6430",
    "INGLABO",
    
    "DSI"
    
  ),
  
  MODULO = c(
    
    rep(
      "Características generales",
      15
    ),
    
    rep(
      "Fuerza de trabajo",
      4
    ),
    
    rep(
      "Ocupados",
      4
    ),
    
    "No ocupados"
    
  ),
  
  DESCRIPCION = c(
    
    "Identificador del directorio",
    "Secuencia del hogar",
    "Número de orden de la persona",
    "Período de la encuesta",
    "Mes de la encuesta",
    "Sexo",
    "Nivel educativo",
    "Afiliación a seguridad social en salud",
    "Edad",
    "Sabe leer y escribir",
    "Departamento",
    "Área geográfica",
    "Clase geográfica",
    "Factor de expansión",
    "Población total",
    
    "Población en edad de trabajar",
    "Población en la fuerza de trabajo",
    "Población fuera de la fuerza de trabajo",
    "Actividad principal",
    
    "Población ocupada",
    "Rama de actividad económica",
    "Posición ocupacional",
    "Ingreso laboral",
    
    "Población desocupada"
    
  ),
  
  CATEGORIA_UNIDAD = c(
    
    "Identificador",
    "Identificador",
    "Identificador",
    "Año y mes",
    "Mes",
    "1 Hombre; 2 Mujer",
    "Categorías educativas",
    "Categorías de afiliación",
    "Años",
    "1 Sí; 2 No",
    "Código",
    "Código",
    "Categoría",
    "Factor de expansión",
    "Indicador",
    
    "Indicador",
    "Indicador",
    "Indicador",
    "Categorías",
    
    "Indicador",
    "Código CIIU Rev. 4",
    "Categorías",
    "Pesos colombianos",
    
    "Indicador"
    
  )
  
)


diccionario_variables


### 1.3.4) Etiquetas para sexo ----

etiquetas_sexo <- data.frame(
  
  P3271 = c(
    1,
    2
  ),
  
  SEXO = c(
    "Hombre",
    "Mujer"
  )
  
)


etiquetas_sexo


### 1.3.5) Etiquetas para posición ocupacional ----

etiquetas_posicion <- data.frame(
  
  P6430 = 1:9,
  
  POSICION_OCUPACIONAL = c(
    
    "Obrero o empleado de empresa particular",
    
    "Obrero o empleado del gobierno",
    
    "Empleado doméstico",
    
    "Trabajador por cuenta propia",
    
    "Patrón o empleador",
    
    "Trabajador familiar sin remuneración",
    
    "Trabajador sin remuneración en empresas de otros hogares",
    
    "Jornalero o peón",
    
    "Otro"
    
  )
  
)


etiquetas_posicion


### 1.3.6) Exportar diccionario ----

write.csv(
  diccionario_variables,
  paste0(
    ruta_outputs,
    "/1_3_diccionario_variables.csv"
  ),
  row.names = FALSE
)


## 1.4) Incorporación de EMICRON 2024 y unión con GEIH ----


### 1.4.1) Leer los módulos de EMICRON ----

# Los archivos de EMICRON se leen con el separador
# predeterminado de read.csv().

emicron_identificacion <- read.csv(
  paste0(
    ruta_emicron,
    "/Módulo de identificación.csv"
  )
)


emicron_caracteristicas <- read.csv(
  paste0(
    ruta_emicron,
    "/Módulo de características del micronegocio.csv"
  )
)


emicron_inclusion <- read.csv(
  paste0(
    ruta_emicron,
    "/Módulo de inclusión financiera.csv"
  )
)


emicron_ventas <- read.csv(
  paste0(
    ruta_emicron,
    "/Módulo de ventas o ingresos.csv"
  )
)


### 1.4.2) Seleccionar variables necesarias ----

emicron_identificacion <- emicron_identificacion %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA,
    COD_DEPTO,
    AREA,
    CLASE_TE,
    P35,
    P241,
    MES_REF,
    GRUPOS4,
    GRUPOS12,
    F_EXP
  )


emicron_caracteristicas <- emicron_caracteristicas %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA,
    P1633,
    P1055
  )


emicron_inclusion <- emicron_inclusion %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA,
    P1764_1,
    P1764_2,
    P1764_3,
    P1764_4,
    P1764_5,
    P1764_6,
    P1764_7,
    P1765,
    P3014
  )


emicron_ventas <- emicron_ventas %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA,
    VENTAS_MES_ANTERIOR
  )


### 1.4.3) Preparar la llave de EMICRON ----

llave_emicron <- c(
  "DIRECTORIO",
  "SECUENCIA_P",
  "SECUENCIA_ENCUESTA"
)


emicron_identificacion <- emicron_identificacion %>%
  mutate(
    DIRECTORIO = as.character(DIRECTORIO),
    SECUENCIA_P = as.character(SECUENCIA_P),
    SECUENCIA_ENCUESTA = as.character(SECUENCIA_ENCUESTA)
  )


emicron_caracteristicas <- emicron_caracteristicas %>%
  mutate(
    DIRECTORIO = as.character(DIRECTORIO),
    SECUENCIA_P = as.character(SECUENCIA_P),
    SECUENCIA_ENCUESTA = as.character(SECUENCIA_ENCUESTA)
  )


emicron_inclusion <- emicron_inclusion %>%
  mutate(
    DIRECTORIO = as.character(DIRECTORIO),
    SECUENCIA_P = as.character(SECUENCIA_P),
    SECUENCIA_ENCUESTA = as.character(SECUENCIA_ENCUESTA)
  )


emicron_ventas <- emicron_ventas %>%
  mutate(
    DIRECTORIO = as.character(DIRECTORIO),
    SECUENCIA_P = as.character(SECUENCIA_P),
    SECUENCIA_ENCUESTA = as.character(SECUENCIA_ENCUESTA)
  )


### 1.4.4) Verificar valores faltantes en la llave ----

tabla_na_llaves_emicron <- data.frame(
  
  MODULO = c(
    "Identificación",
    "Características",
    "Inclusión financiera",
    "Ventas o ingresos"
  ),
  
  NA_DIRECTORIO = c(
    sum(is.na(emicron_identificacion$DIRECTORIO)),
    sum(is.na(emicron_caracteristicas$DIRECTORIO)),
    sum(is.na(emicron_inclusion$DIRECTORIO)),
    sum(is.na(emicron_ventas$DIRECTORIO))
  ),
  
  NA_SECUENCIA_P = c(
    sum(is.na(emicron_identificacion$SECUENCIA_P)),
    sum(is.na(emicron_caracteristicas$SECUENCIA_P)),
    sum(is.na(emicron_inclusion$SECUENCIA_P)),
    sum(is.na(emicron_ventas$SECUENCIA_P))
  ),
  
  NA_SECUENCIA_ENCUESTA = c(
    sum(is.na(emicron_identificacion$SECUENCIA_ENCUESTA)),
    sum(is.na(emicron_caracteristicas$SECUENCIA_ENCUESTA)),
    sum(is.na(emicron_inclusion$SECUENCIA_ENCUESTA)),
    sum(is.na(emicron_ventas$SECUENCIA_ENCUESTA))
  )
  
)


tabla_na_llaves_emicron


if (
  sum(tabla_na_llaves_emicron$NA_DIRECTORIO) > 0 |
  sum(tabla_na_llaves_emicron$NA_SECUENCIA_P) > 0 |
  sum(tabla_na_llaves_emicron$NA_SECUENCIA_ENCUESTA) > 0
) {
  
  stop(
    "Se encontraron valores faltantes en la llave de EMICRON."
  )
  
}


### 1.4.5) Verificar duplicados ----

duplicados_identificacion <- emicron_identificacion %>%
  group_by(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA
  ) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(
    n > 1
  )


duplicados_caracteristicas <- emicron_caracteristicas %>%
  group_by(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA
  ) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(
    n > 1
  )


duplicados_inclusion <- emicron_inclusion %>%
  group_by(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA
  ) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(
    n > 1
  )


duplicados_ventas <- emicron_ventas %>%
  group_by(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA
  ) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(
    n > 1
  )


tabla_llaves_emicron <- data.frame(
  
  MODULO = c(
    "Identificación",
    "Características",
    "Inclusión financiera",
    "Ventas o ingresos"
  ),
  
  LLAVES_DUPLICADAS = c(
    nrow(duplicados_identificacion),
    nrow(duplicados_caracteristicas),
    nrow(duplicados_inclusion),
    nrow(duplicados_ventas)
  )
  
)


tabla_llaves_emicron


if (
  nrow(duplicados_identificacion) > 0 |
  nrow(duplicados_caracteristicas) > 0 |
  nrow(duplicados_inclusion) > 0 |
  nrow(duplicados_ventas) > 0
) {
  
  stop(
    "Se encontraron llaves duplicadas en los módulos de EMICRON."
  )
  
}


### 1.4.6) Construir la base EMICRON ----

n_emicron_original <- nrow(
  emicron_identificacion
)


emicron <- emicron_identificacion %>%
  left_join(
    emicron_caracteristicas,
    by = llave_emicron
  ) %>%
  left_join(
    emicron_inclusion,
    by = llave_emicron
  ) %>%
  left_join(
    emicron_ventas,
    by = llave_emicron
  )


# Verificar que el pegue no aumente las filas

if (nrow(emicron) != n_emicron_original) {
  
  stop(
    "El pegue de los módulos EMICRON aumentó el número de filas."
  )
  
}


dim(emicron)


### 1.4.7) Distribución de SECUENCIA_ENCUESTA ----

tabla_secuencia_encuesta <- emicron %>%
  group_by(
    SECUENCIA_ENCUESTA
  ) %>%
  summarise(
    REGISTROS = n(),
    .groups = "drop"
  ) %>%
  arrange(
    SECUENCIA_ENCUESTA
  )


tabla_secuencia_encuesta


### 1.4.8) Número de propietarios por hogar ----

tabla_propietarios_hogar <- emicron %>%
  group_by(
    DIRECTORIO,
    SECUENCIA_P
  ) %>%
  summarise(
    PROPIETARIOS = n(),
    .groups = "drop"
  ) %>%
  group_by(
    PROPIETARIOS
  ) %>%
  summarise(
    HOGARES = n(),
    .groups = "drop"
  ) %>%
  arrange(
    PROPIETARIOS
  )


tabla_propietarios_hogar


### 1.4.9) Comparar SECUENCIA_ENCUESTA con ORDEN ----

geih_personas <- GEIH %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    ORDEN
  )


comparacion_orden <- emicron %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA
  ) %>%
  left_join(
    geih_personas,
    by = c(
      "DIRECTORIO",
      "SECUENCIA_P"
    )
  ) %>%
  mutate(
    COINCIDE_ORDEN =
      SECUENCIA_ENCUESTA == ORDEN
  )


tabla_orden_persona <- comparacion_orden %>%
  group_by(
    DIRECTORIO,
    SECUENCIA_P,
    SECUENCIA_ENCUESTA
  ) %>%
  summarise(
    COINCIDENCIAS = sum(
      COINCIDE_ORDEN,
      na.rm = TRUE
    ),
    .groups = "drop"
  )


resumen_relacion_orden <- tabla_orden_persona %>%
  summarise(
    
    REGISTROS_EMICRON = n(),
    
    UNA_COINCIDENCIA =
      sum(
        COINCIDENCIAS == 1
      ),
    
    SIN_COINCIDENCIA =
      sum(
        COINCIDENCIAS == 0
      ),
    
    MAS_DE_UNA_COINCIDENCIA =
      sum(
        COINCIDENCIAS > 1
      ),
    
    PORCENTAJE_UNA_COINCIDENCIA =
      round(
        mean(
          COINCIDENCIAS == 1
        ) * 100,
        2
      )
    
  )


resumen_relacion_orden


### 1.4.10) Construir la llave de persona ----

# La comparación anterior permite evaluar empíricamente la relación entre
# SECUENCIA_ENCUESTA y ORDEN. Una coincidencia única muestra que el valor de
# SECUENCIA_ENCUESTA identifica el mismo orden de persona dentro del hogar.
# Si aparecen múltiples coincidencias, la relación sería ambigua y el código
# se detiene antes de construir la llave.

if (resumen_relacion_orden$MAS_DE_UNA_COINCIDENCIA > 0) {
  
  stop(
    "SECUENCIA_ENCUESTA presenta más de una coincidencia con ORDEN."
  )
  
}


if (resumen_relacion_orden$UNA_COINCIDENCIA == 0) {
  
  stop(
    "No se encontró evidencia de correspondencia entre SECUENCIA_ENCUESTA y ORDEN."
  )
  
}


# Con base en la evidencia observada se usa SECUENCIA_ENCUESTA como ORDEN
# para construir la llave de persona entre EMICRON y GEIH.

emicron_persona <- emicron %>%
  mutate(
    ORDEN = SECUENCIA_ENCUESTA
  )


### 1.4.11) Preparar MES_REF ----

# Convertir MES_REF a texto para manejar tanto
# códigos numéricos como nombres de meses.

emicron_persona <- emicron_persona %>%
  mutate(
    
    MES_REF_TEXTO =
      as.character(MES_REF),
    
    MES_REF_NUM = case_when(
      
      MES_REF_TEXTO %in% c(
        "1",
        "ENERO",
        "Enero",
        "enero"
      ) ~ 1,
      
      MES_REF_TEXTO %in% c(
        "2",
        "FEBRERO",
        "Febrero",
        "febrero"
      ) ~ 2,
      
      MES_REF_TEXTO %in% c(
        "3",
        "MARZO",
        "Marzo",
        "marzo"
      ) ~ 3,
      
      MES_REF_TEXTO %in% c(
        "4",
        "ABRIL",
        "Abril",
        "abril"
      ) ~ 4,
      
      MES_REF_TEXTO %in% c(
        "5",
        "MAYO",
        "Mayo",
        "mayo"
      ) ~ 5,
      
      MES_REF_TEXTO %in% c(
        "6",
        "JUNIO",
        "Junio",
        "junio"
      ) ~ 6,
      
      MES_REF_TEXTO %in% c(
        "7",
        "JULIO",
        "Julio",
        "julio"
      ) ~ 7,
      
      MES_REF_TEXTO %in% c(
        "8",
        "AGOSTO",
        "Agosto",
        "agosto"
      ) ~ 8,
      
      MES_REF_TEXTO %in% c(
        "9",
        "SEPTIEMBRE",
        "Septiembre",
        "septiembre"
      ) ~ 9,
      
      MES_REF_TEXTO %in% c(
        "10",
        "OCTUBRE",
        "Octubre",
        "octubre"
      ) ~ 10,
      
      MES_REF_TEXTO %in% c(
        "11",
        "NOVIEMBRE",
        "Noviembre",
        "noviembre"
      ) ~ 11,
      
      MES_REF_TEXTO %in% c(
        "12",
        "DICIEMBRE",
        "Diciembre",
        "diciembre"
      ) ~ 12,
      
      TRUE ~ NA_real_
      
    )
    
  )


table(
  emicron_persona$MES_REF,
  emicron_persona$MES_REF_NUM
)


### 1.4.12) Comparar MES_REF con MES de GEIH ----

comparacion_temporal <- emicron_persona %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    ORDEN,
    MES_REF,
    MES_REF_NUM
  ) %>%
  left_join(
    GEIH %>%
      select(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN,
        ANIO,
        MES
      ),
    by = llave_geih
  ) %>%
  mutate(
    MES_GEIH =
      as.numeric(
        as.character(MES)
      )
  )


n_comparables <- sum(
  !is.na(
    comparacion_temporal$MES_GEIH
  )
)


### 1.4.13) Evaluar relaciones temporales ----

tabla_relacion_meses <- data.frame(
  
  RELACION = c(
    "Mismo mes",
    "Un mes atrás",
    "Un mes adelante"
  ),
  
  COINCIDENCIAS = c(
    
    # Mismo mes
    
    sum(
      comparacion_temporal$MES_REF_NUM ==
        comparacion_temporal$MES_GEIH,
      na.rm = TRUE
    ),
    
    # MES_REF un mes atrás
    
    sum(
      comparacion_temporal$MES_REF_NUM ==
        ifelse(
          comparacion_temporal$MES_GEIH == 1,
          12,
          comparacion_temporal$MES_GEIH - 1
        ),
      na.rm = TRUE
    ),
    
    # MES_REF un mes adelante
    
    sum(
      comparacion_temporal$MES_REF_NUM ==
        ifelse(
          comparacion_temporal$MES_GEIH == 12,
          1,
          comparacion_temporal$MES_GEIH + 1
        ),
      na.rm = TRUE
    )
    
  )
  
)


tabla_relacion_meses <- tabla_relacion_meses %>%
  mutate(
    PORCENTAJE =
      round(
        COINCIDENCIAS /
          n_comparables *
          100,
        2
      )
  )


tabla_relacion_meses


### 1.4.14) Preparar GEIH 2024 ----

geih_2024_micro <- GEIH %>%
  filter(
    ANIO == 2024
  )


duplicados_geih_2024 <- geih_2024_micro %>%
  group_by(
    DIRECTORIO,
    SECUENCIA_P,
    ORDEN
  ) %>%
  summarise(
    n = n(),
    .groups = "drop"
  ) %>%
  filter(
    n > 1
  )


nrow(
  duplicados_geih_2024
)


if (nrow(duplicados_geih_2024) > 0) {
  
  stop(
    "La llave de GEIH 2024 tiene registros duplicados."
  )
  
}


### 1.4.15) Pegue EMICRON - GEIH 2024 ----

n_emicron_antes <- nrow(
  emicron_persona
)


base_micro <- emicron_persona %>%
  left_join(
    geih_2024_micro,
    by = llave_geih
  )


# Verificar que el pegue no aumente las filas

if (nrow(base_micro) != n_emicron_antes) {
  
  stop(
    "El pegue entre EMICRON y GEIH aumentó el número de filas."
  )
  
}


### 1.4.16) Porcentaje de correspondencia ----

base_micro <- base_micro %>%
  mutate(
    EMPAREJADO =
      !is.na(P3271)
  )


resumen_pegue <- base_micro %>%
  summarise(
    
    REGISTROS_EMICRON = n(),
    
    EMPAREJADOS =
      sum(
        EMPAREJADO
      ),
    
    NO_EMPAREJADOS =
      sum(
        !EMPAREJADO
      ),
    
    PORCENTAJE_EMPAREJADO =
      round(
        mean(
          EMPAREJADO
        ) * 100,
        2
      )
    
  )


resumen_pegue


### 1.4.17) Validar sexo, edad y clase ----

validacion_pegue <- base_micro %>%
  filter(
    EMPAREJADO
  ) %>%
  summarise(
    
    COINCIDENCIA_SEXO =
      round(
        mean(
          as.character(P35) ==
            as.character(P3271),
          na.rm = TRUE
        ) * 100,
        2
      ),
    
    COINCIDENCIA_EDAD =
      round(
        mean(
          P241 == P6040,
          na.rm = TRUE
        ) * 100,
        2
      ),
    
    COINCIDENCIA_CLASE =
      round(
        mean(
          as.character(CLASE_TE) ==
            as.character(CLASE),
          na.rm = TRUE
        ) * 100,
        2
      )
    
  )


validacion_pegue


### 1.4.18) Auditoría mensual ----

auditoria_mensual <- base_micro %>%
  group_by(
    MES_REF,
    MES_REF_NUM
  ) %>%
  summarise(
    
    REGISTROS_EMICRON = n(),
    
    EMPAREJADOS =
      sum(
        EMPAREJADO
      ),
    
    PORCENTAJE_CORRESPONDENCIA =
      round(
        mean(
          EMPAREJADO
        ) * 100,
        2
      ),
    
    NO_EMPAREJADOS =
      sum(
        !EMPAREJADO
      ),
    
    .groups = "drop"
    
  ) %>%
  arrange(
    MES_REF_NUM
  )


auditoria_mensual


### 1.4.19) Revisar no emparejados en GEIH 2023 ----

no_emparejados <- base_micro %>%
  filter(
    !EMPAREJADO
  ) %>%
  select(
    DIRECTORIO,
    SECUENCIA_P,
    ORDEN,
    MES_REF,
    MES_REF_NUM
  )


comparacion_2023 <- no_emparejados %>%
  left_join(
    GEIH_2023 %>%
      select(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN,
        MES
      ),
    by = llave_geih
  ) %>%
  mutate(
    EN_GEIH_2023 =
      !is.na(MES)
  )


resumen_fuera_2024 <- comparacion_2023 %>%
  summarise(
    
    NO_EMPAREJADOS_2024 = n(),
    
    ENCONTRADOS_GEIH_2023 =
      sum(
        EN_GEIH_2023
      ),
    
    PORCENTAJE =
      round(
        mean(
          EN_GEIH_2023
        ) * 100,
        2
      )
    
  )


resumen_fuera_2024


### 1.4.20) Relación temporal con GEIH 2023 ----

auditoria_2023 <- comparacion_2023 %>%
  filter(
    EN_GEIH_2023
  ) %>%
  group_by(
    MES_REF,
    MES
  ) %>%
  summarise(
    REGISTROS = n(),
    .groups = "drop"
  )


auditoria_2023


### 1.4.21) Distribución de posición ocupacional ----

distribucion_posicion <- base_micro %>%
  filter(
    EMPAREJADO,
    !is.na(P6430)
  ) %>%
  group_by(
    P6430
  ) %>%
  summarise(
    
    REGISTROS = n(),
    
    TOTAL_EXPANDIDO =
      sum(
        F_EXP,
        na.rm = TRUE
      ),
    
    .groups = "drop"
    
  ) %>%
  mutate(
    
    PORCENTAJE =
      round(
        TOTAL_EXPANDIDO /
          sum(TOTAL_EXPANDIDO) *
          100,
        2
      ),
    
    POSICION_OCUPACIONAL = case_when(
      
      P6430 == 1 ~
        "Obrero o empleado de empresa particular",
      
      P6430 == 2 ~
        "Obrero o empleado del gobierno",
      
      P6430 == 3 ~
        "Empleado doméstico",
      
      P6430 == 4 ~
        "Trabajador por cuenta propia",
      
      P6430 == 5 ~
        "Patrón o empleador",
      
      P6430 == 6 ~
        "Trabajador familiar sin remuneración",
      
      P6430 == 7 ~
        "Trabajador sin remuneración en empresas de otros hogares",
      
      P6430 == 8 ~
        "Jornalero o peón",
      
      P6430 == 9 ~
        "Otro",
      
      TRUE ~
        "No identificado"
      
    )
    
  ) %>%
  arrange(
    desc(PORCENTAJE)
  )


distribucion_posicion


### 1.4.22) Exportar resultados ----

write.csv(
  tabla_na_llaves_emicron,
  paste0(
    ruta_outputs,
    "/1_4_na_llaves_emicron.csv"
  ),
  row.names = FALSE
)


write.csv(
  tabla_llaves_emicron,
  paste0(
    ruta_outputs,
    "/1_4_llaves_emicron.csv"
  ),
  row.names = FALSE
)


write.csv(
  tabla_secuencia_encuesta,
  paste0(
    ruta_outputs,
    "/1_4_secuencia_encuesta.csv"
  ),
  row.names = FALSE
)


write.csv(
  tabla_propietarios_hogar,
  paste0(
    ruta_outputs,
    "/1_4_propietarios_hogar.csv"
  ),
  row.names = FALSE
)


write.csv(
  resumen_relacion_orden,
  paste0(
    ruta_outputs,
    "/1_4_relacion_orden.csv"
  ),
  row.names = FALSE
)


write.csv(
  tabla_relacion_meses,
  paste0(
    ruta_outputs,
    "/1_4_relacion_meses.csv"
  ),
  row.names = FALSE
)


write.csv(
  resumen_pegue,
  paste0(
    ruta_outputs,
    "/1_4_resumen_pegue.csv"
  ),
  row.names = FALSE
)


write.csv(
  validacion_pegue,
  paste0(
    ruta_outputs,
    "/1_4_validacion_pegue.csv"
  ),
  row.names = FALSE
)


write.csv(
  auditoria_mensual,
  paste0(
    ruta_outputs,
    "/1_4_auditoria_mensual.csv"
  ),
  row.names = FALSE
)


write.csv(
  resumen_fuera_2024,
  paste0(
    ruta_outputs,
    "/1_4_fuera_2024.csv"
  ),
  row.names = FALSE
)


write.csv(
  auditoria_2023,
  paste0(
    ruta_outputs,
    "/1_4_auditoria_2023.csv"
  ),
  row.names = FALSE
)


write.csv(
  distribucion_posicion,
  paste0(
    ruta_outputs,
    "/1_4_posicion_ocupacional.csv"
  ),
  row.names = FALSE
)

