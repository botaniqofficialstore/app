const nodemailer = require('nodemailer');
const twilio = require('twilio');
const path = require('path');

// ✅ Email Transporter (using Brevo SMTP)
const emailTransporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,     // smtp-relay.brevo.com
  port: process.env.EMAIL_PORT,     // 587
  secure: true,                    // use STARTTLS, not SSL
  auth: {
    user: process.env.EMAIL_USER,   // botaniqofficialstore@gmail.com
    pass: process.env.EMAIL_PASS    // your Brevo SMTP key
  },
  tls: {
    rejectUnauthorized: false
  }
});

// ✅ Twilio Client for SMS OTP
const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

// ✅ Send OTP via Email
exports.sendEmailOTP = async (toEmail, otp) => {
  const htmlTemplate = `
    <div style="font-family: Arial, sans-serif; padding: 0; background: #26323e; margin: 0;">
      <div style="max-width: 480px; margin: 40px auto; background: #26323e; padding: 80px 30px;">

        <!-- Logo -->
        <div style="text-align: center; margin-bottom: 25px;">
          <img src="cid:botaniqLogo" alt="BotaniQ Logo" style="width: 200px; max-width: 220px;"/>
        </div>

        <!-- Main Message -->
        <h2 style="font-size: 18px; color: #ffffff; text-align: center; margin-bottom: 10px;">
          Let’s Get You Growing — Confirm Your Login
        </h2>

        <p style="font-size: 14px; color: #ffffff; text-align: center; opacity: 0.8; margin-top: 4px;">
          Use the OTP below to verify your account and continue securely.
        </p>

        <!-- OTP Box -->
        <div style="text-align: center; margin: 12px 0 6px 0;">
          <span style="
            font-size: 30px;
            letter-spacing: 6px;
            font-weight: bold;
            color: #ffffff;
            background: rgba(255,255,255,0.1);
            padding: 10px 18px;
            border-radius: 8px;
            display: inline-block;
          ">
            ${otp}
          </span>
        </div>

        <!-- Expiry Info -->
        <p style="font-size: 14px; color: #ffffff; text-align: center; opacity: 0.8;">
          This OTP will expire in <strong>${process.env.OTP_EXPIRES_MINUTES || 2} minutes</strong>.
        </p>

        <!-- Social Section -->
        <hr style="border: none; border-top: 1px solid rgba(255,255,255,0.2); margin: 30px 0;">

        <p style="font-size: 14px; color: #ffffff; text-align: center; margin-bottom: 15px;">
          Connect with us
        </p>

        <div style="display: flex; justify-content: center; align-items: center; gap: 25px;">

          <!-- WhatsApp -->
          <a href="https://wa.me/917306045755" target="_blank" 
            style="text-decoration: none; display: flex; align-items: center; color: #ffffff;">
            <img src="cid:whatsappIcon" alt="WhatsApp" 
                style="width: 22px; height: 22px; margin-right: 2px;">
            <span style="font-size: 13px; color: #ffffff; margin-right: 10px;">
              +91 73060 45755
            </span>
          </a>

          <!-- Instagram -->
          <a href="https://www.instagram.com/botaniqofficialstore" target="_blank" 
            style="text-decoration: none; display: flex; align-items: center; color: #ffffff;">
            <img src="cid:instagramIcon" alt="Instagram" 
                style="width: 22px; height: 22px; margin-right: 2px;">
            <span style="font-size: 13px; color: #ffffff; margin-right: 10px;">
              @botaniqofficialstore
            </span>
          </a>

          <!-- Website -->
          <a href="https://botaniqofficialstore.github.io/botaniqofficialstore/" target="_blank" 
            style="text-decoration: none; display: flex; align-items: center; color: #ffffff;">
            <img src="cid:browser" alt="Website" 
                style="width: 22px; height: 22px; margin-right: 2px;">
            <span style="font-size: 13px; color: #ffffff; margin-right: 10px;">
              botaniqofficialstore.com
            </span>
          </a>

        </div>
      </div>
    </div>
  `;

  const msg = {
    from: process.env.EMAIL_FROM, // ✅ uses "BotaniQ <botaniqofficialstore@gmail.com>"
    to: toEmail,
    subject: 'Your OTP Code - BotaniQ Verification',
    text: `Your OTP code is ${otp}. It will expire in ${process.env.OTP_EXPIRES_MINUTES || 2} minutes.`,
    html: htmlTemplate,
    attachments: [
      {
        filename: 'logo.png',
        path: path.join(__dirname, '../../assets/commonIcons/logo.png'),
        cid: 'botaniqLogo'
      },
      {
        filename: 'whatsapp.png',
        path: path.join(__dirname, '../../assets/commonIcons/whatsapp.png'),
        cid: 'whatsappIcon'
      },
      {
        filename: 'instagram.png',
        path: path.join(__dirname, '../../assets/commonIcons/instagram.png'),
        cid: 'instagramIcon'
      },
      {
        filename: 'browser.png',
        path: path.join(__dirname, '../../assets/commonIcons/browser.png'),
        cid: 'browser'
      }
    ]
  };

  // ✅ Send email
  await emailTransporter.sendMail(msg);
  console.log(`[EMAIL SENT ✅] ${toEmail} → ${otp}`);
};

// ✅ Send OTP via SMS (Twilio)
exports.sendSMSOTP = async (toNumber, otp) => {
  await twilioClient.messages.create({
    body: `Your OTP code is ${otp}. It will expire in ${process.env.OTP_EXPIRES_MINUTES || 2} minutes.`,
    from: process.env.TWILIO_PHONE_NUMBER,
    to: toNumber
  });
  console.log(`[SMS SENT ✅] ${toNumber} → ${otp}`);
};
