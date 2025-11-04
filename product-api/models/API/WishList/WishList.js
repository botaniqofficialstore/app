// models/API/Products/WishList.js

const mongoose = require('mongoose');
const express = require('express');
const router = express.Router();

// Import models
const UserProfile = require('../../Tables/UserProfile');
const Product = require('../../Tables/Product');
const Wishlist = require('../../Tables/Wishlist');
const Cart = require('../../Tables/Cart');



//MARK:- Add to Wishlist POST API --------------------------------------------------->
router.post('/wishlist', async (req, res) => {
  try {
    const { userId, productId } = req.body;

    if (!userId || !productId)
      return res.status(400).json({ message: 'userId and productId are required' });

    // Check if User exists
    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    // Check if Product exists
    const product = await Product.findOne({ productId: String(productId) });
    if (!product)
      return res.status(404).json({ message: 'Invalid productId — product not found' });

    // Prevent duplicate wishlist entry
    const existing = await Wishlist.findOne({ userId, productId });
    if (existing)
      return res.status(400).json({ message: 'Product already added to wishlist' });

    // Save new wishlist entry
    const wishlist = new Wishlist({ userId, productId });
    await wishlist.save();

    res.status(201).json({
      message: 'Product added to wishlist successfully',
      data: wishlist
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding product to wishlist', error: error.message });
  }
});


//MARK:- Remove from Wishlist DELETE API --------------------------------------------------->
router.delete('/wishlist', async (req, res) => {
  try {
    const { userId, productId } = req.body;

    if (!userId || !productId)
      return res.status(400).json({ message: 'userId and productId are required' });

    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    const deleted = await Wishlist.findOneAndDelete({ userId, productId });
    if (!deleted)
      return res.status(404).json({ message: 'Product not found in wishlist' });

    res.json({ message: 'Product removed from wishlist successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error removing wishlist item', error: error.message });
  }
});


// MARK:- Get Wishlist GET API --------------------------------------------------->
router.get('/wishlist', async (req, res) => {
  try {
    const { userId, page = 1, limit = 10 } = req.query;

    if (!userId)
      return res.status(400).json({ message: 'userId is required' });

    // ✅ Verify user
    const user = await UserProfile.findOne({ userId: String(userId) });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    const skip = (page - 1) * limit;

    // ✅ Get wishlist items
    const wishlistItems = await Wishlist.find({ userId })
      .skip(parseInt(skip))
      .limit(parseInt(limit));

    const productIds = wishlistItems.map(item => item.productId);

    // ✅ Fetch product details and user's cart items
    const [products, cartItems] = await Promise.all([
      Product.find({ productId: { $in: productIds } }),
      mongoose.model('Cart').find({ userId }) // Import Cart model once at top of file
    ]);

    // ✅ Prepare response
    const combined = wishlistItems.map(item => {
      const product = products.find(p => p.productId === item.productId);
      const isInCart = cartItems.some(c => c.productId === item.productId);

      return {
        userId: item.userId,
        productId: item.productId,
        addedAt: item.createdAt,
        inCart: isInCart ? 1 : 0, // ✅ 1 if in cart, else 0
        productDetails: product || null
      };
    });

    const total = await Wishlist.countDocuments({ userId });

    res.json({
      message: 'Wishlist fetched successfully',
      total,
      page: Number(page),
      limit: Number(limit),
      data: combined
    });
  } catch (error) {
    console.error('Error fetching wishlist:', error);
    res.status(500).json({ message: 'Error fetching wishlist', error: error.message });
  }
});


module.exports = router;
