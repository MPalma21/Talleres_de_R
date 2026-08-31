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

semilla <- (cod_palma + cod_lopez + cod_echeverry) / 3
set.seed(semilla)

# Comentarios
# (i) Para garantizar la reproducibilidad. Dado que al manejar numeros aleatorios,
#  un semilla nos ayuda a fijar la misma generacion de los numeros
# (ii) Si los resultados no se fijan, puede generar errores operativos y entre
# otros dado que no se garantiza una reproducibilidad de analisis
# (iii) Toda generacion apartado que tenga variables aleatorias o modelos estocasticos
# Si cambia semilla, cambian los objetos generados con runif(), # sample(), rnorm(), etc.
# No cambian los parametros ni objetos
# deterministas como n, edad_min, edad_max e id.

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

###Solución A----

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

###Solución B----

entr_limites <- edades_copia >= lim_inf & edades_copia <= lim_sup
propo_limites <- mean(entr_limites)

print(paste(
  "La proporcion de individuos entre los limites es",
  100 * propo_limites,
  "%"
))

###Solución C----

edades_copia[edades_copia < corte_na] <- NA

cantidad_na <- length(edades_copia[is.na(edades_copia)])

print(paste("La cantidad de NA son", cantidad_na))

###Solución D----

posiciones <- which(
  edades_copia == edad_max
)

cat("Las posciones son", posiciones)


## Ejercicio 5 ---------------------------------------------------------------

###Solución A----

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

levels(educacion)
levels(educacion_sin_ordered)
# ordered = TRUE conserva un orden entre las categorias y permite
# comparaciones relacionales; sin ordered = TRUE el factor es nominal.

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


###Solución B----

graduados_secundaria <- educacion > "Secundaria"

proporcion_graduados_secundaria <- length(educacion[graduados_secundaria]) /
  length(educacion)

cat(
  "La proporcion de graduados de secundaria son: \n",
  round(proporcion_graduados_secundaria, 4) * 100,
  "%"
)

###Solución C----

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

###Solución A----

M <- matrix(
  data = 1:12,
  nrow = 4,
  ncol = 3,
  byrow = TRUE
)

print(M)

###Solución B----

colnames(M) <- c("v1", "v2", "v3")
rownames(M) <- c("obs_1", "obs_2", "obs_3", "obs_4")

print(M)

###Solución C----

# Extramos la segunda fila
M[2, ]

# Extramos la tercera columna
M[, 3]

# Extraemos submatriz
M[1:2, 2:3]

###Solución D----

# Calcular la transpuesta
t(M)

# Producto matricial de M por su transpuesta
M %*% t(M)

dim(M %*% t(M)) # M es 4x3 y t(M) es 3x4; por eso el producto es 4x4.
# Las dimensiones internas (3 y 3) coinciden.

## Ejercicio 7 ---------------------------------------------------------------

###Solución A----

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

###Solución B----
grupo_taller$nombres
grupo_taller$nombres[[2]]


###Solución C----

grupo_taller[1]
grupo_taller[[1]]


class(grupo_taller[[1]])
class(grupo_taller[1])

# grupo_taller[1] devuelve una sublista que contiene el primer elemento.
# grupo_taller[[1]] extrae directamente el contenido del primer elemento.
# Por eso [ ] conserva la estructura de lista, mientras que [[ ]] la elimina.

###Solución D----

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

# Clasificación etaria basada en fuentes oficiales:
# - Naciones Unidas define "juventud" como el grupo de 15 a 24 años.
# - La Organización Mundial de la Salud utiliza 60 años o más
#   como referencia para personas mayores.
#
# Fuentes:
# United Nations, Department of Economic and Social Affairs (2026).
# World Population Highlights 2026: Youth.
#
# World Health Organization (2015).
# World Report on Ageing and Health.
#
# A partir de estas referencias y dado que la muestra inicia en 18 años,
# se definen los siguientes cortes:

