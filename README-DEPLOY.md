# Быстрый старт развертывания

Этот проект подготовлен для развертывания на вашем сервере с доменом **opiumrussia.ru**

## 🚀 Быстрый старт (5 минут)

### Шаг 1: Подготовка сервера

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Перезагрузка для применения изменений
sudo reboot
```

### Шаг 2: Настройка DNS

В настройках домена opiumrussia.ru добавьте:

```
A    @      <IP_вашего_сервера>
A    www    <IP_вашего_сервера>
```

Подождите 5-10 минут для распространения DNS.

### Шаг 3: Загрузка кода

```bash
# Загрузите файлы проекта на сервер
# Можно использовать git clone или scp

cd /path/to/your/app
```

### Шаг 4: Развертывание

```bash
# Сделать скрипты исполняемыми
chmod +x deploy.sh setup-ssl.sh

# Запустить развертывание
./deploy.sh
```

### Шаг 5: Настройка SSL

```bash
# Отредактируйте email в скрипте (опционально)
nano setup-ssl.sh
# Измените: EMAIL="your-email@example.com"

# Запустить настройку SSL
./setup-ssl.sh
```

### Шаг 6: Запуск Nginx

```bash
# После успешной настройки SSL
docker-compose up -d
```

## ✅ Проверка

Откройте в браузере:
- https://opiumrussia.ru
- https://opiumrussia.ru/api/

Проверьте статус контейнеров:
```bash
docker-compose ps
```

Все сервисы должны быть в статусе "Up".

## 📖 Подробная документация

Смотрите [DEPLOYMENT.md](./DEPLOYMENT.md) для полной инструкции по:
- Устранению неполадок
- Резервному копированию
- Мониторингу
- Безопасности

## 🔧 Управление

```bash
# Просмотр логов
docker-compose logs -f

# Перезапуск сервиса
docker-compose restart [service_name]

# Остановка
docker-compose down

# Запуск
docker-compose up -d
```

## 💻 Структура проекта

```
├── docker-compose.yml       # Конфигурация сервисов
├── deploy.sh                # Скрипт развертывания
├── setup-ssl.sh             # Скрипт настройки SSL
├── DEPLOYMENT.md           # Подробная документация
├── backend/
│   ├── Dockerfile
│   ├── server.py
│   └── requirements.txt
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
└── nginx/
    └── nginx.conf           # Главный прокси с SSL
```

## 🔒 Что включено

✅ **Docker контейнеризация** - простое развертывание
✅ **SSL/HTTPS** - автоматический Let's Encrypt
✅ **Nginx реверс-прокси** - оптимизированный
✅ **MongoDB** - встроенная база данных
✅ **Автообновление SSL** - каждые 12 часов
✅ **Production-ready** - готово к продакшену

## ❓ Помощь

Если возникли проблемы:
1. Проверьте логи: `docker-compose logs -f`
2. Читайте DEPLOYMENT.md
3. Проверьте DNS настройки
4. Убедитесь что порты 80 и 443 открыты

---

**Удачи в развертывании!** 🚀
