// Load required modules
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const fs = require('fs');
const admin = require('firebase-admin');


/* ---------------------------------------- Import API Class ----------------------------------------------------------- */
const authRoutes = require('./models/API/Authentication/auth');
const productsRoutes = require('./models/API/Products/Products');
const customerRoutes = require('./models/API/Customer/Customer');
const productDetailsRoutes = require('./models/API/ProductDetails/ProductDetails');
const wishListRoutes = require('./models/API/WishList/WishList');
const cartRoutes = require('./models/API/Cart/Cart');
const orderRoutes = require('./models/API/Orders/Orders');
const notificationRoutes = require('./models/API/Notification/Notification');
const countRoutes = require('./models/API/Count/Count');


// Load the Service Account key
const serviceAccount = JSON.parse(fs.readFileSync('./serviceAccountKey.json', 'utf-8'));

dotenv.config();
console.log('--- ENV CHECK ---');
console.log('EMAIL_USER:', process.env.EMAIL_USER);
console.log('EMAIL_PASS (Length):', process.env.EMAIL_PASS ? process.env.EMAIL_PASS.length : 'MISSING');
console.log('-----------------');
console.log("✅ ENV CHECK:", process.env.EMAIL_USER, process.env.EMAIL_PASS ? "PASS SET" : "PASS MISSING");
const app = express();
app.use(express.json());

// Ensure uploads folder exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log('✅ Uploads folder created');
}
app.use('/uploads', express.static(uploadDir));
app.use('/api', authRoutes);
app.use('/api', productsRoutes);
app.use('/api', productDetailsRoutes);
app.use('/api', customerRoutes);
app.use('/api', wishListRoutes);
app.use('/api', cartRoutes);
app.use('/api', orderRoutes);
app.use('/api', notificationRoutes);
app.use('/api', countRoutes);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected successfully'))
  .catch(err => console.error('❌ MongoDB connection error:', err));


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});


// <---------------------------------------------------------------------------------------------->

// Start server
const PORT = process.env.PORT || 5000;
//app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
app.get('/', (req, res) => {
  res.send('✅ BotaniQ backend is running!');
});

app.listen(PORT, '0.0.0.0', () => console.log(`🚀 Server running on port ${PORT}`));


