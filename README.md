# TRAYECTORIA GIRO:

## MONTECARLO CON KALMAN_CV

<img src="img/montecarlo_cv_5.jpg" width="1000"/>

---
### Análisis por Tramos y Transiciones (σₐ = 5.0)

| # | Tipo              | Duración (s) | Long (RMS / Max) | Trans (RMS / Max) | Vel (RMS / Max) | Rumbo (RMS / Max) |
|----|-------------------|--------------|-------------------|--------------------|------------------|--------------------|
|  1 | uniforme          |      240.0 |  124.82 / 60      |  124.52 / 60       |   2.10 / 0.6     |  17.46 / 0.7     |
|  2 | uniforme_giro     |       24.0 |  138.59 / 140     |   91.94 / 230      |   5.35 / 6.0     |   8.00 / 17.0    |
|  3 | giro              |       98.0 |  133.48 / 100     |  107.88 / 100      |   4.48 / 4.0     |   8.56 / 6.0     |
|  4 | giro_uniforme     |       18.4 |   66.42 / 100     |  139.98 / 100      |   1.78 / 4.0     |   1.33 / 6.0     |
|  5 | uniforme          |      262.0 |   67.49 / 60      |  139.25 / 60       |   1.48 / 0.6     |   0.53 / 0.7     |
### Porcentaje de Incumplimiento EUROCONTROL (σₐ = 5.0)

| Segmento           | Duración (s) | Longitud (%) | Transversal (%) | Velocidad (%) | Rumbo (%) |
|--------------------|--------------|----------------|-------------------|----------------|------------|
| uniforme           |      240.0 |        100.0 |           100.0 |          60.0 |       10.0 |
| uniforme_giro      |       24.0 |         50.0 |             0.0 |          33.3 |        0.0 |
| giro               |       98.0 |         72.0 |            56.0 |          44.0 |       72.0 |
| giro_uniforme      |       18.4 |          0.0 |           100.0 |           0.0 |        0.0 |
| uniforme           |      262.0 |         92.4 |           100.0 |          57.6 |       12.1 |

---
### Resultados de incumplimiento para distintos valores de σₐ según segmentos (Kalman CV)

