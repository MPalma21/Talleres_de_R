# Estructura del Directorio y Reglas de Revisión - Taller 2

## 0. Estructura Modular de la Entrega

El directorio `Entregable_Talleres/Taller_2/` está organizado de forma modular para garantizar claridad evaluativa, reproducibilidad y orden pedagógico:

```text
Entregable_Talleres/Taller_2/
├── Taller2_Grupo_10.R                 # Script oficial de R para calificación (100% autónomo y ejecutable)
├── Informe_Taller_2_Grupo_10.pdf      # Copia raíz del informe ejecutivo final (8 páginas)
├── README.md                          # Guía de organización, reglas metodológicas y outline
├── 01_informe_quarto/                 # Fuentes del informe ejecutivo de entrega
│   ├── Informe_Taller_2_Grupo_10.qmd
│   ├── Informe_Taller_2_Grupo_10.pdf
│   └── Informe_Taller_2_Grupo_10_figuras/
├── 02_cuaderno_pedagogico/            # Cuaderno Quarto interactivo alineado con la Guía Pedagógica
│   ├── Taller2_Cuaderno_Pedagogico.qmd
│   └── Taller2_Cuaderno_Pedagogico.html
├── 03_material_apoyo/                 # Insumos de estudio y preparación de entrevista
│   ├── Guia_Estudio_Academica_Taller2.qmd (.pdf)
│   ├── Propuestas_Graficas_Punto4.qmd (.pdf)
│   └── graficas_catalogo/
└── 04_guia_maestra_estudio/            # Guía Maestra de Estudio integral e interdisciplinaria
    └── Guia_Maestra_Estudio_Taller2.qmd
```

*Nota sobre la carpeta de salidas:* Todas las tablas (`.xlsx`, `.csv`) y gráficos (`.png`) generados por el script y los cuadernos se almacenan de manera unificada en la carpeta `outputs/` ubicada en la raíz del repositorio.

---

## 1. Fuente de autoridad

El enunciado define qué debe responderse. Los scripts y materiales de las
clases definen cómo puede resolverse. No se deben agregar herramientas,
funciones o enfoques externos al curso.

## 2. Estructura del outline

La jerarquía del script debe seguir esta forma:

```text
# Punto ----
## Numeral ----
### Literal ----
#### Subsección técnica ----
```

Cuando el enunciado tenga literales, deben reproducirse exactamente y de forma
visible. Cuando no tenga literales, no se deben inventar. Todos los encabezados
del outline deben terminar en `----`.

## 3. Correspondencia con el enunciado

Cada bloque de código debe responder a un requisito identificable del taller.
Antes de agregar código se debe preguntar: "¿Qué parte del enunciado exige
esto?" Si no existe una respuesta concreta, no se agrega.

## 4. Herramientas permitidas

Solo se pueden utilizar R base, funciones vistas en las clases y paquetes
trabajados explícitamente en clase. Entre los materiales disponibles aparecen:

- `here`
- `dplyr`
- `tidyr`
- `readr`
- `openxlsx`
- `ggplot2`
- `lubridate`

Que un paquete aparezca en esta lista no significa que deba utilizarse. Se
elige la herramienta más sencilla que sea necesaria para el literal.

## 5. Principio de mínima intervención

Se debe evitar la sobreingeniería, la programación defensiva frente a casos
inexistentes, las funciones auxiliares innecesarias, las variables temporales
sin propósito, las verificaciones duplicadas, los análisis no solicitados, las
recodificaciones exhaustivas sin evidencia y el adelanto de puntos posteriores.

## 6. Inspección de datos

Antes de transformar una variable se debe revisar cómo viene realmente. Se
verifica su clase y sus valores cuando sea necesario, y se realiza únicamente
la transformación mínima que los datos y el enunciado justifiquen.

## 7. Loops y joins

Se debe conservar una lógica clara en los loops, verificar las llaves
solicitadas y revisar duplicados cuando corresponda. Cuando el enunciado exija
preservar filas, se debe comprobar que los joins no las multipliquen. No se
construyen llaves artificiales.

## 8. Rutas

Se mantiene una única ruta base y todas las rutas se derivan de ella. No se
introducen rutas absolutas personales.

## 9. Outputs

Los productos solicitados deben generarse desde el script, guardarse en
`outputs` y tener nombres asociados al numeral correspondiente. No se generan
outputs adicionales sin una razón clara. Los outputs históricos no se borran
ni se modifican manualmente.

## 10. Comentarios

Los comentarios deben explicar decisiones metodológicas y permitir relacionar
el código con el enunciado. Deben ser breves y no explicar sintaxis obvia línea
por línea. Todo bloque ejecutable debe quedar bajo un encabezado del outline o
acompañado por un comentario breve que indique su propósito dentro del taller.

## 11. No adelantar soluciones

Se conservan las variables necesarias para puntos posteriores, pero no se
resuelven anticipadamente sus numerales, indicadores, gráficos o análisis.

## 12. Validación

Antes de considerar terminado un cambio se debe:

- ejecutar desde una sesión limpia;
- comprobar la sintaxis;
- comprobar que las rutas funcionen;
- verificar que se mantengan los resultados correctos;
- revisar que cada literal solicitado sea identificable en el outline.

## 13. Uso de IA

La IA puede utilizarse para revisar, editar o refinar código previamente
elaborado por el grupo. No debe utilizarse para delegar la elaboración
sustantiva de soluciones. Todo uso debe declararse según las reglas del
taller.
