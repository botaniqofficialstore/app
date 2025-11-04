const mongoose = require('mongoose');

const CartSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  productId: { type: String, required: true },
  productCount: { type: Number, required: true, default: 1 }
}, { timestamps: true });

// Prevent duplicate product per user
CartSchema.index({ userId: 1, productId: 1 }, { unique: true });

module.exports = mongoose.model('Cart', CartSchema);
