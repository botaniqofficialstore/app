const mongoose = require('mongoose');

<<<<<<< HEAD
=======

//----------------------------------------------------------------------
/** Customer Table */
>>>>>>> dfdff9d8cd23a9cdbbd4a1bc6a20349b46a4ff7a
const UserProfileSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  firstName: { type: String },
  lastName: { type: String },
<<<<<<< HEAD
  email: { type: String, unique: true, sparse: true },
  mobileNumber: { type: String, unique: true, sparse: true },
  otp: {
    code: String,
    expiresAt: Date,
  },
  createdAt: { type: Date, default: Date.now },
=======
  email: { type: String, required: true, unique: true },
  mobileNumber: { type: String, unique: true },
  address: { type: String },
  password: { type: String }, // hashed password
  otp: { code: String, expiresAt: Date }, // for OTP verification
  createdAt: { type: Date, default: Date.now }
>>>>>>> dfdff9d8cd23a9cdbbd4a1bc6a20349b46a4ff7a
});

module.exports = mongoose.model('UserProfile', UserProfileSchema);
