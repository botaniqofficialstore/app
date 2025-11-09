// utils/notification.js
const { Resend } = require('resend');
const twilio = require('twilio');

const resend = new Resend(process.env.RESEND_API_KEY);
const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

// NOTE: host your images publicly (S3/Github Pages) and use absolute URLs in the template.
// Replace exampleLogoUrl with real URL if you have one.
const exampleLogoUrl = process.env.EMAIL_LOGO_URL || 'https://your-cdn.com/logo.png';

exports.sendEmailOTP = async (toEmail, otp) => {
  const htmlTemplate = `
    <div style="font-family: Arial, sans-serif; padding: 0; background: #26323e; margin: 0;">
      <div style="max-width: 480px; margin: 40px auto; background: #26323e; padding: 40px 20px;">
        <div style="text-align:center; margin-bottom:20px;">
          <img src="${exampleLogoUrl}" alt="BotaniQ" style="width:160px; max-width:80%;" />
        </div>
        <h2 style="color:#fff; text-align:center; font-size:18px; margin:6px 0;">Let’s Get You Growing — Confirm Your Login</h2>
        <p style="color:#fff; text-align:center; opacity:.85; margin:8px 0 18px;">Use the OTP below to verify your account securely.</p>

        <div style="text-align:center; margin:10px 0;">
          <span style="
            display:inline-block;
            padding:10px 18px;
            font-size:28px;
            font-weight:700;
            color:#fff;
            letter-spacing:4px;
            border-radius:8px;
            background:rgba(255,255,255,0.08);
          ">${otp}</span>
        </div>

        <p style="color:#fff; text-align:center; opacity:.85; margin-top:12px;">
          This OTP will expire in <strong>${process.env.OTP_EXPIRES_MINUTES || 2} minutes</strong>.
        </p>

        <hr style="border:none;border-top:1px solid rgba(255,255,255,0.12); margin:18px 0;"/>

        <p style="color:#fff; text-align:center; font-size:13px;">Connect with us: <a style="color:#fff" href="https://botaniqofficialstore.github.io/botaniqofficialstore/">Website</a></p>
        <p style="color:#fff; text-align:center; font-size:11px; opacity:.7;">© ${new Date().getFullYear()} BotaniQ Microgreens</p>
      </div>
    </div>
  `;

  try {
    await resend.emails.send({
      from: process.env.EMAIL_FROM || 'BotaniQ <botaniqofficialstore@gmail.com>',
      to: toEmail,
      subject: 'Your OTP Code – BotaniQ Verification',
      html: htmlTemplate
    });
    console.log(`[EMAIL SENT ✅] ${toEmail} → ${otp}`);
  } catch (err) {
    console.error('❌ Resend Email Error:', err);
    throw err; // allow caller to handle
  }
};

exports.sendSMSOTP = async (toNumber, otp) => {
  try {
    await twilioClient.messages.create({
      body: `Your OTP code is ${otp}. It will expire in ${process.env.OTP_EXPIRES_MINUTES || 2} minutes.`,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: toNumber
    });
    console.log(`[SMS SENT ✅] ${toNumber} → ${otp}`);
  } catch (err) {
    console.error('❌ Twilio SMS Error:', err);
    throw err;
  }
};