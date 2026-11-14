# Taller 3: Datos geoespaciales, web scraping y visualización interactiva

Curso: Taller de Programación en R (2026-2), Facultad de Economía, Universidad de los Andes  
Grupo 10: Juan José Echeverry (`202616233`), Miguelangel Palma (`202621481`) y Sergio López (`202111932`)

## 1. Estructura de la entrega

Los scripts, salidas, informe, aplicativo Shiny y anexo de uso de IA están organizados dentro de la carpeta del Taller 3:

```text
Taller_3/
├── Scripts/
│   ├── Punto_1/
│   │   └── 01_procesamiento_geoespacial_idf.R   # Procesamiento geoespacial, cálculo de IDF y mapas
│   ├── Punto_2/
│   │   ├── 01_extraer_sofr_api.R               # Extracción vía REST API (Fed de Nueva York)
│   │   ├── 02_extraer_ibr_banrep.R             # Web scraping sobre feed SDMX-XML (Banco de la República)
│   │   └── 03_analisis_financiero_punto_2.R    # Cruce temporal, spread y gráficos
│   └── Punto_3/
│       ├── 01_preparar_datos_shiny.R           # Preparación de RDS, festivos y cruce GEIH-IDF
│       ├── app.R                               # Archivo principal Shiny (bslib)
│       ├── R/                                  # Módulos Shiny (NS / moduleServer)
│       │   ├── 00_tema_y_datos.R               # Tema bslib, tarjetas KPI y carga de RDS
│       │   ├── mod_tab1_idf.R                  # Pestaña 1: mapa Leaflet IDF y Top 3 municipal
│       │   ├── mod_tab2_tasas.R                # Pestaña 2: doble eje SOFR/IBR y calculadora de pi
│       │   └── mod_tab3_libre.R                # Pestaña 3: gráfico libre en Plotly y tabla DT
│       ├── www/                                # Hojas CSS, JS para MathJax y escudo Uniandes
│       │   ├── css/modern_ui.css
│       │   ├── js/modern_ui.js
│       │   └── img/logo_uniandes.png
│       ├── datos_ejercicio_3c_laboral.csv      # Base departamental usada en el literal 3.C
│       └── data_shiny/                         # Objetos .rds cargados por el tablero
│           ├── df_deptos.rds
│           ├── df_labor.rds
│           ├── df_rates.rds
│           ├── df_top3.rds
│           └── shp_dpto_simp.rds
├── Outputs/
│   ├── Data/
│   │   ├── raw/                                # Respaldos crudos y series individuales
│   │   │   ├── sofr_raw.json
│   │   │   ├── ibr_raw.xml
│   │   │   ├── sofr_diaria_2020_2025.csv
│   │   │   └── ibr_diaria_2020_2025.csv
│   │   └── processed/                          # Tablas consolidadas finales
│   │       ├── idf_departamental_2024.csv
│   │       ├── idf_municipal_ponderado_2024.csv
│   │       ├── auditoria_llaves_ejercicio_1.csv
│   │       └── series_financieras_ibr_sofr.csv
│   └── Images/                                 # Mapas y figuras en 300 DPI
│       ├── 1_1_mapa_idf_departamental.png
│       ├── 1_2_mapa_idf_municipal_bono.png
│       ├── 2_a_tasa_ibr_diaria.png
│       ├── 2_b_tasa_sofr_diaria.png
│       ├── 2_c_doble_eje_ibr_sofr.png
│       └── 3_c_dualismo_laboral_idf.png
├── Notebooks/
│   ├── Taller_3_Grupo_10.qmd                   # Documento fuente Quarto
│   ├── Taller_3_Grupo_10.html                  # Informe compilado en HTML
│   └── Taller_3_Grupo_10.pdf                   # Informe compilado en PDF
├── uso de IA/
│   └── Anexo_Uso_IA_Taller_3_Grupo_10.docx     # Anexo formal de uso auxiliar de IA
└── README.md
```

Los paquetes no vistos en clase están identificados al inicio de cada script y en el informe `.qmd` con el comentario `# [PAQUETE ADICIONAL]: <paquete>` (`readxl`, `readr`, `sf`, `rmapshaper`, `stringr`, `scales`, `httr`, `jsonlite`, `xml2`, `lubridate`, `here`, `shiny`, `bslib`, `leaflet`, `plotly`, `DT`, `ggrepel`, `knitr` y `kableExtra`).

## 2. Distribución por ejes

Cada integrante se encargó de un eje completo (código, sección del informe, pestaña en Shiny y verificación de cifras) y revisó los puntos restantes del taller.

