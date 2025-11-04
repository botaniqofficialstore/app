const mongoose = require('mongoose');

const OrderStatusSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  orderId: { type: String, required: true },
  orderStatus: { type: Number, required: true }, // 0=Placed, 1=Confirmed, 2=Harvested, 3=Packed&Shipped, 4=Delivered
  orderStatusDate: { type: Date, default: Date.now },
}, { timestamps: true });

module.exports = mongoose.model('OrderStatus', OrderStatusSchema);
