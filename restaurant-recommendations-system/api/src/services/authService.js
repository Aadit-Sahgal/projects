const bcrypt = require('bcrypt');
const jwt    = require('jsonwebtoken');

module.exports = {
  hashPassword: pw => bcrypt.hashSync(pw, 10),
  verifyPassword: (pw, hash) => bcrypt.compareSync(pw, hash),
  signToken: user =>
    jwt.sign({ sub: user.id, email: user.email }, process.env.JWT_SECRET, {
      expiresIn: '1h'
    })
};