# YAICA

YAICA - это полнофункциональное веб-приложение с современным интерфейсом и бэкендом.

## Структура проекта

```
yaica/
├── frontend/          # React приложение с Tailwind CSS
├── backend/           # Python Flask сервер
├── nginx/             # Конфигурация Nginx
├── docker-compose.yml # Docker Compose для развертывания
└── deploy.sh          # Скрипт развертывания
```

## Технологии

### Frontend
- **React** - Основной фреймворк
- **Tailwind CSS** - Стилизация
- **shadcn/ui** - UI компоненты
- **Webpack** - Сборка проекта

### Backend
- **Python Flask** - Веб-сервер
- **Docker** - Контейнеризация

### DevOps
- **Docker Compose** - Оркестрация контейнеров
- **Nginx** - Обратный прокси
- **SSL** - Безопасное соединение

## Быстрый старт

### Локальная разработка

1. **Frontend:**
   ```bash
   cd frontend
   npm install
   npm start
   ```

2. **Backend:**
   ```bash
   cd backend
   pip install -r requirements.txt
   python server.py
   ```

### Развертывание с Docker

```bash
# Запуск всех сервисов
docker-compose up -d

# Проверка статуса
./check-deployment.sh
```

## Развертывание

Для развертывания на сервере используйте:

```bash
./deploy.sh
```

Этот скрипт автоматически:
- Соберет Docker образы
- Настроит SSL сертификаты
- Запустит все сервисы

## Особенности

- 🎨 Современный UI с Tailwind CSS
- 🔧 Готовые UI компоненты
- 🐳 Полная контейнеризация
- 🔒 SSL поддержка
- 📱 Адаптивный дизайн
- ⚡ Быстрая разработка

## Лицензия

MIT License
