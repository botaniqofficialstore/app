const express = require('express');
const admin = require('firebase-admin');
const NotificationToken = require('../../Tables/NotificationToken');
const UserProfile = require('../../Tables/UserProfile');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// ✅ Ensure adImage folder exists
const adImageDir = path.join(__dirname, '../../../uploads/adImage');
if (!fs.existsSync(adImageDir)) {
  fs.mkdirSync(adImageDir, { recursive: true });
  console.log('✅ adImage folder created');
}

// ✅ Multer storage setup for adImage
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, adImageDir),
  filename: (req, file, cb) => cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

/* -------------------------------------------------------------------------- */
/* 🔹 Device Register API */
/* -------------------------------------------------------------------------- */
router.post('/notifications/register', async (req, res) => {
  try {
    const { userId, deviceType, fcmToken } = req.body;

    if (!userId || !deviceType || !fcmToken)
      return res.status(400).json({ message: 'userId, deviceType, and fcmToken are required' });

    const user = await UserProfile.findOne({ userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const token = await NotificationToken.findOneAndUpdate(
      { userId, deviceType, fcmToken },
      { userId, deviceType, fcmToken },
      { new: true, upsert: true }
    );

    res.json({ message: 'Device registered successfully', data: token });
  } catch (error) {
    res.status(500).json({ message: 'Error registering device', error: error.message });
  }
});

/* -------------------------------------------------------------------------- */
/* 🔹 Device Unregister API */
/* -------------------------------------------------------------------------- */
router.delete('/notifications/unregister', async (req, res) => {
  try {
    const { userId, fcmToken } = req.body;

    if (!userId)
      return res.status(400).json({ message: 'userId is required' });

    const user = await UserProfile.findOne({ userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const query = fcmToken ? { userId, fcmToken } : { userId };
    const deleted = await NotificationToken.deleteMany(query);

    if (deleted.deletedCount > 0) {
      res.json({ message: 'Device token(s) deleted successfully' });
    } else {
      res.status(404).json({ message: 'No matching tokens found' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error deleting device token', error: error.message });
  }
});

/* -------------------------------------------------------------------------- */
/* 🔹 Send Push Notification (Single User) */
/* -------------------------------------------------------------------------- */
router.post('/notifications/send', async (req, res) => {
  try {
    const { userId, title, body } = req.body;

    if (!userId || !title || !body)
      return res.status(400).json({ message: 'userId, title, and body are required' });

    const user = await UserProfile.findOne({ userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const tokens = await NotificationToken.find({ userId });
    if (!tokens.length)
      return res.status(404).json({ message: 'No tokens found for this user' });

    const payload = {
      notification: { title, body },
      android: { notification: { sound: 'default' } },
      apns: { payload: { aps: { sound: 'default' } } },
    };

    const responses = [];
    for (const tokenData of tokens) {
      const response = await admin.messaging().send({
        token: tokenData.fcmToken,
        ...payload,
      });
      responses.push(response);
    }

    res.json({ message: 'Notification sent successfully', responses });
  } catch (error) {
    res.status(500).json({ message: 'Error sending notification', error: error.message });
  }
});

/* -------------------------------------------------------------------------- */
/* 🔹 Send Advertisement Notification (All Users — auto-expanded image) */
/* -------------------------------------------------------------------------- */
router.post('/notifications/advertisement', upload.single('image'), async (req, res) => {
  try {
    const { title, body } = req.body;
    const file = req.file;

    if (!title || !body)
      return res.status(400).json({ message: 'title and body are required' });
    if (!file)
      return res.status(400).json({ message: 'Image file is required' });

    
    const imageUrl = `/uploads/adImage/${file.filename}`;

    const tokens = await NotificationToken.find({});
    if (!tokens.length)
      return res.status(404).json({ message: 'No registered devices found' });

    const payload = {
      notification: {
        title,
        body,
        image: imageUrl, // ✅ FCM native image field (auto-expanded on Android)
      },
      android: {
        notification: {
          sound: 'default',
          image: imageUrl,
          priority: 'high',
        },
      },
      apns: {
        payload: { aps: { sound: 'default' } },
        fcm_options: { image: imageUrl },
      },
      data: {
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        type: 'advertisement',
      },
    };

    const responses = [];
    for (const tokenData of tokens) {
      try {
        const response = await admin.messaging().send({
          token: tokenData.fcmToken,
          ...payload,
        });
        responses.push(response);
      } catch (err) {
        console.error(`❌ Failed for token ${tokenData.fcmToken}: ${err.message}`);
      }
    }

    res.json({
      message: '✅ Advertisement notification sent successfully',
      totalUsers: tokens.length,
      successCount: responses.length,
      imageUrl,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error sending advertisement', error: error.message });
  }
});

module.exports = router;