| Duracion | %Long   | %Trans  | %Vel   | %Rumbo  | Sigma | Segmento        |
|----------|---------|---------|--------|---------|--------|------------------|
| 240.000  | 55.000  | 55.000  | 30.000 | 11.667  | 0.05  | uniforme         |
| 98.000   | 88.000  | 84.000  | 28.000 | 88.000  | 0.05  | uniforme_giro    |
| 98.000   | 92.000  | 88.000  | 32.000 | 96.000  | 0.05  | giro             |
| 98.368   | 100.000 | 100.000 | 100.000| 88.000  | 0.05  | giro_uniforme    |
| 262.000  | 92.424  | 95.455  | 98.485 | 75.758  | 0.05  | uniforme         |
| 240.000  | 53.333  | 53.333  | 16.667 | 6.667   | 0.10  | uniforme         |
| 98.000   | 88.000  | 84.000  | 36.000 | 88.000  | 0.10  | uniforme_giro    |
| 98.000   | 92.000  | 88.000  | 36.000 | 96.000  | 0.10  | giro             |
| 70.387   | 100.000 | 100.000 | 100.000| 83.333  | 0.10  | giro_uniforme    |
| 262.000  | 57.576  | 100.000 | 96.970 | 48.485  | 0.10  | uniforme         |
| 240.000  | 100.000 | 100.000 | 20.000 | 13.333  | 0.50  | uniforme         |
| 60.459   | 81.250  | 37.500  | 37.500 | 81.250  | 0.50  | uniforme_giro    |
| 98.000   | 92.000  | 88.000  | 68.000 | 96.000  | 0.50  | giro             |
| 38.408   | 60.000  | 80.000  | 80.000 | 30.000  | 0.50  | giro_uniforme    |
| 262.000  | 12.121  | 100.000 | 34.848 | 16.667  | 0.50  | uniforme         |
| 240.000  | 100.000 | 100.000 | 18.333 | 6.667   | 0.80  | uniforme         |
| 52.462   | 78.571  | 21.429  | 28.571 | 78.571  | 0.80  | uniforme_giro    |
| 98.000   | 92.000  | 84.000  | 76.000 | 96.000  | 0.80  | giro             |
| 30.414   | 50.000  | 50.000  | 62.500 | 25.000  | 0.80  | giro_uniforme    |
| 262.000  | 7.576   | 100.000 | 33.333 | 12.121  | 0.80  | uniforme         |
| 240.000  | 100.000 | 100.000 | 20.000 | 13.333  | 1.00  | uniforme         |
| 48.464   | 76.923  | 15.385  | 38.462 | 76.923  | 1.00  | uniforme_giro    |
| 98.000   | 92.000  | 80.000  | 72.000 | 96.000  | 1.00  | giro             |
| 30.414   | 37.500  | 75.000  | 50.000 | 25.000  | 1.00  | giro_uniforme    |
| 262.000  | 7.576   | 100.000 | 25.758 | 9.091   | 1.00  | uniforme         |
| 240.000  | 100.000 | 100.000 | 35.000 | 11.667  | 2.00  | uniforme         |
| 36.466   | 70.000  | 0.000   | 40.000 | 60.000  | 2.00  | uniforme_giro    |
| 98.000   | 88.000  | 56.000  | 72.000 | 96.000  | 2.00  | giro             |
| 22.419   | 0.000   | 100.000 | 0.000  | 16.667  | 2.00  | giro_uniforme    |
| 262.000  | 40.909  | 100.000 | 37.879 | 7.576   | 2.00  | uniforme         |
| 240.000  | 100.000 | 100.000 | 70.000 | 16.667  | 5.00  | uniforme         |
| 24.466   | 57.143  | 0.000   | 28.571 | 0.000   | 5.00  | uniforme_giro    |
| 98.000   | 68.000  | 56.000  | 60.000 | 80.000  | 5.00  | giro             |
| 18.422   | 0.000   | 100.000 | 20.000 | 0.000   | 5.00  | giro_uniforme    |
| 262.000  | 96.970  | 100.000 | 50.000 | 12.121  | 5.00  | uniforme         |
| 240.000  | 100.000 | 100.000 | 81.667 | 18.333  | 7.00  | uniforme         |
| 24.466   | 42.857  | 0.000   | 42.857 | 0.000   | 7.00  | uniforme_giro    |
| 98.000   | 72.000  | 52.000  | 44.000 | 64.000  | 7.00  | giro             |
| 18.422   | 0.000   | 100.000 | 20.000 | 0.000   | 7.00  | giro_uniforme    |
| 262.000  | 100.000 | 100.000 | 65.152 | 19.697  | 7.00  | uniforme         |
| 240.000  | 100.000 | 100.000 | 86.667 | 41.667  | 10.00 | uniforme         |
| 20.465   | 66.667  | 0.000   | 16.667 | 0.000   | 10.00 | uniforme_giro    |
| 98.000   | 72.000  | 60.000  | 28.000 | 44.000  | 10.00 | giro             |
| 18.422   | 0.000   | 100.000 | 0.000  | 0.000   | 10.00 | giro_uniforme    |
| 262.000  | 100.000 | 100.000 | 83.333 | 22.727  | 10.00 | uniforme         |
| 240.000  | 100.000 | 100.000 | 98.333 | 51.667  | 15.00 | uniforme         |
| 20.465   | 100.000 | 0.000   | 50.000 | 0.000   | 15.00 | uniforme_giro    |
| 98.000   | 72.000  | 60.000  | 28.000 | 4.000   | 15.00 | giro             |
| 18.422   | 0.000   | 100.000 | 20.000 | 0.000   | 15.00 | giro_uniforme    |
| 262.000  | 100.000 | 100.000 | 83.333 | 48.485  | 15.00 | uniforme         |

---
Mejores sigmas por segmento:
-  giro: 15
-  giro_uniforme: 10
-  uniforme: 0.1
-  uniforme_giro: 10

**Mejor sigma global: 5**

---

## KALMAN MANIOBRA

### Comparación de valores de los parámetros

TOP 10 resultados por combinación:

 Resultados completos por combinación:
|   σₐ_n |   σₐ_m |     α |     PFA |  RMS total | % Incumpl. |
|--------|--------|------|---------|------------|-------------|
|   0.07 |   15.0 | 0.50 | 5.0e-02 |      42.01 |      29.86 |
|   0.07 |   14.0 | 0.60 | 1.0e-01 |      43.30 |      30.28 |
|   0.04 |   14.0 | 0.50 | 7.0e-02 |      41.39 |      30.56 |
|   0.05 |   19.0 | 0.50 | 5.0e-02 |      41.63 |      30.59 |
|   0.05 |   10.0 | 0.50 | 7.0e-02 |      42.08 |      30.69 |
|   0.07 |   20.0 | 0.50 | 1.0e-01 |      41.29 |      30.80 |
|   0.05 |   17.0 | 0.40 | 5.0e-02 |      41.72 |      30.83 |
|   0.07 |   17.0 | 0.40 | 5.0e-02 |      41.63 |      30.83 |
|   0.06 |   19.0 | 0.50 | 5.0e-02 |      41.76 |      31.01 |
|   0.07 |   14.0 | 0.40 | 7.0e-02 |      41.64 |      31.01 |
---

 MEJOR COMBINACIÓN ENCONTRADA:
