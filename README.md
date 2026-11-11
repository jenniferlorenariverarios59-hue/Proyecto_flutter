# TechStore - Catálogo y Gestión de Productos Tecnológicos

Aplicación multiplataforma (Web y Android) desarrollada en **Flutter** con el sistema de diseño **Vanguard Commerce** (inspirado en Google Stitch). TechStore ofrece un catálogo tecnológico completo, gestión de inventario, métricas financieras en tiempo real, carrito de compras con cupones de descuento y sincronización con API REST externa o modo offline.

---

## 🚀 Funcionalidades Principales

1. **Catálogo Tecnológico Completo**:
   - Productos preconfigurados de ejemplo (Portátiles gamer, Celulares de gama alta, Audífonos con cancelación de ruido, Teclados mecánicos y Mouse ergonómicos).
   - Detalle de cada ítem con imagen (o icono temático inteligente), categoría, SKU, precio y estado de disponibilidad en stock.

2. **Panel de Métricas Bento (Vanguard UI)**:
   - **Catálogo**: Conteo total de productos registrados.
   - **Valor Stock**: Valoración monetaria total calculada en tiempo real (`precio × unidades`).
   - **Por Reponer**: Detección automática de artículos con stock bajo (≤ 5 uds.) o agotados (0 uds.).

3. **Búsqueda y Filtrado Reactivo**:
   - Búsqueda instantánea por nombre de producto, descripción o código SKU.
   - Chips de filtrado rápido por categoría (*Todos, Portátiles, Celulares, Audífonos, Teclados, Mouse*).
   - Chips de estado (*En Stock, Stock Bajo, Agotados*).

4. **Gestión de Inventario (CRUD y Validaciones)**:
   - Formulario modal para registrar productos con validación estricta (nombre ≥ 3 caracteres, precio > 0, stock entero ≥ 0, selección de categoría y SKU único).
   - Formulario de edición de especificaciones, precio y cantidad.
   - Ajuste rápido de existencias con botones (+ / -).
   - Eliminación de ítems con diálogo de confirmación y feedback mediante SnackBars estilizadas.

5. **Carrito de Compras y Checkout**:
   - Control dinámico de cantidades con límite de stock disponible.
   - Barra interactiva de progreso para **Envío Gratis** (compras a partir de \$50).
   - Sistema de cupones de descuento activos: `TECH10` o `VANGUARD10` (-\$10.00).
   - Simulación de Checkout con descuento automático de inventario.

6. **Integración REST y Tolerancia a Fallos**:
   - Pantalla de **Ajustes** para configurar la URL del servidor API REST (presets para localhost, red local o nube).
   - Medición de latencia de red en tiempo real mediante botón de diagnóstico (`Ping`).
   - Modo híbrido / offline: la aplicación continúa operando con datos locales y caché si no hay conexión a internet o si el backend está apagado.

---

## 🛠️ Requisitos del Sistema en el Nuevo Computador

Para compilar y ejecutar este proyecto en otro computador, asegúrate de contar con las siguientes herramientas instaladas:

