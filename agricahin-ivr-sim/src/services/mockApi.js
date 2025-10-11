// Simulated IVR backend logic
// getMockResponse({ pressedKey, textInput, language }) => Promise<string>

const EN_RESPONSES = {
  '1': () => 'Farmer registration started. Please provide your name after the beep (simulated).',
  '2': () => 'Product posting initiated. Provide crop name and quantity.',
  '3': () => 'Market Price: Wheat ₹2145, Maize ₹1880 (reference).',
  '4': () => 'Wallet balance: ₹3,420. Last sale: ₹980 to Distributor D12.',
  '5': () => 'Loan/Insurance application started. Provide acreage and crop type.',
  '6': () => 'Connecting you to support (simulated).'
};

const HI_RESPONSES = {
  '1': () => 'कृषक पंजीकरण शुरू। कृपया अपना नाम बोलें।',
  '2': () => 'उत्पाद पोस्ट करना शुरू। फसल और मात्रा बताएं।',
  '3': () => 'बाज़ार भाव: गेहूँ ₹2145, मक्का ₹1880 (संदर्भ)।',
  '4': () => 'वॉलेट बैलेंस: ₹3,420. पिछली बिक्री: ₹980.',
  '5': () => 'ऋण / बीमा आवेदन शुरू। क्षेत्र और फसल प्रकार दें।',
  '6': () => 'सपोर्ट से जोड़ रहे हैं (सिमुलेशन)।'
};

const TA_RESPONSES = {
  '1': () => 'விவசாய பதிவு தொடங்கியது. உங்கள் பெயரை சொல்க.',
  '2': () => 'தயாரிப்பு பதிவேற்றம் தொடங்கியது. பயிர் மற்றும் அளவு கூறவும்.',
  '3': () => 'சந்தை விலை: கோதுமை ₹2145, மக்காச்சோளம் ₹1880.',
  '4': () => 'வாலட் இருப்பு: ₹3,420. கடைசி விற்பனை: ₹980.',
  '5': () => 'கடன் / காப்பீடு விண்ணப்பம் தொடங்கியது. ஏக்கர் மற்றும் பயிர் வகை சொல்லவும்.',
  '6': () => 'அதிகாரிக்கு இணைத்தல் (செயற்கை).'
};

const MAP = {
  'en-IN': EN_RESPONSES,
  'hi-IN': HI_RESPONSES,
  'ta-IN': TA_RESPONSES
};

export async function getMockResponse({ pressedKey, textInput, language = 'en-IN' }) {
  // Simulate latency
  await new Promise(r => setTimeout(r, 250 + Math.random() * 300));
  const dict = MAP[language] || EN_RESPONSES;
  const base = dict[pressedKey]?.() || 'Unrecognized selection.';
  if (textInput) {
    return base + ' Received input: ' + textInput.slice(0, 60);
  }
  return base;
}

export default { getMockResponse };