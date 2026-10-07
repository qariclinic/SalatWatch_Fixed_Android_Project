# SalatWatch — Android-ready Flutter project

یہ ورژن black-screen اور incomplete Android project کے مسائل دور کرنے کے لیے مرتب کیا گیا ہے۔

## Build

```bash
flutter clean
flutter pub get
flutter analyze
flutter build apk --release
```

APK یہاں بنے گا:
`build/app/outputs/flutter-apk/app-release.apk`

## اہم اصلاحات
- مکمل modern Flutter Android Gradle/plugin configuration
- Flutter embedding v2 اور launch/normal themes
- launcher icon resources
- محفوظ timer lifecycle (`Timer?` + `mounted` check)
- prayer times کو ہر frame میں دوبارہ calculate کرنے کے بجائے state میں رکھنا
- responsive clock UI تاکہ چھوٹی Android screens پر overflow نہ ہو
- GitHub Actions workflow جو release APK خود build کرکے artifact بناتا ہے

اگر Android Studio میں کھولیں تو پہلے `flutter pub get` چلائیں، پھر Run/Build APK کریں۔
# SalatWatch_Fixed_Android_Project
