const jwt = require('jsonwebtoken');
require('dotenv').config();

//MARK:- This method is used to handle access token for every API ------------------------------------>
const authenticateToken = (req, res, next) => {
  // Header example: Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // take second part

  if (!token) {
    return res.status(401).json({ message: 'Access token required' });
  }

  try {
    // Verify access token using your .env secret
    const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
    req.user = decoded; // attach user info to request (userId, email, etc.)
    next(); // ✅ move to next middleware or route handler
  } catch (error) {
    console.error('Token verification failed:', error.message);
    res.status(403).json({ message: 'Invalid or expired access token' });
  }
};

module.exports = authenticateToken;
