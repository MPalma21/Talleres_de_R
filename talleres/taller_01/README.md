# Taller 1 - Programacion en R (2026-02)

Repositorio de trabajo del grupo para construir, revisar y practicar el Taller 1.

## Fechas clave

- Entrega del script: 31 de agosto de 2026, 11:59 p. m.
- Sesion de evaluacion: 2 de septiembre de 2026.
- Entregable principal: un unico script `Taller1_Grupo_NUMERO.R` que corra completo sin intervencion manual.

## Distribucion del trabajo

| Responsable | Historia | Ejercicios | Responsabilidad adicional |
|---|---|---|---|
| Persona 1 | Construccion y analisis de la poblacion | 1, 2, 4, 5, 8, 9, 11, 19 | Verificar nombres y tipos de los objetos base |
| Persona 2 | Herramientas reutilizables | 3, 6, 7, 10, 12, 13, 14, 15, 20 | Probar funciones con casos normales y casos limite |
| Persona 3 | Simulacion y modelos | 16, 17, 18 | Integrar el script y liderar las pruebas completas |

La autoria se divide, pero todos deben comprender y poder modificar los 20 ejercicios.

## Flujo de trabajo

1. Cada persona desarrolla y prueba su bloque en `borradores/`.
2. La persona integradora copia solamente codigo revisado al script maestro.
3. El script maestro siempre conserva los ejercicios del 1 al 20 en orden.
4. Antes de integrar, se verifica que los nombres de objetos coincidan exactamente con el enunciado.
5. Despues de cada integracion se ejecuta, desde la raiz del repositorio, `source("talleres/taller_01/scripts/verificar_estructura.R")`.
6. La version final se ejecuta completa desde una sesion limpia de R.

No se deben usar `source()` ni los archivos de `borradores/` en la entrega final: el archivo entregado tiene que ser autosuficiente.

## Dependencias criticas

```text
2 -> 4, 5, 8, 9, 11, 13, 14, 16, 19
8 -> 11
13 -> 14 -> 16
15 -> 18
16 -> 18, 19
17 -> 18
```

## Cronograma

| Fecha | Actividad |
|---|---|
| 15-16 de agosto | Acordar parametros, nombres, formato y reparto |
| 17-21 de agosto | Desarrollo individual |
| 22 de agosto | Primera integracion |
| 23-25 de agosto | Depuracion y revision de dependencias |
| 26-28 de agosto | Explicacion cruzada de los 20 ejercicios |
| 29 de agosto | Primer simulacro con tres ejercicios aleatorios |
| 30 de agosto | Segundo simulacro y cambios de parametros |
| 31 de agosto | Prueba limpia, revision y entrega |
| 1 de septiembre | Ensayo oral final |

## Lista de control final

- [ ] Reemplazar `NUMERO` en el nombre del script por el numero real del grupo.
- [ ] El script corre de principio a fin en una sesion limpia.
- [ ] Los 20 ejercicios aparecen en orden y tienen comentarios claros.
- [ ] Los valores clave estan definidos una sola vez como parametros.
- [ ] No hay numeros magicos repetidos.
- [ ] No se usan funciones o librerias no permitidas.
- [ ] Las respuestas e interpretaciones estan inmediatamente debajo del codigo correspondiente.
- [ ] Se probaron cambios de semilla, umbrales, tasas y coeficientes.
- [ ] Todos pueden explicar y modificar cualquier ejercicio.
- [ ] Las conversaciones con IA utilizadas estan guardadas en `evidencias_IA/`.
