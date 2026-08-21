# Talleres de R

Repositorio general para organizar los talleres del curso de programacion en R.

Cada taller vive en su propia carpeta dentro de [`talleres/`](talleres/). De esta forma, los scripts, borradores, evidencias y verificaciones de un taller no se mezclan con los de los siguientes.

## Talleres disponibles

| Taller | Estado | Acceso |
|---|---|---|
| Taller 1 | En desarrollo | [`talleres/taller_01/`](talleres/taller_01/) |

## Estructura

```text
Talleres_de_R/
|-- README.md
|-- Talleres_de_R.Rproj
`-- talleres/
    |-- README.md
    `-- taller_01/
        |-- README.md
        |-- Taller1_Grupo_NUMERO.R
        |-- borradores/
        |-- evidencias_IA/
        `-- scripts/
```

## Uso recomendado

1. Abrir `Talleres_de_R.Rproj` en RStudio.
2. Entrar a la carpeta del taller correspondiente.
3. Trabajar inicialmente en los archivos de `borradores/`.
4. Integrar solamente codigo revisado en el script maestro del taller.
5. Ejecutar las verificaciones indicadas en el `README.md` de cada taller.
6. Hacer commits pequenos y descriptivos, indicando el taller y los ejercicios modificados.

El script maestro de cada taller debe seguir siendo autosuficiente: no debe depender de los archivos de `borradores/` para ejecutarse.

