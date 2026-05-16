const axios = require('axios');

class MessagingService {
  async sendOTP(phone, otp) {
    // 1. WhatsApp Graph API (مجاني)
    if (process.env.WHATSAPP_ACCESS_TOKEN && process.env.WHATSAPP_PHONE_NUMBER_ID) {
      try {
        const url = `https://graph.facebook.com/${process.env.GRAPH_API_VERSION || 'v18.0'}/${process.env.WHATSAPP_PHONE_NUMBER_ID}/messages`;
        await axios.post(url, {
          messaging_product: "whatsapp",
          to: this._formatPhone(phone),
          type: "template",
          template: {
            name: "sehatak_otp",
            language: { code: "ar" },
            components: [{ type: "body", parameters: [{ type: "text", text: otp }] }]
          }
        }, { headers: { Authorization: `Bearer ${process.env.WHATSAPP_ACCESS_TOKEN}` } });
        console.log(`✅ WhatsApp sent to ${phone}`);
        return { success: true, channel: 'whatsapp_graph' };
      } catch (e) {
        console.log('❌ WhatsApp Graph Error:', e.response?.data || e.message);
      }
    }

    // 2. وضع تطوير
    return { success: true, channel: 'dev', dev_otp: otp };
  }

  _formatPhone(phone) {
    let cleaned = phone.replace(/[^0-9+]/g, '');
    if (!cleaned.startsWith('+')) cleaned = (cleaned.startsWith('0') ? '+967' + cleaned.substring(1) : '+967' + cleaned);
    return cleaned;
  }
}

module.exports = new MessagingService();
