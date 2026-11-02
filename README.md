# Talleres de Programación en R (2026-02)

Repositorio oficial de trabajo del **Grupo 10** para el desarrollo, control de versiones, análisis y documentación de los talleres prácticos del curso *Taller de Programación en R* de la Maestría en Economía Aplicada (MECA) en la Universidad de los Andes.

---

## Integrantes del Grupo 10

* **Juan José Echeverry** – Código: `202616233`
* **Miguelangel Palma** – Código: `202621481`
* **Sergio López** – Código: `202111932`

---

## Estructura General del Repositorio

```text
Talleres_de_R/
├── README.md                          # Documentación maestra integral del repositorio
├── Entregables_R.Rproj                # Proyecto RStudio (gestión de rutas relativas con here)
├── Enunciado_Talleres/                # Enunciados oficiales en PDF de los tres talleres
│   ├── Taller 1 2026-02 - Enunciado.pdf
│   ├── Taller 2 2026-02 - Enunciado.pdf
│   └── Taller 3 2026-2.pdf
├── librerias/                         # Cheatsheets y documentación oficial en PDF
├── scripts_clase/                     # Scripts pedagógicos y actividades aplicadas del curso
├── Datos/                             # Insumos primarios oficiales y microdatos (no modificados)
│   ├── GEIH_2023/                     # 12 meses de recolección de microdatos GEIH 2023 (DANE)
│   ├── GEIH_2024/                     # 12 meses de recolección de microdatos GEIH 2024 (DANE)
│   ├── EMICRON_2024/                  # Módulos oficiales de micronegocios 2024 (DANE)
│   └── Taller_3/                      # Cartografía vectorial y fuentes del Taller 3 (DNP y DANE)
│       ├── shapefiles/                # Shapefiles oficiales (MGN_DPTO_POLITICO y MGN_MPIO_POLITICO)
│       ├── ResultadosIDF_DNP.xlsx     # Resultados del Índice de Desempeño Fiscal 2024 (DNP)
│       ├── anex-PIBDep...xlsx         # Valor Agregado Municipal 2023 (DANE Cuentas Nacionales)
│       └── PPED-AreaMun...xlsx        # Proyecciones de Población Municipal 2024 (DANE)
├── outputs/                           # Salidas exportadas de los Talleres 1 y 2
├── evidencias_IA/                     # Declaración y registro de uso de herramientas de IA
└── Entregable_Talleres/
    ├── Taller_1/                      # Taller 1: Fundamentos y manipulación en R
    │   └── Taller1_Grupo_10.R
    ├── Taller_2/                      # Taller 2: Mercado Laboral y Micronegocios (GEIH + EMICRON)
    │   ├── README.md
    │   ├── Taller2_Grupo_10.R
    │   ├── Informe_Taller_2_Grupo_10.pdf
    │   ├── 01_informe_quarto/
    │   ├── 02_cuaderno_pedagogico/
    │   └── 04_guia_maestra_estudio/
    └── Taller_3/                      # Taller 3: Datos Geoespaciales, Web Scraping y Shiny
        ├── README.md                  # Outline modular, división de responsabilidades y auditoría
        ├── Scripts/
        │   ├── Punto_1/
        │   │   └── 01_procesamiento_geoespacial_idf.R  # IDF ponderado departamental y mapas
        │   ├── Punto_2/
        │   │   ├── 01_extraer_sofr_api.R              # REST API Fed de Nueva York
        │   │   ├── 02_extraer_ibr_banrep.R            # Web scraping XML BanRep
        │   │   └── 03_analisis_financiero_punto_2.R   # Armonización, spread y gráficos
        │   └── Punto_3/
        │       ├── app.R                              # Aplicativo interactivo Shiny (bslib)
        │       ├── datos_ejercicio_3c_laboral.csv     # Base departamental Literal C
        │       └── data_shiny/                        # RDS serializados para carga rápida
        ├── Outputs/
        │   ├── Data/
        │   │   ├── raw/                               # Respaldos crudos JSON/XML y CSVs
        │   │   └── processed/                         # Base consolidada final (series_financieras)
        │   └── Images/                                # Mapas y figuras a 300 DPI (1_1, 1_2, 2_a, 2_b, 2_c)
        └── Notebooks/
            ├── Taller_3_Grupo_10.qmd                  # Cuaderno maestro Quarto
            ├── Taller_3_Grupo_10.html                 # Versión interactiva para Posit Connect
            └── Taller_3_Grupo_10.pdf                  # Informe académico formal sin desbordes
```

---

## Resumen Ejecutivo de los Talleres

### Taller 1: Fundamentos, Programación Funcional y Manipulación de Vectores
* **Objetivo:** Dominio de las estructuras de datos básicas de R (vectores, matrices, listas, data frames), operaciones vectorizadas, funciones personalizadas y control de flujo.
* **Entregable:** `Entregable_Talleres/Taller_1/Taller1_Grupo_10.R` (20 ejercicios resueltos de forma autónoma).

