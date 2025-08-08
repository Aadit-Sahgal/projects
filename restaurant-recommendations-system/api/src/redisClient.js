require('dotenv').config();
const Redis = require('ioredis');
const redis = new Redis(process.env.REDIS_URL);
redis.on('error', err => console.error(err));
module.exports = redis;