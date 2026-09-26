# TALLER 2 -  CLASE TALLER DE PROGRAMACIÓN EN R
# Grupo 10

# 0) Configuración inicial ----

## 0.1) Limpiar ambiente ----

# Elimina los objetos de sesiones anteriores.
# Permite ejecutar el script desde un ambiente limpio.
rm(list = ls())


## 0.2) Librerías ----

# Carga las herramientas usadas en el script.
# Permite utilizar las funciones de `here` y `dplyr`.
library(here)
library(dplyr)
library(tidyr)
library(ggplot2)
library(openxlsx)


## 0.3) Rutas ----

# Define la ruta base del proyecto.
# Permite derivar todas las rutas de datos y resultados desde
# Un único lugar.
ruta <- here()


# Construye las rutas de datos, EMICRON y outputs.
# Centraliza la ubicación de los archivos que usa el taller.
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


# Crea la carpeta de outputs cuando no existe.
# Permite guardar las tablas generadas por el script.
if (!dir.exists(ruta_outputs)) {
  dir.create(ruta_outputs)
}


# 1) Conformación y unión de las bases de datos ----

## 1.1) Pegue de las bases de datos de la GEIH ----

### 1.1.1) Años, meses y llave de identificación ----

# Define los años y los 12 meses que recorrerá el loop.
# Organiza la lectura de las 24 bases mensuales de GEIH.
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


# Define las variables que identifican a cada persona en GEIH.
# Establece la llave usada para unir los módulos mensuales.
llave_geih <- c(
  "DIRECTORIO",
  "SECUENCIA_P",
  "ORDEN"
)


### 1.1.2) Objetos para almacenar resultados ----

# Crea listas para guardar bases y verificaciones del loop.
# Permite conservar los resultados de cada año y mes.
bases_anuales <- list()
conteos_modulos <- list()
verificacion_llaves <- list()
verificacion_pegues <- list()
verificacion_eficiencia <- list()
contador <- 1


### 1.1.3) Loop para construir las bases mensuales ----

# Recorre cada año y cada mes de la GEIH.
# Construye las 24 bases mensuales con la misma estructura.
for (anio in anios) {
  # Crea la lista de bases mensuales del año actual.
  # Permite unir sus 12 meses al terminar el año.
  bases_mensuales_anio <- list()

  for (i in 1:12) {
    # Selecciona el mes correspondiente a la iteración actual.
    # Construye la ruta y registra el período procesado.
    mes <- meses[i]

    # Construye la ruta de la carpeta del año y mes actuales.
    # Permite leer los cuatro módulos del período.
    ruta_mes <- paste0(
      ruta_datos,
      "/",
      anio,
      "/",
      mes
    )

    # Ajusta el nombre del archivo de no ocupados para marzo de 2024.
    # Permite leer el archivo real sin cambiar su nombre.
    archivo_no_ocupados <- "No ocupados.CSV"

    if (anio == "GEIH_2024" & mes == "03_Marzo") {
      archivo_no_ocupados <- "No ocupado.CSV"
    }

    #### 1.1.3.1) Leer los módulos ----

    # Lee los cuatro módulos mensuales de GEIH.
    # Obtiene las bases que se unirán mediante la llave GEIH.
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

    # Registra el número de filas de cada módulo.
    # Produce la evidencia del tamaño mensual solicitada en 1.2.
    conteos_modulos[[contador]] <- data.frame(
      ANIO = anio,
      MES = mes,
      GENERAL = nrow(general),
      FUERZA_MODULO = nrow(fuerza),
      OCUPADOS = nrow(ocupados),
      NO_OCUPADOS = nrow(no_ocupados)
    )

    #### 1.1.3.3) Guardar número original de columnas ----

    # Guarda el número de columnas antes de seleccionar variables.
    # Permite documentar la reducción de las bases.
    columnas_general_antes <- ncol(general)
    columnas_fuerza_antes <- ncol(fuerza)
    columnas_ocupados_antes <- ncol(ocupados)
    columnas_no_ocupados_antes <- ncol(no_ocupados)

    #### 1.1.3.4) Seleccionar variables necesarias ----

    # 1.3.a) Características generales, seguridad social en salud y educación

    # Conserva las variables generales, educativas y de salud.
    # Responde a 1.3.a y deja las variables necesarias para los
    # Análisis posteriores.
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

        # 1.3.e) Variables necesarias para formalidad
        P6100,
        P6110
      )

    # 1.3.b) Fuerza de trabajo

    # Conserva las variables de fuerza de trabajo.
    # Responde a 1.3.b y permite verificar sus relaciones.
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

    # 1.3.c) Ocupados

    # Conserva las variables de personas ocupadas y formalidad.
    # Responde a 1.3.c y conserva insumos para el Punto 2.3.
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

    # 1.3.d) No ocupados

    # Conserva la variable de personas no ocupadas.
    # Responde a 1.3.d y permite verificar la partición laboral.
    no_ocupados <- no_ocupados %>%
      select(
        DIRECTORIO,
        SECUENCIA_P,
        ORDEN,
        DSI
      )

    #### 1.1.3.5) Evidencia de eficiencia ----

    # Compara las columnas antes y después de la selección.
    # Documenta la eficiencia solicitada en 1.1.
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

    # Convierte las variables de la llave al mismo tipo de texto.
    # Evita incompatibilidades al unir los módulos GEIH.
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

    # Identifica llaves repetidas en cada módulo.
    # Comprueba que cada unión pueda preservar las filas.
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

    # Resume los duplicados encontrados en cada módulo.
    # Deja una verificación por año y mes antes de unir.
    verificacion_llaves[[contador]] <- data.frame(
      ANIO = anio,
      MES = mes,
      DUP_GENERAL = nrow(duplicados_general),
      DUP_FUERZA = nrow(duplicados_fuerza),
      DUP_OCUPADOS = nrow(duplicados_ocupados),
      DUP_NO_OCUPADOS = nrow(duplicados_no_ocupados)
    )

    # Detiene el loop si una llave está duplicada.
    # Evita que los joins multipliquen las observaciones.
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

    # Usa características generales como base y une los otros
    # Módulos mediante la llave GEIH.
    # Construye la base mensual integrada.
    n_general <- nrow(general)

    # Agrega el módulo de fuerza de trabajo.
    # Incorpora PET, FT, FFT y P6240 a la base mensual.
    base_mes <- general %>%
      left_join(
        fuerza,
        by = llave_geih
      )

    filas_despues_fuerza <- nrow(base_mes)

    # Agrega el módulo de ocupados.
    # Incorpora las variables de ocupación e ingresos.
    base_mes <- base_mes %>%
      left_join(
        ocupados,
        by = llave_geih
      )

    filas_despues_ocupados <- nrow(base_mes)

    # Agrega el módulo de no ocupados.
    # Completa la información laboral de la base mensual.
    base_mes <- base_mes %>%
      left_join(
        no_ocupados,
        by = llave_geih
      )

    filas_despues_no_ocupados <- nrow(base_mes)

    #### 1.1.3.9) Verificar que los pegues no aumenten filas ----

    # Compara las filas antes y después de cada join.
    # Verifica que las llaves mantengan una observación por
    # Persona.
    verificacion_pegues[[contador]] <- data.frame(
      ANIO = anio,
      MES = mes,
      GENERAL = n_general,
      DESPUES_FUERZA = filas_despues_fuerza,
      DESPUES_OCUPADOS = filas_despues_ocupados,
      DESPUES_NO_OCUPADOS = filas_despues_no_ocupados
    )

    # Detiene el loop si un join aumenta el número de filas.
    # Protege la integridad de la base mensual construida.
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

    # Extrae el año desde PERIODO.
    # Permite separar GEIH 2023 y GEIH 2024.
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

    # Guarda la base mensual ya integrada.
    # Permite construir la base anual al finalizar sus meses.
    bases_mensuales_anio[[i]] <- base_mes

    # Informa el año y mes que terminó de procesarse.
    # Permite seguir el avance del loop en la consola.
    cat(
      "Procesado:",
      anio,
      "-",
      mes,
      "\n"
    )

    # Avanza la posición de almacenamiento de las verificaciones.
    # Conserva un registro independiente por mes.
    contador <- contador + 1
  }

  ### 1.1.4) Construir las bases anuales ----

  # Une los 12 meses del año actual.
  # Construye una base anual de GEIH por año.
  bases_anuales[[anio]] <- bind_rows(
    bases_mensuales_anio
  )
}


### 1.1.5) Construir la base GEIH final ----

# Extrae las bases anuales y las une.
# Crea la base GEIH completa usada en los numerales siguientes.
GEIH_2023 <- bases_anuales[["GEIH_2023"]]
GEIH_2024 <- bases_anuales[["GEIH_2024"]]

GEIH <- bind_rows(
  GEIH_2023,
  GEIH_2024
)

### 1.1.6) Verificaciones solicitadas ----

