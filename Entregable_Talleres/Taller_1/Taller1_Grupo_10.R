# Taller 1 - Programacion en R
# Grupo: NUMERO
# Integrantes: COMPLETAR
# Fecha de entrega: 31 de agosto de 2026

# NIVEL 1 - BASICO ----------------------------------------------------------

## Ejercicio 1 ---------------------------------------------------------------

# Codigos
# Miguelangel Palma: 202621481
# Sergio Lopez: 202111932
# Juan Jose Echeverry: 202616233

cod_palma <- 202621481
cod_lopez <- 202111932
cod_echeverry <- 202616233

seed <- (cod_palma + cod_lopez + cod_echeverry) / 3

set.seed(seed)

# Comentarios
# (i) Para garantizar la reproducibilidad. Dado que al manejar numeros aleatorios,
#  un semilla nos ayuda a fijar la misma generacion de los numeros
# (ii) Si los resultados no se fijan, puede generar errores operativos y entre otros dado que no se garantiza una reproducibilidad de analisis
# (iii) Toda generacion apartado que tenga variables aleatorias o modelos estocasticos

## Ejercicio 2 ---------------------------------------------------------------

# Parametros
n <- 1000 # Tamaño de la muestra
edad_min <- 18 # edad minima
edad_max <- 65 # edad maxima

# Solucion a

id <- 1:n
print(id)
typeof(id)
class(id)


# Solucion B

edades <- round(runif(n, min = edad_min, max = edad_max))
print(edades)
typeof(edades)
class(edades)


# Solucion C

banco_nombres <- c(
  "Ana",
  "Bernardo",
  "Carlos",
  "Diana",
  "Elena",
  "Fernando",
  "Gabriela",
  "Hernán",
  "Inés",
  "Julián",
  "Karen",
  "Luis",
  "Marta",
  "Nicolás",
  "Olga",
  "Pedro",
  "Rosa",
  "Sara",
  "Tomás",
  "Ulises",
  "Valentina",
  "William"
)

nombres <- sample(
  banco_nombres, # Vector de elementos
  n, # Tamaño del vector a generar
  replace = TRUE # Con reempplazo (Mismo nombre puede aparecer varias veces)
)

print(nombres)
typeof(nombres)
class(nombres)


# Solución D

niveles_educacion <- c("Primaria", "Secundaria", "Pregrado", "Posgrado")

educacion <- factor(
  x = sample(
    # Muestra de N de nivel de eduacion
    niveles_educacion, # Vector de niveles de educacion
    size = n, # Tamaño de la muestra
    replace = TRUE # Con remplazo
  ),
  levels = niveles_educacion, # Niveles del factor
  ordered = TRUE # Aplica la jerarquia del vector
)

print(educacion)
typeof(educacion)
class(educacion)
levels(educacion)


## Ejercicio 3 ---------------------------------------------------------------

ventas_texto <- c(
  "1200",
  "850",
  "930",
  "no reportado",
  "1100",
  "745",
  "sin dato",
  "990",
  "1010",
  "875"
)

# Solucion A

ventas_numerico <- as.numeric(ventas_texto)

# Warning message: NAs introduced by coercion

# Explicacion: El vector contiene strings que no pueden ser convertidos
# a numerico

print(ventas_numerico)
typeof(ventas_numerico)
class(ventas_numerico)

# Solucion B

CountNA <- sum(is.na(ventas_numerico))
print(paste("Los NAs que dentro del vector son:", CountNA))

# "Los NAs que dentro del vector son: 2"

ProportionNA <- ((sum(is.na(ventas_numerico)) / length(ventas_numerico)))
print(paste("Los NAs que dentro del vector son:", ProportionNA * 100, "%"))

# "Los NAs que dentro del vector son: 20 %"

# Solucion C
# Opcion 1
Promedio_No_NA <- mean(ventas_numerico, na.rm = TRUE)
# Opcion 2
Promedio_No_NA_2 <- sum(ventas_numerico[!is.na(ventas_numerico)]) /
  length(ventas_numerico[!is.na(ventas_numerico)])

## Ejercicio 4 ---------------------------------------------------------------

