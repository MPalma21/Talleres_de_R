# Evidencias y Declaración de Uso de Inteligencia Artificial Generativa (IAG)

**Curso:** Taller de Programación en R (2026-02) — Maestría en Economía Aplicada (MECA), Universidad de los Andes  
**Equipo:** Grupo 10 (Juan José Echeverry, Miguelangel Palma, Sergio López)

---

## 1. Marco Institucional y Normativo (Universidad de los Andes)

Esta entrega se fundamenta en las directrices institucionales adoptadas por la Universidad de los Andes en el documento:
* **"Lineamientos para el uso de inteligencia artificial generativa (IAG) en la Universidad de los Andes" (Octubre de 2024)**, elaborado por el Equipo del proyecto IA-Uniandes.

De acuerdo con dicho marco y el enunciado oficial del taller, el trabajo se clasifica en el **Nivel 3: Uso de IA para editar y refinar**, rigiéndose por las siguientes buenas prácticas y principios institucionales:

1. **Uso informado (Secciones 2.2 y 3.1):** Conocimiento previo de las capacidades, sesgos y limitaciones estructurales de las herramientas (como el riesgo de alucinaciones o la invención de sintaxis), reconociendo que la IAG es un complemento pedagógico y no un sustituto del razonamiento humano.
2. **Uso transparente (Sección 3.1):** Declaración explícita en este anexo y en el repositorio sobre qué herramientas se utilizaron, para qué propósitos específicos y sobre qué contenidos.
3. **Uso íntegro y autoría (Sección 3.1):** Reconocimiento de que la legislación colombiana de derechos de autor y la normativa universitaria solo otorgan la condición de autor a personas naturales. Ningún contenido generado por IAG se presenta como de autoría propia; la concepción metodológica, los scripts y las interpretaciones sustantivas son autoría exclusiva de los integrantes del grupo.
4. **Evaluación crítica permanente (Sección 3.1):** Toda salida o sugerencia técnica fue interrogada con el propio raciocinio de los integrantes y contrastada empíricamente frente a los microdatos del DANE, los boletines oficiales y los procedimientos vistos en clase.
5. **Protección de datos y privacidad (Sección 3.1):** No se introdujo información confidencial, reservada ni microdatos personales en los *prompts* utilizados.

---

## 2. Flujo Metodológico de Trabajo por Fases (Lineamientos Uniandes)

Conforme a las recomendaciones de la Universidad para el trabajo académico en entornos computacionales, el proceso de desarrollo del grupo siguió un flujo estructurado en tres fases:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ FASE 1: Exploración Sintáctica y Conceptual Inicial                         │
│ • Consulta de documentación de funciones base y sintaxis de tidyverse.       │
│ • Exploración de parámetros de visualización y temas en ggplot2.            │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ FASE 2: Depuración Técnica y Maquetación Controlada                         │
│ • Diagnóstico de mensajes de advertencia (warnings) y coerción de tipos.    │
│ • Ajuste de tablas booktabs y anchos relativos en XeLaTeX / Quarto.          │
│ • Verificación del formato jerárquico del outline del curso (----).         │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ FASE 3: Auditoría, Validación Empírica y Control Humano Estricto             │
│ • Ejecución autónoma del script maestro desde sesión limpia de R.           │
│ • Contrastación exacta contra boletines del DANE (EI al 42,5 %, FEX, etc.). │
│ • Detección y descarte proactivo de alucinaciones y librerías externas.    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Clasificación de Usos Conforme a los Lineamientos de la Universidad

Siguiendo las funciones específicas recomendadas para estudiantes en la **Sección 3.2 ("Usos recomendados para estudiantes")** del documento institucional de la Universidad, el uso de herramientas de IAG se limitó exclusivamente a funciones prácticas e instrumentales:

### A. Tareas Prácticas Asistidas por IAG (Soporte Técnico e Instrumental)

