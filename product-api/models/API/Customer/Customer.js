// models/API/Products/Customer.js

const express = require('express');
const router = express.Router();
const UserProfile = require('../../Tables/UserProfile');


//MARK:- Create User POST API --------------------------------------------------->
router.post('/users', async (req, res) => {
  try {
    const { firstName, lastName, email, mobileNumber, address } = req.body;

    // Check required fields
    if (!email || !mobileNumber) {
      return res.status(400).json({ message: 'Email and mobileNumber are required' });
    }

    // Check duplicates
    const existingUser = await UserProfile.findOne({
      $or: [
        { email },
        { mobileNumber }
      ]
    });

    if (existingUser) {
      let duplicateField = existingUser.email === email ? 'email' : 'mobileNumber';
      return res.status(400).json({
        message: `User with this ${duplicateField} already exists`
      });
    }

    // ✅ Generate userId in backend
    const userId = `USER-${Date.now()}`;

    // Create new user
    const newUser = new UserProfile({
      userId,
      firstName,
      lastName,
      email,
      mobileNumber,
      address
    });

    await newUser.save();

    res.status(201).json({
      message: 'User created successfully',
      data: newUser
    });

  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ message: 'Error creating user', error: error.message });
  }
});


//MARK:- UPDATE USER PUT API --------------------------------------------------->
router.put('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { email, mobileNumber } = req.body;

    const user = await UserProfile.findOne({ userId });
    if (!user) return res.status(404).json({ message: 'User not found' });

    if (email || mobileNumber) {
      const existingUser = await UserProfile.findOne({
        $or: [
          email ? { email } : null,
          mobileNumber ? { mobileNumber } : null
        ].filter(Boolean),
        userId: { $ne: userId } // exclude same user
      });

      if (existingUser) {
        const duplicateField = existingUser.email === email ? 'email' : 'mobileNumber';
        return res.status(400).json({
          message: `Another user with this ${duplicateField} already exists`
        });
      }
    }

    const updatedUser = await UserProfile.findOneAndUpdate(
      { userId },
      req.body,
      { new: true }
    );

    res.json({ message: 'User updated successfully', data: updatedUser });
  } catch (error) {
    res.status(500).json({ message: 'Error updating user', error: error.message });
  }
});


//MARK:- Delete User DELETE API --------------------------------------------------->
router.delete('/users:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const deletedUser = await UserProfile.findOneAndDelete({ userId });

    if (!deletedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'User deleted successfully', data: deletedUser });
  } catch (error) {
    res.status(500).json({ message: 'Error deleting user', error: error.message });
  }
});

//MARK:- Fetch Single User GET API --------------------------------------------------->
router.get('/users:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await UserProfile.findOne({ userId });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'User fetched successfully', data: user });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching user', error: error.message });
  }
});


//MARK:- Get All Users GET API pagination --------------------------------------------------->
router.get('/users', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const totalUsers = await UserProfile.countDocuments();
    const users = await UserProfile.find()
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });

    res.json({
      message: 'Users fetched successfully',
      currentPage: page,
      totalPages: Math.ceil(totalUsers / limit),
      totalUsers,
      data: users
    });
  } catch (error) {
    res.status(500).json({ message: 'Error fetching users', error: error.message });
  }
});


//MARK:- Get User Profile GET API pagination --------------------------------------------------->
router.get('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Fetch user by userId
    const user = await UserProfile.findOne({ userId });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({
      message: 'User fetched successfully',
      data: user
    });

  } catch (error) {
    console.error('Error fetching user details:', error);
    res.status(500).json({
      message: 'Error fetching user details',
      error: error.message
    });
  }
});



module.exports = router;