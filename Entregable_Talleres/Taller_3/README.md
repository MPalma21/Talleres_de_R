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
│       ├── 01_preparar_datos_shiny.R           # Preparación reproducible de RDS, festivos y cruce GEIH-IDF
│       ├── app.R                               # Orquestador ligero Shiny (bslib Bootstrap 5 + modo oscuro)
│       ├── R/                                  # Módulos Shiny encapsulados (NS / moduleServer)
│       │   ├── 00_tema_y_datos.R               # Tema visual bslib y carga defensiva de insumos RDS
│       │   ├── mod_tab1_idf.R                  # Módulo Pestaña 1 (Mapa Leaflet IDF Dpto. y Top 3 Mpios)
│       │   ├── mod_tab2_tasas.R                # Módulo Pestaña 2 (Doble eje SOFR/IBR y Calculadora π)
│       │   └── mod_tab3_libre.R                # Módulo Pestaña 3 (Diseño libre en Plotly y tabla DT)
│       ├── datos_ejercicio_3c_laboral.csv      # Base departamental integrada (GEIH/EMICRON 2024 + IDF 2024)
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
│   │   └── processed/                          # Bases consolidadas finales del taller
│   │       ├── idf_departamental_2024.csv
│   │       ├── idf_municipal_ponderado_2024.csv
│   │       ├── auditoria_llaves_ejercicio_1.csv
│   │       └── series_financieras_ibr_sofr.csv
│   └── Images/                                 # Gráficas y mapas temáticos vectoriales/raster a 300 DPI
│       ├── 1_1_mapa_idf_departamental.png
│       ├── 1_2_mapa_idf_municipal_bono.png
│       ├── 2_a_tasa_ibr_diaria.png
│       ├── 2_b_tasa_sofr_diaria.png
│       ├── 2_c_doble_eje_ibr_sofr.png
│       └── 3_c_dualismo_laboral_idf.png
│
├── Notebooks/
│   ├── Taller_3_Grupo_10.qmd                   # Documento maestro Quarto reproducible
│   ├── Taller_3_Grupo_10.html                  # Informe interactivo (publicable en Posit Connect Cloud)
│   └── Taller_3_Grupo_10.pdf                   # Informe académico formal (artículo sin desbordes de margen)
│
├── uso de IA/
│   └── Anexo_Uso_IA_Taller_3_Grupo_10.docx      # Anexo formal Word de uso auxiliar de IA y autoría humana
│
└── README.md                                   # Guía de reproducción, división de responsabilidades y auditoría
```

---

## 2. División Equitativa por Ejes Completos (1/3 por Integrante + Revisión Integral)

La estructura de revisión, verificación técnica y sustentación del Taller 3 está organizada bajo un esquema equitativo por **Ejes Completos** (donde cada integrante lidera 1/3 exacto del código, informe, pestaña Shiny y auditoría de su eje, además de realizar la revisión y ejecución transversal de la totalidad del taller):

| Eje Temático | Integrante Líder | Componentes del Eje (Código + Informe + Shiny + Auditoría) | Responsabilidad de Revisión y Sustentación |
| :--- | :--- | :--- | :--- |
| **Eje 1: Datos Geoespaciales y Desempeño Fiscal** | **Sergio López** <br> *(Código: `202111932`)* | **• Ejercicio 1 Completo (Literales A y B)**<br>**• Bono 1 (Mapa Municipal Optimizado)**<br>**• Pestaña 1 del Shiny (`leaflet` + Top 3)**<br>**• Auditoría de Unión Territorial** | • Integración de las 4 fuentes oficiales (DNP IDF Vigencia 2024, DANE MGN Shapefiles, DANE Población 2024 y DANE Valor Agregado 2023) por código DIVIPOLA (`cod_mpio`).<br>• Proyección de VA 2023 a 2024 a precios corrientes (8.27%), demostración de homogeneidad de $w_i$, comprobación $\sum w_i = 1$, segundo procedimiento (`weighted.mean`) y mapa departamental.<br>• Diagnóstico computacional y simplificación topológica Visvalingam-Whyatt (`rmapshaper::ms_simplify`) para los ~1.122 polígonos municipales (Bono 1).<br>• Pestaña 1 interactiva con selector reactivo bidireccional (`leafletProxy`), clic sobre polígono y tabla del Top 3 municipal, más auditoría de Medellín (`05001`). |
| **Eje 2: Web Scraping, APIs y Series Financieras** | **Miguelangel Palma** <br> *(Código: `202621481`)* | **• Ejercicio 2 Completo (Literales A, B y C)**<br>**• Pestaña 2 del Shiny (Doble Eje y $\pi$)**<br>**• Auditoría de Tasas y Paridad** | • Extracción vía **Web Scraping** de la tasa IBR Overnight (2020–2025) desde el portal SUAMECA del Banco de la República (parseo XML SDMX con `xml2`, convención % E.A.).<br>• Extracción vía **API REST** de la tasa SOFR Overnight (2020–2025) desde la Markets Data API de la Reserva Federal de Nueva York (parseo JSON con `jsonlite`).<br>• Armonización de calendarios financieros (`full_join` + *forward-fill*), gráfico estático e interactivo de doble eje y análisis del ciclo monetario.<br>• Pestaña 2 de Shiny con consulta por fecha, cálculo de devaluación implícita $\pi = (1+i_d)/(1+i_e)-1$, alerta en días no hábiles y contraste oficial del 15/03/2024. |
| **Eje 3: Diseño Libre, Arquitectura Shiny e Integridad Reproducible** | **Juan José Echeverry** <br> *(Código: `202616233`)* | **• Ejercicio 3 (Literal C - Diseño Libre)**<br>**• Pestaña 3 y Arquitectura Modular `bslib` (Bono Diseño)**<br>**• Script de Preparación Shiny, Compilación Quarto y Anexo IA** | • Construcción y exportación de `datos_ejercicio_3c_laboral.csv` (`01_preparar_datos_shiny.R`) cruzando GEIH/EMICRON 2024 con el IDF departamental 2024, y visualización interactiva en `plotly` sobre dualismo laboral y desempeño fiscal con filtros reactivos, ajuste MCO, cuadrantes y tabla `DT`.<br>• Refactorización modular de `app.R` + `R/*.R` (`NS`/`moduleServer`) con `bslib` (tema Bootstrap 5 personalizado, `page_navbar`, `value_box`, `navset_card_underline`, `input_dark_mode`) para optar al Bono de Mejor Diseño.<br>• Verificación de ejecución modular autónoma, compilación de `Taller_3_Grupo_10.qmd` a HTML y PDF formal e inclusión de matriz de auditoría y anexo de IA. |

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

# 3. Ejercicio 3 (Preparación de insumos RDS y figura 3.C)
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_3/01_preparar_datos_shiny.R
```

### 3.2 Ejecución del Aplicativo Shiny
Para iniciar el aplicativo interactivo Shiny:
```r
shiny::runApp("Entregable_Talleres/Taller_3/Scripts/Punto_3")
```
El aplicativo abrirá una interfaz moderna con tres pestañas funcionales:
1. **Desempeño Fiscal (IDF):** Mapa interactivo de Colombia en Leaflet con selección bidireccional de departamentos y desglose del Top 3 municipal.
2. **Tasas y Devaluación ($\pi$):** Serie interactiva de doble eje en Plotly, selector de fecha histórica, selector de convención de comparabilidad (tasas publicadas vs. Efectiva Anual base 360) y calculadora de devaluación implícita con detección explícita de festivos asimétricos y fines de semana.
3. **Diseño Libre (Plotly):** Explorador de burbujas en Plotly y tabla de auditoría `DT` sobre dualismo laboral departamental (informalidad vs. ingreso laboral mediano o IDF departamental 2024) con filtros regionales, umbral de ocupados, recta MCO y cuadrantes de promedio nacional.

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
| **1. Unión revisada** | Medellín (`05001`) | IDF 2024: 69.73 \| Peso $w_i$: 0.9243 \| IDF Antioquia: 69.58 | DNP CIFFIT (Vigencia 2024) / DANE Cuentas Nal. | **COINCIDENCIA EXACTA** |
| **2. Contraste de tasa IBR** | 15 de marzo de 2024 / 31 de octubre de 2025 | 12.747% E.A. / 9.250% E.A. | Boletín Oficial BanRep SUAMECA (Serie 241) | **COINCIDENCIA EXACTA** |
| **3. Contraste de tasa SOFR** | 15 de marzo de 2024 / 31 de octubre de 2025 | 5.31% / 4.22% (4.310% E.A.) | Markets Data Release NY Fed (Endpoint 520) | **COINCIDENCIA EXACTA** |
| **4. Cálculo alternativo de índices** | IDF (`weighted.mean`) y Devaluación implícita ($\pi$) | Dif. IDF = 0.0000 \| Al 31/10/2025: $\pi_{\text{directa}} = 4.826\%$ y $\pi_{\text{EA}} = 4.736\%$ | $(1 + i_d)/(1 + i_e) - 1$ en convención directa y E.A. base 360 | **COMPROBADO** |

---

## 5. Declaración de Cumplimiento de Lineamientos de IA

De acuerdo con la reglamentación de la Universidad de los Andes (Nivel 3 de IAG) y el enunciado del curso, las herramientas de inteligencia artificial se emplearon exclusivamente como apoyo técnico para la optimización de código, estructuración modular y depuración de errores sintácticos. La totalidad de las interpretaciones, análisis económicos, formulaciones metodológicas y arquitectura del aplicativo Shiny fueron concebidas y redactadas por los integrantes del Grupo 10. El anexo formal en formato Word requerido por el enunciado se encuentra en [`uso de IA/Anexo_Uso_IA_Taller_3_Grupo_10.docx`](./uso%20de%20IA/Anexo_Uso_IA_Taller_3_Grupo_10.docx).
