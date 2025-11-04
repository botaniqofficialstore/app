// models/API/Products/Cart.js

const express = require('express');
const router = express.Router();
const UserProfile = require('../../Tables/UserProfile');
const Product = require('../../Tables/Product');
const Cart = require('../../Tables/Cart');



//MARK:- Add to Cart POST API --------------------------------------------------->
router.post('/cart', async (req, res) => {
  try {
    const { userId, productId, productCount = 1 } = req.body;

    if (!userId || !productId)
      return res.status(400).json({ message: 'userId and productId are required' });

    // Validate User
    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    // Validate Product
    const product = await Product.findOne({ productId: String(productId) });
    if (!product)
      return res.status(404).json({ message: 'Invalid productId — product not found' });

    // Check for duplicate
    const existing = await Cart.findOne({ userId, productId });
    if (existing)
      return res.status(400).json({ message: 'Product already exists in cart' });

    // Save new cart entry
    const cartItem = new Cart({ userId, productId, productCount });
    await cartItem.save();

    res.status(201).json({ message: 'Product added to cart successfully', data: cartItem });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding product to cart', error: error.message });
  }
});


//MARK:- Remove From Cart DELETE API --------------------------------------------------->
router.delete('/cart', async (req, res) => {
  try {
    const { userId, productId } = req.body;

    if (!userId || !productId)
      return res.status(400).json({ message: 'userId and productId are required' });

    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    const deleted = await Cart.findOneAndDelete({ userId, productId });
    if (!deleted)
      return res.status(404).json({ message: 'Product not found in cart' });

    res.json({ message: 'Product removed from cart successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error removing cart item', error: error.message });
  }
});


//MARK:- Get Cart List GET API --------------------------------------------------->
router.get('/cart', async (req, res) => {
  try {
    const { userId, page = 1, limit = 10 } = req.query;

    if (!userId)
      return res.status(400).json({ message: 'userId is required' });

    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    const skip = (page - 1) * limit;
    const cartItems = await Cart.find({ userId })
      .skip(parseInt(skip))
      .limit(parseInt(limit));

    const productIds = cartItems.map(item => item.productId);
    const products = await Product.find({ productId: { $in: productIds } });

    const combined = cartItems.map(item => {
      const product = products.find(p => p.productId === item.productId);
      return {
        userId: item.userId,
        productId: item.productId,
        productCount: item.productCount,
        addedAt: item.createdAt,
        productDetails: product || null
      };
    });

    const total = await Cart.countDocuments({ userId });

    res.json({
      message: 'Cart fetched successfully',
      total,
      page: Number(page),
      limit: Number(limit),
      data: combined
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching cart', error: error.message });
  }
});


//MARK:- Update Product Count in Cart PUT API --------------------------------------------------->
router.put('/cart', async (req, res) => {
  try {
    const { userId, productId, productCount } = req.body;

    if (!userId || !productId || productCount === undefined)
      return res.status(400).json({ message: 'userId, productId, and productCount are required' });

    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    const product = await Product.findOne({ productId: String(productId) });
    if (!product)
      return res.status(404).json({ message: 'Invalid productId — product not found' });

    const updated = await Cart.findOneAndUpdate(
      { userId, productId },
      { productCount },
      { new: true }
    );

    if (!updated)
      return res.status(404).json({ message: 'Product not found in cart' });

    res.json({ message: 'Cart item updated successfully', data: updated });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error updating cart item', error: error.message });
  }
});

module.exports = router;
