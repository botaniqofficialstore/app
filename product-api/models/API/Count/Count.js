// MARK:- Get Cart & Wishlist count ----------------------------------------->
const express = require('express');
const router = express.Router();
const Cart = require('../../Tables/Cart');
const Wishlist = require('../../Tables/Wishlist');


//MARK:- Count GET API --------------------------------------------------->
router.get('/count', async (req, res) => {
  try {
    const { userId } = req.query; // or req.body if you prefer POST

    if (!userId) {
      return res.status(400).json({ message: 'userId is required' });
    }

    // Count items in Cart and Wishlist
    const [cartCount, wishlistCount] = await Promise.all([
      Cart.countDocuments({ userId }),
      Wishlist.countDocuments({ userId })
    ]);

    // Total count
    const totalCount = cartCount + wishlistCount;

    res.status(200).json({
      message: 'Count fetched successfully',
      cartCount,
      wishlistCount,
      totalCount
    });

  } catch (error) {
    console.error('Error fetching count:', error);
    res.status(500).json({ message: 'Error fetching count', error: error.message });
  }
});

module.exports = router;
