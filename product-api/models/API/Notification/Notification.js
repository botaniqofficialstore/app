const express = require('express');
const admin = require('firebase-admin');
const NotificationToken = require('../../Tables/NotificationToken');
const UserProfile = require('../../Tables/UserProfile'); // 👈 added
const router = express.Router();

//MARK:- Device Register POST API ----------------------------------------------->
router.post('/notifications/register', async (req, res) => {
  try {
    const { userId, deviceType, fcmToken } = req.body;

    if (!userId || !deviceType || !fcmToken)
      return res.status(400).json({ message: 'userId, deviceType, and fcmToken are required' });

    // ✅ Check if user exists
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


//MARK:- Device Unregister DELETE API -------------------------------------------->
router.delete('/notifications/unregister', async (req, res) => {
  try {
    const { userId, fcmToken } = req.body;

    if (!userId)
      return res.status(400).json({ message: 'userId is required' });

    // ✅ Check if user exists
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


//MARK:- Send Push Notification POST API ----------------------------------------->
router.post('/notifications/send', async (req, res) => {
  try {
    const { userId, title, body } = req.body;

    if (!userId || !title || !body)
      return res.status(400).json({ message: 'userId, title, and body are required' });

    // ✅ Check if user exists
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

module.exports = router;
