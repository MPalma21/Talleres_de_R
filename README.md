# Talleres de Programación en R (2026-02)

Repositorio de trabajo del **Grupo 10** para el desarrollo, control de versiones, análisis y documentación de los talleres del curso *Taller de Programación en R* de la Maestría en Economía Aplicada (MECA) en la Universidad de los Andes.

---

## Integrantes del Grupo 10

* **Juan José Echeverry** – Código: `202616233`
* **Miguelangel Palma** – Código: `202621481`
* **Sergio López** – Código: `202111932`

---

## Estructura del Repositorio

```text
Talleres_de_R/
├── README.md                          # Documentación maestra del repositorio
├── Entregables_R.Rproj                # Proyecto RStudio (gestión de rutas con here)
├── Enunciado_Talleres/                # Enunciados oficiales en PDF (Talleres 1 y 2)
│   ├── Taller 1 2026-02 - Enunciado.pdf
│   └── Taller 2 2026-02 - Enunciado.pdf
├── librerias/                         # Cheatsheets y documentación oficial en PDF
├── scripts_clase/                     # Scripts pedagógicos de las Clases 01 a 07
├── scripts/
│   └── verificar_estructura.R        # Comprobación de sintaxis y orden de ejercicios
├── Datos/                             # Microdatos del DANE (no modificados)
│   ├── GEIH_2023/                     # 12 meses de recolección GEIH 2023
│   ├── GEIH_2024/                     # 12 meses de recolección GEIH 2024
│   └── EMICRON_2024/                  # Módulos oficiales de micronegocios 2024
├── outputs/                           # Tablas (.csv, .xlsx) y figuras (.png) exportadas
├── evidencias_IA/                     # Conversaciones y evidencias de soporte en IA
└── Entregable_Talleres/
    ├── Taller_1/
    │   └── Taller1_Grupo_10.R         # Script maestro del Taller 1 (20 ejercicios)
    └── Taller_2/
        ├── README.md                  # Reglas de estilo, outline y buenas prácticas
        ├── Taller2_Grupo_10.R         # Script maestro del Taller 2 (Puntos 0 al 4)
        ├── Informe_Taller_2_Grupo_10.qmd # Fuente Quarto del informe académico
        └── Informe_Taller_2_Grupo_10.pdf # Documento final compilado (8 págs + anexo)
```

---

# Taller 2: Mercado Laboral y Micronegocios en Colombia

## Fechas y Ponderación

* **Entrega de entregables:** Archivos `Taller2_Grupo_10.R`, `Informe_Taller_2_Grupo_10.pdf` y carpeta `outputs/`.
* **Sesión individual de entrevista:** Semana 10 (miércoles 14 de octubre de 2026, horario de clase).
* **Ponderación:** 50 % Evaluación práctica (código, outputs e informe) + 50 % Sesión individual de entrevista (2,5 puntos cada componente sobre 5,0, con opción de hasta 0,25 de bono en el Punto 4).

---

## Distribución de Responsabilidades – Taller 2

