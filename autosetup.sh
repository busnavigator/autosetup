#!/bin/bash

# Exit script on error
set -e

echo "🚀 Starting server setup..."

echo "🔄 Updating packages..."
apt update && apt upgrade -y

echo "📦 Installing required dependencies..."
apt install -y curl git ufw

echo "🛡️ Configuring firewall..."
ufw allow 22
ufw allow 5432
ufw allow 80
ufw allow 443
ufw enable

echo "🐳 Installing Docker..."
apt install docker

echo "📦 Installing Docker Compose..."
apt install docker-compose

echo "🔄 Cloning API repository..."
git clone https://github.com/busnavigator/api
cd /api

echo "🔑 Setting up environment variables..."
cp .env.example .env

echo "🔒 Loading environment variables..."
source .env

echo "🐳 Starting Docker containers..."
docker-compose up -d --build

echo "⏳ Waiting for PostgreSQL to be ready..."
sleep 10

echo "📦 Setting up PostgreSQL database..."

psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF

echo "✅ Server setup complete!"
echo "🚀 Your API is running."
