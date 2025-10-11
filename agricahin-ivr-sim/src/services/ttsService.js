// ttsService.js - simple wrapper around SpeechSynthesis

export function speak(text, { language = 'en-IN', rate = 1, pitch = 1 } = {}) {
  if (typeof window === 'undefined' || !window.speechSynthesis) {
    return Promise.resolve(false);
  }
  return new Promise((resolve) => {
    const utter = new SpeechSynthesisUtterance(text);
    utter.lang = language;
    utter.rate = rate;
    utter.pitch = pitch;
    utter.onend = () => resolve(true);
    utter.onerror = () => resolve(false);
    window.speechSynthesis.speak(utter);
  });
}

export default { speak };