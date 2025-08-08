const { Pool } = require('pg');

// Database configuration
const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: process.env.POSTGRES_PORT || 5432,
  database: process.env.POSTGRES_DB || 'restaurant_recs',
  user: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'password'
});

// Sample restaurant data
const restaurants = [
  {
    name: "Italian Delight",
    cuisine: "Italian",
    rating: 4.5,
    price_range: "$$",
    address: "123 Main Street",
    phone: "555-0101",
    description: "Authentic Italian cuisine with fresh ingredients"
  },
  {
    name: "Sushi Master",
    cuisine: "Japanese",
    rating: 4.8,
    price_range: "$$$",
    address: "456 Oak Avenue",
    phone: "555-0102",
    description: "Premium sushi and Japanese specialties"
  },
  {
    name: "Burger Joint",
    cuisine: "American",
    rating: 4.2,
    price_range: "$",
    address: "789 Pine Street",
    phone: "555-0103",
    description: "Classic American burgers and comfort food"
  },
  {
    name: "Thai Spice",
    cuisine: "Thai",
    rating: 4.6,
    price_range: "$$",
    address: "321 Elm Street",
    phone: "555-0104",
    description: "Authentic Thai cuisine with bold flavors"
  },
  {
    name: "Mexican Fiesta",
    cuisine: "Mexican",
    rating: 4.3,
    price_range: "$$",
    address: "654 Maple Avenue",
    phone: "555-0105",
    description: "Traditional Mexican dishes and margaritas"
  },
  {
    name: "French Bistro",
    cuisine: "French",
    rating: 4.7,
    price_range: "$$$",
    address: "987 Cedar Lane",
    phone: "555-0106",
    description: "Elegant French dining experience"
  },
  {
    name: "Indian Palace",
    cuisine: "Indian",
    rating: 4.4,
    price_range: "$$",
    address: "147 Birch Road",
    phone: "555-0107",
    description: "Rich Indian flavors and traditional dishes"
  },
  {
    name: "Pizza Corner",
    cuisine: "Italian",
    rating: 4.1,
    price_range: "$",
    address: "258 Spruce Drive",
    phone: "555-0108",
    description: "Fresh pizza and Italian favorites"
  },
  {
    name: "Chinese Garden",
    cuisine: "Chinese",
    rating: 4.5,
    price_range: "$$",
    address: "369 Willow Way",
    phone: "555-0109",
    description: "Authentic Chinese cuisine and dim sum"
  },
  {
    name: "Greek Taverna",
    cuisine: "Greek",
    rating: 4.3,
    price_range: "$$",
    address: "741 Poplar Place",
    phone: "555-0110",
    description: "Mediterranean flavors and Greek specialties"
  }
];

async function createTables() {
  try {
    // Create restaurants table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS restaurants (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        cuisine VARCHAR(100) NOT NULL,
        rating DECIMAL(2,1) NOT NULL,
        price_range VARCHAR(10) NOT NULL,
        address TEXT NOT NULL,
        phone VARCHAR(20) NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create users table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        name VARCHAR(255) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        preferences JSONB DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    console.log('Tables created successfully');
  } catch (error) {
    console.error('Error creating tables:', error);
    throw error;
  }
}

async function seedRestaurants() {
  try {
    // Clear existing data
    await pool.query('DELETE FROM restaurants');
    
    // Insert restaurant data
    for (const restaurant of restaurants) {
      await pool.query(`
        INSERT INTO restaurants (name, cuisine, rating, price_range, address, phone, description)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
      `, [
        restaurant.name,
        restaurant.cuisine,
        restaurant.rating,
        restaurant.price_range,
        restaurant.address,
        restaurant.phone,
        restaurant.description
      ]);
    }
    
    console.log(`Seeded ${restaurants.length} restaurants successfully`);
  } catch (error) {
    console.error('Error seeding restaurants:', error);
    throw error;
  }
}

async function main() {
  try {
    console.log('Starting database seeding...');
    
    await createTables();
    await seedRestaurants();
    
    console.log('Database seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Database seeding failed:', error);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run the seeding process
if (require.main === module) {
  main();
}

module.exports = { createTables, seedRestaurants };

