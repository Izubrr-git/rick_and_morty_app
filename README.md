# 🧪 Rick & Morty Flutter App

Мобильное приложение на Flutter для просмотра персонажей из мультсериала **"Рик и Морти"** с возможностью добавления в избранное и оффлайн-доступом.

![rick-and-morty](https://img.shields.io/badge/Flutter-v3.x-blue?logo=flutter)  
![platforms](https://img.shields.io/badge/platform-Android-green?logo=android)

---

## ✨ Функции

- ✅ **Список персонажей** — загрузка с [Rick and Morty API](https://rickandmortyapi.com/)
- ✅ **Пагинация** — автоматическая подгрузка при прокрутке
- ✅ **Избранное** — добавление и удаление персонажей
- ✅ **Сортировка избранного** — по имени, статусу и виду
- ✅ **Оффлайн-режим** — кеширование данных в SQLite
- ✅ **Темная тема** — поддержка светлой и тёмной темы
- ✅ **Анимации** — плавные анимации при добавлении в избранное
- ✅ **Обработка ошибок** — отображение ошибок и возможность повтора

---

## 🏗️ Архитектура

- **Clean Architecture** — строгая организация по слоям
- **Provider** — управление состоянием
- **SQLite** — локальное хранение данных
- **HTTP** — взаимодействие с REST API

---

## 📁 Структура проекта

```plaintext
lib/
├── main.dart                   # Точка входа
├── models/                    # Модели данных
│   ├── character.dart
│   └── character.g.dart
├── services/                  # Слой сервисов
│   ├── api_service.dart       # Работа с API
│   └── database_service.dart  # Работа с SQLite
├── providers/                # Провайдеры (State management)
│   ├── character_provider.dart
│   └── theme_provider.dart
├── pages/                    # Экраны
│   ├── characters_page.dart
│   └── favorites_page.dart
└── widgets/                  # Переиспользуемые UI-компоненты
    └── character_card.dart
