const crypto = require('crypto');

exports.generateOTP = () => {
  const otp = crypto.randomInt(100000, 999999).toString();
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes
  return { otp, expiresAt };
};
