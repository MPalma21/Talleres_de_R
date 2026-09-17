# =============================================================================
# Clase 2: Estructuras de datos y operaciones en R
# Profesor : Santiago Neira
# Objetivos:
# - Repasar (rápido) lo visto en Clase 1: tipos básicos y vectores
# - Nuevos tipos: enteros (L) y factores (variables categóricas)
# - Estructuras: matrices, arrays y listas
# - Indexación avanzada: negativa, por nombre y LÓGICA (filtrado)
# - Operaciones entre objetos: vectorización, recycling, comparaciones
# - Operaciones con matrices: %*%, transpuesta, inversa
# - Simulación básica: distribuciones (runif, rnorm, rbinom, sample)
# =============================================================================

# -----------------------------------------------------------------------------
# 0. Repaso exprés de Clase 1 (5 minutos)
# -----------------------------------------------------------------------------
# En Clase 1 vimos: tipos básicos, vectores con c(), asignación y aritmética.
# Si algo de este bloque no te suena, vuelve a 01_Clase1.R.

10 * 5                          # R como calculadora
typeof(3.14)                    # "double"   (numérico)
typeof("Hola")                  # "character" (texto)
typeof(TRUE)                    # "logical"  (lógico)

salarios <- c(1500, 2000, 1800) # Vector con c() y asignación con <-
salarios * 1.10                 # Vectorización: aumento del 10% a TODOS
salarios[2]                     # Indexación básica: segundo elemento

# Jerarquía de coerción (Clase 1): logical < integer < double < character
c(TRUE, 1, 2)                   # el TRUE se vuelve 1
c(1, 2, "hola")                 # todo se vuelve texto

# -----------------------------------------------------------------------------
# 1. Tipos NUEVOS de esta clase
# -----------------------------------------------------------------------------

# ---------- Enteros (integer) ----------
# El sufijo L fuerza a R a guardar el número como entero (ocupa menos memoria).

print(1L)
typeof(1L)                # "integer"
typeof(1)                 # "double" (sin L, R asume decimal)

print(1L + 2L)            # entero + entero -> entero
print(1L + 3.5)           # entero + double -> double (coerción hacia arriba)

# ---------- Lógicos: TRUE/FALSE vs T/F ----------
# T y F funcionan como abreviaciones, PERO son variables reasignables.
# Buena práctica: escribir siempre TRUE y FALSE completos.

print(T)                  # funciona...
typeof("F")               # "character" -> ¡las comillas cambian todo!

# ---------- Valores faltantes (NA) ----------
# NA = dato que NO conocemos. Se propaga en las operaciones.

print(NA)
NA + 1                    # NA: si no sé cuánto es algo, tampoco sé su suma
NA + 3.14

# ---------- Factores (variables categóricas) ----------
# En economía las usamos todo el tiempo: estrato, nivel educativo, sexo, región.
# Un factor guarda las categorías como niveles (levels).

estrato <- c("alto", "bajo", "medio", "medio", "bajo")

estrato_factor <- as.factor(estrato)
estrato_factor
levels(estrato_factor)    # OJO: as.factor() ordena ALFABÉTICAMENTE
                          # "alto" "bajo" "medio" (no es el orden natural)

# FORMA CORRECTA: declarar el orden de los niveles al crear el factor
estrato_ok <- factor(estrato, levels = c("bajo", "medio", "alto"))
estrato_ok
levels(estrato_ok)        # ahora sí: bajo < medio < alto

# Si además el orden IMPORTA para comparar (ordinal), usamos ordered = TRUE
estrato_ordinal <- factor(estrato,
                          levels  = c("bajo", "medio", "alto"),
                          ordered = TRUE)
estrato_ordinal
estrato_ordinal > "bajo"  # con ordered = TRUE podemos comparar categorías

# Los factores también sirven con números como categorías (ej: código de región)
region <- c(1, 2, 5, 6, 3)
region_factor <- as.factor(region)
levels(region_factor)     # niveles del FACTOR (region, el vector, no tiene levels)

# -----------------------------------------------------------------------------
# 2. Secuencias (útiles para crear datos y para indexar)
# -----------------------------------------------------------------------------