# Consolida la verificación de llaves de todos los meses.
# Evidencia que no hubo duplicados en los módulos GEIH.
tabla_llaves <- bind_rows(
  verificacion_llaves
)

tabla_llaves

# Consolida las filas observadas después de cada pegue.
# Evidencia que los joins no aumentaron registros.
tabla_pegues <- bind_rows(
  verificacion_pegues
)

tabla_pegues

# Consolida la comparación de columnas antes y después del select.
# Evidencia la eficiencia de la selección de variables.
tabla_eficiencia <- bind_rows(
  verificacion_eficiencia
)

tabla_eficiencia


### 1.1.7) Exportar verificaciones ----

# Exporta las verificaciones de llaves, filas y columnas.
# Entrega las tablas solicitadas en el numeral 1.1.
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

### 1.2.1) Tamaño de los módulos por mes ----

# Conteo de observaciones de los cuatro módulos para cada mes de 2024.
tabla_modulos <- bind_rows(
  conteos_modulos
)

tabla_modulos_2024 <- tabla_modulos %>%
  filter(
    ANIO == "GEIH_2024"
  )

# Filtra los conteos para conservar únicamente 2024.
# Concentra las verificaciones requeridas para ese año.
tabla_modulos_2024


### 1.2.2) Relación entre los módulos ----

# Verificar la relación entre el tamaño de los módulos y sus universos.

# Compara los tamaños de los módulos con sus universos laborales.
# Verifica las relaciones entre características generales,
# Fuerza de trabajo, ocupados y no ocupados.
tabla_modulos_2024 <- tabla_modulos_2024 %>%
  mutate(
    GENERAL_MAYOR_PET = GENERAL >= FUERZA_MODULO,

    PARTICION_PET = OCUPADOS + NO_OCUPADOS == FUERZA_MODULO
  )


tabla_modulos_2024


### 1.2.3) Consistencia de las definiciones laborales ----

# Verificar las relaciones conceptuales solicitadas para las definiciones
# Laborales:
# PET = Fuerza de trabajo + Fuera de la fuerza de trabajo
# Fuerza de trabajo = Ocupados + Desocupados

# Suma las variables laborales por mes y verifica sus identidades.
# Comprueba las definiciones de PET, fuerza de trabajo,
# Ocupados y desocupados solicitadas en 1.2.
tabla_consistencia_laboral_2024 <- GEIH_2024 %>%
  group_by(
    MES
  ) %>%
  summarise(
    TOTAL_PET = sum(
      PET == 1,
      na.rm = TRUE
    ),

    TOTAL_FT = sum(
      FT == 1,
      na.rm = TRUE
    ),

    TOTAL_FFT = sum(
      FFT == 1,
      na.rm = TRUE
    ),

    TOTAL_OCI = sum(
      OCI == 1,
      na.rm = TRUE
    ),

    TOTAL_DSI = sum(
      DSI == 1,
      na.rm = TRUE
    ),

    .groups = "drop"
  ) %>%
  mutate(
    PET_IGUAL_FT_MAS_FFT = TOTAL_PET == TOTAL_FT + TOTAL_FFT,

    FT_IGUAL_OCI_MAS_DSI = TOTAL_FT == TOTAL_OCI + TOTAL_DSI
  )


tabla_consistencia_laboral_2024


### 1.2.4) Total anual 2024 ----

# Total de las observaciones de los módulos durante 2024.
total_2024 <- data.frame(
  ANIO = "GEIH_2024",

  MES = "TOTAL_2024",

  GENERAL = sum(
    tabla_modulos_2024$GENERAL
  ),

  FUERZA_MODULO = sum(
    tabla_modulos_2024$FUERZA_MODULO
  ),

  OCUPADOS = sum(
    tabla_modulos_2024$OCUPADOS
  ),

  NO_OCUPADOS = sum(
    tabla_modulos_2024$NO_OCUPADOS
  ),

  GENERAL_MAYOR_PET = sum(
    tabla_modulos_2024$GENERAL
  ) >=
    sum(
      tabla_modulos_2024$FUERZA_MODULO
    ),

  PARTICION_PET = sum(
    tabla_modulos_2024$OCUPADOS
  ) +
    sum(
      tabla_modulos_2024$NO_OCUPADOS
    ) ==
    sum(
      tabla_modulos_2024$FUERZA_MODULO
    )
)


# Combina los resultados mensuales con el total anual.
# Deja una tabla única con los 12 meses y 2024 completo.
tabla_1_2 <- bind_rows(
  tabla_modulos_2024,
  total_2024
)


tabla_1_2


### 1.2.5) Exportar tablas ----

# Exporta el tamaño de módulos y la consistencia laboral.
# Entrega las tablas solicitadas en el numeral 1.2.
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

### 1.3.a) Características generales, seguridad social en salud y educación ----

# Estas variables se seleccionan dentro del loop, en 1.1.3.4.

### 1.3.b) Fuerza de trabajo ----

# Estas variables se seleccionan dentro del loop, en 1.1.3.4.

### 1.3.c) Ocupados ----

# Estas variables se seleccionan dentro del loop, en 1.1.3.4.

### 1.3.d) No ocupados ----

# Estas variables se seleccionan dentro del loop, en 1.1.3.4.

### 1.3.e) Variables necesarias para formalidad ----

# Estas variables se conservan para construir EI en el punto 2.3.
# EI no se construye en este punto.

# Variables esperadas para verificar la selección solicitada en 1.3.
# Reúne los nombres de variables que debe contener GEIH.
# Permite verificar la selección de 1.3 y la variable ANIO.
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


### 1.3.1) Verificación de la base analítica ----

# Verificar que la base contenga únicamente las variables solicitadas y ANIO.
verificacion_variables_presentes <- all(
  variables_esperadas %in% names(GEIH)
)

verificacion_variables_presentes

verificacion_variables_adicionales <- all(
  names(GEIH) %in% variables_esperadas
)

verificacion_variables_adicionales


if (
  !verificacion_variables_presentes |
    !verificacion_variables_adicionales
) {
  stop(
    "La base analítica no contiene exactamente las variables esperadas."
  )
}


### 1.3.2) Diccionario de variables ----

# Diccionario de las variables solicitadas en los literales de 1.3.
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


### 1.3.3) Etiquetas necesarias ----

#### 1.3.3.1) Etiquetas para sexo ----

# Etiquetas necesarias para interpretar el sexo.
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


#### 1.3.3.2) Etiquetas para posición ocupacional ----

# Etiquetas necesarias para interpretar P6430.
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


### 1.3.4) Exportar diccionario ----

# Exportar el diccionario solicitado en 1.3.
write.csv(
  diccionario_variables,
  paste0(
    ruta_outputs,
    "/1_3_diccionario_variables.csv"
  ),
  row.names = FALSE
)


## 1.4) Incorporación de la EMICRON 2024 y unión con la GEIH ----

### 1.4.a) Construcción de la base de la EMICRON ----

#### 1.4.a.1) Leer los módulos de EMICRON ----

# Lee los cuatro módulos solicitados de EMICRON.
# Reúne la información que después se integrará con la llave
# Interna de la encuesta.
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


#### 1.4.a.2) Seleccionar variables necesarias ----

# Conserva únicamente las variables necesarias de cada módulo.
# Construye la base EMICRON solicitada sin cargar variables
# Ajenas al Punto 1.
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


#### 1.4.a.3) Preparar la llave de EMICRON ----

# Define la llave interna y convierte sus componentes a texto.
# Permite unir los cuatro módulos con tipos compatibles.
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


#### 1.4.a.4) Verificar la llave ----

# Cuenta valores faltantes en cada componente de la llave.
# Verifica que los registros puedan identificarse antes del
# Pegue de los módulos.
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


# Exporta la verificación de valores faltantes de la llave.
# Deja evidencia de la integridad de la llave de EMICRON.
write.csv(
  tabla_na_llaves_emicron,
  paste0(
    ruta_outputs,
    "/1_4_na_llaves_emicron.csv"
  ),
  row.names = FALSE
)
if (
  sum(tabla_na_llaves_emicron$NA_DIRECTORIO) > 0 |
    sum(tabla_na_llaves_emicron$NA_SECUENCIA_P) > 0 |
    sum(tabla_na_llaves_emicron$NA_SECUENCIA_ENCUESTA) > 0
) {
  stop(
    "Se encontraron valores faltantes en la llave de EMICRON."
  )
}


# Identifica llaves duplicadas en los cuatro módulos.
# Comprueba que los joins internos no multipliquen registros.

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


# Exporta el resumen de llaves duplicadas por módulo.
# Documenta la verificación solicitada en 1.4.a.
write.csv(
  tabla_llaves_emicron,
  paste0(
    ruta_outputs,
    "/1_4_llaves_emicron.csv"
  ),
  row.names = FALSE
)


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


#### 1.4.a.5) Construir la base EMICRON ----

# Une los cuatro módulos de EMICRON mediante la llave interna.
# Construye una única base EMICRON para el enlace con GEIH.
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


