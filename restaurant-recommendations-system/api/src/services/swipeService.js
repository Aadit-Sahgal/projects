const db   = require('../db');
const pref = require('./userPrefService');

module.exports = {
  async logSwipe(userId, placeId, feedback) {
    await db.query(
      'INSERT INTO swipes(user_id,place_id,feedback) VALUES($1,$2,$3)',
      [userId, placeId, feedback]
    );
    await pref.updateUPV(userId, placeId, feedback);
  },
  async getSwipedIds(userId) {
    const { rows } = await db.query(
      'SELECT place_id FROM swipes WHERE user_id=$1',
      [userId]
    );
    return new Set(rows.map(r => r.place_id));
  }
};