1:10                                      # operador : (paso de 1 en 1)
seq(1, 11, by = 2)                        # con tamaño de paso
seq(from = 0, to = 10, length.out = 11)   # con número de elementos
# El tamaño del salto es (to - from) / (length.out - 1)
# length.out = 11 -> 10 "huecos" de tamaño 1
seq(from = 0, to = 10, length.out = 21)   # 20 huecos de tamaño 0.5

# -----------------------------------------------------------------------------
# 3. Matrices
# -----------------------------------------------------------------------------
# Una matriz es un vector con dos dimensiones (filas x columnas).
# Igual que el vector, es HOMOGÉNEA: todos los elementos del mismo tipo.

valores <- 1:8                                     # (es un vector, no una lista)

matrix(valores, nrow = 2, ncol = 4, byrow = TRUE)  # rellena por FILA
matrix(valores, nrow = 2, ncol = 4, byrow = FALSE) # rellena por COLUMNA (default)

matrix("hola", nrow = 3, ncol = 4)                 # recicla el valor único

# Si el vector no "cabe" exacto, R recicla y lanza una ADVERTENCIA:
# (descomenta para verla)
# matrix(1:20, nrow = 10, ncol = 3)   # 30 celdas, 20 datos -> warning

# Dimensiones y nombres
matriz_resultados <- matrix(c(1, 2, 3, 4), nrow = 2, ncol = 2,
                            dimnames = list(c("modelo1", "modelo2"),
                                            c("estimacion", "error_est")))
matriz_resultados
dim(matriz_resultados)    # filas y columnas
nrow(matriz_resultados)
ncol(matriz_resultados)

# ---------- Arrays (arreglos N-dimensionales) ----------
# Generalización de la matriz a más dimensiones (ej: región x año x variable)

arreglo <- array(1:12, dim = c(2, 2, 3))
arreglo
arreglo[1, 2, 3]          # elemento en fila 1, columna 2, "capa" 3

# -----------------------------------------------------------------------------
# 4. Listas (la estructura HETEROGÉNEA)
# -----------------------------------------------------------------------------
# A diferencia de vectores y matrices, una lista puede mezclar de todo:
# números, textos, matrices... incluso otras listas.

resultados_regresion <- list(
  n            = 150,
  variables    = c("educacion", "experiencia"),
  significativa = TRUE,
  coeficientes = matrix(c(0.08, 0.02, 0.03, 0.01), nrow = 2,
                        dimnames = list(c("educacion", "experiencia"),
                                        c("beta", "error_est")))
)

str(resultados_regresion)   # str() = radiografía de cualquier objeto

# -----------------------------------------------------------------------------
# 5. Indexación y acceso
# -----------------------------------------------------------------------------

# ---------- Vectores ----------
ingresos <- c(10, 20, 30, 40, 50)

ingresos[1]              # primer elemento
ingresos[2:4]            # del 2 al 4
ingresos[-2]             # todos MENOS el segundo (índice negativo = excluir)
ingresos[c(1, 3, 5)]     # posiciones específicas

# ---------- Indexación LÓGICA (filtrado) ----------
# La más importante para análisis de datos: seleccionar según una condición.

ingresos > 25                    # vector lógico, elemento a elemento
ingresos[ingresos > 25]          # ¡filtro! solo los que cumplen la condición

which(ingresos > 25)             # ¿en qué POSICIONES se cumple?

# También sirve para REEMPLAZAR según condición:
ingresos_editado <- ingresos
ingresos_editado[ingresos_editado < 25] <- NA   # censura los menores a 25
ingresos_editado

# Truco clave: TRUE vale 1 y FALSE vale 0, entonces...
sum(ingresos > 25)               # ¿CUÁNTOS cumplen la condición?
mean(ingresos > 25)              # ¿qué PROPORCIÓN cumple? (¡muy usado!)
sum(is.na(ingresos_editado))     # ¿cuántos NA hay?

# ---------- Listas: [ ] vs [[ ]] vs $ ----------
lista_encuesta <- list(
  edad    = c(25, 32, 41),
  ciudad  = "Bogotá",
  ocupado = TRUE
)

lista_encuesta[1]              # devuelve una LISTA con el primer elemento
lista_encuesta[[1]]            # devuelve el CONTENIDO (el vector)
lista_encuesta$edad            # acceso por nombre (equivale a [[ ]])
lista_encuesta[["edad"]]       # equivalente por nombre

