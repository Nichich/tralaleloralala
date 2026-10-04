# ТЗ: Брейнрот-декс (Flutter)

Мобильное приложение на Flutter - справочник-коллекция персонажей итальянского брейнрота (мем из TikTok). Типа покедекса: листаешь персонажей, открываешь карточку с лором, слушаешь фирменную фразу, собираешь избранное.

Это учебный проект, оценивается по критериям ниже. Цель - оценка "5".

## Критерии оценки (обязательно выполнить все)

- 3+ экрана с навигацией между ними
- данные загружаются по REST (GET запрос к JSON)
- во время загрузки - CircularProgressIndicator
- при ошибке или пустых данных - понятный текст и кнопка "Повторить", а не пустой экран
- никаких overflow (желто-черных полос) ни в портретной, ни в альбомной ориентации, ни на узких/широких экранах
- аккуратный внешний вид, все выровнено
- код разложен по папкам: models/, screens/, widgets/, services/, providers/
- доп. фичи: темная тема с переключением + Hero-анимация при переходе список -> детали + проигрывание звука персонажа

## Стек

- Flutter (последняя стабильная), Dart с null safety
- Material 3, useMaterial3: true
- пакеты: http, shared_preferences, provider, audioplayers, cached_network_image
- больше ничего не тащить без необходимости

## Данные

### Источник

JSON лежит в репозитории на GitHub, грузится по raw-ссылке. Ссылку вынести в одну константу в lib/services/api_service.dart:

```dart
const String kDataUrl = 'https://raw.githubusercontent.com/USERNAME/REPO/main/data/brainrots.json';
```

Создай в корне проекта файл data/brainrots.json с 10 персонажами, чтобы я залил его на GitHub. Персонажи:

Tralalero Tralala, Bombardiro Crocodilo, Tung Tung Tung Sahur, Ballerina Cappuccina, Lirili Larila, Brr Brr Patapim, Chimpanzini Bananini, Bombombini Gusini, Cappuccino Assassino, Trippi Troppi.

Описания пиши коротко и с юмором, на русском, 2-3 предложения. В поле image ставь пустую строку - картинки я подставлю сам.

### Формат JSON

```json
[
  {
    "id": "tralalero_tralala",
    "name": "Tralalero Tralala",
    "description": "Акула в найках...",
    "superpower": "Бегает по пляжу быстрее всех",
    "rarity": "legendary",
    "aura": 9000,
    "image": "",
    "sound": "tralalero_tralala.mp3"
  }
]
```

rarity: common | rare | legendary
aura: целое число
sound: имя файла в assets/sounds/

### Модель

lib/models/brainrot.dart - класс Brainrot с fromJson, все поля final. rarity - enum Rarity с методом разбора строки, неизвестное значение = common.

## Структура

```
lib/
  main.dart
  app.dart
  models/
    brainrot.dart
  services/
    api_service.dart
    storage_service.dart
    sound_service.dart
  providers/
    brainrot_provider.dart
    favorites_provider.dart
    theme_provider.dart
  screens/
    home_screen.dart
    list_screen.dart
    detail_screen.dart
    favorites_screen.dart
    settings_screen.dart
  widgets/
    brainrot_card.dart
    brainrot_image.dart
    rarity_chip.dart
    loading_view.dart
    error_view.dart
    empty_view.dart
assets/
  sounds/
data/
  brainrots.json
```

## Экраны

### HomeScreen
Scaffold с NavigationBar снизу, три вкладки: Все, Избранное, Настройки. Переключение вкладок через IndexedStack, чтобы список не перезагружался.

### ListScreen
- сверху поле поиска по имени (фильтр на лету, без учета регистра)
- сетка через GridView.builder с SliverGridDelegateWithMaxCrossAxisExtent (maxCrossAxisExtent около 200), чтобы колонки сами подстраивались под ширину и поворот
- карточка: картинка, имя (maxLines 1, ellipsis), чип редкости, аура
- pull-to-refresh через RefreshIndicator
- состояния: загрузка -> LoadingView, ошибка -> ErrorView с текстом "Брейнрот не загрузился. Проверь интернет" и кнопкой "Повторить", пустой список -> EmptyView, ничего не найдено поиском -> "Никого не нашли"
- тап по карточке -> DetailScreen

### DetailScreen
- картинка сверху в Hero с tag = id персонажа
- имя, чип редкости, аура, суперсила, описание
- кнопка-сердечко в AppBar - добавить/убрать из избранного
- кнопка "Проиграть звук" - играет assets/sounds/<sound>. Если файла нет или ошибка воспроизведения - SnackBar "Звук пока не завезли", без падения
- весь контент в SingleChildScrollView. В альбомной ориентации картинка слева, текст справа (LayoutBuilder или OrientationBuilder)

### FavoritesScreen
- тот же грид, только избранные
- если пусто - EmptyView "Коллекция пуста. Иди собирай брейнротов"
- тап -> DetailScreen с тем же Hero

### SettingsScreen
- SwitchListTile "Темная тема"
- третий вариант "Как в системе" - сделать через SegmentedButton: Светлая / Системная / Темная
- ListTile "Очистить избранное" с диалогом подтверждения
- внизу версия приложения мелким текстом

## Логика

- BrainrotProvider: список, статус (loading / loaded / error / empty), текст ошибки, метод load() и retry. Таймаут запроса 10 секунд. Ловить SocketException, TimeoutException, FormatException и не-200 статус - на все понятный текст для пользователя
- FavoritesProvider: Set<String> id, сохранение в SharedPreferences
- ThemeProvider: ThemeMode, сохранение в SharedPreferences, применяется при старте без мигания (загрузить до runApp)
- картинки: BrainrotImage на базе CachedNetworkImage. Если ссылка пустая или не грузится - плейсхолдер с иконкой и первой буквой имени на цветном фоне, никаких красных экранов
- цвета редкости: common - серый, rare - синий, legendary - золотой. Заданы через ColorScheme, нормально смотрятся в обеих темах

## Оформление

- ColorScheme.fromSeed, один seed-цвет на светлую и темную тему
- отступы кратные 8
- скругления карточек 16
- текстовые стили только из Theme.of(context).textTheme, никаких захардкоженных размеров шрифтов
- все Text, которые могут быть длинными - с maxLines и overflow
- Row с текстом - через Expanded/Flexible

## Требования к коду

- приложение не должно падать ни в одном сценарии: нет сети, битый JSON, нет звука, нет картинки
- flutter analyze без ошибок и предупреждений
- никаких print, используй debugPrint только где реально нужно
- комментарии только там, где без них непонятно, коротко и по-человечески. Никаких шаблонных комментариев типа "// This widget displays..." над каждым классом, никаких эмодзи в коде
- имена переменных и классов на английском, тексты интерфейса на русском
- assets/sounds/ прописать в pubspec.yaml, положить туда файл .gitkeep

## Порядок работы

1. Создай проект и pubspec с зависимостями
2. data/brainrots.json
3. модель, сервисы, провайдеры
4. экраны и виджеты
5. прогони flutter analyze и исправь все
6. в конце напиши мне коротко: куда залить JSON, какую ссылку вставить в kDataUrl, куда положить картинки и звуки

## Проверка перед сдачей

- [ ] запускается без ошибок
- [ ] выключить интернет -> видно ошибку и кнопку "Повторить", после включения и нажатия все грузится
- [ ] поиск фильтрует, "ничего не найдено" показывается
- [ ] Hero-анимация работает из списка и из избранного
- [ ] избранное и тема сохраняются после перезапуска
- [ ] повернуть экран на каждом экране - нет overflow
- [ ] нет звука -> SnackBar, а не краш
