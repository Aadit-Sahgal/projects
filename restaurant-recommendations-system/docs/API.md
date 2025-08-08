# Restaurant Recommendations System API Documentation

## Overview

The Restaurant Recommendations System provides a comprehensive API for managing restaurants, users, and generating personalized recommendations using AI.

## Base URL

- **Development**: `http://localhost:3000`
- **Production**: `https://api.restaurant-recs.com`

## Authentication

Most endpoints require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### Authentication

#### POST /api/auth/login
Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt-token-here",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

#### POST /api/auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "Jane Smith"
}
```

**Response:**
```json
{
  "success": true,
  "token": "jwt-token-here",
  "user": {
    "id": 2,
    "email": "newuser@example.com",
    "name": "Jane Smith"
  }
}
```

### Restaurants

#### GET /api/restaurants
Get all restaurants with optional filtering.

**Query Parameters:**
- `cuisine` (optional): Filter by cuisine type
- `price` (optional): Filter by price range ($, $$, $$$, $$$$)
- `rating` (optional): Minimum rating (0.0-5.0)

**Response:**
```json
{
  "success": true,
  "restaurants": [
    {
      "id": 1,
      "name": "Italian Delight",
      "cuisine": "Italian",
      "rating": 4.5,
      "price": "$$",
      "address": "123 Main St",
      "phone": "555-0101"
    }
  ],
  "count": 1
}
```

#### GET /api/restaurants/:id
Get a specific restaurant by ID.

**Response:**
```json
{
  "success": true,
  "restaurant": {
    "id": 1,
    "name": "Italian Delight",
    "cuisine": "Italian",
    "rating": 4.5,
    "price": "$$",
    "address": "123 Main St",
    "phone": "555-0101"
  }
}
```

### Users

#### GET /api/users
Get all users (admin only).

**Response:**
```json
{
  "success": true,
  "users": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "preferences": {
        "cuisine": "Italian",
        "maxPrice": "$$"
      }
    }
  ]
}
```

#### GET /api/users/:id
Get a specific user by ID.

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "preferences": {
      "cuisine": "Italian",
      "maxPrice": "$$"
    }
  }
}
```

#### POST /api/users
Create a new user account.

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "name": "Jane Smith",
  "password": "password123",
  "preferences": {
    "cuisine": "Japanese",
    "maxPrice": "$$$"
  }
}
```

#### PUT /api/users/:id/preferences
Update user preferences.

**Request Body:**
```json
{
  "preferences": {
    "cuisine": "Thai",
    "maxPrice": "$$"
  }
}
```

### Recommendations

#### POST /api/recommendations
Get personalized restaurant recommendations.

**Request Body:**
```json
{
  "userId": 1,
  "preferences": {
    "cuisine": "Italian",
    "maxPrice": "$$"
  },
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060
  },
  "limit": 10
}
```

**Response:**
```json
{
  "success": true,
  "recommendations": [
    {
      "id": 1,
      "name": "Italian Delight",
      "cuisine": "Italian",
      "rating": 4.5,
      "price": "$$",
      "confidence": 0.85,
      "reason": "Recommended based on your Italian preferences"
    }
  ],
  "generatedAt": "2024-01-15T10:30:00.000Z"
}
```

#### GET /api/recommendations/model-status
Get the status of the AI recommendation model.

**Response:**
```json
{
  "status": "ready",
  "modelVersion": "1.0.0",
  "lastUpdated": "2024-01-15T10:30:00.000Z",
  "features": ["cuisine_preference", "price_filtering", "rating_sorting"]
}
```

### Health Check

#### GET /health
Check the health status of the API service.

**Response:**
```json
{
  "status": "healthy",
  "service": "api-service",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0.0"
}
```

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "error": "Missing required fields: email and password"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid credentials"
}
```

### 404 Not Found
```json
{
  "error": "Restaurant not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Something went wrong!",
  "message": "Internal server error"
}
```

## Rate Limiting

- **Standard endpoints**: 100 requests per minute
- **Recommendation endpoints**: 20 requests per minute

## Pagination

For endpoints that return lists, pagination is supported:

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)

**Response Headers:**
- `X-Total-Count`: Total number of items
- `X-Page-Count`: Total number of pages

## WebSocket Support

For real-time updates, WebSocket connections are available at:

- **Development**: `ws://localhost:3000/ws`
- **Production**: `wss://api.restaurant-recs.com/ws`

## SDKs and Libraries

Official SDKs are available for:
- JavaScript/Node.js
- Python
- Java
- Go

## Support

For API support, please contact:
- Email: api-support@restaurant-recs.com
- Documentation: https://docs.restaurant-recs.com
- GitHub Issues: https://github.com/restaurant-recs/api/issues