- σₐ_normal   = 0.07
- σₐ_maniobra = 15.0
- α           = 0.50
- PFA         = 5.0e-02
- RMS total   = 42.01
- % Incumpl.  = 29.86%

<img src="img/montecarlo_mani_mej.jpg" width="1000"/>


### Análisis por Tramos y Transiciones (Filtro con Maniobra mejor combi)

| # | Tipo              | Duración (s) | Long (RMS / Max) | Trans (RMS / Max) | Vel (RMS / Max) | Rumbo (RMS / Max) |
|----|-------------------|--------------|-------------------|--------------------|------------------|--------------------|
|  1 | uniforme          |      240.0 |   87.30 / 60      |   87.16 / 60       |   3.29 / 0.6     |  17.47 / 0.7     |
|  2 | uniforme_giro     |       24.0 |  288.29 / 140     |  173.60 / 230      |  29.13 / 6.0     |  14.42 / 17.0    |
|  3 | uniforme_giro     |       74.0 |  169.44 / 140     |  151.93 / 215      |  15.39 / 6.0     |  11.12 / 14.5    |
|  4 | giro              |       98.0 |  205.69 / 100     |  157.62 / 100      |  19.74 / 4.0     |  12.03 / 6.0     |
|  5 | giro_uniforme     |       16.3 |   69.10 / 100     |  158.22 / 100      |   2.46 / 4.0     |   1.55 / 6.0     |
|  6 | uniforme          |      262.0 |   37.63 / 60      |   83.99 / 60       |   0.62 / 0.6     |   0.43 / 0.7     |

### Porcentaje de Incumplimiento EUROCONTROL para mejor combi

| Segmento           | Duración (s) | Longitud (%) | Transversal (%) | Velocidad (%) | Rumbo (%) |
|--------------------|--------------|----------------|-------------------|----------------|------------|
| uniforme           |      240.0 |         61.7 |            61.7 |           8.3 |       13.3 |
| uniforme_giro_1    |       24.0 |         66.7 |            16.7 |          33.3 |       33.3 |
| uniforme_giro_2    |       74.0 |         66.7 |            16.7 |          38.9 |       27.8 |
| giro               |       98.0 |         79.2 |            62.5 |          41.7 |       66.7 |
| giro_uniforme      |       16.3 |          0.0 |           100.0 |          20.0 |        0.0 |
| uniforme           |      262.0 |          6.1 |            66.7 |           7.6 |        3.0 |


# TRAYECTORIA CON ACELERACIÓN:

