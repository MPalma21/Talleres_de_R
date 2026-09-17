# =============================================================================
# Clase 3: Flujos de Control y Funciones en R
# Profesor : Santiago Neira 
# Objetivos:
# - Comprender y aplicar estructuras condicionales (if, else if, else)
# - Diferenciar entre if/else e ifelse()
# - Implementar bucles (for, while)
# - Crear funciones personalizadas
# - Documentar funciones correctamente
# - Manejo de errores con stop() y warning()
# - Identificar y corregir errores comunes en funciones
# =============================================================================


# -----------------------------------------------------------------------------
# ESTRUCTURAS CONDICIONALES
# -----------------------------------------------------------------------------

# ---------- Condicional if básico ----------

# Definir un número para evaluar
numero <- 5

# Utilizar una declaración if para determinar si el número es positivo
if (numero > 0) {
  mensaje <- "El número es positivo"
} else if (numero < 0) {
  mensaje <- "El número es negativo"
} else {
  mensaje <- "El número es cero"
}

# Imprimir el resultado
cat("Número:", numero, "\n", mensaje, "\n")

# ---------- Operadores de comparación ----------
# Operadores disponibles:
# igual (==), mayor (>), menor (<), diferente (!=)
# mayor o igual (>=), menor o igual (<=)

numero <- 4

# Las condiciones se pueden realizar sobre múltiples elementos
# o equivale a (|), y equivale a (&)
if (numero > 0 & numero <= 9) {
  mensaje <- "El número está entre 0 y 9"
}

cat("Número:", numero, "\n", mensaje, "\n")

# ---------- Ejemplo práctico: par o impar ----------

numero <- 5

if (numero %% 2 == 0) {
  mensaje <- "El número es par"
} else {
  mensaje <- "El número es impar"
}

cat("Número:", numero, "\n", mensaje, "\n")

# ---------- Diferencia entre if/else e ifelse() ----------

vector_ejemplo <- c(-2:15)

# ifelse() es una función vectorizada que permite realizar 
# acciones ante la ocurrencia de un condicional
resultado_ifelse <- ifelse(vector_ejemplo > 10, vector_ejemplo + 20, 1)
print(resultado_ifelse)

# Verificación de tipos de datos
vector_ejemplo <- as.factor(vector_ejemplo)

if (is.numeric(vector_ejemplo)) {
  print('Es numérico')
} else if (is.character(vector_ejemplo)) {
  print('Es character')
} else if (is.logical(vector_ejemplo)) {
  print('Es logical')
} else {
  print('Es de otro tipo (factor, etc.)')
}

# -----------------------------------------------------------------------------
# BUCLES (LOOPS)
# -----------------------------------------------------------------------------

# ---------- Bucle for básico ----------

for (numero in 1:10) {
  print(numero)  
}

# ---------- Bucle for con listas ----------

# Ejemplo con lista de meses
lista_iteracion <- list(meses = month.name)
for (mes in lista_iteracion[[1]]) {
  print(mes)  
}

# Alternativa usando length para evaluar el tamaño
for (i in 1:length(lista_iteracion[[1]])) {
  print(lista_iteracion[[1]][i])
}

# ---------- Bucles anidados ----------

lista_iteracion_2 <- list(
  meses   = month.name[1:3], 
  numeros = seq(1, 3, 1)
)

# Primer orden: meses externos, números internos
for (mes in lista_iteracion_2[[1]]) {
  for (numero in lista_iteracion_2[[2]]) {
    cat(numero, "", mes, "\n")
  }
}

# Segundo orden: números externos, meses internos
for (numero in lista_iteracion_2[[2]]) {
  for (mes in lista_iteracion_2[[1]]) {
    cat(numero, "", mes, "\n")
  }
}

# ---------- Bucle while (¡PRECAUCIÓN!) ----------

numero <- 1
while (numero <= 5) {
  print(numero)
  if (numero %% 2 == 0) {
    print('El número es par')
  } else {
    print('El número es impar')
  }
  numero <- numero + 1  # ¡Importante! Actualizar la variable de control
}

# -----------------------------------------------------------------------------
# FUNCIONES
# -----------------------------------------------------------------------------

# ---------- Función básica ----------

multiplicacion <- function(x, y) {
  resultado <- x * y
  return(resultado)
}

# Usar la función
resultado_multi <- multiplicacion(3, 40)
print(resultado_multi)

# ---------- Documentación de funciones ----------

# Instalar y cargar el paquete docstring (solo primera vez)
# install.packages("docstring")
library(docstring)

