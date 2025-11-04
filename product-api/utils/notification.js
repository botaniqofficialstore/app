const nodemailer = require('nodemailer');
const twilio = require('twilio');

const emailTransporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

exports.sendEmailOTP = async (toEmail, otp) => {
  await emailTransporter.sendMail({
    from: process.env.EMAIL_USER,
    to: toEmail,
    subject: 'Your OTP Code',
    text: `Your OTP code is ${otp}. It will expire in 2 minutes.`
  });
};

exports.sendSMSOTP = async (toNumber, otp) => {
  await twilioClient.messages.create({
    body: `Your OTP code is ${otp}. It will expire in 2 minutes.`,
    from: process.env.TWILIO_PHONE_NUMBER,
    to: toNumber
  });
};
