# =============================================================================
# Clase 1: Introducción a R
# Profesor : Santiago Neira 
# Objetivos:
# - Primeros pasos en R y RStudio
# - Reconocer tipos básicos de datos
# - Crear y trabajar con vectores
# - Operaciones aritméticas básicas
# =============================================================================

# -----------------------------------------------------------------------------
# Preliminares
# -----------------------------------------------------------------------------
# Las líneas con # son comentarios
# Ejecuta código con Ctrl+Enter (Windows) o Cmd+Enter (Mac)

10 * 5  # Tu primera operación

# -----------------------------------------------------------------------------
# Tipos de Datos Básicos
# -----------------------------------------------------------------------------

# ---------- Números ----------
print(42)
print(3.14)

typeof(42)       # "double"
typeof(42L)

# ---------- Texto (character) ----------

print("Hola Mundo")
typeof("Hola Mundo")  # "character"

# ---------- Lógicos ----------

print(TRUE)
print(FALSE)
typeof(TRUE)     # "logical"

# ---------- Valores faltantes (NA) ----------

print(NA)

# -----------------------------------------------------------------------------
# Vectores (la estructura fundamental de R)
# -----------------------------------------------------------------------------

# Crear vectores con c() ## Todo objeto se puede volver string - Engloba a todos los objetos
## Todo número puede volverse decimal 
## Todo booleano se puede volver número
## Booleano -> Entero -> Double -> Texto 

c(1, 2, 3, 4, 5)

c(1,2,"hola")

c(1,2,1.4)

c("Ana", "Juan", "María")

c(TRUE, FALSE, TRUE)

c(TRUE, 1,2)

c(TRUE, 1, "Maria")

# Secuencias rápidas

1:10                    # Del 1 al 10

seq(0, 100, by = 10)    # De 0 a 100, de 10 en 10

# -----------------------------------------------------------------------------
# Guardar objetos
# -----------------------------------------------------------------------------

edades <- c(20, 25, 30, 35, 40)

palabras = c("pasa","algo?")

c(TRUE, TRUE) -> booleanos

print(edades)

nombres <- c("Ana", "Juan", "María", "Carlos", "Laura")

print(edades)
print(nombres)

## rm(list=ls()) - Borra todo lo que está en ambiente

# -----------------------------------------------------------------------------
# Acceso a elementos de un vector
# -----------------------------------------------------------------------------

edades[1]           # Primer elemento

edades[3]           # Tercer elemento

edades[2:4]         # Del segundo al cuarto

edades[c(1, 3, 5)]  # Elementos 1, 3 y 5


# -----------------------------------------------------------------------------
# Operaciones Aritméticas con vectores
# -----------------------------------------------------------------------------

# Con un solo número
ventas <- c(100, 150, 200, 180, 220)

ventas + 10         # Suma 10 a cada elemento

ventas - 20         # Resta 20 a cada elemento

ventas * 1.19       # Multiplica cada elemento por 1.19

ventas / 2          # Divide cada elemento entre 2

# Entre vectores (elemento a elemento)

precios <- c(10, 20, 15, 25, 30)

cantidades <- c(5, 10, 8, 12, 15)

precios * cantidades  # Multiplica elemento por elemento

precios[5]*cantidades[5]

##precio del 2do elemento por la cuarta cantidad
precios[2]*cantidades[4]

##precios[-1]

# -----------------------------------------------------------------------------
# Conversiones básicas
# -----------------------------------------------------------------------------
numero_texto <- "123"
class(numero_texto)              # "character"

numero <- as.numeric(numero_texto)
class(numero)                    # "numeric"

numero_texto <- as.numeric(numero_texto)

# -----------------------------------------------------------------------------
# Ejercicios de Práctica
# -----------------------------------------------------------------------------

# Datos para practicar
ventas_semana <- c("150", "200", "180", "220", "190")
precios_productos <- c(50, 75, 100, 125, 150)

# Ejercicio 1: Conversión
# 1) Convierte ventas_semana a numérico y guárdalo

# Ejercicio 2: Operaciones básicas
# 1) Crea un vector con las edades de 5 personas
# 2) Suma 5 años a todas las edades


# Ejercicio 3: Precios
# 1) Aplica un descuento del 20% a precios_productos (multiplica por 0.8)
# 2) Aplica IVA del 19% a los precios originales (multiplica por 1.19)

# =============================================================================