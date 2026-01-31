# 📦 Inventario App - Distribuidora Mayorista

Aplicación móvil desarrollada en **Flutter** para el control y gestión de inventario de una distribuidora mayorista. La interfaz sigue una estética moderna (estilo Adidas) y cuenta con funcionalidades avanzadas de búsqueda, filtrado y notificaciones push.

## 🚀 Requisitos de Sistema

* **Flutter SDK:** `^3.10.7`
* **Dart SDK:** `^3.0.0`
* **Java:** JDK 11 o superior (para Android)
* **CocoaPods:** Última versión (solo para usuarios de macOS/iOS)

## 🛠️ Instalación y Configuración

1.  **Clonar el repositorio:**
    ```bash
    git clone [https://github.com/sofiagranda/front_inventario_flutter.git](https://github.com/sofiagranda/front_inventario_flutter.git)
    cd front_inventario_flutter
    ```

2.  **Instalar dependencias:**
    Equivalente al `pip install` de Python.
    ```bash
    flutter pub get
    ```

3.  **Configuración de Firebase:**
    * Descargar `google-services.json` desde la consola de Firebase y colocarlo en `android/app/`.
    * Descargar `GoogleService-Info.plist` y colocarlo en `ios/Runner/`.

## 🌐 Conexión a la API

La aplicación se comunica con un backend centralizado. 

* **URL Base:** `https://paredes-inventario-api.desarrollo-software.xyz`
* **Autenticación:** Se utiliza el paquete `flutter_secure_storage` para persistir el token de sesión tras el login.
* **Headers:** Todas las peticiones protegidas requieren el header:
    `Authorization: Bearer <tu_token>`

## 🔐 Credenciales de Prueba

Para testeo en entorno de desarrollo, utilizar las siguientes cuentas:

| Rol | Username | Password |
| :--- | :--- | :--- |
| **Administrador** | `nicolas` | `epku3758` |
| **Usuario Estándar** | `prueba` | `inventario` |

## 📁 Estructura de Dependencias Principales

El proyecto utiliza las siguientes librerías clave:
* `provider`: Gestión de estado de la aplicación.
* `http`: Cliente para peticiones REST a la API.
* `flutter_secure_storage`: Almacenamiento seguro de credenciales y tokens.
* `image_picker`: Captura de fotos para productos del inventario.
* `firebase_messaging`: Recepción de notificaciones push para alertas de stock.

## ⌨️ Comandos Útiles

* **Limpiar el proyecto:** `flutter clean`
* **Correr en modo Debug:** `flutter run`
* **Generar APK de producción:** `flutter build apk --release`
* **Actualizar dependencias:** `flutter pub upgrade`

---
> **Nota para Desarrolladores:** Si realizas cambios en la interfaz o lógica de favoritos, por favor trabaja sobre una rama (branch) secundaria y realiza un Pull Request hacia `main`.
>
> <img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/f4fb6217-115a-45e8-bb80-b672132fa8fb" />
