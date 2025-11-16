const express = require('express');
const UserProfile = require('../../Tables/UserProfile');
const { generateOTP } = require('../../../utils/otp');
const router = express.Router();
const LoginActivity = require('../../Tables/LoginActivity');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../../../utils/jwt');
const { sendEmailOTP, sendSMSOTP } = require('../../../utils/notification');
const NotificationToken = require('../../Tables/NotificationToken');



//MARK:- Send OTP (Step 1)
router.post('/send-otp', async (req, res) => {
  try {
    const { emailOrMobile } = req.body;
    if (!emailOrMobile)
      return res.status(400).json({ message: 'Email or mobile number is required' });

    const user = await UserProfile.findOne({
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }]
    });

    // ✅ FIXED: Remove the password check
    if (!user)
      return res.status(400).json({ message: 'User not found' });

    // Generate new OTP
    const { otp, expiresAt } = generateOTP();

    // Store OTP
    user.otp = {
      code: otp,
      expiresAt,
    };

    await user.save();

    // Send OTP
    if (user.email) await sendEmailOTP(user.email, otp);
    else if (user.mobileNumber) await sendSMSOTP(user.mobileNumber, otp);

    console.log(`[OTP SENT] ${emailOrMobile} → ${otp}`);

    res.json({ message: 'OTP sent successfully' });
  } catch (error) {
    console.error('Send OTP Error:', error);
    res.status(500).json({ message: error.message });
  }
});



//MARK:- Verify OTP (Step 2)
router.post('/verify-otp', async (req, res) => {
  try {
    const { emailOrMobile, otp, deviceId, appVersion } = req.body;
    if (!emailOrMobile || !otp) {
      return res.status(400).json({ message: 'Email/mobile and OTP are required' });
    }

    const user = await UserProfile.findOne({
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }],
    });

    if (!user || !user.otp?.code)
      return res.status(400).json({ message: 'OTP not found or expired' });

    console.log(`[VERIFY TRY] input=${otp}, saved=${user.otp.code}`);

    // Check expiry
    if (new Date() > new Date(user.otp.expiresAt))
      return res.status(400).json({ message: 'OTP expired. Please resend.' });

    // Check code
    if (String(user.otp.code) !== String(otp))
      return res.status(400).json({ message: 'Invalid OTP' });

    // OTP is valid → clear it
    user.otp = null;
    await user.save();

    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    // Save login activity
    const loginActivity = new LoginActivity({
      userId: user.userId,
      loginType: 'otp',
      deviceId: deviceId || 'unknown',
      appVersion: appVersion || '1.0',
      activeStatus: 0,
    });
    await loginActivity.save();

    res.json({
      message: 'Login successful',
      userId: user.userId,
      accessToken,
      refreshToken,
      loginActivityId: loginActivity._id,
    });

  } catch (error) {
    console.error('Verify OTP Error:', error);
    res.status(500).json({ message: error.message });
  }
});


//MARK:- Resend OTP (Step 3)
router.post('/resend-otp', async (req, res) => {
  try {
    const { emailOrMobile } = req.body;
    if (!emailOrMobile) return res.status(400).json({ message: 'Email or mobile number is required' });

    const user = await UserProfile.findOne({
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }],
    });

    if (!user) return res.status(404).json({ message: 'User not found' });

    // Generate new OTP
    const { otp, expiresAt } = generateOTP();

    // Replace old OTP
    user.otp = { code: otp, expiresAt };
    await user.save();

    // Send new OTP
    if (user.email) await sendEmailOTP(user.email, otp);
    else if (user.mobileNumber) await sendSMSOTP(user.mobileNumber, otp);

    console.log(`[OTP RESENT] ${emailOrMobile} → ${otp}`);

    res.json({ message: 'OTP resent successfully' });
  } catch (error) {
    console.error('Resend OTP Error:', error);
    res.status(500).json({ message: error.message });
  }
});


//MARK:- Social login (Google/Facebook) ------------------------------------->
// NOTE: You usually verify token from Google/Facebook SDK and then create/find user
router.post('/social-login', async (req, res) => {
  try {
    const { email, firstName, lastName, provider, deviceId, appVersion } = req.body;

    if (!email || !provider) {
      return res.status(400).json({ message: 'Email and provider are required' });
    }

    // Find or create user
    let user = await UserProfile.findOne({ email });

    if (!user) {
      user = new UserProfile({
        userId: `user-${Date.now()}`,
        email,
        firstName,
        lastName,
        mobileNumber: undefined, // VERY IMPORTANT → avoid null duplicate issue
      });

      await user.save();
    }

    // Save login activity
    const loginActivity = new LoginActivity({
      userId: user.userId,
      loginType: provider, 
      deviceId: deviceId || 'unknown',
      appVersion: appVersion || '1.0',
      activeStatus: 0
    });

    await loginActivity.save();

    // Generate tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.json({
      message: 'Login successful',
      userId: user.userId,
      accessToken,
      refreshToken,
      loginActivityId: loginActivity._id
    });

  } catch (error) {
    console.error("Social Login Error:", error);
    res.status(500).json({ message: error.message });
  }
});



//MARK:- Logout API (Now also unregisters device) ------------------------------------->
router.post('/logout', async (req, res) => {
  try {
    const { userId, loginActivityId, fcmToken } = req.body;

    if (!userId || !loginActivityId)
      return res.status(400).json({ message: 'userId and loginActivityId are required' });

    // Validate user
    const user = await UserProfile.findOne({ userId });
    if (!user)
      return res.status(404).json({ message: 'Invalid userId — user not found' });

    // Validate login activity
    const loginActivity = await LoginActivity.findOne({ _id: loginActivityId, userId });
    if (!loginActivity)
      return res.status(404).json({ message: 'Login session not found' });

    // ✅ 1. Update logout details
    loginActivity.logoutDate = new Date();
    loginActivity.activeStatus = 1; // inactive
    await loginActivity.save();

    // ✅ 2. Unregister FCM token if provided
    if (fcmToken) {
      const deleted = await NotificationToken.deleteMany({ userId, fcmToken });
      console.log(`🗑️ ${deleted.deletedCount} token(s) removed for ${userId}`);
    } else {
      console.log('⚠️ No fcmToken provided — skipping FCM token removal');
    }

    res.json({
      message: 'Logout successful',
    });

  } catch (error) {
    console.error('Logout Error:', error);
    res.status(500).json({ message: error.message });
  }
});




//MARK:- Refresh Token API ------------------------------------->
router.post('/refresh-token', async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) return res.status(401).json({ message: 'Refresh token missing' });

  try {
    const decoded = verifyRefreshToken(refreshToken); // ✅ same secret

    const user = await UserProfile.findOne({ userId: decoded.userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const newAccessToken = generateAccessToken(user);

    res.json({
      message: 'New access token generated',
      accessToken: newAccessToken,
    });
  } catch (error) {
    console.error('Refresh token error:', error.message);
    res.status(403).json({ message: 'Invalid or expired refresh token' });
  }
});




module.exports = router;