corte_joven <- 25
corte_mayor <- 60

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
joven <- length(edades[edades < 25])
adulto <- length(edades[edades <= 60 & edades >= 25])
mayor <- length(edades[edades > 60])

print(joven)
print(adulto)
print(mayor)


## Ejercicio 10 --------------------------------------------------------------

valor_prueba <- 10
valor_prueba <- 17
valor_prueba <- "Hola"


if (!is.numeric(valor_prueba)) {
  cat("El valor no es numérico") ###Solución A----
} else if (valor_prueba %% 2 == 0) {
  cat("El valor es numérico y par") ###Solución B----
} else {
  cat("El valor es numérico e impar") ###Solución C----
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
tasa <- 0.023 # crecimiento anual
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
      Desviacion_estandar = sd
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
  DesStad <- Estadisticas$Desviacion_estandar
  z_score <- (x - Promedio) / (DesStad)

  return(
    z_score
  )
}


# Ejemplo
edad_std <- estandarizar(edades)
print(edad_std)

estadisticos_manuales(edad_std)
class(edad_std)
typeof(edad_std)
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

  # Longitud de las columnas (+ constante)
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

  colnames(X) <- c("constante", names(x)) # Nombramos las columnas

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

### Solucion A----

salario_min <- 1400000
salario_max <- 12000000
lambda_experiencia <- 10

salario <- runif(
  n,
  min = salario_min,
  max = salario_max
)

experiencia <- rpois(n, lambda = lambda_experiencia)

# Se usa Poisson porque genera valores enteros no negativos,
# consistentes con una medida simple de años de experiencia laboral.

### Solucion B----

edad_std <- estandarizar(edades)
salario_std <- estandarizar(salario)
exper_std <- estandarizar(experiencia)

### Solucion C----

beta_0 <- 2.0 # constante
beta_1 <- 1.2 # efecto de la edad estandarizada
beta_2 <- 0.8 # efecto del salario estandarizado
beta_3 <- 0.4 # efecto de la experiencia estandarizada

### Solucion D----

# Definimos epsilon
epsilon <- rnorm(
  n,
  mean = 0,
  sd = 1
)

# Definimos el Modelo
y <- beta_0 +
  beta_1 * edad_std +
  beta_2 * salario_std +
  beta_3 * exper_std +
  epsilon
## Ejercicio 17 --------------------------------------------------------------

mco_manual <- function(X, y) {
  # Validación del objeto
  if (!is.matrix(X)) {
    stop(print("X debe ser una matriz"))
  }
  # Validamos la condicion de multiplicacion matricial
  if (nrow(X) != length(y)) {
    stop(print("Las filas de X deben ser iguales a la longitud de y"))
  }
  # Estimamos los betas, beta= (X'X)^(-1) (X'Y)
  beta <- solve(t(X) %*% X) %*% t(X) %*% y
  # Convertimos beta a vector
  beta <- as.vector(beta)
  #Asignamos nombres
  names(beta) <- colnames(X)
  #Retornar resultado
  return(beta)
}

## Ejercicio 18 --------------------------------------------------------------

### Solución A----

# Modelo A

lista_A <- list(edad_std = edad_std)
Modelo_A <- lista_a_matriz(lista_A)

# Modelo B

lista_B <- list(edad_std = edad_std, salario_std = salario_std)
Modelo_B <- lista_a_matriz(lista_B)

# Modelo C
lista_C <- list(
  edad_std = edad_std,
  salario_std = salario_std,
  exper_std = exper_std
)
Modelo_C <- lista_a_matriz(lista_C)

### Solución B----
Modelos <- list(
  A = Modelo_A,
  B = Modelo_B,
  C = Modelo_C
)
lista_resultados <- list()

for (i in 1:length(Modelos)) {
  beta <- mco_manual(Modelos[[i]], y)
  epsilon <- y - Modelos[[i]] %*% beta

  lista_resultados[[i]] <- list(
    coeficientes = beta,
    residuos = epsilon,
    SCR = as.numeric(t(epsilon) %*% epsilon)
  )
}