| Eje | Responsable | Alcance técnico |
| :--- | :--- | :--- |
| Eje 1: Datos geoespaciales e IDF | Sergio López (`202111932`) | Unión de las 4 fuentes oficiales por código DIVIPOLA, proyección del VA 2023 a 2024 ($g = 8.27\%$), demostración de invarianza de $w_i$, comprobación $\sum w_i = 1$ frente a `weighted.mean()`, simplificación municipal con `rmapshaper::ms_simplify()` (Bono 1) y Pestaña 1 del Shiny. |
| Eje 2: Web scraping, API y tasas | Miguelangel Palma (`202621481`) | Web scraping SDMX-XML del IBR Overnight (BanRep), consulta REST JSON de la SOFR Overnight (Fed de Nueva York, fecha de consulta `2026-11-02`), empalme de calendarios con *forward-fill*, contraste contra boletines oficiales, gráficos de doble eje y Pestaña 2 del Shiny (con selector Nominal / `% E.A.` sincronizado en KPIs y gráfico Plotly e instrucciones visibles). |
| Eje 3: Diseño libre, Shiny y compilación | Juan José Echeverry (`202616233`) | Cruce departamental GEIH/EMICRON 2024 con IDF 2024 (`datos_ejercicio_3c_laboral.csv`), gráfico de burbujas en Plotly y tabla DT, módulos `NS`/`moduleServer` en `bslib` (`page_navbar`, `kpi_card_institucional`, nota explicativa abierta en Pestaña 3, CSS y MathJax en cliente), compilación Quarto y anexo de IA. |

## 3. Instrucciones de ejecución

### 3.1 Scripts en R y aplicativo Shiny

Con el directorio de trabajo ubicado en la carpeta `Taller_3/` (descomprimida o dentro de `Entregable_Talleres/Taller_3/`), cada componente se ejecuta de forma independiente:

```bash
# 1. Ejercicio 1 (requiere los archivos Excel y shapefiles en Datos/Taller_3/ o dentro de Taller_3/Datos/)
Rscript Scripts/Punto_1/01_procesamiento_geoespacial_idf.R

# 2. Ejercicio 2 (extracción y cruce de tasas IBR y SOFR)
Rscript Scripts/Punto_2/01_extraer_sofr_api.R
Rscript Scripts/Punto_2/02_extraer_ibr_banrep.R
Rscript Scripts/Punto_2/03_analisis_financiero_punto_2.R

# 3. Ejercicio 3 (preparación de insumos .rds y figura 3.C)
Rscript Scripts/Punto_3/01_preparar_datos_shiny.R
```

Para abrir el aplicativo Shiny con sus tres pestañas (Desempeño Fiscal, Tasas y Devaluación Implícita, y Dualismo Laboral y Capacidad Fiscal):

```r
shiny::runApp("Scripts/Punto_3")
```

*(Si se ejecutan los comandos anteriores desde la raíz del repositorio completo en lugar de `Taller_3/`, anteponga `Entregable_Talleres/Taller_3/` a cada ruta).*

### 3.2 Compilación del informe en Quarto

Para regenerar el informe en HTML y PDF:

```bash
quarto render Notebooks/Taller_3_Grupo_10.qmd
```

## 4. Verificaciones antes de entregar

| Requisito | Caso revisado | Resultado en el taller | Fuente oficial | Estado |
| :--- | :--- | :--- | :--- | :--- |
| Unión revisada | Medellín (`05001`) | IDF 2024: `69.73`, $w_i = 0.9243$, IDF Antioquia: `69.58` | DNP CIFFIT (2024) y DANE Cuentas Nacionales | Coincide |
| Contraste IBR | `2024-03-15` y `2025-10-31` | `12.747%` E.A. y `9.250%` E.A. | BanRep SUAMECA (serie `241`, consulta `2026-11-02`) | Coincide |
| Contraste SOFR | `2024-03-15` y `2025-10-31` | `5.31%` y `4.22%` (`4.310%` E.A.) | Markets Data NY Fed (endpoint `520`, consulta `2026-11-02`) | Coincide |
| Procedimiento alternativo | IDF (`weighted.mean`) y $\pi$ | Diferencia máx. IDF = `0.0000`; al `31/10/2025`: $\pi_{\text{directa}} = 4.826\%$ y $\pi_{\text{EA}} = 4.736\%$ | Fórmulas con VA 2023 y convención E.A. base 360 | Verificado |

## 5. Uso de inteligencia artificial

Conforme a los *Lineamientos para el uso de inteligencia artificial generativa (IAG) en la Universidad de los Andes* (octubre de 2024, Nivel 3) y la regla del curso, el grupo utilizó Google Gemini como apoyo auxiliar para sintaxis en R y maquetación de interfaz en Shiny. Las interpretaciones económicas, las decisiones metodológicas y la redacción de los análisis pertenecen exclusivamente a los integrantes del Grupo 10.

* Anexo en Word: [`uso de IA/Anexo_Uso_IA_Taller_3_Grupo_10.docx`](./uso%20de%20IA/Anexo_Uso_IA_Taller_3_Grupo_10.docx)
* Sesión 1 (consultas técnicas en los 3 ejes): <https://share.gemini.google/sRSea3dbMXqg>
* Sesión 2 (refinamiento de interfaz en Shiny): <https://share.gemini.google/NmaotI84oYiV>
