// models/API/Products/ProductDetails.js

const express = require('express');
const router = express.Router();

// Import models
const Product = require('../../Tables/Product');
const ProductDetails = require('../../Tables/ProductDetails');

//MARK:- Create Product Details POST API --------------------------------------------->
router.post('/product-details', async (req, res) => {
  try {
    const { productId, description, nutrients } = req.body;

    // Check if product exists in master
    const master = await Product.findOne({ productId: String(productId) });
    if (!master) {
      return res.status(400).json({ message: 'Invalid ProductID — not found in Product Master' });
    }

    // Prevent duplicates
    const existing = await ProductDetails.findOne({ productId: String(productId) });
    if (existing) {
      return res.status(400).json({ message: 'Product details already exist for this ProductID' });
    }

    const newDetails = new ProductDetails({
      productId: String(productId),
      description,
      nutrients
    });

    await newDetails.save();
    res.status(201).json({ message: 'Product details added successfully', data: newDetails });
  } catch (error) {
    res.status(500).json({ message: 'Error adding product details', error: error.message });
  }
});


//MARK:- Update Product Details PUT API --------------------------------------------->
router.put('/product-details/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    const { description, nutrients } = req.body;

    const master = await Product.findOne({ productId: String(productId) });
    if (!master) {
      return res.status(400).json({ message: 'Invalid ProductID — not found in Product Master' });
    }

    const updated = await ProductDetails.findOneAndUpdate(
      { productId: String(productId) },
      { description, nutrients },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ message: 'Product details not found' });
    }

    res.json({ message: 'Product details updated successfully', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'Error updating product details', error: error.message });
  }
});

//MARK:- Get Product Details GET API --------------------------------------------->
router.get('/product-details/:productId', async (req, res) => {
  try {
    const { productId } = req.params;

    const master = await Product.findOne({ productId: String(productId) });
    if (!master) {
      return res.status(404).json({ message: 'Invalid ProductID — not found in Product Master' });
    }

    const details = await ProductDetails.findOne({ productId: String(productId) });

    if (!details) {
      return res.status(404).json({
        message: 'Product details not found for this ProductID',
        product: {
          productId: master.productId,
          productName: master.productName,
          productPrice: master.productPrice,
          productSellingPrice: master.productSellingPrice,
          image: master.image,
          coverImage: master.coverImage
        }
      });
    }

    const result = {
      productId: master.productId,
      productName: master.productName,
      productPrice: master.productPrice,
      productSellingPrice: master.productSellingPrice,
      image: master.image,
      coverImage: master.coverImage,
      description: details.description,
      nutrients: details.nutrients
    };

    res.json({ message: 'Product details fetched successfully', data: result });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching product details', error: error.message });
  }
});

//MARK:- Delete Product Details DELETE API --------------------------------------------->
router.delete('/product-details/:productId', async (req, res) => {
  try {
    const { productId } = req.params;

    const master = await Product.findOne({ productId: String(productId) });
    if (!master) {
      return res.status(400).json({ message: 'Invalid ProductID — not found in Product Master' });
    }

    const deleted = await ProductDetails.findOneAndDelete({ productId: String(productId) });
    if (!deleted) {
      return res.status(404).json({ message: 'Product details not found' });
    }

    res.json({ message: 'Product details deleted successfully', data: deleted });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting product details', error: error.message });
  }
});

module.exports = router;