suma_simple <- function(x, y) {
  #' Suma dos números
  #'
  #' @param x Un número.
  #' @param y Un número.
  #' @return Un número que es la suma de los parámetros ingresados.
  #' @examples
  #' suma_simple(1, 1)
  #' suma_simple(10, 1)
  return(x + y)
}

# Ver la documentación
docstring(suma_simple)

# Usar la función
suma_simple(2, 3)

# ---------- Funciones más complejas ----------

primera_letra <- function(palabra1, palabra2) {
  #' Compara las primeras letras de dos palabras
  #' 
  #' @param palabra1 Una cadena de caracteres
  #' @param palabra2 Una cadena de caracteres
  #' @return TRUE si las primeras letras son iguales, FALSE en caso contrario
  #' @examples
  #' primera_letra("gato", "guerra")
  #' primera_letra("sol", "luna")
  
  # Extrae primera letra de cada palabra
  letra1 <- substr(palabra1, start = 1, stop = 1)
  letra2 <- substr(palabra2, start = 1, stop = 1)
  
  # Compara las primeras letras
  if (letra1 == letra2) {
    print("Las primeras letras son iguales")
    condicion <- TRUE
  } else {
    print("Las primeras letras son diferentes")
    condicion <- FALSE
  }
  
  return(condicion)
}

# Probar la función
primera_letra("rosa", "rojo")
primera_letra('gato', 'perro')

# ---------- Funciones con bucles ----------

suma_loop <- function(vector) {
  #' Suma todos los elementos de un vector usando un bucle
  #' 
  #' @param vector Un vector numérico
  #' @return La suma de todos los elementos del vector
  #' @examples
  #' suma_loop(c(1, 2, 3, 4))
  #' suma_loop(1:10)
  
  resultado <- 0
  for (elemento in vector) {
    resultado <- resultado + elemento
  }
  return(resultado)
}

suma_loop(c(1, 2, 3, 4))



# -----------------------------------------------------------------------------
# MANEJO DE ERRORES
# -----------------------------------------------------------------------------

# ---------- stop() y warning() ----------

promedio <- function(x) {
  #' Calcula el promedio de un vector de números
  #'
  #' Esta función toma un vector numérico y devuelve su promedio.
  #'
  #' @param x Un vector numérico.
  #' @return Un número que representa el promedio del vector.
  #' @examples
  #' promedio(c(1, 2, 3, 4))
  #' promedio(c(10, 20, 30))
  
  # Verificar que el input sea numérico
  if (!is.numeric(x)) {
    stop("El argumento x debe ser numérico.")
  }
  
  # Advertir si hay valores NA
  if (any(is.na(x))) {
    warning("El vector contiene valores NA que serán ignorados.")
  }
  
  suma <- sum(x, na.rm = TRUE)
  total <- length(x[!is.na(x)])  # Contar solo valores no-NA
  division <- suma / total
  
  return(division)
}

# Probar la función
promedio(c(1, 2, 3, 4))
# promedio(c("hola", "adiós"))  # Esto dará error



# -----------------------------------------------------------------------------
# EJERCICIOS PRÁCTICOS
# -----------------------------------------------------------------------------

#' Ejercicio 1: Crear una función que analice características básicas de texto
#' 
#' Crea una función llamada 'analizar_caracteres' que:
#' 1. Reciba como parámetro un vector de palabras
#' 2. Para cada palabra:
#'    - Verifique si comienza con vocal o consonante
#'    - Cuente el número de letras
#' 3. Debe incluir manejo de errores con stop() y warning()

# Plantilla para el ejercicio:
analizar_caracteres <- function(palabras) {
  #' Analiza características básicas de un vector de palabras
  #' 
  #' @param palabras Vector de caracteres con las palabras a analizar
  #' @return Data frame con el análisis de las palabras
  #' @examples
  #' analizar_caracteres(c("ana", "libro", "sol"))
  
  # Tu código aquí...
  
  return(resultados)
}


#' Ejercicio 2: Crear una función que identifique palíndromos
#' 
#' Crea una función llamada 'detectar_palindromos' que:
#' 1. Reciba como parámetro una cadena de caracteres
#' 2. Determine si la cadena es idéntica al derecho y al revés
#' 3. Ignore mayúsculas/minúsculas y espacios
#' 4. Retorne TRUE/FALSE y un mensaje explicativo

#' Ejercicio 3: Mejorar la función 'suma_loop'
#' 
#' Modifica la función suma_loop para que:
#' 1. Acepte vectores de diferentes tipos (numéricos y caracteres)
#' 2. Si recibe caracteres, los concatene
#' 3. Si recibe números, permita elegir entre suma o multiplicación
#' 4. Incluya documentación completa y manejo de errores
