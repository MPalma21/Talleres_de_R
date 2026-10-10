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
        ├── README.md                     # Reglas de estilo, outline y matriz de outputs
        ├── Taller2_Grupo_10.R            # Script maestro del Taller 2 (Puntos 0 al 4)
        ├── Informe_Taller_2_Grupo_10.pdf # Copia raíz del informe compilado (8 págs + anexo)
        ├── 01_informe_quarto/            # Fuente Quarto (.qmd) y PDF del informe académico
        ├── 02_cuaderno_pedagogico/       # Cuaderno pedagógico interactivo (.qmd y .html)
        └── 04_guia_maestra_estudio/      # Guía maestra de estudio (.qmd, .html y .pdf)
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
| **1.3 Base Analítica** | Sergio López | Diccionario de variables analíticas, etiquetado con las 13 categorías explícitas de `P3042` y diferenciación de `DPTO`, `AREA` y `CLASE`. | Comprobar bidireccionalmente que la base contenga exactamente las variables solicitadas. |
| **1.4 Pegue EMICRON** | Grupo 10 | Integración relacional, demostración empírica de la llave, desfase temporal de un mes y auditoría. | Documentar la correspondencia 1-a-1 de `SECUENCIA_ENCUESTA == ORDEN` y auditar el mes de enero en GEIH 2023. |
| **2.1 Tasas Laborales** | Juan José Echeverry | Poblaciones promedio trimestrales con `FEX_C18 / 3`, fórmulas DANE (TGP, TO, TD) y tablas Excel cronológicas. | Verificar la consistencia aditiva `FT = Ocupados + Desocupados` con diferencia cero. |
| **2.2 Series de Tiempo** | Juan José Echeverry | Gráfico facetado de series de tiempo, brechas estructurales de género y descomposición analítica de la TD. | Interpretar la dinámica conjunta de oferta (TGP) y demanda (TO) en la variación del desempleo. |
| **2.3 Formalidad 13 Ciudades** | Miguelangel Palma | Replicación explícita de la sintaxis oficial `Código_SAS` (`FORMAL`, `SALUD`, `PENSION`, `EI`), validación contra el DANE y gráfico circular. | Contrastar con el boletín oficial octubre-diciembre 2024 (42,5 % exacto) y presentar composición por sexo. |
| **2.4 Posición Ocupacional** | Sergio López | Distribución de ocupados en enero 2023 para total nacional y según sexo (gráfico de barras horizontales). | Identificar que cuenta propia (40,6 %) y patrones (2,6 %) concentran el 43,2 %, justificando el marco de EMICRON. |
| **3.1 Indicadores Básicos** | Miguelangel Palma | Universo de micronegocios con `F_EXP` sin redondeo previo, sexo, ramas (`GRUPOS12`), RUT y Cámara de Comercio. | Contrastar con boletín DANE: 10,3 % calculado en Cámara vs. 10,5 % en Gráfico 9 (−0,2 pp) y 10,337 % en Tabla 8 / Anexo F.6. |
| **3.2 Inclusión Financiera** | Sergio López | Bucle `for` sobre las 7 variables de medios de pago por rama (`GRUPOS4`), solicitud de crédito y ahorro. | Evitar duplicación de código e interpretar la brecha de infraestructura transaccional (<200 palabras). |
| **3.3 Cruce GEIH–EMICRON** | Juan José Echeverry | Cruce de las 13 categorías educativas explícitas del DANE (`P3042`) con tenencia de RUT (`P1633`), ponderado con `F_EXP`. | Auditar códigos `1:13`, `99` y `NA` (71.754 emparejados), graficar barras apiladas horizontales y explicar factores no causales. |
| **4.1 Divergencia Territorial** | Sergio López | Ejercicio libre: Dualismo laboral y salarial departamental (Scatter + LOESS). | Analizar la relación inversa entre tasa de informalidad y mediana de ingreso laboral. |
| **4.2 Inclusión Digital** | Miguelangel Palma | Ejercicio libre: Escala de ventas de micronegocios según `P1764_3` vs. efectivo exclusivo y solicitud de crédito (`P1765`). | Auditar no respuesta en `P1765` (5.202 registros) y contrastar medianas de venta en escala logarítmica. |
| **4.3 Emparejamiento Educativo** | Juan José Echeverry | Ejercicio libre: Intersección de las 13 categorías educativas (`P3042`) y las 9 posiciones ocupacionales (`P6430`) con `geom_count`. | Auditar y excluir 4 registros con `P3042 == 99` e identificar 986.256 ocupados con educación superior en cuenta propia. |

