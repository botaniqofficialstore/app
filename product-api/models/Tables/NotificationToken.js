const mongoose = require('mongoose');

const NotificationTokenSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  deviceType: { type: String, enum: ['android', 'ios'], required: true },
  fcmToken: { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model('NotificationToken', NotificationTokenSchema);
