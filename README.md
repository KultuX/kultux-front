
# KultuX

<p align="center">
  <img src="assets/images/logo.png" width="200" />
</p>

![Flutter](https://img.shields.io/badge/Flutter-3.32-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Status](https://img.shields.io/badge/Status-TFG-purple?style=for-the-badge&logo=academia)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge&logo=open-source-initiative&logoColor=white)
  
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white)
![Web](https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white)


Aplicación móvil y web desarrollada como Trabajo de Fin de Grado para descubrir Extremadura. Permite explorar actividades culturales, restaurantes y alojamientos de la región a través de un mapa interactivo, búsqueda filtrada y sistema de guardados personalizado.

---

## Tecnologías

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white" />
</p>

---

## Requisitos del sistema

| Plataforma | Versión mínima |
|------------|----------------|
| Android | 6.0 (API 23) |
| iOS | 13.0 |
| Navegador | Chrome, Safari, Firefox |

---

## Funcionalidades

- **Inicio** — listado de actividades recientes con paginación infinita
- **Mapa interactivo** — visualización de actividades por localidad sobre el mapa de Extremadura
- **Búsqueda** — filtrado de actividades, restaurantes y alojamientos por nombre, categoría, localidad y fecha
- **Establecimientos** — sección dedicada a restaurantes y alojamientos destacados
- **Guardados** — colección personal de actividades, restaurantes y alojamientos favoritos
- **Perfil** — gestión de cuenta, edición de datos y foto de perfil
- **Autenticación** — registro, login, recuperación de contraseña y modo invitado

---

## Arquitectura

```
lib/
├── api/              # Servicios HTTP para cada entidad
├── models/           # Modelos de datos
├── componentes/      # Widgets reutilizables
├── core/
│   └── utils/        # Utilidades, estado UI, validaciones
└── *.dart            # Páginas principales
```

---

## Backend

Este repositorio contiene únicamente el cliente Flutter. El backend está desarrollado con Java + Spring Boot y desplegado en Render.

- Repositorio backend: [kultux-backend](https://github.com/KultuX/api-gateway)
- API Gateway: `api-gateway-75h9.onrender.com`

---

## Instalación

### Requisitos previos
- Flutter SDK 3.x
- Android Studio / VS Code con extensión Flutter
- Dispositivo físico o emulador Android/iOS

### Pasos
```bash
git clone https://github.com/usuario/kultux.git
cd kultux
flutter pub get
flutter run
```

### Web
```bash
flutter run -d chrome
```

---

## Descarga

- **Android** — Descargar el APK desde [Releases](https://github.com/KultuX/kultux-front/releases)
- **Web/iOS** — Acceder desde [kultux.vercel.app](https://kultux.vercel.app)

---

## Autores

 Cristo Macías Izaguirre | [@CristoMacias](https://github.com/CristoMacias)

 Sandra María Moñino García | [@smmoninog](https://github.com/smmonino) 


---

## Licencia

Este proyecto está licenciado bajo la licencia MIT.



