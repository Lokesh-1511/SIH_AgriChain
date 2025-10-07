import React, { useState, useCallback, useEffect } from 'react';
import PhoneFrame from './PhoneFrame.jsx';
import PhoneUI from './PhoneUI.jsx';
import IVRDescription from './IVRDescription.jsx';
import SpeechInput from './SpeechInput.jsx';
import { getMockResponse } from '../services/mockApi.js';
import { speak } from '../services/ttsService.js';
import offlineQueue from '../services/offlineQueueService.js';

// Feature menu mapping (keys 1-6)
export const MAIN_MENU = [
  { key: '1', label: 'Farmer Registration' },
  { key: '2', label: 'Post Product' },
  { key: '3', label: 'Check Market Price' },
  { key: '4', label: 'Wallet Summary' },
  { key: '5', label: 'Apply Loan/Insurance' },
  { key: '6', label: 'Human Support' }
];

const IVRSimulation = () => {
  const [connected, setConnected] = useState(false);
  const [pressedKeys, setPressedKeys] = useState([]); // chronological
  const [responses, setResponses] = useState([]); // {key, text, ts}
  const [language, setLanguage] = useState('en-IN');
  const [offline, setOffline] = useState(false);
  const [failures, setFailures] = useState(0);
  const [showHumanBtn, setShowHumanBtn] = useState(false);
  const [listeningKey, setListeningKey] = useState(null); // key for which speech input active
  const [speechSupported, setSpeechSupported] = useState(true);
  const [ttsSupported, setTtsSupported] = useState(true);
  const STORAGE_KEY = 'ivrSessionV1';

  // Load persisted session (pressedKeys + responses) on mount
  useEffect(() => {
    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed.pressedKeys)) setPressedKeys(parsed.pressedKeys);
        if (Array.isArray(parsed.responses)) setResponses(parsed.responses);
      }
    } catch (_) {
      // ignore
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Persist whenever pressedKeys or responses change
  useEffect(() => {
    try {
      const payload = JSON.stringify({ pressedKeys, responses });
      localStorage.setItem(STORAGE_KEY, payload);
    } catch (_) {
      // ignore
    }
  }, [pressedKeys, responses]);

  // Capability detection (runs once)
  useEffect(() => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (!SpeechRecognition) setSpeechSupported(false);
    if (!('speechSynthesis' in window)) setTtsSupported(false);
  }, []);

  // Reset state on hangup
  const endCall = useCallback(() => {
    setConnected(false);
    setPressedKeys([]);
    setResponses([]);
    setFailures(0);
    setShowHumanBtn(false);
    setListeningKey(null);
    try { localStorage.removeItem(STORAGE_KEY); } catch(_){}
  }, []);

  const startCall = useCallback(() => {
    setConnected(true);
  }, []);

  const handleCallToggle = useCallback((start) => {
    if (start) startCall(); else endCall();
  }, [startCall, endCall]);

  const processAction = useCallback(async ({ key, textInput }) => {
    try {
      const resp = await getMockResponse({ pressedKey: key, textInput, language });
      const item = { key, text: resp, ts: Date.now() };
      setResponses(r => [...r, item]);
      // TTS (graceful failure)
      if (ttsSupported) {
        speak(resp, { language }).catch(()=>{});
      }
    } catch (e) {
      setFailures(f => f + 1);
    }
  }, [language, ttsSupported]);

  const handleKeyPress = useCallback((key) => {
    if (!connected) return;
    setPressedKeys(pk => [...pk, key]);

    const isMenu = MAIN_MENU.some(m => m.key === key);
    if (!isMenu) {
      // invalid or secondary input -> count as failure
      setFailures(f => f + 1);
      return;
    }

    if (offline) {
      offlineQueue.enqueue({ key, ts: Date.now() });
    } else {
      processAction({ key });
    }

    // Start speech capture for certain keys (simulate voice follow-up) except direct info keys
    if (['1','2','5'].includes(key)) {
      setListeningKey(key); // triggers SpeechInput render
    } else {
      setListeningKey(null);
    }
  }, [connected, offline, processAction]);

  // Physical keyboard support (0-9 * #) while connected
  useEffect(() => {
    if (!connected) return;
    const handler = (e) => {
      // Avoid capturing input when user is typing in a form element
      const tag = (e.target && e.target.tagName) ? e.target.tagName.toLowerCase() : '';
      if (tag === 'input' || tag === 'textarea' || e.target.isContentEditable) return;
      const key = e.key;
      if (/^[0-9*#]$/.test(key)) {
        e.preventDefault();
        handleKeyPress(key);
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [connected, handleKeyPress]);

  // Flush queued actions when offline -> online
  useEffect(() => {
    if (!offline) {
      const q = offlineQueue.drain();
      q.forEach(a => processAction({ key: a.key }));
    }
  }, [offline, processAction]);

  // Human support fallback condition
  useEffect(() => {
    if (failures >= 2) setShowHumanBtn(true);
  }, [failures]);

  const connectHuman = () => {
    const text = 'You are now connected to a human agent.';
    setResponses(r => [...r, { key: 'H', text, ts: Date.now() }]);
    speak('Connecting to human support', { language }).catch(()=>{});
    setShowHumanBtn(false);
  };

  const handleSpeechResult = (transcript) => {
    if (!listeningKey) return;
    // Process transcript via mock API (simulate additional context)
    processAction({ key: listeningKey, textInput: transcript });
    setListeningKey(null);
  };

  return (
    <div className="ivr-sim-container">
      <div className="ivr-top-bar">
        <h2 className="ivr-title">AGRICHAIN IVR Simulation</h2>
        <div className="ivr-controls-inline">
          <label className="ivr-label-sm">Language:&nbsp;
            <select value={language} onChange={e => setLanguage(e.target.value)}>
              <option value="en-IN">English (India)</option>
              <option value="hi-IN">Hindi (hi-IN)</option>
              <option value="ta-IN">Tamil (ta-IN)</option>
            </select>
          </label>
          <button className="btn-small" onClick={() => setOffline(o => !o)}>
            {offline ? 'Go Online' : 'Go Offline'}
          </button>
        </div>
      </div>
      {/* Capability banners */}
      <div className="ivr-banner-stack">
        {!speechSupported && (
          <div className="ivr-banner danger">
            Browser speech recognition unavailable. Voice capture disabled.
          </div>
        )}
        {!ttsSupported && (
          <div className="ivr-banner warn">
            Text-to-Speech not supported. Audio prompts muted.
          </div>
        )}
        {offline && (
          <div className="ivr-banner info">
            Offline mode active — key presses will queue and auto-send when online.
          </div>
        )}
      </div>
      <div className="ivr-layout">
        <div className="ivr-left">
          <PhoneFrame>
            <div className="ivr-phone-wrapper">
              <div className="log-window ivr-log-window">
                {responses.slice(-8).map(r => (
                  <div key={r.ts} className="log-line"><strong>{r.key}</strong>: {r.text}</div>
                ))}
                {responses.length === 0 && connected && (
                  <div className="log-line muted">Menu ready. Press a number.</div>
                )}
                {!connected && (
                  <div className="log-line muted">Press Call to start.</div>
                )}
                {offlineQueue.size() > 0 && offline && (
                  <div className="log-line queued">Queued actions: {offlineQueue.size()}</div>
                )}
              </div>
              <PhoneUI
                connected={connected}
                onCallToggle={handleCallToggle}
                onKeyPress={handleKeyPress}
                pressedKeys={pressedKeys}
                menuLines={MAIN_MENU.map(m => `Press ${m.key} for ${m.label}`)}
              />
              {listeningKey && connected && speechSupported && (
                <SpeechInput
                  key={listeningKey}
                  language={language}
                  onResult={handleSpeechResult}
                  onCancel={() => setListeningKey(null)}
                />
              )}
            </div>
          </PhoneFrame>
          {showHumanBtn && connected && (
            <div className="ivr-human-cta">
              <button className="hangup-btn phone-control-btn" onClick={connectHuman}>Connect to Human Support</button>
            </div>
          )}
        </div>
        <div className="ivr-right">
            <IVRDescription
              pressedKeys={pressedKeys}
              responses={responses}
            />
        </div>
      </div>
    </div>
  );
};

export default IVRSimulation;
