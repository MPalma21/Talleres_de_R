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

## 9. Outputs y Matriz de Auditoría de Archivos

Los productos solicitados deben generarse directamente desde el script oficial `Taller2_Grupo_10.R`, guardarse en la carpeta raíz `outputs/` y tener nombres asociados al numeral correspondiente. La siguiente matriz clasifica los 31 archivos conservados en la carpeta según su función evaluativa y técnica:

| Archivo | Numeral | Categoría | Función y Justificación |
|---|---|---|---|
| `2_1_tasas_hombres.xlsx` | 2.1 | Entregable obligatorio | Tabla Excel de indicadores laborales para hombres (2023-2024). |
| `2_1_tasas_mujeres.xlsx` | 2.1 | Entregable obligatorio | Tabla Excel de indicadores laborales para mujeres (2023-2024). |
| `2_2_tasas_sexo.png` | 2.2 | Entregable obligatorio | Gráfico de serie de tiempo de TGP, TO y TD por sexo en paneles. |
| `2_3_formalidad_13ciudades.png` | 2.3 | Entregable obligatorio | Gráfico circular de distribución de formalidad en 13 ciudades (Dic 2024). |
| `2_4_posicion_nacional.png` | 2.4 | Entregable obligatorio | Gráfico de barras horizontales de posición ocupacional (Ene 2023). |
| `3_1_indicadores.xlsx` | 3.1 | Entregable obligatorio | Tabla Excel de caracterización estructural de micronegocios (2024). |
| `3_2_formas_pago.png` | 3.2 | Entregable obligatorio | Gráfico de barras apiladas de medios de pago por rama de actividad. |
| `3_3_cruce.png` | 3.3 | Entregable obligatorio | Gráfico del análisis conjunto GEIH-EMICRON (Educación vs. Tenencia de RUT). |
| `4_1_geografia_informalidad.png` | 4.1 | Entregable obligatorio | Gráfico de dispersión departamental de informalidad vs. ingreso mediano. |
| `4_2_inclusion_ventas_micro.png` | 4.2 | Entregable obligatorio | Diagrama de cajas de ventas mensuales según adopción digital y crédito. |
| `4_3_desigualdad_lorenz.png` | 4.3 | Entregable obligatorio | Curvas de Lorenz de ingreso laboral comparadas por dominio geográfico. |
| `4_3_mismatch_educacion.png` | 4.3 | Apoyo ejercicio libre | Gráfico alternativo de desajuste educativo por posición ocupacional. |
| `1_1_verificacion_llaves.csv` | 1.1 | Verificación auditable | Auditoría mensual de unicidad de llave en los 4 módulos de GEIH. |
| `1_1_verificacion_pegues.csv` | 1.1 | Verificación auditable | Control mensual de no multiplicación de filas tras left_join. |
| `1_1_eficiencia.csv` | 1.1 | Verificación auditable | Evidencia de reducción de columnas antes y después de select(). |
| `1_2_descripcion_geih_2024.csv` | 1.2 | Insumo de informe | Tabla 1 del informe: tamaño mensual de módulos y total anual 2024. |
| `1_2_consistencia_laboral_2024.csv` | 1.2 | Verificación auditable | Validación de identidades laborales (PET = FT + FFT; FT = Ocup + Desoc). |
| `1_3_diccionario_variables.csv` | 1.3 | Insumo de informe | Tabla 2 del informe: diccionario de variables analíticas de la GEIH. |
| `1_4_relacion_orden.csv` | 1.4.c | Verificación auditable | Evidencia empírica de equivalencia SECUENCIA_ENCUESTA == ORDEN (100 %). |
| `1_4_relacion_meses.csv` | 1.4.c | Verificación auditable | Evidencia empírica de desfase temporal MES_REF == MES_GEIH + 1. |
| `1_4_auditoria_mensual.csv` | 1.4.f | Insumo de informe | Tabla 3 del informe: auditoría mensual de enlace y no emparejados. |
| `1_4_fuera_2024.csv` | 1.4.f | Verificación auditable | Demostración de que no emparejados de Ene 2024 provienen de Dic 2023. |
| `1_4_posicion_ocupacional.csv` | 1.4.g | Insumo de informe | Distribución de posición ocupacional GEIH en propietarios de EMICRON. |
| `2_1_consistencia_tasas.csv` | 2.1 | Verificación auditable | Comprobación de que FT = Ocupados + Desocupados en datos expandidos. |
| `2_3_control_ei_dane.csv` | 2.3 | Verificación auditable | Validación exacta frente al DANE (42,5 % informalidad, 0,0 pp diferencia). |
| `2_3_tabla_formalidad_13ciudades.csv` | 2.3 | Insumo de informe | Cifras expandidas de personas formales e informales por sexo. |
| `3_2_credito_ahorro.csv` | 3.2 | Insumo de informe | Porcentajes de solicitud de crédito (P1765) y ahorro (P3014) en micronegocios. |
| `3_3_tabla_educacion_rut.csv` | 3.3 | Insumo de informe | Tabla de contingencia expandida de nivel educativo por registro en RUT. |
| `4_1_tabla_departamental.csv` | 4.1 | Insumo de informe | Datos agregados por departamento para el análisis espacial libre. |
| `4_2_tabla_inclusion_ventas.csv` | 4.2 | Insumo de informe | Estadísticas descriptivas de ventas por perfil de inclusión financiera. |
| `4_3_tabla_mismatch_educacion.csv` | 4.3 | Insumo de informe | Distribución de niveles educativos por posición ocupacional. |

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