| Función Institucional Uniandes | Aplicación Práctica en el Taller | Herramienta | Mecanismo de Supervisión y Control Humano |
|:---|:---|:---|:---|
| **Función 4: Asistencia en la programación computacional** | Sugerencias puntuales para la **depuración de código en R** (*debugging* de mensajes de error de consola, resolución de advertencias de tipado y verificación del formato del outline jerárquico del curso `----`). | Claude 3.5 Sonnet / ChatGPT-4o | Cada bloque de código sugerido fue revisado, probado y ejecutado línea a línea en una sesión limpia de R por los integrantes, verificando que corriera sin errores ni dependencias externas. |
| **Función 1: Asistencia en la estructuración y maquetación técnica** | Asistencia técnica en la sintaxis de **Quarto y XeLaTeX** (formateo de tablas `booktabs`, control de anchos de columnas relativas `p{...}` y encabezados con `fancyhdr`). | Claude 3.5 Sonnet / ChatGPT-4o | El documento fue compilado y verificado visualmente para certificar la adecuada diagramación de las tablas y gráficos sin desbordar los márgenes de página. |
| **Función 1: Revisión ortotipográfica y gramatical** | Revisión de **ortografía, puntuación y estilo gramatical** sobre textos elaborados previamente por los integrantes del grupo, asegurando claridad expositiva sin sustituir la argumentación original. | ChatGPT-4o / Claude 3.5 Sonnet | Los integrantes contrastaron manualmente que la corrección gramatical preservara con exactitud la interpretación económica y el sentido original de los análisis. |

---

### B. Tareas Sustantivas NO Delegadas (Autoría Intelectual y Humana Exclusiva)

Conforme a la premisa institucional de que *"el proceso de aprendizaje es inherentemente humano y la IAG no debe sustituir el desarrollo de competencias disciplinarias"* (Sección 3.2), los componentes sustantivos del taller fueron concebidos, programados y ejecutados exclusivamente por los integrantes:

1. **Lógica de pegues e integración relacional GEIH–EMICRON (Punto 1.4):**  
   La formulación y demostración empírica de la llave común (`SECUENCIA_ENCUESTA == ORDEN` con 100 % de equivalencia) y el descubrimiento del desfase de recolección de un mes ($\text{MES\_REF} = \text{MES}_{\text{GEIH}} + 1$, trazando los no emparejados de enero de 2024 hacia diciembre de 2023) fue deducida y auditada por el grupo (`outputs/1_4_relacion_orden.csv`, `outputs/1_4_relacion_meses.csv`).
2. **Replicación del algoritmo oficial de informalidad laboral (Punto 2.3):**  
   La traducción manual de las condiciones lógicas del código oficial SAS del DANE (`anex-GEIHEISS-oct-dic2024.xlsx`) a la sintaxis declarativa de `dplyr` para el cálculo de la variable `EI` fue estructurada por el grupo, logrando una réplica exacta del 42,5 % publicado por el DANE (0,0 pp de discrepancia, auditado en `outputs/2_3_control_ei_dane.csv`).
3. **Cálculo de tasas ponderadas e identidades del mercado laboral (Punto 2.1 y 2.2):**  
   La aplicación correcta de los factores de expansión trimestrales ($\text{FEX\_C18} / 3$), las identidades macroeconómicas ($\text{TD} = 1 - \text{TO}/\text{TGP}$) y la verificación de consistencia aditiva ($\text{FT} = \text{Ocupados} + \text{Desocupados}$) fueron programadas y analizadas por los estudiantes.

---

## 4. Matriz de Detección y Descarte Crítico de Alucinaciones

En consonancia con el principio institucional de **evaluación crítica** (Sección 3.1 Uniandes), se documentan los casos específicos donde las herramientas de IAG formularon sugerencias metodológicas o computacionales erróneas, las cuales fueron **identificadas, descartadas y corregidas manualmente** por el equipo:

| Dimensión Técnica | Sugerencia Errónea de la IAG (Alucinación / Desvío) | Razón Técnica del Descarte Humano | Acción Correctiva Implementada por el Grupo |
|:---|:---|:---|:---|
| **Toolkit y Librerías del Curso** | La IAG sugirió utilizar `data.table::fread()` para acelerar la carga de los archivos mensuales o paquetes ajenos al curso. | **Violación de restricciones del enunciado:** El taller prohíbe el uso de librerías externas no abordadas explícitamente en clase. | Se descartó por completo la sugerencia y se implementó una estrategia eficiente de lectura modular con `read.csv()` y pre-filtrado inmediato con `dplyr::select()`. |
| **Metodología de Pegue GEIH–EMICRON** | La IAG asumió un pegue simple directo por `DIRECTORIO + ORDEN` dentro del mismo mes calendario. | **Error conceptual y metodológico:** Ignoraba la discrepancia de nombres de variables entre formularios (`SECUENCIA_ENCUESTA` vs `ORDEN`) y el desfase de recolección de un mes de EMICRON. | El grupo descubrió, probó empíricamente y documentó la equivalencia y el desfase temporal ($\text{MES\_REF} = \text{MES}_{\text{GEIH}} + 1$), rescatando los emparejamientos de enero 2024 desde diciembre 2023. |
| **Ponderación y Factores de Expansión** | La IAG sugirió ponderar el análisis conjunto GEIH–EMICRON combinando `FEX_C18` y `F_EXP`. | **Invalidez estadística:** `FEX_C18` expande personas/hogares a nivel nacional, mientras que `F_EXP` expande exclusivamente el universo de micronegocios. | El grupo aplicó con rigor técnico **únicamente `F_EXP`** para todos los ejercicios de micronegocios (Puntos 3.1, 3.2, 3.3 y 4.2), preservando la representatividad estadística correcta. |