# Agregar y eliminar elementos de una lista:
lista_encuesta$telefono <- "123-456-789"   # agrega un elemento nuevo
lista_encuesta$ocupado  <- NULL            # NULL elimina el elemento
str(lista_encuesta)

# ---------- Matrices: [fila, columna] ----------
matriz_ejemplo <- matrix(1:9, nrow = 3, ncol = 3)
matriz_ejemplo

matriz_ejemplo[3, 2]        # fila 3, columna 2
matriz_ejemplo[2, ]         # segunda fila completa
matriz_ejemplo[, 3]         # tercera columna completa
matriz_ejemplo[1:2, 2:3]    # submatriz
matriz_ejemplo[-2, -2]      # elimina fila 2 y columna 2 ("esquinas")

matriz_resultados["modelo1", "error_est"]   # acceso por nombre
matriz_resultados["modelo1", ]

# Modificar celdas:
matriz_ejemplo[1, 1] <- 30
matriz_ejemplo
matriz_ejemplo <- 2 * matriz_ejemplo   # opera sobre TODA la matriz
matriz_ejemplo

# -----------------------------------------------------------------------------
# 6. Inspección y coerción (conversión de tipos)
# -----------------------------------------------------------------------------

a <- 10
b <- "11"

typeof(a)          # "double" (sin sufijo L)
class(b)           # "character"
is.numeric(a)      # familia is.*: preguntas de tipo (devuelven TRUE/FALSE)
is.character(b)
is.na(NA)

# Coerción EXPLÍCITA con as.*  (Clase 1: as.numeric; hoy generalizamos)
as.numeric("8") + as.numeric("10")   # 18
as.character(8)                      # "8"
as.numeric("hola")                   # NA + warning: no todo es convertible
as.integer(3.9)                      # 3 -> ¡TRUNCA, no redondea!
round(3.9)                           # 4 -> para redondear, round()

# -----------------------------------------------------------------------------
# 7. Operaciones entre objetos
# -----------------------------------------------------------------------------

# 1) Aritmética vectorizada (elemento a elemento) — repaso rápido de Clase 1
x <- c(1, 2, 3, 4)
y <- c(10, 20, 30, 40)
x + y
x * y
x ^ 2
x %% 2                     # módulo: el RESIDUO de dividir entre 2 (par = 0)

# 2) Recycling rule: si un vector es más corto, R lo RECICLA
z <- c(100, 200)
x + z                      # = c(1+100, 2+200, 3+100, 4+200)

# Si la longitud no es múltiplo exacto, R igual recicla pero ADVIERTE:
z_impar <- c(100, 200, 300)
x + z_impar                # warning: longitudes no son múltiplos

# 3) Comparaciones y operadores lógicos
x > 2
x == c(1, 5, 3, 9)         # == compara, = asigna (¡no confundir!)
x != 2
(x > 2) & (y <= 30)        # AND: ambas condiciones
(x > 2) | (y <= 30)        # OR: al menos una
!(x > 2)                   # negación

# 4) NA en operaciones de resumen
val <- c(1, 2, NA, 4)
sum(val)                   # NA (el NA "contamina" el resultado)
sum(val, na.rm = TRUE)     # 7  (na.rm = TRUE ignora los NA)
mean(val, na.rm = TRUE)

# 5) Textos: no existe "suma" de caracteres, se CONCATENA con paste
s1 <- "Hola"; s2 <- "Mundo"
paste(s1, s2)              # "Hola Mundo"  (separador: espacio)
paste0(s1, "_", s2)        # "Hola_Mundo"  (sin separador)

# -----------------------------------------------------------------------------
# 8. Álgebra de matrices (¡el corazón de la econometría!)
# -----------------------------------------------------------------------------

A <- matrix(c(1, 2,
              3, 4), nrow = 2, byrow = TRUE)
B <- matrix(c(10, 20,
              30, 40), nrow = 2, byrow = TRUE)

A * B              # producto elemento a elemento (Hadamard)
A %*% B            # producto MATRICIAL (filas x columnas)
t(A)               # transpuesta
solve(A)           # inversa (si existe)
solve(A) %*% A     # verificación: A^-1 A = identidad
crossprod(A, B)    # t(A) %*% B  (así se calcula X'X en MCO)
tcrossprod(A, B)   # A %*% t(B)

