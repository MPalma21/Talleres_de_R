# Taller 3: Datos Geoespaciales, Web Scraping y Herramientas de Visualización

**Curso:** Taller de Programación en R · 2026-2  
**Facultad de Economía – Universidad de los Andes**  
**Grupo:** 10  
**Integrantes:**
* **Juan José Echeverry** – Código: `202616233`
* **Miguelangel Palma** – Código: `202621481`
* **Sergio López** – Código: `202111932`

---

## 1. Estructura de la Entrega (`Entregable_Talleres/Taller_3/`)

```text
Entregable_Talleres/Taller_3/
├── Taller3_Grupo_10.R                   # Script oficial de calificación (100% autónomo y reproducible)
├── Informe_Taller_3_Grupo_10.Rmd        # Documento R Markdown fuente para compilación a PDF
├── Informe_Taller_3_Grupo_10.pdf        # Documento ejecutivo generado (11 páginas con mapas y figuras)
├── app.R                                # Aplicativo Shiny interactivo (3 pestañas con arquitectura bslib)
├── datos_ejercicio_3c_laboral.csv       # Base de datos utilizada en el Literal C del Ejercicio 3
├── README.md                            # Guía de reproducción, outline y matriz de auditoría
└── data_shiny/                          # Capas y datos serializados para carga instantánea en Shiny
    ├── df_deptos.rds
    ├── df_labor.rds
    ├── df_rates.rds
    ├── df_top3.rds
    └── shp_dpto_simp.rds
```

*Nota sobre la carpeta de salidas:* Todas las figuras (`.png`) y tablas exportadas (`.csv`) se almacenan de manera centralizada en la carpeta `outputs/` ubicada en la raíz del repositorio.

---

## 2. División Equitativa por Ejes Completos (1/3 por Integrante + Revisión Integral)

La estructura de revisión, verificación técnica y sustentación del Taller 3 está organizada bajo un esquema equitativo por **Ejes Completos** (donde cada integrante lidera 1/3 exacto del código, informe, pestaña Shiny y auditoría de su eje, además de realizar la revisión y ejecución transversal de la totalidad del taller):

| Eje Temático | Integrante Líder | Componentes del Eje (Código + Informe + Shiny + Auditoría) | Responsabilidad de Revisión y Sustentación |
| :--- | :--- | :--- | :--- |
| **Eje 1: Datos Geoespaciales y Desempeño Fiscal** | **Sergio López** <br> *(Código: `202111932`)* | **• Ejercicio 1 Completo (Literales A y B)**<br>**• Bono 1 (Mapa Municipal Optimizado)**<br>**• Pestaña 1 del Shiny (`leaflet` + Top 3)**<br>**• Auditoría de Unión Territorial** | • Integración de las 4 fuentes oficiales (DNP IDF 2024, DANE MGN Shapefiles, DANE Población 2024 y DANE Valor Agregado 2023) por código DIVIPOLA (`cod_mpio`).<br>• Proyección de VA 2023 a 2024 a precios corrientes (8,27%), demostración de homogeneidad de $w_i$, comprobación $\sum w_i = 1$ y mapa departamental.<br>• Diagnóstico computacional y simplificación topológica Visvalingam-Whyatt (`rmapshaper::ms_simplify`) para los ~1.120 municipios (Bono 1).<br>• Pestaña 1 interactiva con selector reactivo, clic sobre polígono y tabla del Top 3 municipal, más auditoría de Medellín (`05001`). |
| **Eje 2: Web Scraping, APIs y Series Financieras** | **Miguelangel Palma** <br> *(Código: `202621481`)* | **• Ejercicio 2 Completo (Literales A, B y C)**<br>**• Pestaña 2 del Shiny (Doble Eje y $\pi$)**<br>**• Auditoría de Tasas y Paridad** | • Extracción vía **Web Scraping** de la tasa IBR Overnight (2020–2025) desde el portal SUAMECA del Banco de la República (parseo XML SDMX con `xml2`, convención % E.A.).<br>• Extracción vía **API REST** de la tasa SOFR Overnight (2020–2025) desde la Markets Data API de la Reserva Federal de Nueva York (parseo JSON con `jsonlite`).<br>• Armonización de calendarios financieros (`full_join` + *forward-fill*), gráfico estático e interactivo de doble eje y análisis del ciclo monetario.<br>• Pestaña 2 de Shiny con consulta por fecha, cálculo de devaluación implícita $\pi = (1+i_d)/(1+i_e)-1$, alerta en días no hábiles y contraste oficial del 15/03/2024. |
| **Eje 3: Diseño Libre, Arquitectura Shiny e Integridad Reproducible** | **Juan José Echeverry** <br> *(Código: `202616233`)* | **• Ejercicio 3 (Literal C - Diseño Libre)**<br>**• Pestaña 3 y Arquitectura UI `bslib` (Bono Diseño)**<br>**• Script Maestro, Compilación Rmd y Anexo IA** | • Construcción y exportación de `datos_ejercicio_3c_laboral.csv` y visualización interactiva en `plotly` sobre dualismo laboral departamental (informalidad vs. ingreso mediano) con filtros reactivos.<br>• Arquitectura integral de `app.R` con `bslib` (tema Bootstrap 5 `flatly`, `page_navbar`, `value_box`) para optar al Bono de Mejor Diseño.<br>• Verificación de ejecución autónoma desde cero de `Taller3_Grupo_10.R`, etiquetado de `# [PAQUETE ADICIONAL]`, compilación de `Informe_Taller_3_Grupo_10.Rmd` a PDF e inclusión del Anexo de IA. |