---

## 5. Bitácora Técnica de Prompts Reales

A continuación se presentan los registros de consultas técnicas e instrumentales realizadas durante el desarrollo práctico del taller:

### Caso 1: Depuración de Advertencias en `left_join()` en R
* **Herramienta:** Claude 3.5 Sonnet
* **Prompt representativo:**
  > *"Al ejecutar `left_join()` entre el módulo de Características Generales y Ocupados en R, la consola arroja un warning de coerción de tipos: 'Detected an unexpected many-to-many relationship' y discrepancia en la clase de `DIRECTORIO` (character vs integer). ¿Cómo asegurar la conversión defensiva limpia antes del merge sin alterar las variables originales usando exclusivamente dplyr?"*
* **Aporte práctico:** Sugirió estandarizar previamente `as.character()` en las llaves compuestas y verificar duplicados con `count()`, evitando el conflicto de tipos.
* **Supervisión humana:** El grupo adoptó la estandarización explícita y programó los controles de no multiplicación de filas auditados en `outputs/1_1_verificacion_pegues.csv`.

### Caso 2: Maquetación de Tablas Complejas en Quarto / XeLaTeX
* **Herramienta:** ChatGPT-4o
* **Prompt representativo:**
  > *"Tengo una tabla generada con knitr::kable(format = 'latex', booktabs = TRUE) con 13 filas de niveles educativos que se desborda horizontalmente en la página de un documento XeLaTeX de 9pt. ¿Cómo puedo ajustar el ancho relativo al 42% del textwidth sin que se desborden las columnas numéricas formateadas con puntos de mil?"*
* **Aporte práctico:** Proveyó la estructura envolvente de `\resizebox{0.42\textwidth}{!}{...}` y el entorno `\begin{center}`.
* **Supervisión humana:** Se integró la función `tabla_latex()` en el chunk de setup y se validó visualmente la maquetación en el PDF final sin errores de compilación.

### Caso 3: Personalización de Ejes y Rotación en `ggplot2`
* **Herramienta:** Claude 3.5 Sonnet
* **Prompt representativo:**
  > *"¿Cómo rotar las etiquetas del eje X a 45 grados con alineación hjust = 1 en ggplot2 y asegurar que las etiquetas numéricas del eje Y muestren porcentajes formateados en español (coma decimal) sin importar librerías externas?"*
* **Aporte práctico:** Indicó la sintaxis de `theme(axis.text.x = element_text(angle = 45, hjust = 1))` y el uso de `formatC(decimal.mark = ",")` o `scales::percent_format()` base.
* **Supervisión humana:** Se aplicó la configuración gráfica en los scripts de figuras asegurando una paleta sobria y visualmente clara.

---

## 6. Registro de Conversaciones para Bloque Neón

En cumplimiento de los requisitos de entrega, a continuación se relacionan los espacios para adjuntar las conversaciones completas:

* **Conversación 1 – Depuración sintáctica en R:** [Adjuntar enlace público o archivo PDF antes de la entrega final]
* **Conversación 2 – Maquetación en Quarto / XeLaTeX:** [Adjuntar enlace público o archivo PDF antes de la entrega final]


---

# Anexo Taller 3: Datos Geoespaciales, Web Scraping y Visualización Interactiva

## 1. Alcance y Directrices Institucionales Aplicadas al Taller 3
Para el desarrollo del Taller 3, el Grupo 10 mantuvo una adhesión estricta a los **Lineamientos de IAG de la Universidad de los Andes (Nivel 3: Edición y Refinamiento)**:
1. **Asistencia Técnica Limitada:** Se emplearon herramientas de IA exclusivamente como asistente de programación en sintaxis espacial (`sf`, `rmapshaper`), consumo de APIs financieras (`httr`, `jsonlite`), parseo de respuestas SDMX en XML (`xml2`) y arquitectura de interfaz reactiva en Shiny (`bslib`).
2. **Autoría Humana y Análisis Económico Exclusivo:** La concepción de las interpretaciones, el análisis sustantivo de las finanzas territoriales colombianas, la evaluación de la paridad en tasas de interés (IBR vs. SOFR) y la redacción integral del informe escrito en R Markdown fueron elaboradas al 100% por los integrantes del Grupo 10.