# Creamos copia de edades
edades_copia <- edades

# Umbrales establecidos
umbral_mayor <- 40 # umbral de edad del literal a.
lim_inf <- 25 # límite inferior del literal b.
lim_sup <- 35 # límite superior del literal b.
corte_na <- 20 # corte de censura del literal c.

### a) Solucion -----

# Individuos mayores al umbral
supera_umbral <- length(edades_copia[edades_copia > umbral_mayor])

print(paste(
  "La cantidad de individuos que superan el umbral de edad son",
  supera_umbral
))

# Proporcion del total

caso_totales <- length(edades_copia)


proporcion_supera_umbral <- round(100 * (supera_umbral / caso_totales), 2)

print(paste(
  "La proporcion de individuos que supera el umbral es",
  proporcion_supera_umbral,
  "%"
))

### b) Solucion -----

entr_limites <- edades_copia >= lim_inf & edades_copia <= lim_sup
propo_limites <- mean(entr_limites)

print(paste(
  "La proporcion de individuos entre los limites es",
  100 * propo_limites,
  "%"
))

### c) Solucion -----

edades_copia[edades_copia < corte_na] <- NA

cantidad_na <- length(edades_copia[is.na(edades_copia)])

print(paste("La cantidad de NA son", cantidad_na))

### d) Solucion -----

posiciones <- which(
  edades_copia == edad_max,
  arr.ind = TRUE
)

cat("Las posciones son", posiciones)


## Ejercicio 5 ---------------------------------------------------------------

### a) solución ----

educacion_sin_ordered <- factor(
  x = sample(
    # Muestra de N de nivel de eduacion
    niveles_educacion, # Vector de niveles de educacion
    size = n, # Tamaño de la muestra
    replace = TRUE # Con remplazo
  ),
  levels = niveles_educacion, # Niveles del factor
  ordered = FALSE # Aplica la jerarquia del vector
)

# En el print vemos la jerarquia "<" entre niveles
print(educacion_sin_ordered)
print(educacion)


# En el class, vemos que ademas de levels hay un orden
class(educacion_sin_ordered)
class(educacion)

cat(
  "La diferencia de usar ordered = TRUE: \n",
  "* Permite establecer una jerarquia en los niveles de educacion \n",
  "* Esto permite operaciones relacionales"
)


v
graduados_secundaria <- educacion > "Secundaria"

proporcion_graduados_secundaria <- length(educacion[graduados_secundaria]) /
  length(educacion)

cat(
  "La proporcion de graduados de secundaria son: \n",
  round(proporcion_graduados_secundaria, 4) * 100,
  "%"
)

### c)  solución ----

individuos_educacion <- table(educacion)
print(individuos_educacion)


cat(
  "\n La proporcion de graduados de Primaria son:",
  individuos_educacion[individuos_educacion = "Primaria"],
  "\n La proporcion de graduados de Secundaria son:",
  individuos_educacion[individuos_educacion = "Secundaria"],
  "\n La proporcion de graduados de Pregrado son:",
  individuos_educacion[individuos_educacion = "Pregrado"],
  "\n La proporcion de graduados de Posgrado son:",
  individuos_educacion[individuos_educacion = "Posgrado"]
)


## Ejercicio 6 ---------------------------------------------------------------

### a)  solución ----

M <- matrix(
  data = 1:12,
  nrow = 4,
  ncol = 3,
  byrow = TRUE
)

print(M)

### b)  solución ----

colnames(M) <- c("v1", "v2", "v3")
rownames(M) <- c("obs_1", "obs_2", "obs_3", "obs_4")

print(M)

### c)  solución ----

# Extramos la segunda fila
M[2, ]

# Extramos la tercera columna
M[, 3]

# Extraemos submatriz
M[1:2, 2:3]

### d)  solución ----

# Calcular la transpuesta
t(M)

# Producto matricial de M por su transpuesta
M %*% t(M)


cat(
  "\n La matriz M tiene es de 4x3 y la transpuestas de M es 3x4.",
  "\n Por lo tanto, las dimensiones de la matriz es",
  dim(M %*% t(M))
)

