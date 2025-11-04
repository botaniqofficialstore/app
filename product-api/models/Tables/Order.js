const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  orderId: { type: String, required: true }, 
  productId: { type: String, required: true },
  productCount: { type: Number, required: true, default: 1 },
  orderDate: { type: Date, default: Date.now },
  totalPrice: { type: Number, required: true },
  currentOrderStatus: { type: Number, default: 0 }, // 0=Placed
  currentOrderStatusDate: { type: Date, default: Date.now },
  deliveryDate: { type: Date, default: null },
}, { timestamps: true });

// Optional: add index for faster queries
OrderSchema.index({ userId: 1, orderId: 1 });

module.exports = mongoose.model('Order', OrderSchema);
