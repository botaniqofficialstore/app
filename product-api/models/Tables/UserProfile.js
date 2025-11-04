const mongoose = require('mongoose');


//----------------------------------------------------------------------
/** Customer Table */
const UserProfileSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  firstName: { type: String },
  lastName: { type: String },
  email: { type: String, required: true, unique: true },
  mobileNumber: { type: String, unique: true },
  address: { type: String },
  password: { type: String }, // hashed password
  otp: { code: String, expiresAt: Date }, // for OTP verification
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('UserProfile', UserProfileSchema);