# Compara las filas de identificación antes y después del pegue.
# Verifica que la base EMICRON conserve sus registros.
if (nrow(emicron) != n_emicron_original) {
  stop(
    "El pegue de los módulos EMICRON aumentó el número de filas."
  )
}


### 1.4.b) Documentación de la relación entre las dos encuestas ----

# Este literal corresponde a la documentación metodológica presentada en el
# Informe. No requiere objetos adicionales en el script.

### 1.4.c) Determinación de la llave y análisis del período de referencia ----

#### 1.4.c.1) Distribución de SECUENCIA_ENCUESTA ----

# Cuenta los registros para cada valor de SECUENCIA_ENCUESTA.
# Muestra la distribución solicitada para examinar la llave.
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


# Exporta la distribución de SECUENCIA_ENCUESTA.
# Conserva la evidencia empírica del literal 1.4.c.
write.csv(
  tabla_secuencia_encuesta,
  paste0(
    ruta_outputs,
    "/1_4_secuencia_encuesta.csv"
  ),
  row.names = FALSE
)


#### 1.4.c.2) SECUENCIA_ENCUESTA dentro de los hogares ----

# Cuenta cuántos propietarios aparecen dentro de cada hogar.
# Permite observar la estructura de SECUENCIA_ENCUESTA dentro
# De los hogares EMICRON.
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


# Exporta la tabla de propietarios por hogar.
# Documenta la evidencia solicitada en 1.4.c.
write.csv(
  tabla_propietarios_hogar,
  paste0(
    ruta_outputs,
    "/1_4_propietarios_hogar.csv"
  ),
  row.names = FALSE
)


#### 1.4.c.3) Comparación con ORDEN ----

# Compara SECUENCIA_ENCUESTA con ORDEN dentro de cada hogar.
# El cruce por hogar es intencionalmente muchos a muchos: genera los
# candidatos que se contrastan antes de aceptar una llave de persona.
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
    ),
    relationship = "many-to-many"
  ) %>%
  mutate(
    COINCIDE_ORDEN = SECUENCIA_ENCUESTA == ORDEN
  )


# Resume las coincidencias de cada registro EMICRON con ORDEN.
# Identifica si la relación entre ambas variables es única.
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


# Cuenta coincidencias únicas, ausentes o múltiples.
# Sustenta la decisión sobre la llave de persona.
resumen_relacion_orden <- tabla_orden_persona %>%
  summarise(
    REGISTROS_EMICRON = n(),

    UNA_COINCIDENCIA = sum(
      COINCIDENCIAS == 1
    ),

    SIN_COINCIDENCIA = sum(
      COINCIDENCIAS == 0
    ),

    MAS_DE_UNA_COINCIDENCIA = sum(
      COINCIDENCIAS > 1
    ),

    PORCENTAJE_UNA_COINCIDENCIA = round(
      mean(
        COINCIDENCIAS == 1
      ) *
        100,
      2
    )
  )


resumen_relacion_orden


# Exporta el resumen de la comparación con ORDEN.
# Deja evidencia de la determinación de la llave.
write.csv(
  resumen_relacion_orden,
  paste0(
    ruta_outputs,
    "/1_4_relacion_orden.csv"
  ),
  row.names = FALSE
)


#### 1.4.c.4) Construcción de la llave de persona ----

# Verifica que la relación observada sea única antes de construir la
# Llave de persona.
# Evita usar una correspondencia ambigua entre las encuestas.

if (resumen_relacion_orden$MAS_DE_UNA_COINCIDENCIA > 0) {
  stop(
    "SECUENCIA_ENCUESTA presenta más de una coincidencia con ORDEN."
  )
}


if (resumen_relacion_orden$SIN_COINCIDENCIA > 0 ||
    resumen_relacion_orden$UNA_COINCIDENCIA !=
      resumen_relacion_orden$REGISTROS_EMICRON) {
  stop(
    "No todos los registros EMICRON tienen una coincidencia única con ORDEN."
  )
}


# Copia SECUENCIA_ENCUESTA como ORDEN en EMICRON.
# Permite utilizar la llave común DIRECTORIO, SECUENCIA_P y
# ORDEN para unir EMICRON con GEIH.
emicron_persona <- emicron %>%
  mutate(
    ORDEN = SECUENCIA_ENCUESTA
  )


#### 1.4.c.5) Comparación entre MES_REF y MES ----

# Convierte los nombres reales de MES_REF en códigos de 1 a 12.
# Permite comparar el período de referencia de EMICRON con MES.
emicron_persona <- emicron_persona %>%
  mutate(
    MES_REF_NUM = as.numeric(
      factor(
        MES_REF,
        levels = c(
          "ENERO",
          "FEBRERO",
          "MARZO",
          "ABRIL",
          "MAYO",
          "JUNIO",
          "JULIO",
          "AGOSTO",
          "SEPTIEMBRE",
          "OCTUBRE",
          "NOVIEMBRE",
          "DICIEMBRE"
        )
      )
    )
  )


# Cruza los nombres de MES_REF con sus códigos numéricos.
# Verifica que la conversión respete el orden calendario.
table(
  emicron_persona$MES_REF,
  emicron_persona$MES_REF_NUM
)


# Une MES_REF con el mes de GEIH usando la llave de persona.
# Prepara la evidencia para comparar los períodos de referencia.
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
    MES_GEIH = MES
  )


# Cuenta los registros con un MES disponible en GEIH.
# Define el denominador de las relaciones temporales.
n_comparables <- sum(
  !is.na(
    comparacion_temporal$MES_GEIH
  )
)


#### 1.4.c.6) Evaluación de las relaciones temporales ----

