const axios = require('axios');
const AI = axios.create({ baseURL: process.env.AI_SERVICE_URL, timeout: 5000 });

module.exports = {
  async getRecommendations(userId, placeIds, k = 10) {
    const { data } = await AI.post('/recommend', {
      user_id:   userId,
      place_ids: placeIds,
      k
    });
    return data.recommendations;
  }
};