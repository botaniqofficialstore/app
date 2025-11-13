// models/Tables/ReelLike.js
const mongoose = require('mongoose');

const ReelLikeSchema = new mongoose.Schema({
  reelId: { type: String, required: true },
  userId: { type: String, required: true },
  isLiked: { type: Boolean, default: false },
  updatedAt: { type: Date, default: Date.now },
});

ReelLikeSchema.index({ reelId: 1, userId: 1 }, { unique: true }); // Prevent duplicates

module.exports = mongoose.model('ReelLike', ReelLikeSchema);
