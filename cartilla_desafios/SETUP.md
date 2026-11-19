# Cartilla Flutter — Desafíos 4, 4B, 4C, 5, 6, 7 y 8 (Android Studio)

## 1. Crear el proyecto
1. Android Studio → New Flutter Project → nombre `cartilla_desafios`
   (org `com.example` → applicationId `com.example.cartilla_desafios`).
2. Borrá el contenido de `lib/` y copiá la carpeta `lib/` de este zip.
3. En `pubspec.yaml` reemplazá `dependencies:` por el bloque de `pubspec_dependencies.yaml`.
4. Terminal: `flutter pub get`

## 2. Ajustes de Android
**android/app/build.gradle(.kts)**
- `minSdk = 23`
- Para flutter_local_notifications: en `compileOptions` agregar
  `isCoreLibraryDesugaringEnabled = true` y en `dependencies`:
  `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`

**android/app/src/main/AndroidManifest.xml** (dentro de `<manifest>`, antes de `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## 3. Firebase (Desafíos 7 y 8)
1. console.firebase.google.com → crear proyecto → agregar app Android (`com.example.cartilla_desafios`).
2. Descargar `google-services.json` → `android/app/`.
3. Authentication → habilitar "Correo electrónico/contraseña".
4. Firestore Database → crear en modo de prueba.
5. Agregar el plugin de Google Services (sección 7.2 de la cartilla).
Sin Firebase la app corre en "modo local" y los desafíos 4, 4C, 5 y 6 funcionan igual.

## 4. Desafío 4B
Pegar `desafio_4b_dartpad.dart` en https://dartpad.dev

## 5. Desafío 8
Generá un QR por alumno en qr.io con el nombre como contenido.

## 6. Entrega (Git)
git add . && git commit -m "Desafío X completo" && git push
