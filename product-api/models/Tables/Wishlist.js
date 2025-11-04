const mongoose = require('mongoose');

const WishlistSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  productId: { type: String, required: true },
}, { timestamps: true });

// Prevent duplicate product per user
WishlistSchema.index({ userId: 1, productId: 1 }, { unique: true });

module.exports = mongoose.model('Wishlist', WishlistSchema);
