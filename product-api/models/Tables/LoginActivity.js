const mongoose = require('mongoose');

const LoginActivitySchema = new mongoose.Schema({
  userId: { type: String, required: true },
  loginType: { type: String, enum: ['manual', 'google', 'facebook', 'otp'], required: true },
  loginDate: { type: Date, default: Date.now },
  logoutDate: { type: Date, default: null },
  deviceId: { type: String },
  appVersion: { type: String },
  activeStatus: { type: Number, enum: [0, 1], default: 0 } // 0 = Active, 1 = Inactive
}, { timestamps: true });

module.exports = mongoose.model('LoginActivity', LoginActivitySchema);
