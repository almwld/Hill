const axios = require('axios');

class MessagingService {
  async sendOTP(phone, otp) {
    // لو مفاتيح Twilio موجودة، استخدم Twilio Verify
    if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
      try {
        await axios.post(
          `https://verify.twilio.com/v2/Services/${process.env.TWILIO_VERIFY_SERVICE_SID}/Verifications`,
          new URLSearchParams({ To: this._formatPhone(phone), Channel: 'sms' }).toString(),
          {
            auth: { username: process.env.TWILIO_ACCOUNT_SID, password: process.env.TWILIO_AUTH_TOKEN },
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          }
        );
        console.log(`✅ Twilio SMS sent to ${phone}`);
        return { success: true, channel: 'twilio_sms' };
      } catch (e) {
        console.log('❌ Twilio failed, using dev mode:', e.message);
      }
    }
    // وضع تطوير - إرجاع الرمز
    return { success: true, channel: 'whatsapp', dev_otp: otp };
  }

  _formatPhone(phone) {
    let cleaned = phone.replace(/[^0-9+]/g, '');
    if (cleaned.startsWith('00')) cleaned = '+' + cleaned.substring(2);
    if (!cleaned.startsWith('+')) cleaned = (cleaned.startsWith('0') ? '+967' + cleaned.substring(1) : '+967' + cleaned);
    return cleaned;
  }
}

module.exports = new MessagingService();