1. **Git**: [git-scm.com](https://git-scm.com/)
2. **Flutter SDK**: Versión 3.19.0 o superior (compatible con Dart SDK 3.3+)
   - Descarga oficial: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
   - Asegúrate de agregar la carpeta `bin` de Flutter a la variable de entorno `PATH`.
3. **Visual Studio Code**: [code.visualstudio.com](https://code.visualstudio.com/)
   - Extensiones de VS Code requeridas:
     - **Flutter** (`Dart-Code.flutter`)
     - **Dart** (`Dart-Code.dart-code`)
4. **Para ejecutar en Google Chrome (Web)**:
   - Navegador Google Chrome actualizado.
5. **Para ejecutar en Android**:
   - **Android Studio** con Android SDK y Android SDK Command-line Tools instalados.
   - Un teléfono físico con **Depuración por USB** habilitada (en Opciones de Desarrollador) o un Emulador AVD de Android.
   - Java JDK (versión 17 o 21, normalmente provisto con Android Studio).

---

## 💻 Instrucciones Paso a Paso para Visual Studio Code

### Paso 1: Descomprimir y abrir el proyecto
1. Descomprime el archivo ZIP portable en tu carpeta preferida (por ejemplo `C:\Proyectos\TechStore` o `~/Proyectos/TechStore`).
2. Abre **Visual Studio Code**.
3. Selecciona el menú **File (Archivo)** > **Open Folder (Abrir carpeta...)** y selecciona la carpeta descomprimida del proyecto.

### Paso 2: Verificar el entorno de desarrollo
Abre una terminal integrada en VS Code (`Ctrl + ñ` o `Terminal > New Terminal`) y ejecuta:
```bash
flutter doctor
```
Verifica que las casillas de Flutter, Chrome y Android Toolchain estén marcadas en verde. Si falta aceptar licencias de Android, ejecuta `flutter doctor --android-licenses`.

### Paso 3: Instalar las dependencias
En la terminal integrada de VS Code ejecuta:
```bash
flutter pub get
```
Este comando descargará todos los paquetes necesarios declarados en `pubspec.yaml` (incluyendo `http: ^1.6.0` y `cupertino_icons: ^1.0.8`).

### Paso 4: Ejecutar el análisis y las pruebas automatizadas
Para verificar que el código no tenga ningún problema de sintaxis o tipo:
```bash
flutter analyze
```
*(Debe indicar: `No issues found!`)*

Para ejecutar la batería de 5 suites de pruebas:
```bash
flutter test
```
*(Debe indicar: `All tests passed!`)*

---

## 📱 Cómo Ejecutar la Aplicación

### Opción A: Desde la interfaz de Visual Studio Code (Recomendado)
El proyecto incluye perfiles preconfigurados en `.vscode/launch.json`:
1. Ve al panel lateral de **Run & Debug (Ejecutar y Depurar)** en VS Code (`Ctrl + Shift + D`).
2. En el menú desplegable superior, selecciona:
   - **`TechStore (Chrome)`** para abrir directamente en Google Chrome.
   - **`TechStore (Dispositivo Conectado / Android)`** para ejecutar en tu celular Android o emulador.
3. Presiona **`F5`** para iniciar con depuración y soporte de *Hot Reload*.

---

### Opción B: Desde la Terminal

#### 1. Ejecutar en Google Chrome (Web)
```bash
flutter run -d chrome
```
*Se abrirá automáticamente Google Chrome con la aplicación en vivo.*

#### 2. Ejecutar en Dispositivo Android
1. Conecta tu teléfono Android por cable USB a la computadora.
2. Desbloquea la pantalla del celular y acepta el aviso: *"¿Permitir depuración por USB?"*.
3. Lista los dispositivos detectados para confirmar:
   ```bash
   flutter devices
   ```
4. Lanza la aplicación indicando el dispositivo:
   ```bash
   flutter run
   ```
   *(O especifica el ID si tienes más de uno conectado: `flutter run -d <device_id>`)*

---

## 📦 Compilación para Producción

### Generar la Versión Web
Para generar la versión optimizada para desplegar en cualquier servidor o hosting web (GitHub Pages, Firebase Hosting, Vercel, Netlify o servidor Apache/Nginx):
```bash
flutter build web
```
*El resultado compilado se guardará en la carpeta `build/web/`.*

### Generar el Instalador Android (APK Release)
Para generar el archivo APK de producción listo para instalar en cualquier teléfono Android:
```bash
flutter build apk --release
```
*El instalador generado se ubicará en:*
`build/app/outputs/flutter-apk/app-release.apk`

---

## 📂 Arquitectura del Código Fuente

```
lib/
├── main.dart                   # Punto de entrada de la aplicación y configuración de MaterialApp
├── models/
│   ├── product.dart            # Entidad de producto tecnológico, SKU, estados de stock y JSON
│   └── cart_item.dart          # Modelo de ítem de carrito con cálculo de subtotales
├── theme/
│   └── app_theme.dart          # Paleta Vanguard Commerce (Indigo/Emerald), tipografías y bordes
├── services/
│   ├── api_service.dart        # Cliente HTTP REST para consumo de endpoints externos
│   ├── product_repository.dart # Singleton con catálogo tecnológico, métricas y modo offline
│   └── cart_service.dart       # Gestor del carrito de compras, cupones y checkout
├── widgets/
│   ├── metric_card.dart        # Tarjetas Bento financieras superiores
│   ├── category_filter_chips.dart # Chips de filtrado reactivo por categoría y stock
│   ├── product_card.dart       # Tarjeta de producto con imagen, precio y badges
│   ├── add_product_sheet.dart  # Modal con formulario validado para nuevo producto
│   └── edit_product_sheet.dart # Modal para edición de productos existentes
└── screens/
    ├── catalog_screen.dart     # Pantalla principal con búsqueda y catálogo
    ├── product_detail_sheet.dart # Detalle de producto, ajuste rápido y añadir al carrito
    ├── cart_screen.dart        # Pantalla de carrito, barra de envío gratis y pago
    ├── settings_screen.dart    # Configuración de URL de API, prueba Ping y modo offline
    └── main_navigation_screen.dart # Barra de navegación inferior persistente
```

---

## 👥 Soporte y Verificación

- **Pruebas integradas**: 5/5 pruebas automatizadas cubren renderizado, modelos, repositorio, cupones y ajuste dinámico de inventario.
- **Portabilidad**: El proyecto no contiene rutas locales absolutas en el código fuente; todas las importaciones son relativas o usan el esquema de paquetes de Dart.