---

## Principios Metodológicos y Reglas de Desarrollo

1. **Ruta base única:** Todo el script maestro deriva sus ubicaciones a partir de `ruta <- here()`. No existen rutas absolutas locales ni dependencias fijadas a disco personal.
2. **Herramientas autorizadas:** Se utiliza exclusivamente R base y paquetes trabajados explícitamente en el curso (`here`, `dplyr`, `tidyr`, `ggplot2`, `openxlsx`).
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
   * El informe compilado (`Informe_Taller_2_Grupo_10.pdf`) se mantiene dentro del límite máximo de **8 páginas de reporte analítico** + **1 página de Anexo de IA** (con contador reiniciado a 1).

---

## Principales Hallazgos y Cifras de Validación Oficial (DANE)

* **Mercado Laboral GEIH 2024:**
  * Muestra anual: 829.683 personas en General; 657.803 en PET; 353.672 Ocupados; 304.131 No ocupados.
  * Consistencia perfecta: $\text{PET} = \text{FT} + \text{FFT}$ y $\text{FT} = \text{OCI} + \text{DSI}$ con diferencia cero en los 12 meses.
  * Relación macroeconómica verificada: $\text{TD} = 1 - \frac{\text{TO}}{\text{TGP}}$, demostrando que la caída del desempleo en el cuarto trimestre de 2024 (7,06 % en hombres y 11,15 % en mujeres) obedeció a una absorción efectiva de empleo hacia fin de año.
* **Integración GEIH–EMICRON:**
  * La llave común es `DIRECTORIO + SECUENCIA_P + ORDEN`, tras comprobar que `SECUENCIA_ENCUESTA == ORDEN` en el 100 % de los casos.
  * Relación temporal: $\text{MES\_REF} = \text{MES}_{\text{GEIH}} + 1$ en el 100 % de los registros comparables (un mes adelante).
  * 71.754 micronegocios emparejados en 2024 (91,41 %). Los 6.747 no emparejados corresponden en su totalidad a enero de 2024, cuyas entrevistas ocurrieron en diciembre de 2023 (100 % localizados en GEIH 2023).
  * Validación independiente: 100 % de coincidencia en sexo (`P35` vs `P3271`), edad (`P241` vs `P6040`) y clase (`CLASE_TE` vs `CLASE`).
* **Formalidad Laboral (13 ciudades):**
  * La replicación explícita de la sintaxis oficial `Código_SAS` arrojó una tasa de informalidad del **42,5 %** en octubre–diciembre de 2024, idéntica a la publicada en el boletín del DANE (diferencia de 0,0 pp), y de 42,2 % en hombres y 42,3 % en mujeres en diciembre de 2024.
