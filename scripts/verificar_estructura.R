# Verificacion basica de la estructura del script maestro.
# Ejecutar desde la raiz del proyecto con:
# source("scripts/verificar_estructura.R")

archivos_maestros <- list.files(
  path = ".",
  pattern = "^Taller1_Grupo_.*[.]R$",
  full.names = TRUE
)

if (length(archivos_maestros) != 1) {
  stop("Debe existir exactamente un script maestro Taller1_Grupo_*.R")
}

script_maestro <- archivos_maestros[[1]]

# Detecta errores de sintaxis sin ejecutar las soluciones.
parse(file = script_maestro)

lineas <- readLines(script_maestro, warn = FALSE)
ejercicios <- paste("## Ejercicio", 1:20)

faltantes <- ejercicios[!vapply(
  ejercicios,
  function(encabezado) any(startsWith(lineas, encabezado)),
  logical(1)
)]

if (length(faltantes) > 0) {
  stop(paste("Faltan encabezados:", paste(faltantes, collapse = ", ")))
}

posiciones <- vapply(
  ejercicios,
  function(encabezado) which(startsWith(lineas, encabezado))[[1]],
  integer(1)
)

if (is.unsorted(posiciones)) {
  stop("Los ejercicios no se encuentran en orden del 1 al 20")
}

message("Estructura correcta: sintaxis valida y ejercicios 1 a 20 en orden.")

