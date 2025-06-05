Rick & Morty Flutter App
Мобильное приложение на Flutter для просмотра персонажей из мультсериала "Рик и Морти" с возможностью добавления в избранное и оффлайн-доступом.
Функции
✅ Реализованные возможности:

Список персонажей - загрузка с Rick and Morty API
Пагинация - автоматическая подгрузка при скролле
Избранное - добавление/удаление персонажей
Сортировка избранного - по имени, статусу, виду
Оффлайн режим - кеширование данных в SQLite
Темная тема - переключение светлая/темная тема
Анимации - при добавлении в избранное
Обработка ошибок - с возможностью повтора

🏗️ Архитектура:

Clean Architecture - разделение по слоям
Provider - для управления состоянием
SQLite - локальная база данных
HTTP - для REST API запросов

Структура проекта
lib/
├── main.dart                 # Точка входа
├── models/                   # Модели данных
│   ├── character.dart
│   └── character.g.dart
├── services/                 # Сервисы
│   ├── api_service.dart     # REST API
│   └── database_service.dart # SQLite
├── providers/               # State Management
│   ├── character_provider.dart
│   └── theme_provider.dart
├── pages/                   # Экраны
│   ├── characters_page.dart
│   └── favorites_page.dart
└── widgets/                 # UI компоненты
    └── character_card.dart
