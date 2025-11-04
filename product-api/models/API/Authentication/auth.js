const express = require('express');
const bcrypt = require('bcrypt');
const UserProfile = require('../../Tables/UserProfile');
const { generateOTP } = require('../../../utils/otp');
const router = express.Router();
const nodemailer = require('nodemailer');
const LoginActivity = require('../../Tables/LoginActivity');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../../../utils/jwt');


// Transporter for sending OTP emails
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

//MARK:- Login with email/mobile & password ------------------------------------->
router.post('/login', async (req, res) => {
  try {
    const { emailOrMobile, password, deviceId, appVersion } = req.body;

    const user = await UserProfile.findOne({ 
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }] 
    });

    if (!user || !user.password)
      return res.status(400).json({ message: 'User not found or password not set' });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(400).json({ message: 'Invalid password' });

    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    // Save login activity
    const loginActivity = new LoginActivity({
      userId: user.userId,
      loginType: 'manual',
      deviceId: deviceId || 'unknown',
      appVersion: appVersion || '1.0',
      activeStatus: 0
    });
    await loginActivity.save();

    res.json({
      message: 'Login successful',
      userId: user.userId,
      accessToken,
      refreshToken,
      loginActivityId: loginActivity._id
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


//MARK:- Create password for new login ------------------------------------->
router.post('/create-password', async (req, res) => {
  try {
    const { userId, password } = req.body;

    // ✅ Validate input
    if (!userId || !password) {
      return res.status(400).json({ message: 'userId and password are required' });
    }

    // ✅ Find user by userId
    const user = await UserProfile.findOne({ userId });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // ✅ Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // ✅ Update user record
    user.password = hashedPassword;
    await user.save();

    res.json({ message: 'Password created successfully' });

  } catch (error) {
    console.error('Error creating password:', error);
    res.status(500).json({ message: error.message });
  }
});



//MARK:- Update password ------------------------------------->
router.post('/update-password', async (req, res) => {
  try {
    const { emailOrMobile, newPassword } = req.body;
    const user = await UserProfile.findOne({ 
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }] 
    });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    await user.save();

    res.json({ message: 'Password updated successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


//MARK:- Send OTP ------------------------------------->
router.post('/send-otp', async (req, res) => {
  try {
    const { emailOrMobile } = req.body;
    const user = await UserProfile.findOne({ 
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }] 
    });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const { otp, expiresAt } = generateOTP();
    user.otp = { code: otp, expiresAt };
    await user.save();

    // Send OTP via email
    if (user.email) {
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: 'Your OTP Code',
        text: `Your OTP code is ${otp}. It will expire in 5 minutes.`
      });
    }

    res.json({ message: 'OTP sent successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


//MARK:- Resend OTP ------------------------------------->
router.post('/resend-otp', async (req, res) => {
  try {
    const { emailOrMobile } = req.body;
    const user = await UserProfile.findOne({ 
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }] 
    });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const { otp, expiresAt } = generateOTP();
    user.otp = { code: otp, expiresAt };
    await user.save();

    // Send OTP via email
    if (user.email) {
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: 'Your OTP Code',
        text: `Your OTP code is ${otp}. It will expire in 5 minutes.`
      });
    }

    res.json({ message: 'OTP resent successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


//MARK:- Social login (Google/Facebook) ------------------------------------->
// NOTE: You usually verify token from Google/Facebook SDK and then create/find user
router.post('/social-login', async (req, res) => {
  try {
    const { email, firstName, lastName, provider } = req.body; // provider = google/facebook

    let user = await UserProfile.findOne({ email });
    if (!user) {
      user = new UserProfile({ userId: `user-${Date.now()}`, email, firstName, lastName });
      await user.save();
    }

    // Save login activity for social login
  const loginActivity = new LoginActivity({
    userId: user.userId,
    loginType: provider, // 'google' or 'facebook'
    deviceId: req.body.deviceId || 'unknown',
    appVersion: req.body.appVersion || '1.0',
    activeStatus: 0
  });

  await loginActivity.save();
  const token = generateToken(user);

   res.json({
     message: 'Login successful',
     userId: user.userId,
     token,
     loginActivityId: loginActivity._id
    });

    
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
  });


//MARK:- VERIFY OTP API
router.post('/verify-otp', async (req, res) => {
  try {
    const { emailOrMobile, otp } = req.body;

    // 1️⃣ Find user by email or mobile number
    const user = await UserProfile.findOne({
      $or: [{ email: emailOrMobile }, { mobileNumber: emailOrMobile }]
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // 2️⃣ Ensure OTP exists
    if (!user.otp || !user.otp.code || !user.otp.expiresAt) {
      return res.status(400).json({ message: 'OTP not generated or expired' });
    }

    // 3️⃣ Check expiry
    const now = new Date();
    if (now > new Date(user.otp.expiresAt)) {
      return res.status(400).json({ message: 'OTP expired. Please resend.' });
    }

    // 4️⃣ Compare OTP
    if (user.otp.code !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    // 5️⃣ Mark OTP as verified (or clear it)
    user.otp = null;
    user.isOtpVerified = true; // optional flag
    await user.save();

    return res.json({ message: 'OTP verified successfully', verified: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});


//MARK:- Logout API ------------------------------------->
router.post('/logout', async (req, res) => {
  try {
    const { userId, loginActivityId } = req.body;

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

    // Update logout date and status
    loginActivity.logoutDate = new Date();
    loginActivity.activeStatus = 1; // inactive
    await loginActivity.save();

    res.json({ message: 'Logout successful', data: loginActivity });
  } catch (error) {
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