| Punto / Numeral | Responsable Principal | Temática Abordada | Responsabilidad Adicional |
|:---|:---|:---|:---|
| **1.1 Pegue GEIH** | Juan José Echeverry | Lógica de bucles anidados, preservación de tildes UTF-8, pre-filtrado en RAM y controles defensivos. | Verificar `1_1_eficiencia.csv` y controles de no duplicidad de llaves ni multiplicación de filas. |
| **1.2 Descripción GEIH** | Sergio López & Miguelangel Palma | Universos muestrales, identidades laborales PET = FT + FFT y FT = OCI + DSI. | Contrastar filtros del cuestionario DANE y verificar consistencia mes a mes. |
| **1.3 Base Analítica** | Sergio López | Diccionario de variables analíticas, etiquetado y diferenciación conceptual de `DPTO`, `AREA` y `CLASE`. | Comprobar bidireccionalmente que la base contenga exactamente las variables solicitadas. |
| **1.4 Pegue EMICRON** | Grupo 10 | Integración relacional, demostración empírica de la llave, desfase temporal de un mes y auditoría. | Documentar la correspondencia 1-a-1 de `SECUENCIA_ENCUESTA == ORDEN` y auditar el mes de enero en GEIH 2023. |
| **2.1 Tasas Laborales** | Juan José Echeverry | Poblaciones promedio trimestrales con `FEX_C18 / 3`, fórmulas DANE (TGP, TO, TD) y tablas Excel cronológicas. | Verificar la consistencia aditiva `FT = Ocupados + Desocupados` con diferencia cero. |
| **2.2 Series de Tiempo** | Juan José Echeverry | Gráfico facetado de series de tiempo, brechas estructurales de género y descomposición analítica de la TD. | Interpretar la dinámica conjunta de oferta (TGP) y demanda (TO) en la variación del desempleo. |
| **2.3 Formalidad 13 Ciudades** | Miguelangel Palma | Traducción de sintaxis oficial `Código_SAS` de la variable `EI`, validación contra el DANE y gráfico de torta. | Contrastar con el boletín oficial octubre-diciembre 2024 (42,5 % exacto) y evaluar diciembre 2024. |
| **2.4 Posición Ocupacional** | Sergio López | Distribución de ocupados en enero 2023 para total nacional y según sexo (gráfico de barras horizontales). | Identificar que cuenta propia y patrones concentran 43,2 %, justificando el marco de EMICRON. |
| **3.1 Indicadores Básicos** | Miguelangel Palma | Universo de micronegocios con `F_EXP`, composición sectorial, sexo del propietario, RUT y Cámara de Comercio. | Validación obligatoria frente a boletín DANE (coincidencia exacta en 5.297.252 micronegocios). |
| **3.2 Inclusión Financiera** | Sergio López | Bucle `for` sobre las 7 variables de medios de pago por rama (`GRUPOS4`), acceso a crédito y ahorro. | Evitar duplicación de código e interpretar la brecha de infraestructura transaccional (<200 palabras). |
| **3.3 Cruce GEIH–EMICRON** | Juan José Echeverry | Formulación de pregunta analítica (educación vs RUT), uso exclusivo de `F_EXP`, ventana efectiva feb-dic 2024. | Delimitar universo (71.754 micros) y explicar factores mediadores económicos no causales. |
| **4.1 Divergencia Territorial** | Sergio López | Ejercicio libre: Dualismo laboral y salarial departamental (Scatter + LOESS). | Analizar la correlación no lineal entre tasa de informalidad y mediana de ingreso laboral. |
| **4.2 Inclusión Digital** | Miguelangel Palma | Ejercicio libre: Escala de ventas de micronegocios según pagos electrónicos y crédito (Violín + Boxplot log). | Contrastar medianas de venta y sustentar con teoría de scoring alternativo y asimetrías de información. |
| **4.3 Desigualdad Salarial** | Juan José Echeverry | Ejercicio libre: Curvas de Lorenz de la masa salarial y coeficientes de Gini urbano vs rural. | Discutir el contraste de Gini (0,475 en cabeceras vs 0,433 en rural) y la nivelación hacia abajo en el campo. |

---

## Principios Metodológicos y Reglas de Desarrollo

1. **Ruta base única:** Todo el script maestro deriva sus ubicaciones a partir de `ruta <- here()`. No existen rutas absolutas locales ni dependencias fijadas a disco personal.
2. **Herramientas autorizadas:** Se utiliza exclusivamente R base y paquetes trabajados explícitamente en el curso (`here`, `dplyr`, `tidyr`, `ggplot2`, `openxlsx`, `lubridate`).
3. **Manejo eficiente de memoria:**
   * Pre-filtrado inmediato con `select()` antes de ejecutar los merges mensuales, reduciendo las bases de ~200 a ~25 variables.
   * Limpieza de objetos intermedios y almacenamiento estructurado en listas.
   * Evidencia documentada en `outputs/1_1_eficiencia.csv`.
4. **Preservación de registros y llaves oficiales:**
   * Se comprueba programáticamente que ningún pegue multiplique filas ni admita llaves duplicadas (`stop()` defensivo).
   * No se construyen llaves artificiales ni se eliminan registros para forzar emparejamientos.
5. **Uso estricto de factores de expansión:**
   * En GEIH se utiliza `FEX_C18` (ajustado como `FEX_C18 / 3` para trimestres y `FEX_C18 / 12` para análisis anual).
   * En EMICRON y en el análisis conjunto (Punto 3.3 y 4.2) se utiliza **exclusivamente `F_EXP`**, evitando la mezcla indebida de ponderadores.
6. **Cumplimiento estricto del límite de páginas:**
   * El informe compilado (`Informe_Taller_2_Grupo_10.pdf`) tiene **exactamente 8 páginas de reporte analítico** + **1 página de Anexo de IA** (con contador reiniciado a 1).

---

## Principales Hallazgos y Cifras de Validación Oficial (DANE)

* **Mercado Laboral GEIH 2024:**
  * Muestra anual: 829.683 personas en General; 657.803 en PET; 353.672 Ocupados; 304.131 No ocupados.
  * Consistencia perfecta: $\text{PET} = \text{FT} + \text{FFT}$ y $\text{FT} = \text{OCI} + \text{DSI}$ con diferencia cero en los 12 meses.
  * Relación macroeconómica verificada: $\text{TD} = 1 - \frac{\text{TO}}{\text{TGP}}$, demostrando que la caída del desempleo a fin de año (7,06 % en hombres y 11,15 % en mujeres) responde a absorción efectiva de empleo.
