# 🗳️ Vota Dolores Hidalgo — Plebiscito Vecinal Digital

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Metodología](https://img.shields.io/badge/Metodolog%C3%ADa-TDD%20100%25-brightgreen)](https://en.wikipedia.org/wiki/Test-driven_development)
[![Pruebas](https://img.shields.io/badge/Tests-10%20Pasando-success)](#-pruebas-automatizadas-tdd)
[![Arquitectura](https://img.shields.io/badge/Arquitectura-Clean%20%2F%20Dart%20Puro-blueviolet)](#-arquitectura-del-proyecto)

Aplicación móvil desarrollada en **Flutter** para la consulta ciudadana en el municipio de **Dolores Hidalgo C.I.N., Guanajuato**. El sistema permite a los ciudadanos participar democráticamente en la priorización de obras públicas municipales, garantizando reglas de negocio estrictas construidas y blindadas mediante **Desarrollo Guiado por Pruebas (TDD)** y una experiencia de usuario interactiva con animaciones nativas.

---

## 📋 Tabla de Contenido
1. [Descripción del Proyecto](#-descripción-del-proyecto)
2. [Reglas de Negocio Protegidas con TDD](#-reglas-de-negocio-protegidas-con-tdd)
3. [Arquitectura del Proyecto](#-arquitectura-del-proyecto)
4. [Ciclo de Desarrollo TDD (Rondas)](#-ciclo-de-desarrollo-tdd-rondas)
5. [Pruebas Automatizadas](#-pruebas-automatizadas-tdd)
6. [Animaciones e Interfaz Gráfica](#-animaciones-e-interfaz-gráfica)
7. [Instrucciones de Instalación y Ejecución](#-instrucciones-de-instalación-y-ejecución)
8. [📸 Evidencias de la Aplicación](#-evidencias-de-la-aplicación)

---

## 🏛️ Descripción del Proyecto

El municipio propone a votación la pregunta:
> **"¿Qué obra prioritaria debe realizar el municipio este año?"**

Opciones de obra registradas:
- 🏛️ **Rehabilitación del Jardín Principal**
- 📚 **Nueva Biblioteca Digital**
- 💡 **Alumbrado en el Barrio de Analco**
- 🛝 **Parque Infantil en la Colonia Guanajuato**

Los vecinos emiten su voto, visualizan el progreso porcentual con barras animadas fluidas y, al consultar el desenlace, se revela la propuesta ganadora mediante un diálogo con animación de escala elástica.

---

## 🛡️ Reglas de Negocio Protegidas con TDD

A diferencia de proyectos lúdicos simples, esta aplicación implementa reglas de integridad electoral:

* **Unicidad de voto:** Cada ciudadano (identificado por un ID único) solo puede emitir un voto por plebiscito.
* **Existencia de opción:** Se validan los identificadores de obra, rechazando votos dirigidos a opciones inexistentes (`ResultadoVoto.opcionInvalida`).
* **Control de vigencia temporal:** El sistema impide votar si la fecha actual ha sobrepasado la fecha límite configurada (`ResultadoVoto.votacionCerrada`).
* **Protección contra división entre cero:** Cuando no existen votos registrados (0 votos totales), el cálculo devuelve `0%` exacto, evitando valores matemáticos `NaN`.
* **Detección genuina de empates:** Si dos o más propuestas comparten el puntaje máximo, el sistema reconoce el empate formalmente sin tomar decisiones aleatorias.
* **Manejo declarativo con Enums:** Se implementó `ResultadoVoto` para evitar el abuso de excepciones en el flujo de control esperado.

---

## 🏗️ Arquitectura del Proyecto

El código sigue una estricta separación de responsabilidades: **modelos y lógica en Dart puro**, desacoplados por completo del framework de Flutter:

```text
vota_dolores_hidalgo/
├── lib/
│   ├── modelos/                      # Capa de Dominio (Dart puro)
│   │   ├── opcion_votacion.dart      # Entidad: id, texto, votos acumulados
│   │   ├── votacion.dart             # Agregado: pregunta, opciones, fechaCierre, Set votantes
│   │   └── resultado_opcion.dart     # Value Object / DTO: opción y su porcentaje
│   ├── logica/                       # Casos de Uso / Servicio (Dart puro)
│   │   ├── resultado_voto.dart       # Enum con estados de respuesta
│   │   └── servicio_votacion.dart    # Guard clauses, conteo, empates y reloj
│   ├── presentation/                 # Capa UI / Presentación (Flutter)
│   │   └── votacion_screen.dart      # Pantalla con barras Tween y diálogo animado
│   └── main.dart                     # Entrada principal de la app y tema Material 3
└── test/
    └── servicio_votacion_test.dart    # Suite de pruebas unitarias y de integración
```

---

## 🔄 Ciclo de Desarrollo TDD (Rondas)

El desarrollo avanzó progresivamente bajo el ciclo **Rojo 🔴 → Verde 🟢 → Refactor 🔵**:

| Ronda | Objetivo | Ciclo TDD |
| :---: | :--- | :--- |
| **1** | Registrar un voto válido | 🔴 Test de incremento → 🟢 Implementación mínima con `opcion!.votos++`. |
| **2** | Rechazar votos a opciones inexistentes | 🔴 Test con `'no-existe'` → 🟢 Validación de nulos y retorno `opcionInvalida`. |
| **3** | Un usuario no puede votar dos veces | 🔴 Test con mismo `idUsuario` → 🟢 Validación previa en `votantes.contains`. |
| **4** | Cálculo seguro de porcentajes | 🔴 Test con votos + test con 0 votos → 🟢 Cálculo con `fold` y protección contra `NaN`. |
| **5** | Determinar ganador con más votos | 🔴 Test de conteo mayoritario → 🟢 Cálculo mediante `reduce` y filtro `where`. |
| **6** | Reconocer empate sin elegir al azar | 🔴 Test de 3 opciones empatadas → 🟢 Pasa en verde directo confirmando robustez de `where`. |
| **7** | Restringir votos posteriores al cierre | 🔴 Test con fecha pasada y fecha activa → 🟢 Comprobación contra `fechaCierre`. |
| **8** | Refactorización de legibilidad | 🔵 Reorganización en *Guard Clauses* legibles en español sin alterar comportamiento. |
| **Int.**| Plebiscito completo de integración | 🎯 Simulación de múltiples vecinos votando, descarte de voto duplicado y ganador final. |

---

## 🧪 Pruebas Automatizadas (TDD)

Para ejecutar la suite completa de pruebas:

```bash
flutter test
```

### Resumen de la Ejecución de Pruebas:
```text
00:00 +0: Ronda 1 — Registrar un voto válido: registrar un voto valido incrementa el contador de esa opcion
00:00 +1: Ronda 2 — Rechazar votos a opciones que no existen: votar por una opcion que no existe regresa opcionInvalida
00:00 +2: Ronda 3 — Un usuario no puede votar dos veces: un mismo usuario no puede votar dos veces
00:00 +3: Ronda 4 — Calcular resultados con porcentajes: calcula el porcentaje de cada opcion correctamente
00:00 +4: Ronda 4 — Calcular resultados con porcentajes: si no hay ningun voto, todos los porcentajes son 0
00:00 +5: Ronda 5 — Determinar el ganador: determinarGanador regresa la opcion con mas votos
00:00 +6: Ronda 6 — Reconocer un empate (no elegir al azar): si hay empate, determinarGanador regresa mas de una opcion
00:00 +7: Ronda 7 — No se puede votar después del cierre: no se puede votar si la votacion ya cerro
00:00 +8: Ronda 7 — No se puede votar después del cierre: si la votacion sigue abierta, el voto se registra normalmente
00:00 +9: Prueba de integración: un plebiscito completo: simulacion completa: varios vecinos votan y se determina un ganador
00:00 +10: All tests passed!
```

---

## ✨ Animaciones e Interfaz Gráfica

La aplicación utiliza animaciones nativas sin librerías externas:
1. **Barras de Progreso Animadas:** Mediante `TweenAnimationBuilder<double>` con curva `Curves.easeOutCubic`, logrando que tanto el ancho visual como el porcentaje numérico crezcan suavemente al actualizarse.
2. **Modal de Ganador con Rebote:** Desplegado mediante `showGeneralDialog` combinando `ScaleTransition` (`Curves.elasticOut`) y `FadeTransition` para una aparición dinámica.

---

## 🚀 Instrucciones de Instalación y Ejecución

### Prerrequisitos
- Flutter SDK instalado (versión 3.24 o superior).
- Dispositivo Android conectado, emulador iniciado, o soporte para Windows Desktop.

### Pasos
1. Clonar o abrir este repositorio en tu equipo.
2. Obtener las dependencias del proyecto:
   ```bash
   flutter pub get
   ```
3. Ejecutar las pruebas unitarias y de integración:
   ```bash
   flutter test
   ```
4. Ejecutar el análisis de código para comprobar buenas prácticas:
   ```bash
   flutter analyze
   ```
5. Iniciar la aplicación:
   ```bash
   flutter run
   ```

---

## 📸 Evidencias de la Aplicación

> *Coloca aquí las capturas de pantalla o GIFs demostrativos de tu aplicación. Puedes guardar tus imágenes en una carpeta como `docs/evidencias/` o `assets/evidencias/` y referenciarlas abajo.*

### 1. Pantalla Principal y Opciones de Votación
*Visualización inicial del plebiscito municipal con sus 4 opciones:*

| Vista Inicial de la Encuesta |
| :---: |
| <img width="959" height="482" alt="image" src="https://github.com/user-attachments/assets/a30e61db-06cb-4ea9-8594-d3bc62f0b41b" />
 |

---

### 2. Animación de Barras y Actualización de Porcentajes
*Demostración de las barras creciendo con `TweenAnimationBuilder` al registrar un voto:*

| Votación y Animación de Barras |
| :---: |
| <img width="959" height="408" alt="image" src="https://github.com/user-attachments/assets/32a72b81-bb72-4ce9-a154-8e7e2adf7800" />
 |

---

### 3. Validación de Regla: Intento de Voto Duplicado
*El sistema notifica al usuario mediante un SnackBar que su voto ya fue registrado:*

| Notificación de Voto Único |
| :---: |
| ![Voto Duplicado Rechazado](docs/evidencias/03_voto_duplicado.png) |

---

### 4. Diálogo de Ganador con Efecto Elástico
*Aparición del cuadro de diálogo con animación de rebote mostrando la obra electa o empate:*

| Ganador Revelado / Caso de Empate |
| :---: |
| <img width="959" height="457" alt="image" src="https://github.com/user-attachments/assets/5339d35f-a2e4-4dc1-9768-7bbac095dfbe" />
| <img width="959" height="408" alt="image" src="https://github.com/user-attachments/assets/fa09138a-0572-4733-b10e-fe3032f44ac0" />


---

### 5. Evidencia de Pruebas Automatizadas en Terminal
*Captura de terminal con el comando `flutter test` ejecutando las 10 pruebas exitosamente:*

| Resultado de `flutter test` (10 tests en verde) |
| :---: |
| <img width="354" height="40" alt="image" src="https://github.com/user-attachments/assets/5315c58f-9036-4132-8abc-11b4d289ebf1" />
 |

---

### 6. Evidencia de Calidad de Código (`flutter analyze`)
*Captura de terminal demostrando 0 advertencias y 0 errores:*

| Resultado de `flutter analyze` |
| :---: |
| <img width="366" height="58" alt="image" src="https://github.com/user-attachments/assets/c72d0a91-2a3b-4d02-8f0c-b75002bc850e" />
 |

---