### Taller 2: Mercado Laboral y Micronegocios en Colombia (GEIH y EMICRON)
* **Objetivo:** Procesamiento a gran escala de encuestas de hogares y unidades económicas del DANE:
  - Integración mensual de la GEIH 2024 (PET, FT, Ocupados, Desocupados).
  - Cálculo de tasas laborales (TGP, TO, TD) con factores de expansión trimestrales y anuales.
  - Replicación exacta de la sintaxis oficial DANE para formalidad laboral (42.5% en 13 ciudades).
  - Integración relacional GEIH-EMICRON (71.754 micronegocios emparejados).
  - Ejercicios libres: dualismo laboral y salarial, inclusión digital y emparejamiento educativo.
* **Entregables:** `Entregable_Talleres/Taller_2/` (Script maestro, informes en PDF y Cuaderno Pedagógico).

### Taller 3: Datos Geoespaciales, Web Scraping y Aplicaciones Interactivas
* **Objetivo:** Ingesta de fuentes heterogéneas, cartografía vectorial, consumo de APIs REST, web scraping automatizado y desarrollo de tableros interactivos:
  1. **Ejercicio 1 (Datos Geoespaciales e IDF):**
     - Integración municipal de 4 fuentes: DNP (IDF 2024), DANE Cuentas Nacionales (Valor Agregado 2023 proyectado a 2024 al 8.27%), DANE Proyecciones de Población 2024 y Marco Geoestadístico Nacional (MGN).
     - Demostración de homogeneidad del ponderador $w_i = (Pob_i \times VA_i) / \sum (Pob_j \times VA_j)$, comprobación de consistencia $\sum w_i = 1$ y cálculo del IDF departamental ponderado.
     - Cartografía: mapa temático departamental (`1_1_mapa_idf_departamental.png`) y mapa municipal optimizado con simplificación topológica Visvalingam-Whyatt (`1_2_mapa_idf_municipal_bono.png`), reduciendo el 92% de vértices redundantes sin generar huecos ni traslapes.
  2. **Ejercicio 2 (Web Scraping, APIs y Series Financieras):**
     - Extracción vía **Web Scraping** de la tasa IBR Overnight (2020–2025) desde el servicio SDMX-XML del Banco de la República (parseo directo con `xml2`).
     - Extracción vía **API REST** de la tasa SOFR Overnight (2020–2025) desde la Markets Data API de la Reserva Federal de Nueva York (parseo estructurado con `jsonlite`).
     - Armonización temporal con `full_join` y tratamiento de festivos asimétricos mediante *forward-fill* (`fill(..., .direction = "down")`), garantizando continuidad financiera sin distorsión.
     - Estimación del spread ($i_{IBR} - i_{SOFR}$) y comprobación analítica de la devaluación implícita $\pi = \frac{1+i_d}{1+i_e} - 1$ frente a la aproximación por serie de Taylor.
  3. **Ejercicio 3 (Aplicativo Shiny Interactivo):**
     - Tablero interactivo con arquitectura Bootstrap 5 (`bslib`, tema `cosmo`, `page_navbar`, `value_box`).
     - **Pestaña 1:** Mapa coroplético interactivo en Leaflet con selección de departamentos y desglose del Top 3 municipal.
     - **Pestaña 2:** Gráfico interactivo en Plotly con doble eje independiente, selector de fecha histórica y calculadora de devaluación implícita con alertas dinámicas en días no hábiles.
     - **Pestaña 3:** Visualización en Plotly sobre dualismo laboral departamental (tasa de informalidad vs. mediana de ingresos) con selectores reactivos.
* **Entregables:** `Entregable_Talleres/Taller_3/` (Scripts modulares por ejercicio, salidas centralizadas y reporte Quarto compilado en HTML y PDF académico).

---

## Instrucciones de Reproducción

### Ejecución del Taller 3
Desde la raíz del repositorio en la consola o RStudio:

```bash
# 1. Ejecutar el procesamiento geoespacial (Punto 1)
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_1/01_procesamiento_geoespacial_idf.R

# 2. Ejecutar la extracción de datos y análisis de tasas (Punto 2)
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_2/01_extraer_sofr_api.R
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_2/02_extraer_ibr_banrep.R
Rscript Entregable_Talleres/Taller_3/Scripts/Punto_2/03_analisis_financiero_punto_2.R

# 3. Lanzar la aplicación interactiva Shiny (Punto 3)
Rscript -e "shiny::runApp('Entregable_Talleres/Taller_3/Scripts/Punto_3')"

# 4. Compilar el reporte Quarto (HTML interactivo y PDF académico)
quarto render Entregable_Talleres/Taller_3/Notebooks/Taller_3_Grupo_10.qmd
```

---

## Declaración sobre Uso de Inteligencia Artificial

De acuerdo con las directrices del curso y la reglamentación de la Universidad de los Andes (Nivel 3 de IAG), las herramientas de inteligencia artificial generativa se utilizaron exclusivamente como apoyo técnico para la optimización de código, estructuración modular y maquetación de informes reproducibles. La formulación metodológica, las decisiones analíticas, la interpretación económica y el control de calidad son autoría íntegra de los integrantes del Grupo 10. Las evidencias de auditoría reposan en `evidencias_IA/` y en las matrices técnicas de cada entrega.
