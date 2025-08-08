const db = require('../db');

module.exports = {
  async getNearbyPlaces(lat, lon, radius_m) {
    const { rows } = await db.query(
      `
      SELECT place_id,name,cuisine,price_range,lat,lng,
        earth_distance(ll_to_earth(lat,lng),ll_to_earth($1,$2)) AS distance_m
      FROM restaurants
      WHERE earth_distance(ll_to_earth(lat,lng),ll_to_earth($1,$2)) <= $3
      ORDER BY distance_m
      LIMIT 100
      `,
      [lat, lon, radius_m]
    );
    return rows;
  }
};