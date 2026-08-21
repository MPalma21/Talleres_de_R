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

## Ejercicio 5 ---------------------------------------------------------------

## Ejercicio 6 ---------------------------------------------------------------

## Ejercicio 7 ---------------------------------------------------------------

## Ejercicio 8 ---------------------------------------------------------------

# NIVEL 2 - INTERMEDIO ------------------------------------------------------

## Ejercicio 9 ---------------------------------------------------------------

## Ejercicio 10 --------------------------------------------------------------

## Ejercicio 11 --------------------------------------------------------------

## Ejercicio 12 --------------------------------------------------------------

## Ejercicio 13 --------------------------------------------------------------

## Ejercicio 14 --------------------------------------------------------------

## Ejercicio 15 --------------------------------------------------------------

# NIVEL 3 - AVANZADO --------------------------------------------------------

## Ejercicio 16 --------------------------------------------------------------

## Ejercicio 17 --------------------------------------------------------------

## Ejercicio 18 --------------------------------------------------------------

## Ejercicio 19 --------------------------------------------------------------

## Ejercicio 20 --------------------------------------------------------------
