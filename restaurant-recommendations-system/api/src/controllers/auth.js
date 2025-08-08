const db = require('../db');
const { hashPassword, verifyPassword, signToken } = require('../services/authService');

exports.signup = async (req, res, next) => {
  const { email, password, default_radius } = req.body;
  try {
    const password_hash = hashPassword(password);
    const { rows } = await db.query(`
      INSERT INTO users(email,password_hash,default_radius)
      VALUES($1,$2,$3) RETURNING id,email,default_radius
    `, [email, password_hash, default_radius]);
    const user = rows[0];
    const token = signToken(user);
    res.status(201).json({
      id: user.id,
      email: user.email,
      default_radius: user.default_radius,
      access_token: token
    });
  } catch (e) {
    if (e.code === '23505') return res.status(400).json({ error: 'Email already in use' });
    next(e);
  }
};

exports.login = async (req, res, next) => {
  const { email, password } = req.body;
  try {
    const { rows } = await db.query(
      `SELECT id,email,password_hash,default_radius FROM users WHERE email=$1`,
      [email]
    );
    const user = rows[0];
    if (!user || !verifyPassword(password, user.password_hash)) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    const token = signToken(user);
    res.json({ access_token: token, default_radius: user.default_radius });
  } catch (e) {
    next(e);
  }
};