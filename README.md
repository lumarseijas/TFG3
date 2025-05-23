# TRAYECTORIA GIRO:

## CON KALMAN_CV:
<img src="img/kalman_cv.png" width="500"/>

## MONTECARLO CON KALMAN_CV VIENDO CON MÁSCARA EUROCONTROL

<img src="img/montecarlo_CV_EURO.png" width="1000"/>

---

### Análisis por Tramos y Transiciones (σₐ = 1.1)

| # | Tipo              | Duración (s) | Long (RMS / Max) | Trans (RMS / Max) | Vel (RMS / Max) | Rumbo (RMS / Max) |
|----|-------------------|--------------|-------------------|--------------------|------------------|--------------------|
|  1 | uniforme          |      240.0 |  101.03 / 60      |  100.82 / 60       |   3.94 / 0.6     |  17.44 / 0.7     |
|  2 | uniforme_giro     |       24.0 |  184.51 / 140     |   96.83 / 230      |   4.32 / 6.0     |  14.47 / 17.0    |
|  3 | uniforme_giro     |       22.0 |  477.45 / 140     |  113.39 / 215      |   6.44 / 6.0     |  25.23 / 14.5    |
|  4 | giro              |       98.0 |  340.77 / 100     |  276.25 / 100      |  10.47 / 4.0     |  20.94 / 6.0     |
|  5 | giro_uniforme     |       27.9 |  108.69 / 100     |  121.21 / 100      |   3.59 / 4.0     |   4.26 / 6.0     |
|  6 | uniforme          |      262.0 |   59.65 / 60      |  106.65 / 60       |   1.38 / 0.6     |   1.32 / 0.7     |
### Porcentaje de Incumplimiento EUROCONTROL (σₐ = 1.1)

| Segmento           | Duración (s) | Longitud (%) | Transversal (%) | Velocidad (%) | Rumbo (%) |
|--------------------|--------------|----------------|-------------------|----------------|------------|
| uniforme           |      240.0 |        100.0 |           100.0 |          21.7 |        5.0 |
| uniforme_giro_1    |       24.0 |         50.0 |             0.0 |          16.7 |       33.3 |
| uniforme_giro_2    |       22.0 |        100.0 |            16.7 |          50.0 |      100.0 |
| giro               |       98.0 |         92.0 |            76.0 |          76.0 |       96.0 |
| giro_uniforme      |       27.9 |         42.9 |           100.0 |          57.1 |       14.3 |
| uniforme           |      262.0 |          6.2 |           100.0 |          27.7 |        9.2 |

---
### Resultados de incumplimiento para distintos valores de σₐ (Kalman CV)

| σₐ   | Longitud (%) | Transversal (%) | Velocidad (%) | Rumbo (%) |
|------|---------------|------------------|----------------|-------------|
| 0.10 | 69.6          | 83.0             | 59.3           | 50.5        |
| 0.50 | 62.7          | 91.5             | 35.6           | 30.5        |
| 0.70 | 60.3          | 90.2             | 35.1           | 29.3        |
| 0.80 | 60.1          | 89.6             | 34.7           | 27.2        |
| 0.90 | 59.3          | 90.7             | 34.9           | 27.9        |
| 0.95 | 58.7          | 88.4             | 29.7           | 27.9        |
| 1.00 | 58.7          | 89.5             | 29.7           | 26.7        |
| 1.05 | 58.1          | 89.5             | 31.4           | 25.6        |
| **1.10** | **58.2**     | **86.5**           | **32.4**         | **25.9**      |
| 1.20 | 57.6          | 87.6             | 34.1           | 25.3        |
| 1.50 | 58.0          | 88.2             | 34.9           | 24.3        |
| 2.00 | 65.9          | 87.4             | 42.5           | 22.2        |
| 5.00 | 87.7          | 89.0             | 62.0           | 20.9        |
| 7.00 | 90.7          | 89.5             | 64.2           | 27.8        |
| 10.0 | 90.7          | 89.5             | 72.8           | 28.4        |

> **Nota:** El valor óptimo según el mínimo incumplimiento medio total es **σₐ = 1.10**.


<img src="img/comparacion_sigmas_cv.png" width="500"/>


