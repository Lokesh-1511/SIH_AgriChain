import React, { useMemo } from 'react';

/*
  Props:
    pressedKeys: string[]  (chronological list of keys user has pressed in current call)
  Behavior:
    - Displays static mapping of primary menu options (1-6)
    - Highlights the latest valid selection
    - Shows a dynamic description / response panel below the mapping
*/

const FEATURE_MAP = {
  '1': {
    title: 'Farmer Registration',
    description: 'Begin or continue a farmer profile registration process. The system can collect name, land size, and basic crop details.'
  },
  '2': {
    title: 'Post Product',
    description: 'List a harvested crop batch for distributors/retailers with quantity, tentative price, and location.'
  },
  '3': {
    title: 'Check Market Price',
    description: 'Retrieve current mandi / market reference prices for key commodities (e.g., wheat, maize, rice).'
  },
  '4': {
    title: 'Wallet Summary',
    description: 'Hear your token / credit balance, recent payouts, and pending settlements.'
  },
  '5': {
    title: 'Apply for Loan/Insurance',
    description: 'Initiate a request for micro‑loan or crop insurance; system can gather acreage, crop type, risk indicators.'
  },
  '6': {
    title: 'Human Support',
    description: 'Escalate to a live agent or schedule a callback when agents are unavailable.'
  }
};

const IVRDescription = ({ pressedKeys = [], responses = [] }) => {
  const latestValid = useMemo(() => {
    for (let i = pressedKeys.length - 1; i >= 0; i -= 1) {
      const k = pressedKeys[i];
      if (FEATURE_MAP[k]) return k;
    }
    return null;
  }, [pressedKeys]);

  const activeFeature = latestValid ? FEATURE_MAP[latestValid] : null;

  return (
    <div className="panel" style={{ padding: '1rem 1.25rem' }}>
      <h3 style={{ marginTop: 0 }}>IVR Menu Mapping</h3>
      <p style={{ marginTop: 0, fontSize: 14, opacity: 0.8 }}>
        Press a number on the phone keypad. Below mapping updates as you interact.
      </p>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 12, marginTop: 12 }}>
        {Object.entries(FEATURE_MAP).map(([digit, info]) => {
          const isActive = digit === latestValid;
          return (
            <div
              key={digit}
              style={{
                border: '1px solid ' + (isActive ? '#2563eb' : '#e2e8f0'),
                borderRadius: 10,
                padding: '10px 12px',
                background: isActive ? 'linear-gradient(135deg,#1d4ed8,#2563eb)' : '#ffffff',
                color: isActive ? '#fff' : '#1e293b',
                boxShadow: isActive ? '0 4px 12px rgba(37,99,235,0.35)' : '0 2px 6px rgba(0,0,0,0.05)',
                transition: '0.18s'
              }}
            >
              <div style={{ fontSize: 13, fontWeight: 600, letterSpacing: 0.5 }}>Key {digit}</div>
              <div style={{ fontSize: 12, marginTop: 4, fontWeight: 500 }}>{info.title}</div>
            </div>
          );
        })}
      </div>
      <div style={{ marginTop: 20 }}>
        <h4 style={{ margin: '0 0 6px', fontSize: 16 }}>Current Selection</h4>
        {activeFeature ? (
          <div style={{ fontSize: 14, lineHeight: '1.35rem' }}>
            <strong>{activeFeature.title}:</strong> {activeFeature.description}
          </div>
        ) : (
          <div style={{ fontSize: 13, opacity: 0.7 }}>No selection yet. Press 1–6 to explore features.</div>
        )}
        {pressedKeys.length > 0 && (
          <div style={{ marginTop: 16, fontSize: 12, opacity: 0.6 }}>
            Input history: {pressedKeys.slice(-12).join(' ')}
          </div>
        )}
        {responses.length > 0 && (
          <div style={{ marginTop: 24 }}>
            <h4 style={{ margin: '0 0 8px', fontSize: 15 }}>Responses</h4>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, maxHeight: 220, overflowY: 'auto' }}>
              {responses.slice(-10).map(r => (
                <div key={r.ts} style={{
                  background: '#ffffff',
                  border: '1px solid #e2e8f0',
                  borderLeft: '4px solid #2563eb',
                  padding: '8px 10px',
                  borderRadius: 8,
                  fontSize: 13,
                  lineHeight: '1.25rem',
                  boxShadow: '0 1px 2px rgba(0,0,0,0.05)'
                }}>
                  <div style={{ fontSize: 11, opacity: 0.55, marginBottom: 2 }}>Key {r.key}</div>
                  <div>{r.text}</div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default IVRDescription;
