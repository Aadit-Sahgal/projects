const { logSwipe } = require('../services/swipeService');

exports.swipe = async (req, res, next) => {
  try {
    const { place_id, feedback } = req.body;
    await logSwipe(req.user.id, place_id, feedback);
    res.json({ status: 'ok' });
  } catch (e) {
    next(e);
  }
};