## CV
    Duracion    %Long     %Trans     %Vel     %Rumbo    Sigma          Segmento              SegmentoBase    
    ________    ______    ______    ______    ______    _____    ____________________    ____________________

        240     61.667        60        20    3.3333    0.05     "uniforme"              "uniforme"          
     18.418          0         0         0         0    0.05     "uniforme_acelerado"    "uniforme_acelerado"
        100         76        88        84        36    0.05     "acelerado"             "acelerado"         
     18.491        100       100       100       100    0.05     "acelerado_uniforme"    "acelerado_uniforme"
        262     77.273    77.273     96.97    75.758    0.05     "uniforme"              "uniforme"          
        240     53.333    53.333    8.3333    8.3333     0.1     "uniforme"              "uniforme"          
     18.418          0         0         0         0     0.1     "uniforme_acelerado"    "uniforme_acelerado"
        100         72        88        84        48     0.1     "acelerado"             "acelerado"         
     18.491        100       100       100       100     0.1     "acelerado_uniforme"    "acelerado_uniforme"
        262     51.515    51.515    93.939    48.485     0.1     "uniforme"              "uniforme"          
        240        100       100    13.333    6.6667     0.5     "uniforme"              "uniforme"          
     18.418          0         0         0         0     0.5     "uniforme_acelerado"    "uniforme_acelerado"
        100         52       100        76        40     0.5     "acelerado"             "acelerado"         
     18.491         60       100        20         0     0.5     "acelerado_uniforme"    "acelerado_uniforme"
        262     43.939    39.394    33.333    6.0606     0.5     "uniforme"              "uniforme"          
        240        100       100    13.333        10     0.8     "uniforme"              "uniforme"          
     18.418          0         0         0         0     0.8     "uniforme_acelerado"    "uniforme_acelerado"
        100          0       100        12        12     0.8     "acelerado"             "acelerado"         
     18.491          0       100         0         0     0.8     "acelerado_uniforme"    "acelerado_uniforme"
        262     98.485    98.485    40.909    3.0303     0.8     "uniforme"              "uniforme"          
        240        100       100    8.3333        10       1     "uniforme"              "uniforme"          
     18.418          0         0         0         0       1     "uniforme_acelerado"    "uniforme_acelerado"
        100          0       100         0         8       1     "acelerado"             "acelerado"         
     18.491          0       100         0         0       1     "acelerado_uniforme"    "acelerado_uniforme"
        262        100       100    43.939    3.0303       1     "uniforme"              "uniforme"          
        240        100       100        30    6.6667       2     "uniforme"              "uniforme"          
     18.418          0         0         0         0       2     "uniforme_acelerado"    "uniforme_acelerado"
        100          0       100         0         0       2     "acelerado"             "acelerado"         
     18.491          0       100         0         0       2     "acelerado_uniforme"    "acelerado_uniforme"
        262        100       100    37.879    3.0303       2     "uniforme"              "uniforme"          
        240        100       100    68.333    13.333       5     "uniforme"              "uniforme"          
     18.418          0         0         0         0       5     "uniforme_acelerado"    "uniforme_acelerado"
        100          0       100         0         0       5     "acelerado"             "acelerado"         
     18.491          0       100         0         0       5     "acelerado_uniforme"    "acelerado_uniforme"
        262        100       100    63.636    9.0909       5     "uniforme"              "uniforme"          
        240        100       100    78.333    16.667       7     "uniforme"              "uniforme"          
     18.418          0        60         0         0       7     "uniforme_acelerado"    "uniforme_acelerado"
        100          0       100         0         0       7     "acelerado"             "acelerado"         
     18.491          0       100         0         0       7     "acelerado_uniforme"    "acelerado_uniforme"
        262        100       100    65.152    10.606       7     "uniforme"              "uniforme"          
        240        100       100    83.333        35      10     "uniforme"              "uniforme"          
     18.418          0       100         0         0      10     "uniforme_acelerado"    "uniforme_acelerado"
        100          0       100         0         0      10     "acelerado"             "acelerado"         
     18.491          0       100         0         0      10     "acelerado_uniforme"    "acelerado_uniforme"
        262        100       100    71.212    12.121      10     "uniforme"              "uniforme"          
        240        100       100    96.667        50      15     "uniforme"              "uniforme"          
     18.418          0       100         0         0      15     "uniforme_acelerado"    "uniforme_acelerado"
        100          0       100         0         0      15     "acelerado"             "acelerado"         
     18.491          0       100         0         0      15     "acelerado_uniforme"    "acelerado_uniforme"
        262        100       100    84.848    16.667      15     "uniforme"              "uniforme"          

Mejores sigmas por segmento:
- acelerado: 2
- acelerado_uniforme: 0.8000
- uniforme: 0.5000
- uniforme_acelerado: 0.0500

**Mejor sigma global: 1**
---

### Análisis por Tramos y Transiciones (σₐ = 1.0)

| # | Tipo              | Duración (s) | Long (RMS / Max) | Trans (RMS / Max) | Vel (RMS / Max) | Rumbo (RMS / Max) |
|----|-------------------|--------------|-------------------|--------------------|------------------|--------------------|
|  1 | uniforme          |      240.0 |  101.83 / 60      |  101.63 / 60       |   4.85 / 0.6     |  17.34 / 0.7     |
|  2 | uniforme_acelerado |       19.1 |   86.39 / 310     |   85.73 / 120      |   7.69 / 26.0    |   0.19 / 6.0     |
|  3 | acelerado         |      100.0 |  112.31 / 180     |  111.25 / 60       |  13.50 / 17.0    |   0.95 / 1.5     |
|  4 | acelerado_uniforme |        0.0 |     NaN / Inf     |     NaN / Inf      |    NaN / Inf     |    NaN / Inf     |
|  5 | acelerado_uniforme |       19.2 |  103.79 / 180     |  102.66 / 60       |   7.77 / 17.0    |   0.53 / 1.5     |
|  6 | uniforme          |      262.0 |   72.97 / 60      |   72.27 / 60       |   2.03 / 0.6     |   0.45 / 0.7     |
### Porcentaje de Incumplimiento EUROCONTROL (σₐ = 1.0)