names(lista_resultados) <- names(Modelos)

### Solución C----
#Cambia el coeficiente gracias a que agregamos variables control, mejorando la precisión de la estimación
print(lista_resultados$A$SCR)
print(lista_resultados$B$SCR)
print(lista_resultados$C$SCR)
#El Modelo C es el que tiene una menor SCR, gracias a la inclusión de variables control
#

## Ejercicio 19 --------------------------------------------------------------

###Solución A----
#Creamos datos_taller
datos_taller <- data.frame(
  id,
  nombres,
  edades,
  educacion,
  salario
)

###Solución B----

str(datos_taller)
head(datos_taller)
dim(datos_taller)

cat(
  "\n La columna id es:",
  class(datos_taller$id),
  "\n la columna  nombres es:",
  class(datos_taller$nombres),
  "\n la columna  edades es:",
  class(datos_taller$edades),
  "\n la columna  educacion es:",
  class(datos_taller$educacion),
  "\n la columna  salario es:",
  class(datos_taller$salario)
)

###Solución C----

# Definimos cantidad de valores faltantes
n_faltantes <- 50

# Seleccionamos aleatoriamente las filas
posiciones_NA <- sample(
  1:nrow(datos_taller),
  n_faltantes
)


# Reemplazamos por NA el salario en las filas seleccionadas
datos_taller$salario[posiciones_NA] <- NA

# Cantidad de valores faltantes por columna
cantidad_NA <- colSums(is.na(datos_taller))

print(cantidad_NA)

# Porcentaje de valores faltantes por columna
porcentaje_NA <- colMeans(is.na(datos_taller)) * 100

print(porcentaje_NA)


### Solución D ----

# Creamos un data frame únicamente con filas completas
datos_completos <- datos_taller[complete.cases(datos_taller), ]

# Calculamos cuántas filas se perdieron
filas_perdidas <- nrow(datos_taller) - nrow(datos_completos)

# Mostramos el resultado
cat("La cantidad de filas perdidas es:", filas_perdidas)

### Solución E ----

# Ordenamos los datos de mayor a menor salario
datos_ordenados <- datos_completos[
  order(datos_completos$salario, decreasing = TRUE),
]

# Mostramos las primeras 5 filas
head(datos_ordenados, 5)


## Ejercicio 20 --------------------------------------------------------------

### Solución A ----

# Cargamos base de datos

data(airquality)
head(airquality, 6)

# Valores NA en cada Columna
na_por_columna <- colSums(is.na(airquality))
print(na_por_columna)

### Solución B ----

medias_columnas <- apply(
  airquality, # Dataset (Array , Matrix)
  MARGIN = 2, # 1 = Rows , 2 = Columns
  FUN = function(x) mean(x, na.rm = TRUE) # Funcion a aplicar
)

print(medias_columnas)

### Solución C ----

rango_manual <- function(x) {
  if (any(is.na(x))) {
    datos <- x[!is.na(x)]
    print("El vector contiene NAs, serán ignorados en la operación")
  } else {
    datos <- x
  }

  maximo <- max(datos)
  minimo <- min(datos)

  rango <- maximo - minimo

  return(rango)
}

apply(airquality, 2, rango_manual)

### Solución D ----

# La variable con mayor rango es Solar.R, con un rango de 327.
# Sin embargo, el rango puede ser una medida engañosa de variabilidad
# cuando se comparan variables medidas en unidades diferentes.
# Por ejemplo, Solar.R, Wind y Temp están expresadas en escalas distintas,
# por lo que un rango numéricamente mayor no implica necesariamente que
# esa variable sea relativamente más variable.
# Además, el rango solo utiliza el valor máximo y el mínimo, por lo que
# puede verse muy afectado por valores extremos.
