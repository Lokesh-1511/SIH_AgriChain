import React, { useState, useEffect } from 'react';

const KEYS = ['1','2','3','4','5','6','7','8','9','*','0','#'];

const PhoneUI = ({
  onKeyPress = () => {},
  onCallToggle = () => {},
  connected = false,
  pressedKeys = [],
  menuLines = []
}) => {
  const [pressed, setPressed] = useState(null);

  useEffect(() => {
    if (!connected) {
      setPressed(null);
    }
  }, [connected]);

  const handlePress = (key) => {
    setPressed(key);
    onKeyPress(key);
    setTimeout(() => setPressed(null), 140);
  };

  const highlightSet = new Set(pressedKeys.slice(-8));

  return (
    <div className="phone-ui-root">
      <div className="phone-screen-area">
        <div className="phone-screen-text" style={{ whiteSpace: 'pre-line', fontSize: 12 }}>
          {!connected && 'IVR Menu: Press Call to begin'}
          {connected && menuLines.length > 0 && menuLines.map(line => {
            const digit = line.match(/Press (\d)/)?.[1];
            const active = digit && highlightSet.has(digit);
            return (
              <div key={line} style={{
                background: active ? 'rgba(59,130,246,0.15)' : 'transparent',
                borderRadius: 6,
                padding: '2px 4px',
                marginBottom: 2,
                fontWeight: active ? 600 : 400
              }}>{line}</div>
            );
          })}
          {connected && menuLines.length === 0 && 'CALL ACTIVE — Press keys to interact'}
        </div>
      </div>

      <div className="phone-keypad">
        {KEYS.map(k => (
          <button
            key={k}
            className={`phone-key ${pressed === k ? 'pressed' : ''}`}
            onMouseDown={() => handlePress(k)}
            onTouchStart={() => handlePress(k)}
            aria-label={`key-${k}`}
          >
            {k}
          </button>
        ))}
      </div>

      <div className="phone-controls">
        {!connected ? (
          <button className="call-btn phone-control-btn" onClick={() => onCallToggle(true)}>Call</button>
        ) : (
          <button className="hangup-btn phone-control-btn" onClick={() => onCallToggle(false)}>End Call</button>
        )}
      </div>
    </div>
  );
};

export default PhoneUI;
