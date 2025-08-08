#!/bin/bash

# Restaurant Recommendations System Startup Script

echo "🍽️  Starting Restaurant Recommendations System..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install it and try again."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created. Please edit it with your configuration."
fi

# Build and start services
echo "🚀 Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check API service
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ API Service is healthy"
else
    echo "❌ API Service is not responding"
fi

# Check AI service
if curl -f http://localhost:8001/health > /dev/null 2>&1; then
    echo "✅ AI Service is healthy"
else
    echo "❌ AI Service is not responding"
fi

# Seed the database
echo "🌱 Seeding database..."
docker-compose exec api npm run seed

echo ""
echo "🎉 Restaurant Recommendations System is ready!"
echo ""
echo "📊 Service URLs:"
echo "   API Service: http://localhost:3000"
echo "   AI Service:  http://localhost:8001"
echo "   Health Check: http://localhost:3000/health"
echo ""
echo "📚 API Documentation: http://localhost:3000/docs"
echo ""
echo "🛠️  Useful commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop services: docker-compose down"
echo "   Restart services: docker-compose restart"
echo ""

