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
    
    GENERAL_MAYOR_PET =
      GENERAL >= FUERZA_MODULO,
    
    PARTICION_PET =
      OCUPADOS + NO_OCUPADOS == FUERZA_MODULO
    
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

# Total de las observaciones de los módulos durante 2024.
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
# Establece empíricamente la correspondencia de la persona.
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


if (resumen_relacion_orden$UNA_COINCIDENCIA == 0) {
  
  stop(
    "No se encontró evidencia de correspondencia entre SECUENCIA_ENCUESTA y ORDEN."
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


# Calcula el porcentaje de cada relación temporal.
# Permite comparar las tres hipótesis sobre el período de
# Referencia.
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
    EMPAREJADO =
      !is.na(P3271)
  )


# Cuenta registros emparejados y no emparejados.
# Resume la correspondencia entre EMICRON y GEIH.
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
    EN_GEIH_2023 =
      !is.na(MES)
  )


# Cuenta los no emparejados y los encontrados en GEIH 2023.
# Resume la razón estructural del no emparejamiento.
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
