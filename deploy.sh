#!/bin/bash

# Deployment Script for opiumrussia.ru
# This script will deploy the application with Docker Compose

set -e

DOMAIN="opiumrussia.ru"

echo "=================================="
echo "Deployment Script for ${DOMAIN}"
echo "=================================="
echo ""

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    echo "Install Docker with: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose is not installed."
    echo "Install Docker Compose from: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Warning: This script may require root privileges."
    echo "If you encounter permission errors, run with: sudo ./deploy.sh"
    echo ""
fi

echo "Step 1: Checking environment files..."
if [ ! -f ./backend/.env ]; then
    echo "Creating backend .env file..."
    cat > ./backend/.env << 'EOF'
MONGO_URL=mongodb://mongodb:27017
DB_NAME=test_database
CORS_ORIGINS=https://opiumrussia.ru,http://opiumrussia.ru
EOF
    echo "✓ Backend .env created"
else
    echo "✓ Backend .env exists"
fi

if [ ! -f ./frontend/.env ]; then
    echo "Creating frontend .env file..."
    cat > ./frontend/.env << 'EOF'
REACT_APP_BACKEND_URL=https://opiumrussia.ru
EOF
    echo "✓ Frontend .env created"
else
    echo "✓ Frontend .env exists"
fi

echo ""
echo "Step 2: Creating necessary directories..."
mkdir -p ./nginx/ssl
mkdir -p ./certbot/conf
mkdir -p ./certbot/www
echo "✓ Directories created"

echo ""
echo "Step 3: Stopping existing containers..."
docker-compose down 2>/dev/null || true
echo "✓ Stopped"

echo ""
echo "Step 4: Building Docker images..."
docker-compose build --no-cache
echo "✓ Images built"

echo ""
echo "Step 5: Starting services..."
docker-compose up -d mongodb backend frontend
echo "✓ Services started"

echo ""
echo "Step 6: Waiting for services to be ready..."
echo -n "Waiting for backend"
for i in {1..30}; do
    if docker-compose exec -T backend curl -s http://localhost:8001/api/ > /dev/null 2>&1; then
        echo " ✓"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo "=================================="
echo "✓ Deployment Complete!"
echo "=================================="
echo ""
echo "Services Status:"
docker-compose ps
echo ""
echo "Next Steps:"
echo "1. Make sure your domain ${DOMAIN} points to this server's IP address"
echo "2. Run SSL setup script: ./setup-ssl.sh"
echo "3. After SSL setup, start nginx: docker-compose up -d nginx"
echo ""
echo "To view logs: docker-compose logs -f [service_name]"
echo "To stop services: docker-compose down"
echo ""
