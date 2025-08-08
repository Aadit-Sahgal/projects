@echo off
chcp 65001 >nul

echo 🍽️  Starting Restaurant Recommendations System...

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not running. Please start Docker and try again.
    pause
    exit /b 1
)

REM Check if docker-compose is available
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ docker-compose is not installed. Please install it and try again.
    pause
    exit /b 1
)

REM Create .env file if it doesn't exist
if not exist .env (
    echo 📝 Creating .env file from template...
    copy env.example .env
    echo ✅ .env file created. Please edit it with your configuration.
)

REM Build and start services
echo 🚀 Building and starting services...
docker-compose up --build -d

REM Wait for services to be ready
echo ⏳ Waiting for services to be ready...
timeout /t 10 /nobreak >nul

REM Check service health
echo 🔍 Checking service health...

REM Check API service
curl -f http://localhost:3000/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ API Service is healthy
) else (
    echo ❌ API Service is not responding
)

REM Check AI service
curl -f http://localhost:8001/health >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ AI Service is healthy
) else (
    echo ❌ AI Service is not responding
)

REM Seed the database
echo 🌱 Seeding database...
docker-compose exec api npm run seed

echo.
echo 🎉 Restaurant Recommendations System is ready!
echo.
echo 📊 Service URLs:
echo    API Service: http://localhost:3000
echo    AI Service:  http://localhost:8001
echo    Health Check: http://localhost:3000/health
echo.
echo 📚 API Documentation: http://localhost:3000/docs
echo.
echo 🛠️  Useful commands:
echo    View logs: docker-compose logs -f
echo    Stop services: docker-compose down
echo    Restart services: docker-compose restart
echo.
pause

