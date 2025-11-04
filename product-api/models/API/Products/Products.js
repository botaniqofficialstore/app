// models/API/Products/Products.js
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Cart = require('../../Tables/Cart');
const Product = require('../../Tables/Product');
const Wishlist = require('../../Tables/Wishlist');
const UserProfile = require('../../Tables/UserProfile');

// Ensure uploads folder exists
const uploadDir = path.join(__dirname, '../../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer storage setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname))
});
const upload = multer({ storage });


//MARK:- Create Product POST API --------------------------------------------------->
router.post('/product', upload.fields([
  { name: 'image', maxCount: 1 },
  { name: 'coverImage', maxCount: 1 }
]), async (req, res) => {
  try {
    const { productId, productName, productPrice, productSellingPrice, gram } = req.body;

    const image = req.files?.image?.[0] ? `/uploads/${path.basename(req.files.image[0].path)}` : null;
    const coverImage = req.files?.coverImage?.[0] ? `/uploads/${path.basename(req.files.coverImage[0].path)}` : null;

    const product = new Product({
      productId,
      productName,
      productPrice,
      productSellingPrice,
      gram,
      image,
      coverImage
    });

    await product.save();

    res.status(201).json({
      message: 'Product added successfully',
      data: product
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error adding product', error: error.message });
  }
});

//MARK:- GET ALL PRODUCTS GET API (with pagination) --------------------------------------------------->
/*router.get('/product', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const products = await Product.find().skip(skip).limit(limit);
    const total = await Product.countDocuments();

    res.json({
      totalItems: total,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      data: products
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching products', error: error.message });
  }
});*/

//MARK:- GET ALL PRODUCTS GET API (with pagination + wishlist check) --------------------------------------------------->
router.get('/product', async (req, res) => {
  try {
    const userId = req.query.userId?.toString(); // optional userId from query
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Initialize empty arrays
    let wishlistProductIds = [];
    let cartProductIds = [];

    // If userId provided, validate and fetch related data
    if (userId) {
      const user = await UserProfile.findOne({ userId: String(userId) });
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      // ✅ Fetch wishlist items
      const wishlistItems = await Wishlist.find({ userId }).select('productId -_id');
      wishlistProductIds = wishlistItems.map(item => item.productId);

      // ✅ Fetch cart items
      const cartItems = await Cart.find({ userId }).select('productId -_id');
      cartProductIds = cartItems.map(item => item.productId);
    }

    // Fetch products with pagination
    const products = await Product.find().skip(skip).limit(limit);
    const total = await Product.countDocuments();

    // Append isWishlisted & inCart flags
    const updatedProducts = products.map(product => ({
      ...product._doc,
      isWishlisted: (userId && wishlistProductIds.includes(product.productId)) ? 1 : 0,
      inCart: (userId && cartProductIds.includes(product.productId)) ? 1 : 0, // ✅ new field
    }));

    res.json({
      totalItems: total,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      data: updatedProducts
    });

  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ message: 'Error fetching products', error: error.message });
  }
});


//MARK:- Update Product PUT API --------------------------------------------------->
router.put('/product/:id', upload.fields([
  { name: 'image', maxCount: 1 },
  { name: 'coverImage', maxCount: 1 }
]), async (req, res) => {
  try {
    const { id } = req.params;

    // 🔍 Find product by _id
    const product = await Product.findById(id);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    // 🗑️ Delete old images if new ones uploaded
    if (req.files['image'] && product.image) {
      const oldImagePath = path.join(__dirname, '../../../', product.image);
      fs.unlink(oldImagePath, err => {
        if (err) console.error('Error deleting old image:', err);
      });
    }

    if (req.files['coverImage'] && product.coverImage) {
      const oldCoverImagePath = path.join(__dirname, '../../../', product.coverImage);
      fs.unlink(oldCoverImagePath, err => {
        if (err) console.error('Error deleting old cover image:', err);
      });
    }

    //  Update product fields (only provided ones)
    if (req.body.productId) product.productId = req.body.productId;
    if (req.body.productName) product.productName = req.body.productName;
    if (req.body.productPrice) product.productPrice = req.body.productPrice;
    if (req.body.productSellingPrice) product.productSellingPrice = req.body.productSellingPrice;
    if (req.body.gram) product.gram = req.body.gram;

    if (req.files['image']) {
      product.image = `/uploads/${path.basename(req.files['image'][0].path)}`;
    }

    if (req.files['coverImage']) {
      product.coverImage = `/uploads/${path.basename(req.files['coverImage'][0].path)}`;
    }

    await product.save();

    res.status(200).json({
      message: 'Product updated successfully',
      data: product
    });
  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({
      message: 'Error updating product',
      error: error.message
    });
  }
});

//MARK:- Delete Product PUT API --------------------------------------------------->
router.delete('/product:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    const deleted = await Product.findOneAndDelete({ productId });

    if (!deleted) return res.status(404).json({ message: 'Product not found' });

    if (deleted.image) {
      fs.unlink(path.join(__dirname, '../../../', deleted.image), err => {
        if (err) console.error('Error deleting product image:', err);
      });
    }

    if (deleted.coverImage) {
      fs.unlink(path.join(__dirname, '../../../', deleted.coverImage), err => {
        if (err) console.error('Error deleting cover image:', err);
      });
    }

    res.json({ message: 'Product and images deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error deleting product', error: error.message });
  }
});

module.exports = router;