| Segmento           | Duración (s) | Longitud (%) | Transversal (%) | Velocidad (%) | Rumbo (%) |
|--------------------|--------------|----------------|-------------------|----------------|------------|
| uniforme           |      240.0 |        100.0 |           100.0 |          24.6 |       16.4 |
| uniforme_acelerado |       19.1 |          0.0 |             0.0 |           0.0 |        0.0 |
| acelerado          |      100.0 |          0.0 |           100.0 |           0.0 |        0.0 |
| acelerado_uniforme_1 |        0.0 |          NaN |             NaN |           NaN |        NaN |
| acelerado_uniforme_2 |       19.2 |          0.0 |           100.0 |           0.0 |        0.0 |
| uniforme           |      262.0 |        100.0 |           100.0 |          38.5 |        0.0 |

## MANIOBRA

TOP:

|   σₐ_n |   σₐ_m |     α |     PFA |  RMS total | % Incumpl. |
|--------|--------|------|---------|------------|-------------|
|   0.05 |   10.0 | 0.40 | 5.0e-02 |      41.89 |      28.44 |
|   0.08 |   20.0 | 0.40 | 5.0e-02 |      41.97 |      29.81 |
|   0.07 |   11.0 | 0.40 | 5.0e-02 |      43.04 |      30.00 |
|   0.07 |   15.0 | 0.40 | 5.0e-02 |      42.64 |      30.59 |
|   0.05 |   14.0 | 0.40 | 5.0e-02 |      43.29 |      31.21 |
|   0.08 |   15.0 | 0.70 | 5.0e-02 |      44.49 |      31.37 |
|   0.08 |   15.0 | 0.40 | 5.0e-02 |      43.57 |      31.37 |
|   0.08 |   10.0 | 0.40 | 5.0e-02 |      44.02 |      31.68 |
|   0.08 |   15.0 | 0.70 | 2.0e-02 |      45.20 |      31.83 |

 MEJOR COMBINACIÓN ENCONTRADA:
- σₐ_normal   = 0.05
- σₐ_maniobra = 10.0
- α           = 0.40
- PFA         = 5.0e-02
- RMS total   = 41.89
- % Incumpl.  = 28.44%

### Análisis por Tramos y Transiciones (Filtro con Maniobra mejor combi)

| # | Tipo              | Duración (s) | Long (RMS / Max) | Trans (RMS / Max) | Vel (RMS / Max) | Rumbo (RMS / Max) |
|----|-------------------|--------------|-------------------|--------------------|------------------|--------------------|
|  1 | uniforme          |      240.0 |   86.78 / 60      |   86.65 / 60       |   3.55 / 0.6     |  17.44 / 0.7     |
|  2 | uniforme_acelerado |       17.3 |   52.75 / 310     |   52.47 / 120      |   8.26 / 26.0    |   0.19 / 6.0     |
|  3 | acelerado         |      100.0 |  132.15 / 180     |  131.35 / 60       |  15.66 / 17.0    |   1.12 / 1.5     |
|  4 | acelerado_uniforme |       17.3 |  165.93 / 180     |  165.18 / 60       |  12.55 / 17.0    |   0.42 / 1.5     |
|  5 | uniforme          |      262.0 |   81.45 / 60      |   80.81 / 60       |   3.29 / 0.6     |   0.42 / 0.7     |

### Porcentaje de Incumplimiento EUROCONTROL mejor combi

| Segmento           | Duración (s) | Longitud (%) | Transversal (%) | Velocidad (%) | Rumbo (%) |
|--------------------|--------------|----------------|-------------------|----------------|------------|
| uniforme           |      240.0 |         55.0 |            55.0 |          13.3 |        8.3 |
| uniforme_acelerado |       17.3 |          0.0 |             0.0 |           0.0 |        0.0 |
| acelerado          |      100.0 |         12.0 |            88.0 |          40.0 |       16.0 |
| acelerado_uniforme_2 |       17.3 |          0.0 |           100.0 |          20.0 |        0.0 |
| uniforme           |      262.0 |         48.5 |            48.5 |          19.7 |        0.0 |

**NO ESTÁ DEL TODO ACTUALIZADO ESTE README**