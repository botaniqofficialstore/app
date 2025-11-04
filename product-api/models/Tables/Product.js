const mongoose = require('mongoose');

//----------------------------------------------------------------------
/** Master Table */
const ProductSchema = new mongoose.Schema({
  productId: { type: String, required: true, unique: true },
  productName: { type: String, required: true },
  productPrice: { type: Number, required: true },
  productSellingPrice: { type: Number, required: true },
  gram: { type: Number, required: true },
  image: { type: String, default: null }, 
  coverImage: { type: String, default: null },

}, { timestamps: true });

module.exports = mongoose.model('Product', ProductSchema);
