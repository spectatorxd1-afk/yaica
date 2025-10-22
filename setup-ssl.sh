#!/bin/bash

# SSL Setup Script for opiumrussia.ru
# This script will obtain SSL certificates from Let's Encrypt

set -e

DOMAIN="opiumrussia.ru"
EMAIL="admin@${DOMAIN}"  # Change this to your email

echo "=================================="
echo "SSL Certificate Setup for ${DOMAIN}"
echo "=================================="
echo ""

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "Step 1: Creating necessary directories..."
mkdir -p ./nginx/ssl
mkdir -p ./certbot/conf
mkdir -p ./certbot/www

echo "Step 2: Creating temporary nginx configuration for certificate validation..."
cat > ./nginx/nginx-init.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        listen [::]:80;
        server_name opiumrussia.ru www.opiumrussia.ru;

        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }

        location / {
            return 200 'OK';
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo "Step 3: Starting nginx temporarily for certificate validation..."
mv ./nginx/nginx.conf ./nginx/nginx.conf.backup 2>/dev/null || true
cp ./nginx/nginx-init.conf ./nginx/nginx.conf

# Start only nginx and certbot services
docker-compose up -d nginx

echo "Waiting for nginx to start..."
sleep 5

echo "Step 4: Requesting SSL certificate from Let's Encrypt..."
echo "Using email: ${EMAIL}"
echo "Domain: ${DOMAIN}"
echo ""
read -p "Is this email correct? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please edit the EMAIL variable in this script and run again."
    exit 1
fi

# Request certificate
docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email ${EMAIL} \
    --agree-tos \
    --no-eff-email \
    -d ${DOMAIN} \
    -d www.${DOMAIN}

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ SSL Certificate obtained successfully!"
    echo ""
    echo "Step 5: Restoring production nginx configuration..."
    mv ./nginx/nginx.conf.backup ./nginx/nginx.conf 2>/dev/null || true
    
    echo "Step 6: Restarting nginx with SSL configuration..."
    docker-compose restart nginx
    
    echo ""
    echo "=================================="
    echo "✓ SSL Setup Complete!"
    echo "=================================="
    echo ""
    echo "Your website is now secured with HTTPS."
    echo "Certificate will auto-renew every 12 hours."
    echo ""
    echo "You can now access your site at:"
    echo "  https://${DOMAIN}"
    echo ""
else
    echo ""
    echo "✗ Failed to obtain SSL certificate."
    echo ""
    echo "Common issues:"
    echo "1. Domain ${DOMAIN} is not pointing to this server's IP"
    echo "2. Port 80 is blocked by firewall"
    echo "3. Email address is invalid"
    echo ""
    echo "Please check your domain DNS settings and try again."
    echo ""
    # Restore original config
    mv ./nginx/nginx.conf.backup ./nginx/nginx.conf 2>/dev/null || true
    exit 1
fi
