// models/API/Products/Orders.js

const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const UserProfile = require('../../Tables/UserProfile');
const Product = require('../../Tables/Product');
const Order = require('../../Tables/Order');
const Cart = require('../../Tables/Cart');
const OrderStatus = require('../../Tables/OrderStatus');
const authenticateToken = require('../../../middleware/authMiddleware');


//MARK:- Place Order POST API --------------------------------------------------->
router.post('/orders', async (req, res) => {
  try {
    const { userId, products } = req.body;
    // products = [{ productId: "5001", productCount: 2 }, { productId: "5002", productCount: 1 }]

    if (!userId || !Array.isArray(products) || products.length === 0)
      return res.status(400).json({ message: 'userId and product list are required' });

    // Validate user
    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    // Validate and calculate total
    let totalPrice = 0;
    for (const item of products) {
      const product = await Product.findOne({ productId: String(item.productId) });
      if (!product) return res.status(404).json({ message: `Invalid productId ${item.productId}` });
      totalPrice += product.productSellingPrice * item.productCount;
    }

    // Create unique orderId
    const orderId = uuidv4();

    // Create orders for each product
    const orders = [];
    for (const item of products) {
      const product = await Product.findOne({ productId: String(item.productId) });

      const order = new Order({
        userId,
        orderId,
        productId: item.productId,
        productCount: item.productCount,
        totalPrice: product.productSellingPrice * item.productCount,
        currentOrderStatus: 0,
        currentOrderStatusDate: new Date(),
      });

      await order.save();
      orders.push(order);
    }

    // Add initial OrderStatus (Placed = 0)
    const orderStatus = new OrderStatus({
      userId,
      orderId,
      orderStatus: 0,
      orderStatusDate: new Date(),
    });
    await orderStatus.save();

    // ✅ Remove ordered items from cart
    const productIds = products.map(p => p.productId);
    await Cart.deleteMany({ userId: String(userId), productId: { $in: productIds } });

    res.status(201).json({
      message: 'Order placed successfully and cart updated',
      orderId,
      data: orders,
      orderStatus,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error placing order', error: error.message });
  }
});

//MARK:- Add Order New Status POST API --------------------------------------------------->
router.post('/order-status', authenticateToken, async (req, res) => {
  try {
    const { userId, orderId, orderStatus } = req.body;

    if (!userId || !orderId || orderStatus === undefined)
      return res.status(400).json({ message: 'userId, orderId, and orderStatus are required' });

    // Validate user
    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user) return res.status(404).json({ message: 'Invalid userId — user not found' });

    // Validate order
    const orderExists = await Order.findOne({ orderId, userId });
    if (!orderExists) return res.status(404).json({ message: 'Invalid orderId — order not found' });

    const newStatus = new OrderStatus({
      userId,
      orderId,
      orderStatus,
      orderStatusDate: new Date(),
    });
    await newStatus.save();

    res.status(201).json({ message: 'Order status added successfully', data: newStatus });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding order status', error: error.message });
  }
});


//MARK:- Get Orders GET API --------------------------------------------------->
router.get('/orders', async (req, res) => {
  try {
    const { userId, page = 1, limit = 10 } = req.query;

    if (!userId)
      return res.status(400).json({ message: 'userId is required' });

    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    const skip = (page - 1) * limit;

    // ✅ Sort by orderDate (latest first)
    const orders = await Order.find({ userId })
      .sort({ orderDate: -1 })
      .skip(parseInt(skip))
      .limit(parseInt(limit));

    if (!orders.length)
      return res.status(200).json({
        message: 'No orders found for this user',
        total: 0,
        page: Number(page),
        limit: Number(limit),
        data: [],
      });

    // Extract all unique IDs
    const orderIds = [...new Set(orders.map(o => o.orderId))];
    const productIds = orders.map(o => o.productId);

    // Fetch related data
    const [products, statuses] = await Promise.all([
      Product.find({ productId: { $in: productIds } }),
      OrderStatus.find({ orderId: { $in: orderIds } }),
    ]);

    // ✅ Group and structure order data
    const groupedOrders = orderIds.map(orderId => {
      const relatedOrders = orders.filter(o => o.orderId === orderId);
      const relatedStatus = statuses.filter(s => s.orderId === orderId);

      const orderDetails = relatedOrders.map(o => ({
        productId: o.productId,
        productCount: o.productCount,
        totalPrice: o.totalPrice,
        productDetails: products.find(p => p.productId === o.productId) || null,
      }));

      const orderTotalAmount = orderDetails.reduce(
        (sum, item) => sum + (item.totalPrice || 0),
        0
      );

      return {
        orderId,
        userId,
        orderDate: relatedOrders[0].orderDate,
        deliveryDate: relatedOrders[0].deliveryDate,
        currentOrderStatus: relatedOrders[0].currentOrderStatus,
        currentOrderStatusDate: relatedOrders[0].currentOrderStatusDate,
        orderTotalAmount,
        orderDetails,
        orderTracking: relatedStatus.map(s => ({
          orderStatus: s.orderStatus,
          orderStatusDate: s.orderStatusDate,
        })),
      };
    });

    // ✅ Ensure latest first (safety sort)
    groupedOrders.sort((a, b) => new Date(b.orderDate) - new Date(a.orderDate));

    const total = await Order.countDocuments({ userId });

    res.status(200).json({
      message: 'Orders fetched successfully',
      total,
      page: Number(page),
      limit: Number(limit),
      data: groupedOrders,
    });

  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      message: 'Error fetching orders',
      error: error.message,
    });
  }
});



