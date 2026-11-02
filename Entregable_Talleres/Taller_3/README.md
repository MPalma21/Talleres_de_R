# Taller 3: Datos Geoespaciales, Web Scraping y Herramientas de Visualización

**Curso:** Taller de Programación en R · 2026-2  
**Facultad de Economía – Universidad de los Andes**  
**Grupo:** 10  
**Integrantes:**
* **Juan José Echeverry** – Código: `202616233`
* **Miguelangel Palma** – Código: `202621481`
* **Sergio López** – Código: `202111932`

---

## 1. Estructura Modular de la Entrega (`Entregable_Talleres/Taller_3/`)

La entrega se encuentra organizada bajo una arquitectura modular estricta por componentes funcionales:

```text
Entregable_Talleres/Taller_3/
├── Scripts/
│   ├── Punto_1/
│   │   └── 01_procesamiento_geoespacial_idf.R   # Procesamiento geoespacial, cálculo de IDF y mapas
│   ├── Punto_2/
│   │   ├── 01_extraer_sofr_api.R               # Extracción automatizada vía REST API (Fed de Nueva York)
│   │   ├── 02_extraer_ibr_banrep.R             # Web scraping directo sobre feed SDMX-XML (Banco de la República)
│   │   └── 03_analisis_financiero_punto_2.R    # Armonización temporal, cálculo de spread y gráficos
│   └── Punto_3/
│       ├── app.R                               # Aplicativo interactivo Shiny (arquitectura bslib Bootstrap 5)
│       ├── datos_ejercicio_3c_laboral.csv      # Base departamental utilizada en el Literal C
│       └── data_shiny/                         # Capas espaciales y bases serializadas para Shiny
│           ├── df_deptos.rds
│           ├── df_labor.rds
│           ├── df_rates.rds
│           ├── df_top3.rds
│           └── shp_dpto_simp.rds
│
├── Outputs/
│   ├── Data/
│   │   ├── raw/                                # Respaldos crudos y series individuales tratadas
│   │   │   ├── sofr_raw.json
│   │   │   ├── ibr_raw.xml
│   │   │   ├── sofr_diaria_2020_2025.csv
│   │   │   └── ibr_diaria_2020_2025.csv
│   │   └── processed/                          # Base consolidada final del taller
│   │       └── series_financieras_ibr_sofr.csv
│   └── Images/                                 # Gráficas y mapas temáticos vectoriales/raster a 300 DPI
│       ├── 1_1_mapa_idf_departamental.png
│       ├── 1_2_mapa_idf_municipal_bono.png
│       ├── 2_a_tasa_ibr_diaria.png
│       ├── 2_b_tasa_sofr_diaria.png
│       └── 2_c_doble_eje_ibr_sofr.png
│
├── Notebooks/
│   ├── Taller_3_Grupo_10.qmd                   # Documento maestro Quarto reproducible
│   ├── Taller_3_Grupo_10.html                  # Informe interactivo (publicable en Posit Connect Cloud)
│   └── Taller_3_Grupo_10.pdf                   # Informe académico formal (artículo sin desbordes de margen)
│
└── README.md                                   # Guía de reproducción, división de responsabilidades y auditoría
```

---

## 2. División Equitativa por Ejes Completos (1/3 por Integrante + Revisión Integral)

La estructura de revisión, verificación técnica y sustentación del Taller 3 está organizada bajo un esquema equitativo por **Ejes Completos** (donde cada integrante lidera 1/3 exacto del código, informe, pestaña Shiny y auditoría de su eje, además de realizar la revisión y ejecución transversal de la totalidad del taller):