# Aplicación: resolver un sistema de ecuaciones Ax = b
# (ej: equilibrio oferta-demanda con 2 mercados)
b_vec <- c(5, 6)
solve(A, b_vec)    


# -----------------------------------------------------------------------------
# 9. Simulación: distribuciones en R
# -----------------------------------------------------------------------------
# R genera datos aleatorios de casi cualquier distribución (prefijo r).
# set.seed() fija la "semilla" para que TODOS obtengamos lo mismo (replicabilidad).

set.seed(2026)

runif(10, min = 0, max = 100)          # Uniforme
rnorm(10, mean = 1, sd = 2)            # Normal
rbinom(10, size = 20, prob = 0.6)      # Binomial
rpois(10, lambda = 2)                  # Poisson
sample(c("M", "F"), size = 10, replace = TRUE)   # Muestreo con reemplazo

# Mini-ejemplo: simular ingresos y calcular pobreza
ingresos_sim <- rnorm(1000, mean = 2000, sd = 500)
mean(ingresos_sim < 1500)              # proporción bajo la "línea de pobreza"

# -----------------------------------------------------------------------------
# 10. Guardar y borrar objetos del ambiente
# -----------------------------------------------------------------------------
a <- 10
11 -> b                    # también funciona (pero mejor usar <-)

ls()                       # ¿qué hay en mi ambiente?
rm(a, b)                   # borrar objetos específicos
# rm(list = ls())          # borrar TODO el ambiente (con cuidado)

# -----------------------------------------------------------------------------
# Datos para ejercicios (insumo)
# -----------------------------------------------------------------------------

# Ejercicio 1
ventas_diarias      <- c("120", "150", "180", "140", "200")
categorias_producto <- c("A", "B", "A", "C", "B", "A")

# Ejercicio 3
datos_tienda <- list(
  ventas    = c(1500, 2000, 1800, 2200, 1900),
  productos = c("Laptop", "Mouse", "Teclado"),
  activo    = TRUE,
  ubicacion = list(
    ciudad    = "Bogotá",
    direccion = "Calle 123"
  )
)

# Ejercicio 5
datos_estudiantes <- list(
  nombres = c("Ana", "Juan", "María", "Carlos", "Laura"),
  notas   = matrix(
    c(85, 90, 88, 92, 78,
      76, 82, 89, 90, 85,
      90, 88, 82, 85, 87),
    nrow = 5, ncol = 3,
    dimnames = list(
      c("E1", "E2", "E3", "E4", "E5"),
      c("Parcial1", "Parcial2", "Final")
    )
  )
)

# -----------------------------------------------------------------------------
# Guía de ejercicios (enunciados)
# -----------------------------------------------------------------------------
# Ejercicio 1: Estructuras de Datos y Coerción
# 1) Convierte ventas_diarias a numérico
# 2) Crea un factor con categorias_producto
# 3) Calcula el promedio de ventas diarias (ya numérico)
# 4) ¿Cuántos niveles diferentes hay en categorias_producto?
#    (pista: levels() y length(), o table())

# Ejercicio 2: Matrices y Operaciones
# 1) Crea una matriz 3x3 con 1:9
# 2) Asigna nombres: filas = F1,F2,F3; cols = C1,C2,C3
# 3) Extrae la segunda fila completa
# 4) Calcula la transpuesta
# 5) Multiplica la matriz original por su transpuesta (ojo: %*%)

# Ejercicio 3: Listas y Acceso
# 1) Accede a las ventas con $
# 2) Extrae el segundo producto con [[]] y con []
# 3) Obtén la ciudad dentro de ubicacion
# 4) Agrega un elemento "telefono" = "123-456-789"

# Ejercicio 4: Vectorización y Operaciones Lógicas
# 1) Crea un vector 1:10
# 2) Vector lógico de mayores que 5
# 3) Usa ese lógico para filtrar > 5 (sección 5: indexación lógica)
# 4) Reemplaza los pares por NA (pista: x %% 2 == 0, sección 7)
# 5) Cuenta los NA con is.na() y sum()

# Ejercicio 5 (opcional): Simulación
# 1) Con set.seed(123), simula 500 salarios ~ Normal(media=2500, sd=800)
# 2) ¿Qué proporción gana menos de 1800?
# 3) Reemplaza por NA los salarios negativos (si los hay) y cuenta cuántos son
# =============================================================================
