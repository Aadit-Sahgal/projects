const { getNearbyPlaces } = require('../services/locationService');
const { getSwipedIds } = require('../services/swipeService');
const { getRecommendations } = require('../services/aiClient');

exports.recommend = async (req, res, next) => {
  try {
    const { latitude, longitude, radius_m = 2000, k = 10 } = req.body;
    const nearby = await getNearbyPlaces(latitude, longitude, radius_m);
    const ids = nearby.map(r => r.place_id);
    const seen = await getSwipedIds(req.user.id);
    const cand = ids.filter(id => !seen.has(id));
    if (!cand.length) return res.status(404).json({ error: 'No unseen restaurants nearby' });
    const ranked = await getRecommendations(req.user.id, cand, k);
    const out = ranked.map(r => ({
      ...nearby.find(p => p.place_id === r.place_id),
      score: r.score
    }));
    res.json({ recommendations: out });
  } catch (e) {
    next(e);
  }
};