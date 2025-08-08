# Restaurant Recommendations System

A modern restaurant recommendation system built with Node.js, PostgreSQL, Redis, and AI services.

## 🏗️ Architecture

This project consists of multiple microservices:

- **API Service**: Main REST API for restaurant recommendations
- **AI Service**: Machine learning service for personalized recommendations
- **PostgreSQL**: Primary database for restaurant and user data
- **Redis**: Caching and session management

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)

### Running with Docker

1. Clone the repository:
```bash
git clone <repository-url>
cd restaurant-recommendations-system
```

2. Set up environment variables:
```bash
cp env.example .env
# Edit .env with your configuration
```

3. Start all services:
```bash
docker-compose up -d
```

4. Seed the database:
```bash
docker-compose exec api npm run seed
```

The API will be available at `http://localhost:3000`

### Local Development

1. Install dependencies:
```bash
cd api && npm install
cd ../ai-service && npm install
```

2. Set up the database:
```bash
# Start PostgreSQL and Redis
docker-compose up postgres redis -d

# Run migrations and seed data
cd api && npm run seed
```

3. Start the services:
```bash
# Terminal 1 - API Service
cd api && npm start

# Terminal 2 - AI Service
cd ai-service && npm start
```

## 📁 Project Structure

```
restaurant-recommendations-system/
├── api/                    # Main API service
│   ├── src/               # Source code
│   ├── package.json       # Dependencies
│   └── Dockerfile         # Container configuration
├── ai-service/            # AI/ML service
├── infra/                 # Infrastructure configuration
│   └── env/              # Environment files
├── docs/                  # Documentation
├── scripts/               # Utility scripts
├── docker-compose.yml     # Multi-service orchestration
└── README.md             # This file
```

## 🔧 Configuration

### Environment Variables

Create `.env` files in the following locations:

- `infra/env/api.env` - API service configuration
- `infra/env/ai.env` - AI service configuration
- `infra/env/postgres.env` - Database configuration

### API Endpoints

- `GET /api/restaurants` - List restaurants
- `GET /api/restaurants/:id` - Get restaurant details
- `POST /api/recommendations` - Get personalized recommendations
- `POST /api/users` - Create user account
- `POST /api/auth/login` - User authentication

## 🧪 Testing

```bash
# Run API tests
cd api && npm test

# Run AI service tests
cd ai-service && npm test
```

## 📊 Monitoring

- API Health: `http://localhost:3000/health`
- AI Service Health: `http://localhost:8001/health`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, please open an issue in the GitHub repository or contact the development team.

