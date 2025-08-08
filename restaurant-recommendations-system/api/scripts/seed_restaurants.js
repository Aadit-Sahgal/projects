require('dotenv').config();
const axios = require('axios');
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const GOOGLE_KEY = process.env.GOOGLE_API_KEY;

async function fetchNearby(lat, lng, radius) {
  let results = [], token = null;
  do {
    const { data } = await axios.get(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
      { params: { key: GOOGLE_KEY, location: `${lat},${lng}`, radius, pagetoken: token } }
    );
    results = results.concat(data.results);
    token = data.next_page_token;
    if (token) await new Promise(r => setTimeout(r, 2000));
  } while (token);
  return results;
}

async function fetchDetails(placeId) {
  const { data } = await axios.get(
    'https://maps.googleapis.com/maps/api/place/details/json',
    { params: { key: GOOGLE_KEY, place_id: placeId, fields: 'name,types,price_level,photos,geometry' } }
  );
  return data.result;
}

(async () => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const nearby = await fetchNearby(41.8781, -87.6298, 2000);
    for (const place of nearby) {
      const det = await fetchDetails(place.place_id);
      const cuisine = det.types.find(t => ['italian','chinese','mexican','japanese','indian'].includes(t)) || 'other';
      const price = det.price_level || 2;
      const photos = (det.photos||[]).slice(0,3).map(p=>p.photo_reference);
      await client.query(`
        INSERT INTO restaurants
          (place_id,name,cuisine,price_range,lat,lng,menu_text,photo_ref)
        VALUES($1,$2,$3,$4,$5,$6,$7,$8)
        ON CONFLICT(place_id) DO UPDATE SET
          name=EXCLUDED.name,
          cuisine=EXCLUDED.cuisine,
          price_range=EXCLUDED.price_range,
          lat=EXCLUDED.lat,
          lng=EXCLUDED.lng,
          photo_ref=EXCLUDED.photo_ref
      `, [
        det.place_id, det.name, cuisine, '$'.repeat(price),
        det.geometry.location.lat, det.geometry.location.lng,
        null, photos
      ]);
    }
    await client.query('COMMIT');
    console.log('Seeding complete');
  } catch (e) {
    await client.query('ROLLBACK');
    console.error(e);
  } finally {
    client.release();
    pool.end();
  }
})();