| σₐ       | Comportamiento global                        | Tramos rectos                                 | Tramos de giro                                   | Robustez global |
| -------- | -------------------------------------------- | --------------------------------------------- | ------------------------------------------------ | --------------- |
| **0.5**  | Muy rígido, gran error en maniobras          | Muy bajo error (6 m y 120 m RMS)              | Error muy alto (852 m, 587 m)                    |  Baja         |
| **1.0**  | Más equilibrado, mejora notable en giros     | Bajo error (43 m)                             | Sigue fallando en giros cortos (498 m)           |  Aceptable    |
| **3.0**  | Buen compromiso entre rigidez y flexibilidad | Aumenta ligeramente el error (7–8 m)          | Giros mucho mejor seguidos (113 m)               |  Alta         |
| **5.0**  | Más flexible pero ruido y errores visibles   | Más error en rectas (8.2 m y 4.8 m), aún bajo | Giros suaves, pero pierde precisión (68 m)       |  Media        |
| **10.0** | Muy laxo, pierde precisión en zonas estables | RMS hasta 12.9 m en rectas                    | Sigue bien los giros (27.4 m) pero poco realista |  Muy baja     |


## KALMAN MANIOBRA

### Comparación de valores de los parámetros

TOP 10 resultados por combinación:

|   σₐ_n |   σₐ_m |    α |     PFA |  RMS total | % Incumpl. |
|--------|--------|------|---------|------------|-------------|
|   0.03 |   22.0 | 0.52 | 5.5e-02 |       9.23 |       9.52 |
|   0.03 |   23.0 | 0.50 | 5.5e-02 |       9.04 |       9.67 |
|   0.02 |   22.0 | 0.50 | 6.0e-02 |       9.45 |       9.76 |
|   0.02 |   22.0 | 0.52 | 7.0e-02 |       9.18 |       9.82 |
|   0.03 |   23.5 | 0.52 | 5.5e-02 |       9.48 |       9.85 |
|   0.03 |   24.0 | 0.50 | 6.0e-02 |       9.40 |       9.97 | 
|   0.03 |   21.5 | 0.50 | 7.0e-02 |       9.20 |      10.06 |
|   0.03 |   21.0 | 0.55 | 7.0e-02 |       9.81 |      10.06 |
|   0.03 |   24.0 | 0.52 | 6.0e-02 |       9.19 |      10.08 |
|   0.02 |   23.0 | 0.50 | 6.0e-02 |       8.80 |      10.12 |




MEJOR COMBINACIÓN ENCONTRADA:

σₐ_normal   = 0.03

σₐ_maniobra = 22.0

α           = 0.52

PFA         = 5.5e-02

RMS total   = 9.23

% Incumpl.  = 9.52%

<img src="img/montecarlo_maniobra.png" width="1000"/>


## Análisis por Tramos y Transiciones (Filtro con Maniobra)

| # | Tipo              | Duración (s) | Long (RMS / Max) | Trans (RMS / Max) | Vel (RMS / Max) | Rumbo (RMS / Max) |
|----|-------------------|--------------|-------------------|--------------------|------------------|--------------------|
|  1 | uniforme          |      240.0 |    4.04 / 60      |    5.51 / 60       |   3.59 / 0.6     |  17.44 / 0.7     |
|  2 | uniforme_giro     |       24.0 |  208.50 / 140     |  226.91 / 230      |  34.87 / 6.0     |  14.11 / 17.0    |
|  3 | uniforme_giro     |       74.0 |   52.32 / 140     |  110.57 / 215      |  21.24 / 6.0     |  11.68 / 14.5    |
|  4 | giro              |       98.0 |  111.87 / 100     |  147.14 / 100      |  25.19 / 4.0     |  12.31 / 6.0     |
|  5 | giro_uniforme     |       19.1 |    6.84 / 100     |    6.13 / 100      |   1.68 / 4.0     |   0.25 / 6.0     |
|  6 | uniforme          |      262.0 |    6.23 / 60      |   17.30 / 60       |   0.45 / 0.6     |   0.20 / 0.7     |

## Porcentaje de Incumplimiento EUROCONTROL

| Segmento           | Duración (s) | Longitud (%) | Transversal (%) | Velocidad (%) | Rumbo (%) |
|--------------------|--------------|----------------|-------------------|----------------|------------|
| uniforme           |      240.0 |          0.0 |             0.0 |          16.7 |        5.0 |
| uniforme_giro_1    |       24.0 |         50.0 |            50.0 |          16.7 |       33.3 |
| uniforme_giro_2    |       74.0 |          5.3 |            15.8 |          31.6 |       31.6 |
| giro               |       98.0 |         16.0 |            40.0 |          44.0 |       60.0 |
| giro_uniforme      |       19.1 |          0.0 |             0.0 |           0.0 |        0.0 |
| uniforme           |      262.0 |          0.0 |             1.5 |           6.1 |        0.0 |



Detalle de incumplimiento por métrica (mejor combinación):

Longitudinal:   4.44 %

Transversal:    7.78 %

Velocidad:      15.56 %

Rumbo:          15.56 %