---

## 3. Instrucciones de Ejecución y Reproducibilidad

### 3.1 Ejecución del Script Maestro de Calificación
Para ejecutar el flujo completo desde la consola de Windows o RStudio:
```bash
Rscript Entregable_Talleres/Taller_3/Taller3_Grupo_10.R
```
El script descargará automáticamente los datos faltantes en `Datos/Taller_3/`, calculará las ponderaciones, generará las visualizaciones en `outputs/` y exportará las capas optimizadas para Shiny.

### 3.2 Ejecución del Aplicativo Shiny
Para iniciar el aplicativo interactivo Shiny:
```r
shiny::runApp("Entregable_Talleres/Taller_3")
```
El aplicativo abrirá una interfaz moderna con tres pestañas funcionales:
1. **Desempeño Fiscal (IDF):** Mapa interactivo de Colombia en Leaflet con selección de departamentos y desglose del Top 3 municipal.
2. **Tasas y Devaluación:** Serie interactiva de doble eje en Plotly, selector de fecha histórica y calculadora de la tasa de devaluación implícita con manejo de festivos.
3. **Diseño Libre (Plotly):** Scatter interactivo de informalidad vs. ingreso laboral mediano con filtros regionales y selector de población.

### 3.3 Compilación del Informe en PDF
```r
rmarkdown::render("Entregable_Talleres/Taller_3/Informe_Taller_3_Grupo_10.Rmd")
```

---

## 4. Matriz de Auditoría y Verificación de Integridad

En estricto apego a las instrucciones de entrega, se documentan las comprobaciones técnicas realizadas:

| Evidencia Solicitada | Caso Auditado | Valor Obtenido en el Taller | Fuente Oficial Primaria | Estado de Verificación |
| :--- | :--- | :--- | :--- | :--- |
| **1. Unión revisada** | Medellín (`05001`) | IDF: 69,78 \| Peso $w_i$: 0,9243 | DNP CIFFIT / DANE Cuentas Nal. | **COINCIDENCIA EXACTA** |
| **2. Contraste de tasa IBR** | 15 de marzo de 2024 | 12,75% E.A. | Boletín Oficial BanRep SUAMECA | **COINCIDENCIA EXACTA** |
| **3. Contraste de tasa SOFR** | 15 de marzo de 2024 | 5,31% | Markets Data Release NY Fed | **COINCIDENCIA EXACTA** |
| **4. Cálculo redundante** | Devaluación implícita ($\pi$) | 7,06% | $(1 + 0,1275)/(1 + 0,0531) - 1$ | **COMPROBADO** |

---

## 5. Declaración de Cumplimiento de Lineamientos de IA

De acuerdo con la reglamentación de la Universidad de los Andes (Nivel 3 de IAG), las herramientas de inteligencia artificial se emplearon exclusivamente como apoyo técnico para la programación de sintaxis espacial y optimización de código. La totalidad de las interpretaciones, análisis económicos y decisiones metodológicas fueron concebidas y redactadas por los integrantes del Grupo 10.