## Ejercicio 7 ---------------------------------------------------------------

### a)  solución ----

grupo_taller <- list(
  nombres = c("Sergio", "MiguelAngel", "Juan"),
  semestre = c(1, 1, 1),
  entrego_a_tiempo = c(TRUE, TRUE, TRUE),
  contacto = list(
    correo = c(
      "m.palma1@uniandes.edu.co",
      "sa.lopezv@uniandes.edu.co",
      "j.echeverryd@uniandes.edu.co"
    ),
    ciudad = c("Bogota", "Bogota", "Bogota")
  )
)

### b)  solución ----

grupo_taller$nombres[[2]]


grupo_taller[[3]]

### c)  solución ----

# Con un solo [] seleccionamos elementos de la lista,
# pero el resultado sigue siendo una lista.
grupo_taller[1]

class(grupo_taller[1])

# Con [[]] extraemos el contenido del elemento de la lista.
# Si ese contenido es un vector, luego podemos seleccionar
# un elemento específico de ese vector con [].

grupo_taller[[1]][2]

class(grupo_taller[[1]])

### d)  solución ----

# Crear nuevo elemento
grupo_taller$curso <- "Taller de R"
print(grupo_taller)

# Eliminar elemento
grupo_taller$entrego_a_tiempo <- NULL
print(grupo_taller)

## Ejercicio 8 ---------------------------------------------------------------

frases <- paste(
  nombres,
  "tiene",
  edades,
  "años y su nivel educativo es",
  paste0(
    educacion,
    "."
  )
)

head(frases, 5)

# NIVEL 2 - INTERMEDIO ------------------------------------------------------

## Ejercicio 9 ---------------------------------------------------------------

corte_joven <- 30
corte_mayor <- 50

grupo_etario <- ifelse(
  edades < corte_joven,
  "Joven",
  ifelse(
    edades <= corte_mayor,
    "Adulto",
    "Mayor"
  )
)
table(grupo_etario)

#Verificaciones
joven <- length(edades[edades < 30])
adulto <- length(edades[edades <= 50 & edades >= 30])
mayor <- length(edades[edades > 50])

print(joven)
print(adulto)
print(mayor)

## Ejercicio 10 --------------------------------------------------------------

valor_prueba <- 10
valor_prueba <- 17
valor_prueba <- "Hola"


if (!is.numeric(valor_prueba)) {
  cat("El valor no es numérico") ###a) Solución----
} else if (valor_prueba %% 2 == 0) {
  cat("El valor es numérico y par") ###b) Solución----
} else {
  cat("El valor es numérico e impar") ###c) Solución----
}

## Ejercicio 11 --------------------------------------------------------------

edad_corte <- 55
vocales <- c("A", "E", "I", "O", "U")

for (i in 1:length(frases)) {
  #Tomar variables de interés
  edad_par <- edades[i] %% 2 == 0
  edad_mayor <- edades[i] > edad_corte
  nombre_no_vocal <- !(substr(nombres[i], 1, 1) %in% vocales)
  #Establecer reglas con variables definidas
  if (edad_par & edad_mayor & nombre_no_vocal) {
    cat(frases[i], "\n")
  }
}

## Ejercicio 12 --------------------------------------------------------------

#Definimos los parámetros
pob_inicial <- 50000 # población hoy
tasa <- 0 # crecimiento anual
meta <- 80000 # población objetivo

#Definimos Valores Iniciales
poblacion <- pob_inicial
anios <- 0

#Bucle While
#Siga creciendo mientras la poblacion sea <= a la meta
if (tasa <= 0) {
  cat("La tasa debe ser mayor que 0")
} else {
  while (poblacion <= meta) {
    #Crecimiento con tasa anual
    poblacion <- poblacion * (1 + tasa)
    anios <- anios + 1
  }

  #Imprimir Resultados
  cat("Tarda", anios, "años", "en alcanzar", round(poblacion), "personas.")
}
#Si la tasa fuera 0, la población nunca crece y los años crecen hasta al el
#infinito, entonces el bucle nunca termina.
#Por este motivo, usamos un if que no admita tasas menores o iguales a cero