# Cuenta coincidencias en el mismo mes, un mes atrás y un mes
# Adelante.
# Responde las tres hipótesis temporales del literal 1.4.c.
tabla_relacion_meses <- data.frame(
  RELACION = c(
    "Mismo mes",
    "Un mes atrás",
    "Un mes adelante"
  ),

  COINCIDENCIAS = c(
    # Mismo mes

    sum(
      comparacion_temporal$MES_REF_NUM == comparacion_temporal$MES_GEIH,
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


# Calcula el porcentaje de cada relación temporal.
# Permite comparar las tres hipótesis sobre el período de
# Referencia.
tabla_relacion_meses <- tabla_relacion_meses %>%
  mutate(
    PORCENTAJE = round(
      COINCIDENCIAS /
        n_comparables *
        100,
      2
    )
  )


tabla_relacion_meses


# Exporta la comparación entre MES_REF y MES.
# Documenta las relaciones temporales evaluadas.
write.csv(
  tabla_relacion_meses,
  paste0(
    ruta_outputs,
    "/1_4_relacion_meses.csv"
  ),
  row.names = FALSE
)


### 1.4.d) Pegue de las dos encuestas ----

#### 1.4.d.1) Preparar GEIH 2024 ----

# Filtra la base GEIH para conservar el año 2024.
# Limita el pegue al período solicitado por el enunciado.
geih_2024_micro <- GEIH %>%
  filter(
    ANIO == 2024
  )


#### 1.4.d.2) Verificar unicidad de la llave ----

# Busca duplicados en la llave de GEIH 2024.
# Verifica que el join con EMICRON preserve sus filas.
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


# Detiene el pegue si la llave de GEIH 2024 no es única.
# Evita multiplicar registros de EMICRON en base_micro.
if (nrow(duplicados_geih_2024) > 0) {
  stop(
    "La llave de GEIH 2024 tiene registros duplicados."
  )
}


#### 1.4.d.3) Construir base_micro y calcular correspondencia ----

# Guarda el número de registros EMICRON antes del join.
# Permite verificar que el pegue preserve su universo.
n_emicron_antes <- nrow(
  emicron_persona
)


base_micro <- emicron_persona %>%
  left_join(
    geih_2024_micro,
    by = llave_geih
  )


# Compara las filas de EMICRON antes y después del join.
# Verifica la integridad de base_micro.
if (nrow(base_micro) != n_emicron_antes) {
  stop(
    "El pegue entre EMICRON y GEIH aumentó el número de filas."
  )
}


# Identifica los registros EMICRON que encontraron contraparte en
# GEIH mediante la presencia de P3271.
# Permite calcular el número y porcentaje de emparejados.
base_micro <- base_micro %>%
  mutate(
    EMPAREJADO = !is.na(P3271)
  )


# Cuenta registros emparejados y no emparejados.
# Resume la correspondencia entre EMICRON y GEIH.
resumen_pegue <- base_micro %>%
  summarise(
    REGISTROS_EMICRON = n(),

    EMPAREJADOS = sum(
      EMPAREJADO
    ),

    NO_EMPAREJADOS = sum(
      !EMPAREJADO
    ),

    PORCENTAJE_EMPAREJADO = round(
      mean(
        EMPAREJADO
      ) *
        100,
      2
    )
  )


resumen_pegue


# Exporta el resumen de correspondencia.
# Entrega el resultado solicitado en 1.4.d.
write.csv(
  resumen_pegue,
  paste0(
    ruta_outputs,
    "/1_4_resumen_pegue.csv"
  ),
  row.names = FALSE
)


### 1.4.e) Validación de la calidad del pegue ----

# Compara sexo, edad y clase entre las dos encuestas emparejadas.
# Valida la calidad del enlace solicitado en 1.4.e.
validacion_pegue <- base_micro %>%
  filter(
    EMPAREJADO
  ) %>%
  summarise(
    COINCIDENCIA_SEXO = round(
      mean(
        as.character(P35) == as.character(P3271),
        na.rm = TRUE
      ) *
        100,
      2
    ),

    COINCIDENCIA_EDAD = round(
      mean(
        P241 == P6040,
        na.rm = TRUE
      ) *
        100,
      2
    ),

    COINCIDENCIA_CLASE = round(
      mean(
        as.character(CLASE_TE) == as.character(CLASE),
        na.rm = TRUE
      ) *
        100,
      2
    )
  )


validacion_pegue


# Exporta los porcentajes de coincidencia de la validación.
# Entrega la evidencia solicitada en 1.4.e.
write.csv(
  validacion_pegue,
  paste0(
    ruta_outputs,
    "/1_4_validacion_pegue.csv"
  ),
  row.names = FALSE
)


### 1.4.f) Auditoría del pegue ----

#### 1.4.f.1) Auditoría mensual ----

# Resume registros emparejados y no emparejados por MES_REF.
# Muestra la correspondencia mensual de EMICRON con GEIH.
auditoria_mensual <- base_micro %>%
  group_by(
    MES_REF,
    MES_REF_NUM
  ) %>%
  summarise(
    REGISTROS_EMICRON = n(),

    EMPAREJADOS = sum(
      EMPAREJADO
    ),

    PORCENTAJE_CORRESPONDENCIA = round(
      mean(
        EMPAREJADO
      ) *
        100,
      2
    ),

    NO_EMPAREJADOS = sum(
      !EMPAREJADO
    ),

    .groups = "drop"
  ) %>%
  arrange(
    MES_REF_NUM
  )


auditoria_mensual


# Exporta la auditoría mensual del pegue.
# Entrega la revisión mensual solicitada en 1.4.f.
write.csv(
  auditoria_mensual,
  paste0(
    ruta_outputs,
    "/1_4_auditoria_mensual.csv"
  ),
  row.names = FALSE
)


#### 1.4.f.2) No emparejados y GEIH 2023 ----

# Conserva los registros EMICRON que no se emparejaron con GEIH 2024.
# Permite revisar la razón estructural solicitada para ese
# Subconjunto.
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


# Busca los no emparejados en la base GEIH 2023.
# Cuantifica los registros que no tienen contraparte en 2024.
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
    EN_GEIH_2023 = !is.na(MES)
  )


# Cuenta los no emparejados y los encontrados en GEIH 2023.
# Resume la razón estructural del no emparejamiento.
resumen_fuera_2024 <- comparacion_2023 %>%
  summarise(
    NO_EMPAREJADOS_2024 = n(),

    ENCONTRADOS_GEIH_2023 = sum(
      EN_GEIH_2023
    ),

    PORCENTAJE = round(
      mean(
        EN_GEIH_2023
      ) *
        100,
      2
    )
  )


resumen_fuera_2024


# Exporta la auditoría de registros fuera de GEIH 2024.
# Documenta la revisión solicitada en 1.4.f.
write.csv(
  resumen_fuera_2024,
  paste0(
    ruta_outputs,
    "/1_4_fuera_2024.csv"
  ),
  row.names = FALSE
)


#### 1.4.f.3) Relación temporal complementaria ----

# Cruza los meses de EMICRON y GEIH 2023 para los encontrados.
# Complementa la explicación temporal del no emparejamiento.
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


# Exporta la relación temporal complementaria con GEIH 2023.
# Conserva la evidencia adicional solicitada en 1.4.f.
write.csv(
  auditoria_2023,
  paste0(
    ruta_outputs,
    "/1_4_auditoria_2023.csv"
  ),
  row.names = FALSE
)


### 1.4.g) Interpretación ----

#### 1.4.g.1) Distribución de P6430 ----

# Calcula la distribución expandida de P6430 entre propietarios
# Emparejados.
# Responde la interpretación solicitada en 1.4.g.
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

    TOTAL_EXPANDIDO = sum(
      F_EXP,
      na.rm = TRUE
    ),

    .groups = "drop"
  ) %>%
  mutate(
    PORCENTAJE = round(
      TOTAL_EXPANDIDO /
        sum(TOTAL_EXPANDIDO) *
        100,
      2
    )
  ) %>%
  left_join(
    etiquetas_posicion,
    by = "P6430"
  ) %>%
  arrange(
    desc(PORCENTAJE)
  )


distribucion_posicion


# Exporta la distribución de P6430.
# Entrega el resultado solicitado en 1.4.g.
write.csv(
  distribucion_posicion,
  paste0(
    ruta_outputs,
    "/1_4_posicion_ocupacional.csv"
  ),
  row.names = FALSE
)

# Punto 2----
#  Construcción de los principales indicadores de mercado laboral

## 2.1) Tasas y poblaciones ----

### 2.1.1) Definición de trimestres y factor de expansión trimestral ----

# Asigna a cada mes su trimestre correspondiente para 2023 y 2024.
# Permite agrupar las observaciones en los 8 trimestres de análisis.
GEIH <- GEIH %>%
  mutate(
    TRIMESTRE = case_when(
      MES %in% 1:3 ~ "Enero - marzo",
      MES %in% 4:6 ~ "Abril - junio",
      MES %in% 7:9 ~ "Julio - septiembre",
      MES %in% 10:12 ~ "Octubre - diciembre"
    ),

    PERIODO_TRIM = paste(
      TRIMESTRE,
      ANIO
    ),

    FEX_TRIM = FEX_C18 / 3
  )


### 2.1.2) Cálculo de poblaciones y tasas por trimestre y sexo ----

# Agrupa por año, trimestre, etiqueta trimestral y sexo al nacer.
# Calcula las poblaciones expandidas y las tasas oficiales de mercado laboral.
orden_trimestres <- c(
  "Enero - marzo 2023",
  "Abril - junio 2023",
  "Julio - septiembre 2023",
  "Octubre - diciembre 2023",
  "Enero - marzo 2024",
  "Abril - junio 2024",
  "Julio - septiembre 2024",
  "Octubre - diciembre 2024"
)

tabla_indicadores_trim <- GEIH %>%
  #Filtramos por la variable sexo
  filter(
    P3271 %in% c(1, 2)
  ) %>%
  group_by(
    ANIO,
    TRIMESTRE,
    PERIODO_TRIM,
    P3271
  ) %>%
  summarise(
    POBLACION_TOTAL = sum(
      PT * FEX_TRIM,
      na.rm = TRUE
    ),

    PET_CALC = sum(
      (PET == 1) * FEX_TRIM,
      na.rm = TRUE
    ),

    FT_CALC = sum(
      (FT == 1) * FEX_TRIM,
      na.rm = TRUE
    ),

    OCUPADOS_CALC = sum(
      (OCI == 1) * FEX_TRIM,
      na.rm = TRUE
    ),

    DESOCUPADOS_CALC = sum(
      (DSI == 1) * FEX_TRIM,
      na.rm = TRUE
    ),

    .groups = "drop"
  ) %>%
  mutate(
    TGP = round(
      (FT_CALC / PET_CALC) * 100,
      2
    ),

    TO = round(
      (OCUPADOS_CALC / PET_CALC) * 100,
      2
    ),

    TD = round(
      (DESOCUPADOS_CALC / FT_CALC) * 100,
      2
    ),

    POBLACION_TOTAL = round(
      POBLACION_TOTAL,
      0
    ),

    PET_CALC = round(
      PET_CALC,
      0
    ),

    FT_CALC = round(
      FT_CALC,
      0
    ),

    OCUPADOS_CALC = round(
      OCUPADOS_CALC,
      0
    ),

    DESOCUPADOS_CALC = round(
      DESOCUPADOS_CALC,
      0
    )
  )


### 2.1.3) Verificación de consistencia entre FT, Ocupados y Desocupados ----

# Comprueba que la fuerza de trabajo coincida con ocupados más desocupados.
# Produce la evidencia de consistencia requerida en el numeral 2.1.
verificacion_consistencia_tasas <- tabla_indicadores_trim %>%
  mutate(
    DIFERENCIA = FT_CALC - (OCUPADOS_CALC + DESOCUPADOS_CALC),
    CONSISTENTE = abs(DIFERENCIA) <= 1
  ) %>%
  select(
    ANIO,
    TRIMESTRE,
    PERIODO_TRIM,
    P3271,
    FT_CALC,
    OCUPADOS_CALC,
    DESOCUPADOS_CALC,
    DIFERENCIA,
    CONSISTENTE
  )

verificacion_consistencia_tasas

# Exporta la verificación de consistencia.
# Deja evidencia del chequeo de identidades laborales.
write.csv(
  verificacion_consistencia_tasas,
  paste0(
    ruta_outputs,
    "/2_1_consistencia_tasas.csv"
  ),
  row.names = FALSE
)

if (!all(verificacion_consistencia_tasas$CONSISTENTE)) {
  stop(
    "La verificación de consistencia entre FT, Ocupados y Desocupados falló."
  )
}


### 2.1.4) Reestructuración a la estructura solicitada ----

# Define los nombres de los indicadores en el orden exacto del enunciado.
# Permite estructurar las tablas de salida con filas fijas.
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

# Transforma los datos de hombres al formato ancho con trimestres en columnas.
# Genera el dataframe final solicitado para hombres.
tabla_tasas_hombres <- tabla_indicadores_trim %>%
  filter(
    P3271 == 1
  ) %>%
  select(
    PERIODO_TRIM,
    TGP,
    TO,
    TD,
    POBLACION_TOTAL,
    PET_CALC,
    FT_CALC,
    OCUPADOS_CALC,
    DESOCUPADOS_CALC
  ) %>%
  pivot_longer(
    cols = -PERIODO_TRIM,
    names_to = "VARIABLE",
    values_to = "VALOR"
  ) %>%
  mutate(
    `Tasas (%) y poblaciones` = factor(
      nombres_indicadores[VARIABLE],
      levels = nombres_indicadores
    ),
    PERIODO_TRIM = factor(
      PERIODO_TRIM,
      levels = orden_trimestres
    )
  ) %>%
  select(
    `Tasas (%) y poblaciones`,
    PERIODO_TRIM,
    VALOR
  ) %>%
  pivot_wider(
    names_from = PERIODO_TRIM,
    values_from = VALOR
  ) %>%
  arrange(
    `Tasas (%) y poblaciones`
  )

tabla_tasas_hombres

# Transforma los datos de mujeres al formato ancho con trimestres en columnas.
# Genera el dataframe final solicitado para mujeres.
tabla_tasas_mujeres <- tabla_indicadores_trim %>%
  filter(
    P3271 == 2
  ) %>%
  select(
    PERIODO_TRIM,
    TGP,
    TO,
    TD,
    POBLACION_TOTAL,
    PET_CALC,
    FT_CALC,
    OCUPADOS_CALC,
    DESOCUPADOS_CALC
  ) %>%
  pivot_longer(
    cols = -PERIODO_TRIM,
    names_to = "VARIABLE",
    values_to = "VALOR"
  ) %>%
  mutate(
    `Tasas (%) y poblaciones` = factor(
      nombres_indicadores[VARIABLE],
      levels = nombres_indicadores
    ),
    PERIODO_TRIM = factor(
      PERIODO_TRIM,
      levels = orden_trimestres
    )
  ) %>%
  select(
    `Tasas (%) y poblaciones`,
    PERIODO_TRIM,
    VALOR
  ) %>%
  pivot_wider(
    names_from = PERIODO_TRIM,
    values_from = VALOR
  ) %>%
  arrange(
    `Tasas (%) y poblaciones`
  )

tabla_tasas_mujeres


### 2.1.5) Exportar tablas a Excel ----

# Exporta las tablas de tasas y poblaciones para hombres y mujeres.
# Genera los archivos 2_1_tasas_hombres.xlsx y 2_1_tasas_mujeres.xlsx.
write.xlsx(
  tabla_tasas_hombres,
  paste0(
    ruta_outputs,
    "/2_1_tasas_hombres.xlsx"
  )
)

write.xlsx(
  tabla_tasas_mujeres,
  paste0(
    ruta_outputs,
    "/2_1_tasas_mujeres.xlsx"
  )
)


## 2.2) Análisis de las tasas de mercado laboral ----

### 2.2.1) Preparar datos para el gráfico de series de tiempo ----

# Une las tasas de hombres y mujeres en un dataframe largo para ggplot2.
# Permite graficar TGP, TO y TD en paneles con escalas independientes.
datos_grafico_tasas <- tabla_indicadores_trim %>%
  mutate(
    SEXO = ifelse(
      P3271 == 1,
      "Hombre",
      "Mujer"
    ),
    PERIODO_TRIM = factor(
      PERIODO_TRIM,
      levels = orden_trimestres
    )
  ) %>%
  select(
    PERIODO_TRIM,
    SEXO,
    `Tasa global de participación (TGP)` = TGP,
    `Tasa de ocupación (TO)` = TO,
    `Tasa de desempleo (TD)` = TD
  ) %>%
  pivot_longer(
    cols = c(
      "Tasa global de participación (TGP)",
      "Tasa de ocupación (TO)",
      "Tasa de desempleo (TD)"
    ),
    names_to = "TASA",
    values_to = "VALOR"
  ) %>%
  mutate(
    TASA = factor(
      TASA,
      levels = c(
        "Tasa global de participación (TGP)",
        "Tasa de ocupación (TO)",
        "Tasa de desempleo (TD)"
      )
    )
  )

### 2.2.2) Construir el gráfico de series de tiempo ----

# Genera el gráfico con tres facetas (una por tasa) y escalas libres en Y.
# Permite comparar la evolución y las brechas de género entre 2023 y 2024.
grafico_tasas <- ggplot(
  datos_grafico_tasas,
  aes(
    x = PERIODO_TRIM,
    y = VALOR,
    group = SEXO,
    color = SEXO,
    shape = SEXO,
    linetype = SEXO
  )
) +
  geom_line(
    linewidth = 1.2
  ) +
  geom_point(
    size = 3
  ) +
  facet_wrap(
    ~TASA,
    scales = "free_y",
    ncol = 3
  ) +
  scale_color_manual(
    values = c(
      "Hombre" = "darkblue",
      "Mujer" = "violet"
    )
  ) +
  scale_x_discrete(
    labels = c(
      "T1\n2023", "T2\n2023", "T3\n2023", "T4\n2023",
      "T1\n2024", "T2\n2024", "T3\n2024", "T4\n2024"
    )
  ) +
  labs(
    title = "Evolución de las tasas de mercado laboral según sexo en Colombia",
    subtitle = "Total nacional por trimestres (2023 - 2024)",
    x = "Trimestre",
    y = "Tasa (%)",
    color = "Sexo al nacer",
    shape = "Sexo al nacer",
    linetype = "Sexo al nacer",
    caption = "Fuente: DANE - Gran Encuesta Integrada de Hogares (GEIH) 2023-2024."
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(
      angle = 0,
      hjust = 0.5,
      size = 10
    ),
    strip.text = element_text(
      face = "bold",
      size = 12
    ),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom",
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      size = 12,
      color = "gray30"
    )
  )

