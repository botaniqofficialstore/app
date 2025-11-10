const axios = require("axios");
const twilio = require("twilio");

// ✅ Twilio Client (for SMS)
const twilioClient = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

// ✅ Send OTP via Email (Brevo API)
exports.sendEmailOTP = async (toEmail, otp) => {
  try {
    const htmlTemplate = `
      <div style="font-family: Arial, sans-serif; padding: 0; background: #26323e; margin: 0;">
        <div style="max-width: 480px; margin: 40px auto; background: #26323e; padding: 80px 30px;">
          <div style="text-align: center; margin-bottom: 25px;">
            <img src="https://botaniqofficialstore.github.io/botaniqofficialstore/assets/logo.png" 
                 alt="BotaniQ Logo" style="width: 180px; max-width: 220px;"/>
          </div>
          <h2 style="font-size: 18px; color: #ffffff; text-align: center; margin-bottom: 10px;">
            Let’s Get You Growing — Confirm Your Login
          </h2>
          <p style="font-size: 14px; color: #ffffff; text-align: center; opacity: 0.8; margin-top: 4px;">
            Use the OTP below to verify your account and continue securely.
          </p>
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
            ">${otp}</span>
          </div>
          <p style="font-size: 14px; color: #ffffff; text-align: center; opacity: 0.8;">
            This OTP will expire in <strong>${process.env.OTP_EXPIRES_MINUTES || 2} minutes</strong>.
          </p>
          <hr style="border: none; border-top: 1px solid rgba(255,255,255,0.2); margin: 30px 0;">
          <p style="font-size: 14px; color: #ffffff; text-align: center; margin-bottom: 15px;">
            Connect with us
          </p>
          <div style="text-align: center; color: #fff;">
            <p>🌿 <a href="https://www.instagram.com/botaniqofficialstore" style="color:#fff;text-decoration:none;">@botaniqofficialstore</a></p>
            <p>🌱 <a href="https://wa.me/917306045755" style="color:#fff;text-decoration:none;">+91 73060 45755</a></p>
            <p>💚 <a href="https://botaniqofficialstore.github.io/botaniqofficialstore/" style="color:#fff;text-decoration:none;">Website</a></p>
          </div>
        </div>
      </div>
    `;

    // ✅ Brevo API Request (Render Safe)
    const response = await axios.post(
      "https://api.brevo.com/v3/smtp/email",
      {
        sender: { name: "BotaniQ", email: process.env.EMAIL_FROM },
        to: [{ email: toEmail }],
        subject: "Your OTP Code – BotaniQ Verification",
        htmlContent: htmlTemplate,
      },
      {
        headers: {
          "accept": "application/json",
          "content-type": "application/json",
          "api-key": process.env.BREVO_API_KEY, // ✅ must match Render environment key
        },
      }
    );

    console.log(`[EMAIL SENT ✅] ${toEmail} → ${otp}`);
    return response.data;
  } catch (error) {
    console.error("Send OTP Error (Email):", error.response?.data || error.message);
    throw new Error("Failed to send OTP email");
  }
};

// ✅ Send OTP via SMS (Twilio)
exports.sendSMSOTP = async (toNumber, otp) => {
  try {
    await twilioClient.messages.create({
      body: `Your OTP code is ${otp}. It will expire in ${
        process.env.OTP_EXPIRES_MINUTES || 2
      } minutes.`,
      from: process.env.TWILIO_PHONE_NUMBER,
      to: toNumber,
    });
    console.log(`[SMS SENT ✅] ${toNumber} → ${otp}`);
  } catch (error) {
    console.error("Send OTP Error (SMS):", error.message);
    throw new Error("Failed to send OTP SMS");
  }
};