* **Micronegocios EMICRON 2024:**
  * Total nacional: **5.297.252 micronegocios** (coincidencia exacta con el DANE).
  * Comercio (23,9 %) y agricultura (21,5 %) lideran el tejido empresarial.
  * Formalidad tributaria (`P1633 == 1`): **22,4 %** con RUT y **77,6 %** sin RUT.
  * Registro mercantil en Cámara de Comercio (`P1055 == 1`): **10,3 % calculado** frente al **10,5 % publicado en el Gráfico 9** del boletín DANE (diferencia de **$-0,2$ puntos porcentuales**). En la **Tabla 8 / Anexo F.6** del boletín, las cantidades absolutas publicadas (`547.581` sobre `5.297.252`) producen exactamente **10,337 %** (**10,3 %**).
  * Inclusión financiera: efectivo ubicuo (85,1 % a 94,3 %); transferencias bancarias o por internet (`P1764_3`) alcanzan 51,9 % en servicios y 43,4 % en comercio pero caen a 6,7 % en el agro. Solicitud de crédito (`P1765 == 1`): 14,2 %; ahorro (`P3014 == 1`): 18,1 %.
* **Cruce Conjunto GEIH–EMICRON con las 13 Categorías Educativas del DANE (Punto 3.3):**
  * El 100 % de los 71.754 propietarios emparejados registra niveles conocidos en `1:13` (`0` en `99`, `0` en `NA`, `0` inválidos; 4.864.444 micronegocios expandidos).
  * Tenencia de RUT por nivel educativo (`P3042`): *Preescolar* 0,0 % ($n=6$), *Ninguno* 2,8 %, *Básica primaria* 11,7 %, *Normalista* 13,1 %, *Básica secundaria* 14,5 %, *Media académica* 22,3 %, *Media técnica* 26,8 %, *Técnica profesional* 34,0 %, *Tecnológica* 43,9 %, *Universitaria* 51,7 %, *Especialización* 73,2 %, *Maestría* 78,7 % y *Doctorado* 88,8 %.
* **Análisis Socioeconómico Libre (Punto 4):**
  * **4.1 Dualismo territorial:** Relación inversa entre informalidad e ingresos (Bogotá: 34,6 % informalidad y \$1,6M COP mediana vs. Chocó/Sucre/La Guajira: >79 % informalidad y \$0,6M COP mediana).
  * **4.2 Inclusión digital y solicitud de crédito:** En 69.847 micronegocios válidos con ventas positivas (excluyendo 5.202 `NA` en `P1765` y 645 otros perfiles de pago), la mediana de ventas pasa de **\$1,20M** (solo efectivo sin solicitud de crédito) y **\$1,70M** (solo efectivo con solicitud) a **\$2,30M** (transferencias sin solicitud) y **\$3,00M** (transferencias con solicitud de crédito).
  * **4.3 Nivel educativo y posición ocupacional:** Sobre 353.668 ocupados con nivel conocido (`1:13`, excluyendo 4 registros con `P3042 == 99`), se identifican **986.256 ocupados con educación superior o posgrado** (`8:13`) trabajando por cuenta propia.

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
El script genera de manera autónoma la totalidad de las tablas y figuras en la carpeta `outputs/`.

### 2. Compilar el Informe Académico en Quarto a PDF
Desde la terminal en la raíz del proyecto:
```bash
quarto render "Entregable_Talleres/Taller_2/01_informe_quarto/Informe_Taller_2_Grupo_10.qmd"
```
Requisitos de compilación: Quarto CLI y distribución LaTeX con soporte para XeLaTeX (TinyTeX o MacTeX con paquetes `babel-spanish`, `booktabs`, `fancyhdr`, `titlesec`, `openxlsx`, `png`, `knitr`).

---

## Declaración sobre Uso de Inteligencia Artificial

De acuerdo con las directrices del curso y los lineamientos de la Universidad de los Andes (Nivel 3 de IAG), las herramientas de inteligencia artificial generativa se utilizaron exclusivamente como apoyo para la edición de estilo, revisión gramatical, formateo de tablas en LaTeX y verificación cruzada de consistencia sintáctica. La autoría, las decisiones metodológicas, la lógica de los algoritmos y la interpretación sustantiva son responsabilidad íntegra de los integrantes del Grupo 10. Las evidencias completas reposan en `evidencias_IA/` y en el anexo final del informe.
