const redis = require('../redisClient');

module.exports = {
  async updateUPV(userId, placeId, feedback) {
    await redis.hincrbyfloat(`upv:${userId}`, placeId, feedback);
  },
  async getUPV(userId) {
    const raw = await redis.hgetall(`upv:${userId}`);
    return Object.fromEntries(
      Object.entries(raw).map(([k, v]) => [k, parseFloat(v)])
    );
  }
};