//MARK:- Update Delivery Date PUT API --------------------------------------------------->
router.put('/orders/delivery-date', async (req, res) => {
  try {
    const { userId, orderId, deliveryDate } = req.body;

    if (!userId || !orderId || !deliveryDate)
      return res.status(400).json({ message: 'userId, orderId, and deliveryDate are required' });

    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user) return res.status(404).json({ message: 'Invalid userId — user not found' });

    const updated = await Order.updateMany(
      { userId, orderId },
      { deliveryDate }
    );

    if (updated.modifiedCount === 0)
      return res.status(404).json({ message: 'Order not found' });

    res.json({ message: 'Delivery date updated successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error updating delivery date', error: error.message });
  }
});


//MARK:- Update Current Order Status PUT API --------------------------------------------------->
router.put('/orders/status', async (req, res) => {
  try {
    const { userId, orderId, currentOrderStatus } = req.body;

    if (!userId || !orderId || currentOrderStatus === undefined)
      return res.status(400).json({ message: 'userId, orderId, and currentOrderStatus are required' });

    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user) return res.status(404).json({ message: 'Invalid userId — user not found' });

    const order = await Order.findOne({ orderId, userId });
    if (!order) return res.status(404).json({ message: 'Invalid orderId — order not found' });

    const now = new Date();

    await Order.updateMany(
      { userId, orderId },
      { currentOrderStatus, currentOrderStatusDate: now }
    );

    const newStatus = new OrderStatus({
      userId,
      orderId,
      orderStatus: currentOrderStatus,
      orderStatusDate: now,
    });
    await newStatus.save();

    res.json({
      message: 'Order status updated successfully',
      data: newStatus
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error updating order status', error: error.message });
  }
});


//MARK:- Cancel Order DELETE API --------------------------------------------------->
router.delete('/orders', async (req, res) => {
  try {
    const { userId, orderId } = req.body;

    if (!userId || !orderId)
      return res.status(400).json({ message: 'userId and orderId are required' });

    // ✅ Validate user
    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    // ✅ Check if order exists
    const orderExists = await Order.findOne({ userId, orderId });
    if (!orderExists)
      return res.status(404).json({ message: 'Order not found or already cancelled' });

    // ✅ Delete all products in that order
    const deleteResult = await Order.deleteMany({ userId, orderId });

    // ✅ Log cancelled status (e.g., orderStatus = 5 = Cancelled)
    const cancelStatus = new OrderStatus({
      userId,
      orderId,
      orderStatus: 5, // You can define your own enum: 5 = Cancelled
      orderStatusDate: new Date(),
    });
    await cancelStatus.save();

    res.status(200).json({
      message: 'Order cancelled successfully',
      deletedCount: deleteResult.deletedCount,
      orderStatus: cancelStatus,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      message: 'Error cancelling order',
      error: error.message,
    });
  }
});


module.exports = router;
