const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const Reel = require('../../Tables/Reel');
const ReelLike = require('../../Tables/ReelLike');
const UserProfile = require("../../Tables/UserProfile");

// ✅ Add new Reel (Admin only)
router.post("/reels", async (req, res) => {
  try {
    const { reelUrl, caption } = req.body;
    if (!reelUrl) return res.status(400).json({ message: "Reel URL is required" });

    const newReel = new Reel({
      reelId: uuidv4(),
      reelUrl,
      caption,
    });

    await newReel.save();
    res.json({ message: "Reel uploaded successfully", reel: newReel });
  } catch (err) {
    console.error("Error adding reel:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Delete reel (Admin only)
router.delete("/reels/:reelId", async (req, res) => {
  try {
    const { reelId } = req.params;
    const deleted = await Reel.findOneAndDelete({ reelId });
    if (!deleted) return res.status(404).json({ message: "Reel not found" });
    await ReelLike.deleteMany({ reelId });
    res.json({ message: "Reel deleted successfully" });
  } catch (err) {
    console.error("Error deleting reel:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Like / Unlike a reel
router.post("/reels/like", async (req, res) => {
  try {
    const { reelId, userId, isLiked } = req.body;

    if (!reelId || !userId)
      return res.status(400).json({ message: "reelId and userId are required" });

    const user = await UserProfile.findOne({ userId });
    if (!user) return res.status(404).json({ message: "Invalid userId" });

    const reel = await Reel.findOne({ reelId });
    if (!reel) return res.status(404).json({ message: "Invalid reelId" });

    if (isLiked) {
      // Add or update like
      await ReelLike.updateOne({ reelId, userId }, { isLiked: true }, { upsert: true });
      res.json({ message: "Reel liked" });
    } else {
      // Remove like
      await ReelLike.deleteOne({ reelId, userId });
      res.json({ message: "Reel unliked" });
    }
  } catch (err) {
    console.error("Error liking reel:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Get all Reels with pagination & like info
router.post("/reels/list", async (req, res) => {
  try {
    const { userId, page = 1, limit = 10 } = req.body;

    if (!userId) return res.status(400).json({ message: "userId is required" });
    const user = await UserProfile.findOne({ userId });
    if (!user) return res.status(404).json({ message: "Invalid userId" });

    const skip = (page - 1) * limit;

    // Fetch reels
    const reels = await Reel.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    const totalCount = await Reel.countDocuments();

    // Attach like info
    const formatted = await Promise.all(
      reels.map(async (reel) => {
        const totalLikes = await ReelLike.countDocuments({ reelId: reel.reelId });
        const isLiked = await ReelLike.exists({ reelId: reel.reelId, userId });
        return {
          reelId: reel.reelId,
          reelUrl: reel.reelUrl,
          caption: reel.caption,
          totalLikes,
          isLikedByUser: !!isLiked,
        };
      })
    );

    res.json({
      page: Number(page),
      limit: Number(limit),
      totalReels: totalCount,
      reels: formatted,
    });
  } catch (err) {
    console.error("Error fetching reels:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Get all Reels with pagination
router.post("/admin/reels/list", async (req, res) => {
  try {
    const {page = 1, limit = 10 } = req.body;

    const skip = (page - 1) * limit;

    // Fetch reels
    const reels = await Reel.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(Number(limit));

    const totalCount = await Reel.countDocuments();

    // Attach like info
    const formatted = await Promise.all(
      reels.map(async (reel) => {
        const totalLikes = await ReelLike.countDocuments({ reelId: reel.reelId });
        return {
          reelId: reel.reelId,
          reelUrl: reel.reelUrl,
          caption: reel.caption,
          totalLikes,
        };
      })
    );

    res.json({
      page: Number(page),
      limit: Number(limit),
      totalReels: totalCount,
      reels: formatted,
    });
  } catch (err) {
    console.error("Error fetching reels:", err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
