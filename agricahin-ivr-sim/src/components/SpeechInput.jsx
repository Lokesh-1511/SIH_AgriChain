import React, { useEffect, useRef, useState } from 'react';

// Simple speech input component that streams interim transcript and final result.
// Props:
//   language: BCP-47 code (e.g., 'en-IN')
//   onResult(text)
//   onCancel()
// Automatically stops after first final result or on manual cancel.

const SpeechInput = ({ language = 'en-IN', onResult = () => {}, onCancel = () => {} }) => {
  const recognitionRef = useRef(null);
  const [listening, setListening] = useState(false);
  const [interim, setInterim] = useState('');
  const [error, setError] = useState(null);

  useEffect(() => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) {
      setError('Speech recognition not supported in this browser.');
      return;
    }
    const rec = new SpeechRecognition();
    rec.lang = language;
    rec.continuous = false;
    rec.interimResults = true;
    rec.maxAlternatives = 1;

    rec.onstart = () => setListening(true);
    rec.onerror = (e) => {
      setError(e.error || 'speech-error');
    };
    rec.onresult = (e) => {
      let finalText = '';
      let interimText = '';
      for (let i = e.resultIndex; i < e.results.length; i += 1) {
        const res = e.results[i];
        if (res.isFinal) finalText += res[0].transcript;
        else interimText += res[0].transcript;
      }
      setInterim(interimText);
      if (finalText) {
        onResult(finalText.trim());
        rec.stop();
      }
    };
    rec.onend = () => {
      setListening(false);
      // If we ended without a final result but have interim, treat it as final fallback
      if (interim && !error) {
        onResult(interim.trim());
      }
    };

    recognitionRef.current = rec;
    rec.start();

    return () => {
      try { rec.stop(); } catch (_) {}
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [language]);

  const handleCancel = () => {
    try { recognitionRef.current?.stop(); } catch (_) {}
    onCancel();
  };

  return (
    <div className="speech-input-panel">
      <div className="speech-header">Speech Capture {listening && <span className="live-dot" />}</div>
      {error ? (
        <div className="speech-error">{error}</div>
      ) : (
        <div className="speech-content">
          <div className="speech-interim">{interim || (listening ? 'Listening…' : 'Processing…')}</div>
        </div>
      )}
      <div className="speech-actions">
        <button className="hangup-btn phone-control-btn" onClick={handleCancel}>Cancel</button>
      </div>
    </div>
  );
};

export default SpeechInput;