## Ejercicio 13 --------------------------------------------------------------

#' Calcular estadísticas manualmente
#'
#' Calcula el promedio y la desviación estándar muestral de un
#' vector numérico sin utilizar las funciones mean() ni sd().
#'
#' Si el vector contiene valores NA, la función genera una advertencia
#' y los excluye de los cálculos.
#'
#' @param x Un vector numérico.
#'
#' @returns Una lista con el promedio y la desviación estándar muestral
#' del vector.
#'
#' @examples
#' estadisticos_manuales(c(10, 20, 30, 40))
#' estadisticos_manuales(c(10, 20, NA, 40))
#'
#'
estadisticos_manuales <- function(x) {
  if (!is.numeric(x)) {
    stop(print("No es numerico"))
  }
  if (any(is.na(x))) {
    warning(print("El vector contiene NAs"))
  }

  datos <- x[!is.na(x)]
  promedio <- sum(datos) / length(datos)
  sd <- sqrt(
    (sum((datos - promedio)^2)) / (length(datos) - 1)
  )

  return(
    list(
      Promedio = promedio,
      DesStad = sd
    )
  )
}


#Ejemplo de uso

x <- c(2, 5, 4, 6, NA, 4)
ejemplo <- estadisticos_manuales(x)

class(ejemplo)

# Aplicamos la funcion a edades
estadisticos_manuales(edades)

# probamos valores
mean(edades)
sd(edades)

## Ejercicio 14 --------------------------------------------------------------

# Definimos funcion
estandarizar <- function(x) {
  # Definimos estadisticas
  Estadisticas <- estadisticos_manuales(x)
  Promedio <- Estadisticas$Promedio
  DesStad <- Estadisticas$DesStad
  z_score <- (x - Promedio) / (DesStad)

  return(
    z_score
  )
}


# Ejemplo
edades_std <- estandarizar(edades)
print(edades_std)

estadisticos_manuales(edades_std)
class(edades_std)
typeof(edades_std)
# La media del vector estandarizado es aproximadamente 0 y su desviación
# estándar aproximadamente 1. La diferencia respecto a los valores exactos
# se debe a la representación finita de los números y a los errores de
# redondeo asociados a la aritmética de punto flotante utilizada por R.
# Fuente: R Core Team, R FAQ, sección 7.31:
# "Why doesn't R think these numbers are equal?"

## Ejercicio 15 --------------------------------------------------------------

lista_a_matriz <- function(x) {
  if (!is.list(x)) {
    stop(print("El objeto no es una lista"))
  }
  if (!all(sapply(x, is.numeric))) {
    stop(print("En la lista hay elementos que no son numericos"))
  }
  if (!all(sapply(x, length) == sapply(x, length)[1])) {
    #Todos los vectores tengan la misma longitudad comparada al primer vector
    stop(print("Los vectores deben tener las mismas dimensiones"))
  }
  #Indicamos matriz
  # Longitud de las filas de la lista
  n_filas <- length(x[[1]])

  # Longitud de las columnas (+ contante)
  n_columnas <- length(x) + 1

  # Definimos matriz
  X <- matrix(
    1,
    nrow = n_filas,
    ncol = n_columnas
  )

  # Agregamos cada vector de la lista a partir de la segunda columna
  for (j in 1:length(x)) {
    # x[[j]]
    # X[, j + 1] llenar por posicion en su respectiva fila omitiendo la contante
    X[, j + 1] <- x[[j]]
  }

  return(X)
}


# Ejemplo de pruebas
prueba <- list(
  edad = c(20, 30, 40),
  salario = c(100, 200, 300)
)

prueba[[2]]

matriz_prueba <- lista_a_matriz(prueba)
print(matriz_prueba)

matriz_prueba[3, 2]
matriz_prueba[[4]]

# NIVEL 3 - AVANZADO --------------------------------------------------------

## Ejercicio 16 --------------------------------------------------------------

## Ejercicio 17 --------------------------------------------------------------

## Ejercicio 18 --------------------------------------------------------------

## Ejercicio 19 --------------------------------------------------------------

## Ejercicio 20 --------------------------------------------------------------