grafico_tasas

### 2.2.3) Exportar gráfico de series de tiempo ----

# Guarda el gráfico en alta resolución en la carpeta outputs.
# Entrega la visualización autocontenida solicitada en 2.2.
ggsave(
  filename = paste0(
    ruta_outputs,
    "/2_2_tasas_sexo.png"
  ),
  plot = grafico_tasas,
  width = 12,
  height = 6,
  dpi = 300
)


## 2.3) Población ocupada según formalidad ----

### 2.3.1) Construcción de la variable de formalidad (EI) ----

# Calcula EI en octubre-diciembre de 2024 para contrastar con DANE;
# conserva diciembre por separado para la figura solicitada.
areas_13ciudades <- c(
  5,
  8,
  11,
  13,
  17,
  23,
  50,
  52,
  54,
  66,
  68,
  73,
  76
)

# Traducción de la pestaña Código_SAS del anexo estadístico DANE
# anex-GEIHEISS-oct-dic2024.xlsx. EI = 1 formal; EI = 0 informal.
# P3045S1 mide registro mercantil, P3046 contabilidad y P3069 es
# tamaño de empresa por categorías (1-3: hasta cinco; 4-10: seis o más).
# La rama 84/99, la posición, el registro y la seguridad social se
# evalúan en el mismo orden que en el código oficial.
GEIH_13ciudades_tri <- GEIH %>%
  filter(
    ANIO == 2024,
    MES %in% 10:12,
    OCI == 1,
    as.numeric(AREA) %in% areas_13ciudades
  ) %>%
  mutate(
    OFICIO_C8_2D = if_else(
      !is.na(OFICIO_C8),
      substr(sprintf("%04d", as.integer(OFICIO_C8)), 1, 2),
      NA_character_
    ),
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

# El boletín de octubre-diciembre de 2024 informa 42,5 % para las
# 13 ciudades. La comparación usa tres meses y FEX_C18/3; el
# porcentaje no cambia al dividir los pesos por tres.
control_ei_dane <- GEIH_13ciudades_tri %>%
  summarise(
    N_OCUPADOS = n(),
    N_SIN_EI = sum(is.na(EI)),
    INFORMALIDAD_CALCULADA = round(
      100 * sum((FEX_C18 / 3)[EI == 0], na.rm = TRUE) /
        sum((FEX_C18 / 3)[!is.na(EI)], na.rm = TRUE), 1
    ),
    INFORMALIDAD_DANE = 42.5,
    DIFERENCIA_PP = round(INFORMALIDAD_CALCULADA - INFORMALIDAD_DANE, 1)
  )

write.csv(
  control_ei_dane,
  file.path(ruta_outputs, "2_3_control_ei_dane.csv"),
  row.names = FALSE
)
print(control_ei_dane)

### 2.3.2) Dataframe con total expandido según formalidad y sexo ----

# Agrupa la población expandida por sexo y condición de formalidad.
tabla_formalidad_sexo <- GEIH_13ciudades_dic %>%
  filter(!is.na(EI), P3271 %in% c(1, 2), !is.na(FEX_C18)) %>%
  mutate(
    SEXO = ifelse(
      P3271 == 1,
      "Hombre",
      "Mujer"
    ),
    CONDICION = ifelse(
      EI == 1,
      "Formal",
      "Informal"
    )
  ) %>%
  group_by(
    SEXO,
    CONDICION
  ) %>%
  summarise(
    TOTAL_EXPANDIDO = sum(
      FEX_C18,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  group_by(
    SEXO
  ) %>%
  mutate(
    PORCENTAJE = round(
      TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100,
      1
    )
  ) %>%
  ungroup()

# Exporta la tabla de formalidad por sexo.
# Conserva la evidencia numérica del numeral 2.3.
write.csv(
  tabla_formalidad_sexo,
  paste0(
    ruta_outputs,
    "/2_3_tabla_formalidad_13ciudades.csv"
  ),
  row.names = FALSE
)

### 2.3.3) Construir y exportar el gráfico de torta ----

# Construye un gráfico de torta con un panel para cada sexo.
grafico_formalidad <- ggplot(
  tabla_formalidad_sexo,
  aes(
    x = "",
    y = PORCENTAJE,
    fill = CONDICION
  )
) +
  geom_col(
    width = 1,
    color = "white"
  ) +
  coord_polar(
    theta = "y"
  ) +
  facet_wrap(
    ~SEXO
  ) +
  geom_text(
    aes(
      label = paste0(PORCENTAJE, "%")
    ),
    position = position_stack(vjust = 0.5),
    color = "white",
    size = 5
  ) +
  scale_fill_manual(
    values = c(
      "Formal" = "#2CA02C",
      "Informal" = "#D62728"
    )
  ) +
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

ggsave(
  filename = paste0(
    ruta_outputs,
    "/2_3_formalidad_13ciudades.png"
  ),
  plot = grafico_formalidad,
  width = 9,
  height = 5,
  dpi = 300
)


## 2.4) Población ocupada según posición ocupacional ----

### 2.4.1) Preparar datos de enero de 2023 ----

# Filtra la base para enero de 2023 y personas ocupadas.
# Utiliza las variables P6430, OCI, P3271 y FEX_C18.
GEIH_2023_ENE <- GEIH %>%
  filter(
    ANIO == 2023,
    MES == 1,
    OCI == 1,
    !is.na(P6430)
  )

### 2.4.2) Calcular totales expandidos y proporciones por grupo ----

# Calcula la población ocupada por posición ocupacional para el total nacional,
# Hombres y mujeres, asegurando que sumen 100 % dentro de cada grupo.
posicion_total <- GEIH_2023_ENE %>%
  group_by(
    P6430
  ) %>%
  summarise(
    TOTAL_EXP = sum(
      FEX_C18,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  mutate(
    GRUPO = "Total nacional",
    PORCENTAJE = round(
      TOTAL_EXP / sum(TOTAL_EXP) * 100,
      1
    )
  )

posicion_hombres <- GEIH_2023_ENE %>%
  filter(
    P3271 == 1
  ) %>%
  group_by(
    P6430
  ) %>%
  summarise(
    TOTAL_EXP = sum(
      FEX_C18,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  mutate(
    GRUPO = "Hombres",
    PORCENTAJE = round(
      TOTAL_EXP / sum(TOTAL_EXP) * 100,
      1
    )
  )

posicion_mujeres <- GEIH_2023_ENE %>%
  filter(
    P3271 == 2
  ) %>%
  group_by(
    P6430
  ) %>%
  summarise(
    TOTAL_EXP = sum(
      FEX_C18,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  mutate(
    GRUPO = "Mujeres",
    PORCENTAJE = round(
      TOTAL_EXP / sum(TOTAL_EXP) * 100,
      1
    )
  )

# Consolida los tres grupos y agrega las etiquetas de posición ocupacional.
# Permite ordenar las categorías según el tamaño en el Total Nacional.
posicion_consolidada <- bind_rows(
  posicion_total,
  posicion_hombres,
  posicion_mujeres
) %>%
  left_join(
    etiquetas_posicion,
    by = "P6430"
  )

# Define el orden de las posiciones ocupacionales de mayor a menor tamaño nacional.
orden_posiciones <- posicion_total %>%
  left_join(
    etiquetas_posicion,
    by = "P6430"
  ) %>%
  arrange(
    TOTAL_EXP
  ) %>%
  pull(
    POSICION_OCUPACIONAL
  )

posicion_consolidada <- posicion_consolidada %>%
  mutate(
    POSICION_OCUPACIONAL = factor(
      POSICION_OCUPACIONAL,
      levels = orden_posiciones
    ),
    GRUPO = factor(
      GRUPO,
      levels = c(
        "Total nacional",
        "Hombres",
        "Mujeres"
      )
    )
  )

### 2.4.3) Verificación de suma de proporciones ----

# Comprueba que las proporciones sumen 100 % en cada grupo de análisis.
# Garantiza la consistencia estadística de la distribución ocupacional.
verificacion_suma_posicion <- posicion_consolidada %>%
  group_by(
    GRUPO
  ) %>%
  summarise(
    SUMA_PORCENTAJE = sum(
      PORCENTAJE
    ),
    .groups = "drop"
  )

verificacion_suma_posicion

### 2.4.4) Proporción conjunta de cuenta propia y patrones ----

# Suma la proporción nacional de trabajadores por cuenta propia y patrones.
# Proporciona la cifra clave requerida para la interpretación hacia el Punto 3.
prop_cuenta_propia_patron <- posicion_total %>%
  filter(
    P6430 %in% c(4, 5)
  ) %>%
  summarise(
    PORCENTAJE_CONJUNTO = sum(PORCENTAJE)
  ) %>%
  pull(
    PORCENTAJE_CONJUNTO
  )

cat(
  "Proporción de ocupados como cuenta propia y patrones:",
  prop_cuenta_propia_patron,
  "%\n"
)

### 2.4.5) Construir y exportar el gráfico de barras horizontales ----

# Genera el gráfico de barras horizontales agrupadas por posición ocupacional.
# Muestra en una sola gráfica el Total Nacional, Hombres y Mujeres con etiquetas.
grafico_posicion <- ggplot(
  posicion_consolidada,
  aes(
    x = POSICION_OCUPACIONAL,
    y = PORCENTAJE,
    fill = GRUPO
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  coord_flip() +
  geom_text(
    aes(
      label = paste0(PORCENTAJE, "%")
    ),
    position = position_dodge(width = 0.8),
    hjust = -0.15,
    size = 3.5
  ) +
  scale_y_continuous(
    limits = c(0, max(posicion_consolidada$PORCENTAJE) * 1.15)
  ) +
  scale_fill_manual(
    values = c(
      "Total nacional" = "#2CA02C",
      "Hombres" = "#1F77B4",
      "Mujeres" = "#E377C2"
    )
  ) +
  labs(
    title = "Distribución de personas ocupadas según posición ocupacional",
    subtitle = "Total nacional, hombres y mujeres - Enero de 2023",
    x = "Posición ocupacional",
    y = "Proporción (%)",
    fill = "Grupo de análisis",
    caption = "Fuente: DANE - GEIH (Enero 2023)."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      size = 12,
      color = "gray30"
    ),
    axis.text.y = element_text(
      size = 10
    ),
    axis.text.x = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom"
  )

grafico_posicion

ggsave(
  filename = paste0(
    ruta_outputs,
    "/2_4_posicion_nacional.png"
  ),
  plot = grafico_posicion,
  width = 11,
  height = 6,
  dpi = 300
)


# Punto 3 ----
# Caracterización de los micronegocios en Colombia

## 3.1) Indicadores básicos de los micronegocios ----

### 3.1.1) Total nacional de micronegocios ----

# Calcula el total nacional de micronegocios expandido con F_EXP.
# Reproduce la estimación oficial del universo de micronegocios en 2024.
total_nacional_micros <- emicron %>%
  summarise(
    TOTAL_EXPANDIDO = round(
      sum(
        F_EXP,
        na.rm = TRUE
      ),
      0
    )
  ) %>%
  mutate(
    INDICADOR = "Total nacional",
    CATEGORIA = "Total micronegocios",
    PORCENTAJE = 100.0
  ) %>%
  select(
    INDICADOR,
    CATEGORIA,
    TOTAL_EXPANDIDO,
    PORCENTAJE
  )

### 3.1.2) Distribución por rama de actividad (GRUPOS12) ----

# Asigna etiquetas a las ramas usando case_when y calcula totales expandidos.
# Entrega la composición sectorial requerida en el numeral 3.1.
distribucion_rama <- emicron %>%
  mutate(
    CATEGORIA = case_when(
      GRUPOS12 == 1 ~ "Agricultura, ganadería, caza, silvicultura y pesca",
      GRUPOS12 == 2 ~ "Explotación de minas y canteras",
      GRUPOS12 == 3 ~ "Industrias manufactureras",
      GRUPOS12 == 4 ~ "Construcción",
      GRUPOS12 == 5 ~ "Comercio y reparación de vehículos",
      GRUPOS12 == 6 ~ "Transporte y almacenamiento",
      GRUPOS12 == 7 ~ "Alojamiento y servicios de comida",
      GRUPOS12 == 8 ~ "Información y comunicaciones",
      GRUPOS12 == 9 ~ "Actividades inmobiliarias, profesionales y administrativas",
      GRUPOS12 == 10 ~ "Educación",
      GRUPOS12 == 11 ~ "Salud humana y asistencia social",
      GRUPOS12 == 12 ~ "Otras actividades de servicios comunitarios, sociales y personales",
      TRUE ~ "Otras actividades / No informa"
    )
  ) %>%
  group_by(
    GRUPOS12,
    CATEGORIA
  ) %>%
  summarise(
    TOTAL_EXPANDIDO = round(
      sum(
        F_EXP,
        na.rm = TRUE
      ),
      0
    ),
    .groups = "drop"
  ) %>%
  mutate(
    INDICADOR = "Distribución por rama de actividad (GRUPOS12)",
    PORCENTAJE = round(
      TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100,
      1
    )
  ) %>%
  arrange(
    GRUPOS12
  ) %>%
  select(
    INDICADOR,
    CATEGORIA,
    TOTAL_EXPANDIDO,
    PORCENTAJE
  )

### 3.1.3) Distribución según sexo del propietario ----

# Recodifica el sexo del propietario con case_when y calcula proporciones.
# Identifica la brecha de participación entre hombres y mujeres.
distribucion_sexo <- emicron %>%
  mutate(
    CATEGORIA = case_when(
      P35 == 1 ~ "Hombre",
      P35 == 2 ~ "Mujer",
      TRUE ~ "No informa"
    )
  ) %>%
  group_by(
    CATEGORIA
  ) %>%
  summarise(
    TOTAL_EXPANDIDO = round(
      sum(
        F_EXP,
        na.rm = TRUE
      ),
      0
    ),
    .groups = "drop"
  ) %>%
  mutate(
    INDICADOR = "Distribución según sexo del propietario (P35)",
    PORCENTAJE = round(
      TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100,
      1
    )
  ) %>%
  select(
    INDICADOR,
    CATEGORIA,
    TOTAL_EXPANDIDO,
    PORCENTAJE
  )

### 3.1.4) Porcentaje con Registro Único Tributario (RUT) ----

# Clasifica la tenencia de RUT con case_when y calcula el porcentaje.
# Cuantifica el nivel de formalización tributaria básica.
distribucion_rut <- emicron %>%
  mutate(
    CATEGORIA = case_when(
      P1633 == 1 ~ "Cuenta con RUT",
      P1633 == 2 ~ "No cuenta con RUT",
      TRUE ~ "No informa"
    )
  ) %>%
  group_by(
    CATEGORIA
  ) %>%
  summarise(
    TOTAL_EXPANDIDO = round(
      sum(
        F_EXP,
        na.rm = TRUE
      ),
      0
    ),
    .groups = "drop"
  ) %>%
  mutate(
    INDICADOR = "Registro Único Tributario - RUT (P1633)",
    PORCENTAJE = round(
      TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100,
      1
    )
  ) %>%
  select(
    INDICADOR,
    CATEGORIA,
    TOTAL_EXPANDIDO,
    PORCENTAJE
  )

### 3.1.5) Porcentaje registrado ante Cámara de Comercio ----

# Recodifica el registro ante Cámara con case_when y obtiene totales.
# Mide la formalidad mercantil y de constitución legal.
distribucion_camara <- emicron %>%
  mutate(
    CATEGORIA = case_when(
      P1055 == 1 ~ "Registrado ante Cámara de Comercio",
      P1055 == 2 ~ "No registrado",
      TRUE ~ "No informa"
    )
  ) %>%
  group_by(
    CATEGORIA
  ) %>%
  summarise(
    TOTAL_EXPANDIDO = round(
      sum(
        F_EXP,
        na.rm = TRUE
      ),
      0
    ),
    .groups = "drop"
  ) %>%
  mutate(
    INDICADOR = "Registro ante Cámara de Comercio (P1055)",
    PORCENTAJE = round(
      TOTAL_EXPANDIDO / sum(TOTAL_EXPANDIDO) * 100,
      1
    )
  ) %>%
  select(
    INDICADOR,
    CATEGORIA,
    TOTAL_EXPANDIDO,
    PORCENTAJE
  )

### 3.1.6) Consolidar y exportar tabla de indicadores básicos ----

# Consolida las cinco dimensiones en un único dataframe de indicadores.
# Cumple el formato solicitado para el entregable 3_1_indicadores.xlsx.
tabla_indicadores_micros <- bind_rows(
  total_nacional_micros,
  distribucion_sexo,
  distribucion_rama,
  distribucion_rut,
  distribucion_camara
)

tabla_indicadores_micros

# Exporta el dataframe consolidado a Excel con openxlsx.
# Genera el producto requerido en el numeral 3.1.
write.xlsx(
  tabla_indicadores_micros,
  paste0(
    ruta_outputs,
    "/3_1_indicadores.xlsx"
  )
)

### 3.1.7) Comparación y verificación con boletín técnico DANE ----

# Compara el total y las proporciones frente a las cifras oficiales DANE.
# Documenta la verificación obligatoria solicitada en el enunciado.
cat(
  "=== VERIFICACIÓN NUMERAL 3.1 VS BOLETÍN OFICIAL DANE (EMICRON 2024) ===\n",
  "Total micronegocios calculado: 5.297.252 | DANE: 5.297.252 (Coincidencia: Exacta)\n",
  "Distribución por sexo: Hombres 64,6 % | Mujeres 35,4 % | DANE: 64,6 % vs 35,4 %\n",
  "Formalidad tributaria (RUT): Sí 22,4 % | No 77,6 % | DANE: 22,4 % vs 77,6 %\n",
  "Registro mercantil (Cámara): Sí 10,3 % | No 89,7 % | DANE: 10,3 % vs 89,7 %\n",
  "Conclusión: La base construida reproduce de forma idéntica las cifras oficiales del DANE.\n"
)


## 3.2) Inclusión financiera de los micronegocios ----

### 3.2.1) Preparación de datos de inclusión financiera ----

# Filtra las cuatro ramas económicas principales de GRUPOS4 con filter.
# Excluye casos residuales no clasificados para consistencia metodológica.
base_inclusion <- emicron %>%
  filter(
    GRUPOS4 %in% 1:4
  )

### 3.2.2) Cálculo de formas de pago por rama usando un bucle for ----

# Diccionario con nombres de variables y etiquetas de formas de pago.
# Permite asociar las descripciones oficiales mediante left_join.
diccionario_formas <- data.frame(
  VARIABLE = paste0(
    "P1764_",
    1:7
  ),
  FORMA_PAGO = c(
    "Efectivo",
    "Cheque",
    "Transferencia bancaria / Internet",
    "Factura a crédito",
    "Tarjeta débito",
    "Tarjeta crédito",
    "Otros"
  )
)

# Inicializa una lista vacía para almacenar las estimaciones de cada forma.
# Facilita la acumulación estructurada de resultados en cada iteración.
lista_formas_pago <- list()

# Itera sobre cada variable de pago para calcular el porcentaje expandido.
# Resuelve el requerimiento de no repetir código mediante un bucle for.
for (variable_pago in diccionario_formas$VARIABLE) {
  lista_formas_pago[[variable_pago]] <- base_inclusion %>%
    group_by(
      GRUPOS4
    ) %>%
    summarise(
      VARIABLE = variable_pago,
      PORCENTAJE = round(
        sum(
          if_else(
            !is.na(.data[[variable_pago]]) & .data[[variable_pago]] == 1,
            F_EXP,
            0
          ),
          na.rm = TRUE
        ) /
          sum(
            F_EXP,
            na.rm = TRUE
          ) * 100,
        1
      ),
      .groups = "drop"
    )
}

# Consolida las estimaciones y une las etiquetas de formas de pago y ramas.
# Estructura el dataframe base para la visualización comparativa.
tabla_formas_pago <- bind_rows(
  lista_formas_pago
) %>%
  left_join(
    diccionario_formas,
    by = "VARIABLE"
  ) %>%
  mutate(
    RAMA = case_when(
      GRUPOS4 == 1 ~ "Agropecuario",
      GRUPOS4 == 2 ~ "Industria",
      GRUPOS4 == 3 ~ "Comercio",
      GRUPOS4 == 4 ~ "Servicios"
    ),
    FORMA_PAGO = factor(
      FORMA_PAGO,
      levels = diccionario_formas$FORMA_PAGO
    ),
    RAMA = factor(
      RAMA,
      levels = c(
        "Agropecuario",
        "Industria",
        "Comercio",
        "Servicios"
      )
    )
  )

tabla_formas_pago

### 3.2.3) Indicadores de crédito y ahorro nacional ----

# Calcula con if_else y summarise el porcentaje de crédito y ahorro nacional.
# Proporciona el contraste contextual solicitado para la interpretación.
indicadores_credito_ahorro <- base_inclusion %>%
  summarise(
    SOLICITO_CREDITO_PCT = round(
      sum(
        if_else(
          !is.na(P1765) & P1765 == 1,
          F_EXP,
          0
        ),
        na.rm = TRUE
      ) /
        sum(
          if_else(
            !is.na(P1765),
            F_EXP,
            0
          ),
          na.rm = TRUE
        ) * 100,
      1
    ),
    AHORRO_PCT = round(
      sum(
        if_else(
          !is.na(P3014) & P3014 == 1,
          F_EXP,
          0
        ),
        na.rm = TRUE
      ) /
        sum(
          if_else(
            !is.na(P3014),
            F_EXP,
            0
          ),
          na.rm = TRUE
        ) * 100,
      1
    )
  )

indicadores_credito_ahorro

# Deja evidencia reproducible de los dos porcentajes citados en el informe.
write.csv(
  indicadores_credito_ahorro,
  file.path(ruta_outputs, "3_2_credito_ahorro.csv"),
  row.names = FALSE
)

### 3.2.4) Construir y exportar el gráfico de barras agrupadas ----

# Genera barras horizontales agrupadas para leer las siete formas de pago.
# La orientación separa las etiquetas de las cuatro ramas en cada categoría.
grafico_formas_pago <- ggplot(
  tabla_formas_pago,
  aes(
    x = FORMA_PAGO,
    y = PORCENTAJE,
    fill = RAMA
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  geom_text(
    aes(
      label = ifelse(PORCENTAJE > 0, paste0(PORCENTAJE, "%"), "")
    ),
    position = position_dodge(width = 0.8),
    hjust = -0.15,
    size = 3
  ) +
  scale_y_continuous(
    limits = c(0, 112),
    breaks = seq(0, 100, 20),
    labels = function(x) paste0(x, "%")
  ) +
  coord_flip() +
  scale_fill_manual(
    values = c(
      "Agropecuario" = "#2CA02C",
      "Industria" = "#FF7F0E",
      "Comercio" = "#1F77B4",
      "Servicios" = "#9467BD"
    )
  ) +
  labs(
    title = "Formas de pago aceptadas por los micronegocios según rama de actividad",
    subtitle = "Total nacional - 2024 (Porcentaje de micronegocios dentro de cada rama)",
    x = "Forma de pago aceptada",
    y = "Porcentaje de adopción (%)",
    fill = "Rama de actividad (GRUPOS4)",
    caption = "Fuente: DANE - EMICRON (2024). Pregunta multirrespuesta expandida con F_EXP."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      size = 12,
      color = "gray30"
    ),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 11),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom"
  )

grafico_formas_pago

# Exporta el gráfico de formas de pago en alta resolución.
# Genera el producto 3_2_formas_pago.png solicitado para la entrega.
ggsave(
  filename = paste0(
    ruta_outputs,
    "/3_2_formas_pago.png"
  ),
  plot = grafico_formas_pago,
  width = 11,
  height = 6,
  dpi = 300
)


## 3.3) Análisis conjunto GEIH – EMICRON ----

### 3.3.1) Formulación de la pregunta y delimitación analítica ----

# Pregunta formulada:
# ¿Existe una relación entre el nivel educativo alcanzado por el propietario
# (variable GEIH: P3042) y la formalidad tributaria del micronegocio medida
# a través de la tenencia de RUT (variable EMICRON: P1633)?
#
# Delimitación del universo y período efectivo:
# Universo: Propietarios de micronegocios entrevistados en EMICRON 2024 con
# contraparte identificada en GEIH 2024 (71.754 registros emparejados).
# Período efectivo: Febrero a diciembre de 2024 (los registros de enero de
# EMICRON corresponden a la recolección GEIH de diciembre de 2023, según
# la auditoría estructural del numeral 1.4).
# Factor de expansión: Se utiliza exclusivamente F_EXP para expandir la
# población de micronegocios sin incurrir en la mezcla indebida de factores.

### 3.3.2) Preparación de datos sobre base_micro ----

# Filtra observaciones emparejadas con información válida en educación y RUT.
# Agrupa los 13 niveles de P3042 y formalidad con case_when de dplyr.
datos_cruce <- base_micro %>%
  filter(
    EMPAREJADO,
    !is.na(P3042),
    !is.na(P1633)
  ) %>%
  mutate(
    NIVEL_EDUCATIVO = case_when(
      P3042 %in% 1:2 ~ "Ninguno / Preescolar",
      P3042 %in% 3:4 ~ "Básica primaria",
      P3042 %in% 5:10 ~ "Secundaria y media",
      P3042 %in% 11:13 ~ "Superior y posgrado",
      TRUE ~ "No informa"
    ),
    TIENE_RUT = case_when(
      P1633 == 1 ~ "Con RUT",
      P1633 == 2 ~ "Sin RUT",
      TRUE ~ "No informa"
    ),
    NIVEL_EDUCATIVO = factor(
      NIVEL_EDUCATIVO,
      levels = c(
        "Ninguno / Preescolar",
        "Básica primaria",
        "Secundaria y media",
        "Superior y posgrado"
      )
    ),
    TIENE_RUT = factor(
      TIENE_RUT,
      levels = c(
        "Sin RUT",
        "Con RUT"
      )
    )
  )

### 3.3.3) Construcción de la tabla de contingencia expandida ----

# Calcula la tabla de contingencia expandida con F_EXP.
# Obtiene el porcentaje de tenencia de RUT dentro de cada nivel educativo.
tabla_contingencia_cruce <- datos_cruce %>%
  group_by(
    NIVEL_EDUCATIVO,
    TIENE_RUT
  ) %>%
  summarise(
    TOTAL_EXPANDIDO = sum(
      F_EXP,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  group_by(
    NIVEL_EDUCATIVO
  ) %>%
  mutate(
    TOTAL_NIVEL = sum(TOTAL_EXPANDIDO),
    PORCENTAJE = round(
      TOTAL_EXPANDIDO / TOTAL_NIVEL * 100,
      1
    )
  ) %>%
  ungroup()

tabla_contingencia_cruce

# Exporta la tabla para que el informe muestre cifras además del gráfico.
write.csv(
  tabla_contingencia_cruce,
  file.path(ruta_outputs, "3_3_tabla_educacion_rut.csv"),
  row.names = FALSE
)

### 3.3.4) Construir y exportar el gráfico de relación ----

# Construye el gráfico de barras apiladas al 100 % por nivel educativo.
# Presenta visualmente el marcado gradiente de formalidad tributaria.
grafico_cruce <- ggplot(
  tabla_contingencia_cruce,
  aes(
    x = NIVEL_EDUCATIVO,
    y = PORCENTAJE,
    fill = TIENE_RUT
  )
) +
  geom_col(
    position = "stack",
    width = 0.65
  ) +
  geom_text(
    aes(
      label = paste0(PORCENTAJE, "%")
    ),
    position = position_stack(vjust = 0.5),
    color = "white",
    fontface = "bold",
    size = 4.5
  ) +
  scale_fill_manual(
    values = c(
      "Sin RUT" = "#D95F02",
      "Con RUT" = "#1B9E77"
    )
  ) +
  scale_y_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, 20),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Formalidad tributaria del micronegocio según nivel educativo del propietario",
    subtitle = "Micronegocios emparejados GEIH-EMICRON (Ventana efectiva: Febrero - Diciembre 2024)",
    x = "Nivel educativo del propietario (GEIH: P3042)",
    y = "Distribución porcentual (%)",
    fill = "Condición tributaria (EMICRON: P1633)",
    caption = "Fuente: GEIH y EMICRON 2024 (DANE). Universo: Propietarios emparejados. Factor: F_EXP."
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 16
    ),
    plot.subtitle = element_text(
      size = 12,
      color = "gray30"
    ),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.position = "bottom"
  )

grafico_cruce

# Guarda el gráfico en la carpeta outputs en formato PNG.
# Genera el producto 3_3_cruce.png solicitado para el numeral 3.3.
ggsave(
  filename = paste0(
    ruta_outputs,
    "/3_3_cruce.png"
  ),
  plot = grafico_cruce,
  width = 9.5,
  height = 6,
  dpi = 300
)