* **Integración GEIH–EMICRON:**
  * La llave común es `DIRECTORIO + SECUENCIA_P + ORDEN`, tras comprobar que `SECUENCIA_ENCUESTA == ORDEN` en el 100 % de los casos.
  * Relación temporal: $\text{MES\_REF} = \text{MES}_{\text{GEIH}} + 1$ en el 100 % de los registros comparables (un mes adelante).
  * 71.754 micronegocios emparejados en 2024 (91,41 %). Los 6.747 no emparejados corresponden en su totalidad a enero de 2024, cuyas entrevistas ocurrieron en diciembre de 2023 (100 % localizados en GEIH 2023).
  * Validación independiente: 100 % de coincidencia en sexo (`P35` vs `P3271`), edad (`P241` vs `P6040`) y clase (`CLASE_TE` vs `CLASE`).
* **Formalidad Laboral (13 ciudades):**
  * La traducción de la sintaxis oficial `Código_SAS` arrojó una tasa de informalidad del **42,5 %** en octubre–diciembre de 2024, idéntica a la publicada en el boletín del DANE (diferencia de 0,0 pp).
  * Diciembre 2024: 42,2 % en hombres y 42,3 % en mujeres.
* **Micronegocios EMICRON 2024:**
  * Total nacional: **5.297.252 micronegocios** (coincidencia exacta con el DANE).
  * Comercio (23,9 %) y agro (21,5 %) lideran el tejido empresarial.
  * Formalidad tributaria (RUT): 22,4 %; registro mercantil (Cámara): 10,3 %.
  * Inclusión financiera: efectivo ubicuo (>85-94 %); transferencias/billeteras alcanzan 51,9 % en servicios pero caen a 6,7 % en el agro. Acceso a crédito formal: 14,2 %; ahorro: 18,1 %.
* **Cruce Conjunto GEIH–EMICRON (Punto 3.3):**
  * Gradiente positivo monótono de tenencia de RUT: 2,8 % en sin educación $\rightarrow$ 12,6 % en primaria $\rightarrow$ 30,4 % en secundaria $\rightarrow$ 75,0 % en superior/posgrado.
  * Mediadores económicos no causales: escala de ventas y requerimientos formales de la rama de actividad.
* **Análisis Socioeconómico Libre (Punto 4):**
  * **4.1 Dualismo territorial:** Correlación negativa no lineal entre informalidad e ingresos (Bogotá: 34,6 % informalidad y \$1,6M COP mediana vs Chocó/La Guajira: >79-83 % informalidad y \$600.000 COP mediana).
  * **4.2 Inclusión digital:** Micronegocios con pagos electrónicos y crédito alcanzan medianas de \$4,5 a \$5,2M COP vs \$1,38M COP en unidades de solo efectivo sin crédito.
  * **4.3 Desigualdad salarial:** Coeficiente de Gini salarial de 0,475 en cabeceras urbanas vs 0,433 en áreas rurales (nivelación precaria hacia abajo en el campo).

---

## Instrucciones de Reproducción y Ejecución

### 1. Ejecutar el Script Maestro de R
Abrir el proyecto en RStudio (`Entregables_R.Rproj`) o ejecutar desde una sesión limpia de R:
```R
# Limpiar el entorno y verificar sintaxis
rm(list = ls())
parse("Entregable_Talleres/Taller_2/Taller2_Grupo_10.R")

# Ejecutar el procesamiento completo
source("Entregable_Talleres/Taller_2/Taller2_Grupo_10.R")
```
El script genera de manera autónoma la totalidad de las 38 tablas y figuras en la carpeta `outputs/`.

### 2. Compilar el Informe Académico en Quarto a PDF
Desde la terminal en la raíz del proyecto:
```bash
quarto render "Entregable_Talleres/Taller_2/Informe_Taller_2_Grupo_10.qmd"
```
Requisitos de compilación: Quarto CLI y distribución LaTeX con soporte para XeLaTeX (TinyTeX o MacTeX con paquetes `babel-spanish`, `booktabs`, `fancyhdr`, `titlesec`, `openxlsx`, `png`, `knitr`).

---

## Declaración sobre Uso de Inteligencia Artificial

De acuerdo con las directrices del curso y los lineamientos de la Universidad de los Andes (Nivel 3 de IAG), las herramientas de inteligencia artificial generativa se utilizaron exclusivamente como apoyo para la edición de estilo, revisión gramatical, formateo de tablas en LaTeX y verificación cruzada de consistencia sintáctica. La autoría, las decisiones metodológicas, la lógica de los algoritmos y la interpretación sustantiva son responsabilidad íntegra de los integrantes del Grupo 10. Las evidencias completas reposan en `evidencias_IA/` y en el anexo final del informe.
