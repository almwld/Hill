const axios = require('axios');

class MessagingService {
  async sendOTP(phone, otp) {
    // 1. WhatsApp Graph API أولاً
    if (process.env.META_ACCESS_TOKEN && process.env.WHATSAPP_PHONE_NUMBER_ID) {
      try {
        await axios.post(
          `https://graph.facebook.com/v18.0/${process.env.WHATSAPP_PHONE_NUMBER_ID}/messages`,
          {
            messaging_product: "whatsapp",
            to: this._formatPhone(phone),
            type: "template",
            template: {
              name: "sehatak_otp",
              language: { code: "ar" },
              components: [{ type: "body", parameters: [{ type: "text", text: otp }] }]
            }
          },
          { headers: { Authorization: `Bearer ${process.env.META_ACCESS_TOKEN}` } }
        );
        console.log(`✅ WhatsApp sent to ${phone}`);
        return { success: true, channel: 'whatsapp_meta' };
      } catch (e) {
        console.log('WhatsApp Error:', e.response?.data || e.message);
      }
    }

    // 2. Twilio Verify احتياطي
    if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN && process.env.TWILIO_VERIFY_SERVICE_SID) {
      try {
        await axios.post(
          `https://verify.twilio.com/v2/Services/${process.env.TWILIO_VERIFY_SERVICE_SID}/Verifications`,
          new URLSearchParams({ To: this._formatPhone(phone), Channel: 'sms' }).toString(),
          { auth: { username: process.env.TWILIO_ACCOUNT_SID, password: process.env.TWILIO_AUTH_TOKEN } }
        );
        console.log(`✅ Twilio SMS sent to ${phone}`);
        return { success: true, channel: 'twilio_sms' };
      } catch (e) {
        console.log('Twilio Error:', e.response?.data || e.message);
      }
    }

    // 3. وضع تطوير
    return { success: true, channel: 'dev', dev_otp: otp };
  }

  _formatPhone(phone) {
    let cleaned = phone.replace(/[^0-9+]/g, '');
    if (!cleaned.startsWith('+')) cleaned = (cleaned.startsWith('0') ? '+967' + cleaned.substring(1) : '+967' + cleaned);
    return cleaned;
  }
}

module.exports = new MessagingService();
