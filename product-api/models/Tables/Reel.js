// models/Tables/Reel.js
const mongoose = require('mongoose');

const ReelSchema = new mongoose.Schema({
  reelId: { type: String, required: true, unique: true },
  reelUrl: { type: String, required: true },
  caption: { type: String },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Reel', ReelSchema);
