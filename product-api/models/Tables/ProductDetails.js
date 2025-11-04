const mongoose = require('mongoose');

const NutrientSchema = new mongoose.Schema({
  vitamin: { type: String, required: true },
  benefit: { type: String, required: true }
});

const ProductDetailsSchema = new mongoose.Schema({
  productId: { type: String, required: true, unique: true }, // 👈 string
  description: { type: String, required: true },
  nutrients: [NutrientSchema],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ProductDetails', ProductDetailsSchema);
