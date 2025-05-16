# TRAYECTORIA GIRO:

## CON KALMAN_CV:
 ![kalman](img/kalman_cv.png)
## CON MONTECARLO APLICANDO KALMAN_CV:
![montecarlo_cv](img/montecarlo_cv.png)

## MONTECARLO CON KALMAN_CV VIENDO CON MÁSCARA EUROCONTROL

![montecarlo_CV_EURO](img/montecarlo_CV_EURO.png)

---
PORCENTAJE DE INCUMPLIMIENTO EUROCONTROL para σₐ **0.50**
 
|Segmento           |  Dur(s) | Long(%) |Trans(%)|   Vel(%)| Rumbo(%)    |
| ------------------|---------| --------|------|-----------|----------|
|uniforme           |   240.0  |   44.3 |   57.4 |    82.0 |    65.6|
|uniforme_giro      |   67.5  |   76.5  |   58.8 |    35.3  |   88.2
|giro               |    98.0 |    83.3 |    83.3 |    79.2 |   100.0
|giro_uniforme      |    37.4  |   60.0 |   100.0 |   90.0  |   40.0
|uniforme           |   262.0  |   18.2  |   53.0 |    83.3  |   47.0

---
COMPARACIÓN DE INCUMPLIMIENTO PARA DISTINTOS σ_a 

     σ_a    Long(%)   Trans(%)     Vel(%)   Rumbo(%)
    0.10       59.9       68.6       69.2       49.4
    0.25       51.7       63.4       78.5       57.6
    0.50       45.9       51.7       73.3       55.8
    1.00       45.3       51.7       85.5       69.2
    1.50       45.3       51.2       86.6       73.3
    2.00       38.4       58.1       80.2       79.7
    2.50       32.6       51.7       84.3       73.3
    3.00       44.2       57.0       90.7       75.6
    3.50       37.2       57.0       81.4       78.5
    4.00       36.0       57.6       86.0       77.9
    4.50       40.7       57.6       84.9       76.2
    5.00       37.8       61.0       94.2       77.3
    5.50       37.8       55.8       90.7       78.5
    6.00       47.1       57.0       89.0       72.7
    6.50       41.3       51.2       91.3       70.3
    7.00       41.3       56.4       93.0       72.1
    7.50       35.5       52.3       92.4       74.4
    8.00       43.0       52.9       91.9       73.3
    8.50       39.5       54.1       98.3       79.7
    9.00       34.9       54.7       93.6       76.2
    9.50       38.4       51.2       91.3       75.6
    10.0       51.2       59.9       94.2       81.4

El mejor valor de σₐ es **0.50** con un incumplimiento medio total del 56.69%