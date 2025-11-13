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
const reelsRoutes = require('./models/API/Reels/Reels');

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

// ✅ Ensure both uploads and adImage folders exist
const uploadsDir = path.join(__dirname, 'uploads');
const adImageDir = path.join(uploadsDir, 'adImage');

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
  console.log('✅ Uploads folder created');
}

if (!fs.existsSync(adImageDir)) {
  fs.mkdirSync(adImageDir, { recursive: true });
  console.log('✅ adImage folder created');
}

// ✅ Serve uploads and adImage publicly
app.use('/uploads', express.static(uploadsDir));

/* ---------------------------------------- API Routes ----------------------------------------------------------- */
app.use('/api', authRoutes);
app.use('/api', productsRoutes);
app.use('/api', productDetailsRoutes);
app.use('/api', customerRoutes);
app.use('/api', wishListRoutes);
app.use('/api', cartRoutes);
app.use('/api', orderRoutes);
app.use('/api', notificationRoutes);
app.use('/api', countRoutes);
app.use('/api', reelsRoutes);

/* ---------------------------------------- MongoDB Connection ----------------------------------------------------------- */
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected successfully'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

/* ---------------------------------------- Firebase Initialization ----------------------------------------------------------- */
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

/* ---------------------------------------- Root Route ----------------------------------------------------------- */
app.get('/', (req, res) => {
  res.send('✅ BotaniQ backend is running!');
});

/* ---------------------------------------- Server Start ----------------------------------------------------------- */
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`🚀 Server running on port ${PORT}`));