---

## 2. Tareas Sustantivas NO Delegadas (Autoría Humana Exclusiva - Grupo 10)
* **Formulación del Ponderador y Demostración de Homogeneidad (Punto 1.2):**  
  La deducción analítica de que el ponderador municipal $w_i = (L_i \cdot VA_i) / \sum(L_k \cdot VA_k)$ es invariante ante cualquier tasa uniforme de crecimiento proporcional del valor agregado fue formulada por los estudiantes, aportando una justificación metodológica robusta en el informe.
* **Diagnóstico de Complejidad Computacional (Punto 1.3 - Bono):**  
  El análisis de cuellos de botella por densidad poligonal en dispositivos gráficos vectoriales y la decisión de implementar el algoritmo Visvalingam con preservación topológica (`rmapshaper`) fue investigada y resuelta por el equipo.
* **Diseño Libre en Plotly y Dualismo Laboral (Punto 3.3):**  
  La articulación temática de la informalidad laboral frente al ingreso mediano departamental, integrando los hallazgos de los talleres anteriores y redactando la interpretación de disparidades centro-periferia, fue concebida directamente por los integrantes del Grupo 10.

---

## 3. Matriz de Detección y Descarte Crítico de Alucinaciones en Taller 3

| Dimensión Técnica | Sugerencia Errónea de la IAG (Alucinación / Desvío) | Razón Técnica del Descarte Humano | Acción Correctiva Implementada por el Grupo |
| :--- | :--- | :--- | :--- |
| **Simplificación de Polígonos Municipales** | La IAG sugirió aplicar `sf::st_simplify(dTolerance = 0.05)` de forma directa sobre la capa de municipios. | **Degeneración Cartográfica:** El algoritmo de Douglas-Peucker genera huecos vacíos (*gaps*) y superposiciones (*overlaps*) entre municipios colindantes. | Se descartó y se implementó `rmapshaper::ms_simplify(keep = 0.08, keep_shapes = TRUE)` preservando la topología compartida. |
| **Puntaje del IDF Departamental** | La IAG propuso promediar aritméticamente el IDF de los municipios sin ponderar por población o producto. | **Violación del Enunciado:** El taller exige explícitamente una media ponderada por el producto de población y valor agregado. | El grupo programó la fórmula estricta $IDF_j = \sum IDF_i \cdot w_i$ comprobando que $\sum w_i = 1$. |
| **Convenciones de Tasas Financieras** | La IAG intentó calcular la devaluación implícita mezclando tasas porcentuales directamente sin transformar a decimales. | **Error Matemático / Financiero:** La fórmula $\pi = (1 + i_d)/(1 + i_e) - 1$ requiere tasas expresadas en base decimal comparable. | Se estructuró la transformación defensiva $i = \text{tasa}/100$ tanto en el script maestro como en la reactividad de Shiny. |

---

## 4. Registro de Prompts Reales - Taller 3

### Caso 1: Parseo de Respuestas XML SDMX de BanRep
* **Herramienta:** Antigravity / Gemini 3.8 Flash
* **Prompt representativo:**
  > *"¿Cómo extraer de forma limpia los nodos `<generic:Obs>` con `ObsDimension` y `ObsValue` de un archivo XML con namespaces complejos en R usando la librería `xml2` sin perder las fechas en formato AAAAMMDD?"*
* **Aporte práctico:** Proveyó la sintaxis para capturar los namespaces con `xml_ns()` y filtrar mediante XPath relativo `.//generic:Series[.//generic:Value[@id='SUBJECT' and @value='IRIBRM00']]`.
* **Supervisión humana:** El grupo verificó contra los boletines oficiales que la serie correspondiera a la convención Efectiva Anual (`UNIT_MEASURE = ER`).

### Caso 2: Manejo de Días No Hábiles en Series Cruzadas IBR–SOFR
* **Herramienta:** Antigravity / Gemini 3.8 Flash
* **Prompt representativo:**
  > *"Al fusionar series diarias de tasas de Colombia y Estados Unidos, los festivos bancarios difieren. ¿Cuál es la forma más limpia en `tidyr` para aplicar un forward-fill sobre las fechas faltantes manteniendo la serie diaria continua?"*
* **Aporte práctico:** Sugirió el uso de `full_join()` ordenado por fecha seguido de `tidyr::fill(sofr_on, ibr_on, .direction = 'down')`.
* **Supervisión humana:** Se validó que el método forward-fill refleja la práctica financiera estándar donde la última tasa de cierre se mantiene activa durante días feriados.
