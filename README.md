# Right Way

Мобильное приложение на Flutter: антропометрия, настройки питания, генерация плана через ИИ (Gemini, OpenAI, Groq), просмотр и выбор активного плана на неделю. Данные планов и профиля тела хранятся локально.

## Идея
1. Введите параметры тела и цели питания.
2. В настройках укажите провайдера ИИ, ключ и модель.
3. На экране питания задайте длительность плана, цель, название, исключения и запустите расчет.
4. Ответ ИИ сохраняется в локальную базу, план помечается активным, открывается вкладка с планом на сегодня и на всю неделю.

## API ключ
1. Зайти на сайт https://console.groq.com/home.
2. Открыть вкладку API Keys
3. Создать и скопировать ключ
4. Вставить ключ в настройках. 

Бесплатного ключа хватает на 4-5 запросов с разных моделей.

## Архитектура

- **Слои по фичам:** `domain` (модели, контракты репозиториев, use case), `data` (ObjectBox, Dio, реализации репозиториев), `ui` (экраны, Bloc/Cubit).
- **Связь слоев:** UI вызывает use case или репозиторий через DI; ошибки уходят в `ErrorReporter` (стрим для Snackbar), сеть через Dio.
- **Состояние:** `flutter_bloc` (настройки питания, тело, настройки приложения), `Cubit` для экрана плана.
- **Навигация:** `auto_route`, корневой таббар с вложенными маршрутами.
- **DI:** `get_it`, сборка в `CoreDi` и `FeaturesDi`.
- **Локальное хранилище:** ObjectBox (планы, дни, приемы, профиль тела); ключи ИИ в `flutter_secure_storage`; тема в `shared_preferences`.

## Структура `lib/`

| Путь | Назначение |
|------|------------|
| `app/` | `App`, `AppInitializer`: запуск, регистрация Talker/Bloc observer, ObjectBox, роутер |
| `core/` | Общее: `di`, `network` (Dio, ApiClient), `errors`, `logging`, `theme`, `router`, `storage`, `ai` (провайдеры, модели, хранилище ключей) |
| `features/body_info/` | Профиль тела: локальный репозиторий, экран, Bloc |
| `features/nutrition_settings/` | Параметры плана и вызов расчета через ИИ, Bloc |
| `features/today_plan/` | Список планов, активный план, дни и блюда, Cubit |
| `features/app_settings/` | Настройки ИИ и приложения |
| `features/root_tabs/` | Нижняя навигация и оболочка табов |
| `features/di/` | Регистрация зависимостей фич в GetIt |
| `objectbox.g.dart` | Сгенерированный код ObjectBox (не править вручную) |


## Сборка и запуск

Требования: Flutter SDK из `pubspec.yaml` (`environment.sdk`), Xcode для iOS, Android SDK для Android.

```bash
flutter pub get
```

Перед первой сборкой или после смены сущностей ObjectBox и маршрутов сгенерируйте код:

```bash
dart run build_runner build --delete-conflicting-outputs
```

В `pubspec.yaml` в assets указан `.env`: при появлении загрузки переменных окружения положите файл в корень репозитория.

Запуск на устройстве или эмуляторе:

```bash
flutter run
```

Сборка релиза (пример для Android):

```bash
flutter build apk
# или
flutter build appbundle
```

Для iOS: откройте `ios/Runner.xcworkspace` в Xcode или выполните `flutter build ios`.

## Анализ кода

```bash
dart analyze
```
