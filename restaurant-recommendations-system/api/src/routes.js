const express = require('express');
const authC = require('./controllers/auth');
const swipeC = require('./controllers/swipe');
const recC = require('./controllers/recommend');
const authenticate = require('./middleware/auth');

const router = express.Router();
router.post('/signup', authC.signup);
router.post('/login',  authC.login);
router.post('/swipe', authenticate, swipeC.swipe);
router.post('/recommend', authenticate, recC.recommend);

module.exports = router;