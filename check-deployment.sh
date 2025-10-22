#!/bin/bash

# Deployment Check Script
# This script checks if everything is configured correctly

echo "===================================="
echo "Deployment Configuration Check"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print check result
check_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
        ERRORS=$((ERRORS + 1))
    fi
}

warning_result() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

echo "Checking Prerequisites..."
echo ""

# Check Docker
if command_exists docker; then
    check_result 0 "Docker is installed"
    docker --version | sed 's/^/  /'
else
    check_result 1 "Docker is NOT installed"
    echo "  Install: curl -fsSL https://get.docker.com | sh"
fi
echo ""

# Check Docker Compose
if command_exists docker-compose || docker compose version >/dev/null 2>&1; then
    check_result 0 "Docker Compose is installed"
    if command_exists docker-compose; then
        docker-compose --version | sed 's/^/  /'
    else
        docker compose version | sed 's/^/  /'
    fi
else
    check_result 1 "Docker Compose is NOT installed"
fi
echo ""

echo "Checking Required Files..."
echo ""

# Check docker-compose.yml
if [ -f "./docker-compose.yml" ]; then
    check_result 0 "docker-compose.yml exists"
else
    check_result 1 "docker-compose.yml is missing"
fi

# Check Dockerfiles
if [ -f "./backend/Dockerfile" ]; then
    check_result 0 "backend/Dockerfile exists"
else
    check_result 1 "backend/Dockerfile is missing"
fi

if [ -f "./frontend/Dockerfile" ]; then
    check_result 0 "frontend/Dockerfile exists"
else
    check_result 1 "frontend/Dockerfile is missing"
fi

# Check nginx config
if [ -f "./nginx/nginx.conf" ]; then
    check_result 0 "nginx/nginx.conf exists"
else
    check_result 1 "nginx/nginx.conf is missing"
fi

echo ""
echo "Checking Environment Files..."
echo ""

# Check backend .env
if [ -f "./backend/.env" ]; then
    check_result 0 "backend/.env exists"
    
    # Check required variables
    if grep -q "MONGO_URL" ./backend/.env; then
        check_result 0 "  MONGO_URL is set"
    else
        warning_result "  MONGO_URL is not set"
    fi
    
    if grep -q "DB_NAME" ./backend/.env; then
        check_result 0 "  DB_NAME is set"
    else
        warning_result "  DB_NAME is not set"
    fi
else
    warning_result "backend/.env does not exist (will be created by deploy.sh)"
fi

# Check frontend .env
if [ -f "./frontend/.env" ]; then
    check_result 0 "frontend/.env exists"
    
    if grep -q "REACT_APP_BACKEND_URL" ./frontend/.env; then
        check_result 0 "  REACT_APP_BACKEND_URL is set"
        BACKEND_URL=$(grep "REACT_APP_BACKEND_URL" ./frontend/.env | cut -d '=' -f2)
        echo "  Current: $BACKEND_URL"
    else
        warning_result "  REACT_APP_BACKEND_URL is not set"
    fi
else
    warning_result "frontend/.env does not exist (will be created by deploy.sh)"
fi

echo ""
echo "Checking DNS Configuration..."
echo ""

DOMAIN="opiumrussia.ru"
if command_exists dig; then
    DNS_IP=$(dig +short $DOMAIN | tail -n1)
    if [ -n "$DNS_IP" ]; then
        check_result 0 "DNS record for $DOMAIN exists: $DNS_IP"
        
        # Try to get server's public IP
        if command_exists curl; then
            SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null)
            if [ -n "$SERVER_IP" ]; then
                echo "  Server IP: $SERVER_IP"
                if [ "$DNS_IP" = "$SERVER_IP" ]; then
                    check_result 0 "  DNS points to this server"
                else
                    warning_result "  DNS does NOT point to this server"
                    echo "    DNS IP: $DNS_IP"
                    echo "    Server IP: $SERVER_IP"
fi
            fi
        fi
    else
        warning_result "No DNS record found for $DOMAIN"
        echo "  Make sure to add A records:"
        echo "    A    @      YOUR_SERVER_IP"
        echo "    A    www    YOUR_SERVER_IP"
    fi
else
    warning_result "'dig' command not found, cannot check DNS"
    echo "  Install: sudo apt install dnsutils"
fi

echo ""
echo "Checking Ports..."
echo ""

if command_exists netstat; then
    # Check if port 80 is in use
    if netstat -tuln | grep -q ":80 "; then
        warning_result "Port 80 is already in use"
        netstat -tuln | grep ":80 " | sed 's/^/  /'
    else
        check_result 0 "Port 80 is available"
    fi
    
    # Check if port 443 is in use
    if netstat -tuln | grep -q ":443 "; then
        warning_result "Port 443 is already in use"
        netstat -tuln | grep ":443 " | sed 's/^/  /'
    else
        check_result 0 "Port 443 is available"
    fi
else
    warning_result "'netstat' command not found, cannot check ports"
    echo "  Install: sudo apt install net-tools"
fi

echo ""
echo "===================================="
echo "Summary"
echo "===================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You can proceed with deployment:"
    echo "  ./deploy.sh"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo ""
    echo "You can proceed with deployment, but review the warnings:"
    echo "  ./deploy.sh"
else
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    fi
    echo ""
    echo "Please fix the errors before deploying."
    exit 1
fi

echo ""