| Eje Temático | Integrante Líder | Componentes del Eje (Código + Informe + Shiny + Auditoría) | Responsabilidad de Revisión y Sustentación |
| :--- | :--- | :--- | :--- |
| **Eje 1: Datos Geoespaciales y Desempeño Fiscal** | **Sergio López** <br> *(Código: `202111932`)* | **• Ejercicio 1 Completo (Literales A y B)**<br>**• Bono 1 (Mapa Municipal Optimizado)**<br>**• Pestaña 1 del Shiny (`leaflet` + Top 3)**<br>**• Auditoría de Unión Territorial** | • Integración de las 4 fuentes oficiales (DNP IDF 2024, DANE MGN Shapefiles, DANE Población 2024 y DANE Valor Agregado 2023) por código DIVIPOLA (`cod_mpio`).<br>• Proyección de VA 2023 a 2024 a precios corrientes (8.27%), demostración de homogeneidad de $w_i$, comprobación $\sum w_i = 1$ y mapa departamental.<br>• Diagnóstico computacional y simplificación topológica Visvalingam-Whyatt (`rmapshaper::ms_simplify`) para los ~1.120 municipios (Bono 1).<br>• Pestaña 1 interactiva con selector reactivo, clic sobre polígono y tabla del Top 3 municipal, más auditoría de Medellín (`05001`). |
| **Eje 2: Web Scraping, APIs y Series Financieras** | **Miguelangel Palma** <br> *(Código: `202621481`)* | **• Ejercicio 2 Completo (Literales A, B y C)**<br>**• Pestaña 2 del Shiny (Doble Eje y $\pi$)**<br>**• Auditoría de Tasas y Paridad** | • Extracción vía **Web Scraping** de la tasa IBR Overnight (2020–2025) desde el portal SUAMECA del Banco de la República (parseo XML SDMX con `xml2`, convención % E.A.).<br>• Extracción vía **API REST** de la tasa SOFR Overnight (2020–2025) desde la Markets Data API de la Reserva Federal de Nueva York (parseo JSON con `jsonlite`).<br>• Armonización de calendarios financieros (`full_join` + *forward-fill*), gráfico estático e interactivo de doble eje y análisis del ciclo monetario.<br>• Pestaña 2 de Shiny con consulta por fecha, cálculo de devaluación implícita $\pi = (1+i_d)/(1+i_e)-1$, alerta en días no hábiles y contraste oficial del 15/03/2024. |
| **Eje 3: Diseño Libre, Arquitectura Shiny e Integridad Reproducible** | **Juan José Echeverry** <br> *(Código: `202616233`)* | **• Ejercicio 3 (Literal C - Diseño Libre)**<br>**• Pestaña 3 y Arquitectura UI `bslib` (Bono Diseño)**<br>**• Script Maestro, Compilación Quarto y Anexo IA** | • Construcción y exportación de `datos_ejercicio_3c_laboral.csv` y visualización interactiva en `plotly` sobre dualismo laboral departamental (informalidad vs. ingreso mediano) con filtros reactivos.<br>• Arquitectura integral de `app.R` con `bslib` (tema Bootstrap 5 `cosmo`/`flatly`, `page_navbar`, `value_box`) para optar al Bono de Mejor Diseño.<br>• Verificación de ejecución modular autónoma, compilación de `Taller_3_Grupo_10.qmd` a HTML y PDF formal e inclusión de matriz de auditoría. |

---

## 3. Instrucciones de Ejecución y Reproducibilidad

### 3.1 Ejecución Modular por Ejercicios
Cada ejercicio puede ejecutarse de manera independiente y secuencial:

```bash
# 1. Ejercicio 1 (Datos Geoespaciales e IDF)
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_1/01_procesamiento_geoespacial_idf.R

# 2. Ejercicio 2 (Web Scraping y APIs)
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_2/01_extraer_sofr_api.R
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_2/02_extraer_ibr_banrep.R
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_2/03_analisis_financiero_punto_2.R
```

### 3.2 Ejecución del Aplicativo Shiny
Para iniciar el aplicativo interactivo Shiny:
```r
shiny::runApp("Entregable_Talleres/Taller_3/Scripts/Punto_3")
```
El aplicativo abrirá una interfaz moderna con tres pestañas funcionales:
1. **Desempeño Fiscal (IDF):** Mapa interactivo de Colombia en Leaflet con selección de departamentos y desglose del Top 3 municipal.
2. **Tasas y Devaluación:** Serie interactiva de doble eje en Plotly, selector de fecha histórica y calculadora de la tasa de devaluación implícita con manejo de festivos.
3. **Diseño Libre (Plotly):** Scatter interactivo de informalidad vs. ingreso laboral mediano con filtros regionales y selector de población.

### 3.3 Compilación del Informe en Quarto (HTML y PDF)
Para renderizar simultáneamente el reporte interactivo y el documento PDF académico formal:
```bash
quarto render Entregable_Talleres/Taller_3/Notebooks/Taller_3_Grupo_10.qmd
```

---

## 4. Matriz de Auditoría y Verificación de Integridad

En estricto apego a las instrucciones de entrega, se documentan las comprobaciones técnicas realizadas:

| Evidencia Solicitada | Caso Auditado | Valor Obtenido en el Taller | Fuente Oficial Primaria | Estado de Verificación |
| :--- | :--- | :--- | :--- | :--- |
| **1. Unión revisada** | Medellín (`05001`) | IDF: 69.78 \| Peso $w_i$: 0.9243 | DNP CIFFIT / DANE Cuentas Nal. | **COINCIDENCIA EXACTA** |
| **2. Contraste de tasa IBR** | 15 de marzo de 2024 | 12.750% E.A. | Boletín Oficial BanRep SUAMECA | **COINCIDENCIA EXACTA** |
| **3. Contraste de tasa SOFR** | 15 de marzo de 2024 | 5.310% | Markets Data Release NY Fed | **COINCIDENCIA EXACTA** |
| **4. Cálculo analítico** | Devaluación implícita ($\pi$) | 7.065% | $(1 + 0.1275)/(1 + 0.0531) - 1$ | **COMPROBADO** |

---

## 5. Declaración de Cumplimiento de Lineamientos de IA

De acuerdo con la reglamentación de la Universidad de los Andes (Nivel 3 de IAG), las herramientas de inteligencia artificial se emplearon exclusivamente como apoyo técnico para la optimización de código, estructuración modular y maquetación de informes reproducibles. La totalidad de las interpretaciones, análisis económicos y decisiones metodológicas fueron concebidas y redactadas por los integrantes del Grupo 10.
