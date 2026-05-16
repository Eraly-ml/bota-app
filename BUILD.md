# Сборка Bota Flutter приложения

## Что изменено / что нового

- Темная премиум-тема (бургунди, стекло, золото)
- AI-чат через Kimi (Moonshot AI) с голосовым вводом (STT)
- ElevenLabs TTS для голоса маскота
- Друзья + мультиплеер-дуэли (hot-seat на одном устройстве)
- Купоны с QR-кодом
- Юрта-билдер
- Родительский режим со статистикой и screen-time
- Оффлайн-first, все данные в SharedPreferences

## Требования

- Flutter 3.29.3+ (stable)
- Dart 3.5.0+
- Android Studio с Android SDK (API 24+)
- JDK 17

## Шаг 1. Настройка окружения

### 1.1 Установи Flutter

```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"
flutter doctor
```

Убедись, что `flutter doctor` показывает:
- [x] Flutter (Channel stable)
- [x] Android toolchain
- [x] Android Studio

### 1.2 Настрой `android/local.properties`

Файл `android/local.properties` уже есть, но пути укажут твои:

```properties
sdk.dir=/Users/YOUR_NAME/Library/Android/sdk
flutter.sdk=/Users/YOUR_NAME/flutter
flutter.buildMode=release
flutter.versionName=1.0.0
flutter.versionCode=1
```

На Windows:
```properties
sdk.dir=C:\\Users\\YOUR_NAME\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\flutter
```

## Шаг 2. Зависимости

```bash
cd Bota-main/my_app
flutter pub get
```

Если есть конфликты — `flutter clean && flutter pub get`.

## Шаг 3. API ключи

Файл `.env` уже лежит в корне и содержит:

```env
KIMI_API_KEY=sk-kimi-aDB7lF9wKaNU5rigPSNXRSJo1fpPNiU6jsLjHPVjJLYJ7RiCGLIq5KgtTjjjQCl6
```

Он уже подключен в `pubspec.yaml`:

```yaml
assets:
  - .env
```

Если нужен ElevenLabs TTS (голос Боты), добавь в `.env`:

```env
ELEVENLABS_API_KEY=your_key_here
```

Без ключа TTS просто молчит — приложение не падает.

## Шаг 4. AndroidManifest.xml — проверь разрешения

Файл `android/app/src/main/AndroidManifest.xml` уже содержит нужные разрешения:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
```

`RECORD_AUDIO` обязателен для голосового ввода (speech_to_text).

## Шаг 5. Application ID

В `android/app/build.gradle.kts` уже проставлено:

```kotlin
namespace = "kz.bota.app"
applicationId = "kz.bota.app"
minSdk = 24
```

Если хочешь свой `applicationId` — поменяй в этом файле.

## Шаг 6. Сборка APK

### Debug (быстро, для теста)

```bash
flutter run
```

### Release APK

```bash
flutter build apk --release
```

Результат: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (для Google Play)

```bash
flutter build appbundle --release
```

Результат: `build/app/outputs/bundle/release/app-release.aab`

## Шаг 7. Подпись release (обязательно для Google Play)

В `android/app/build.gradle.kts` сейчас стоит:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

Для релиза в Google Play замени на свою подпись:

```kotlin
android {
    signingConfigs {
        create("release") {
            keyAlias = "your_alias"
            keyPassword = "your_password"
            storeFile = file("your_keystore.jks")
            storePassword = "your_password"
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

## Шаг 8. Проверка перед сборкой

```bash
flutter analyze
flutter test
```

`flutter analyze` должен показать 0 ошибок (1 старый warning в `map_screen.dart` — не критично).

## Структура проекта (ключевые файлы)

```
lib/
  main.dart                          # Точка входа, загрузка .env
  models/
    child_profile.dart               # Профиль ребенка + друзья + челленджи
    friend.dart                      # Модель друга
    challenge.dart                   # Модель дуэли
    coupon.dart                      # Модель купона
  providers/
    game_provider.dart               # Provider: профиль, друзья, челленджи, монеты
  screens/
    ai_chat_screen.dart              # AI-чат с Kimi + STT голосовой ввод
    friends_screen.dart              # Друзья, челленджи, лидерборд
    multiplayer_challenge_screen.dart # Экран дуэли (hot-seat)
    game_quiz_screen.dart            # Викторина
    game_math_screen.dart            # Математика
    game_memory_screen.dart          # Память
    game_yurt_screen.dart            # Юрта-билдер
    shop_screen.dart                 # Магазин + купоны
    coupon_screen.dart               # QR-код купона
    parent_screen.dart               # Родительский режим
    explore_kz_screen.dart           # Карта Казахстана
  services/
    ai_service.dart                  # Kimi API (moonshot-v1-8k)
    voice_service.dart               # ElevenLabs TTS
    stt_service.dart                 # Speech-to-text
    supabase_service.dart            # Загрузка квиза/призов из JSON
  theme/
    app_colors.dart                  # Темная тема
  data/
    locale_strings.dart              # Локализация ru/kk
assets/
  data/
    quiz.json                        # 25 вопросов викторины
    locale.json                      # 120+ строк i18n
    prizes.json                      # Призы магазина
  yurt/                              # Части юрты
```

## Известные нюансы

1. **AI-чат** работает через `api.moonshot.cn`. Нужен интернет. Без ключа — ошибка авторизации (обрабатывается gracefully).
2. **STT (голосовой ввод)** требует разрешение микрофона на Android. На эмуляторе может не работать — тестируй на реальном устройстве.
3. **ElevenLabs TTS** играет MP3 через `audioplayers`. Без ключа — просто тишина.
4. **Supabase** используется только для sync в облако (опционально). Вся основная логика оффлайн.
5. **WebView** используется в `explore_kz_screen` для 3D-моделей.

## Техподдержка

Если `flutter build` падает с ошибкой NDK:
- Открой Android Studio → SDK Manager → SDK Tools → установи NDK (Side by side)
- Или удали строку `ndkVersion = flutter.ndkVersion` из `android/app/build.gradle.kts`

Если падает с `minSdk`:
- `minSdk = 24` в `android/app/build.gradle.kts` достаточно для всех плагинов.

Если speech_to_text не инициализируется:
- Проверь разрешение `RECORD_AUDIO` в настройках приложения на устройстве.
