import React, { useState } from 'react';
import PhoneFrame from '../components/PhoneFrame.jsx';
import PhoneUI from '../components/PhoneUI.jsx';
import IVRDescription from '../components/IVRDescription.jsx';

const initialLog = [
  { t: Date.now(), msg: 'Ready. Press Call to begin.' }
];


const SimulatorPage = () => {
  const [connected, setConnected] = useState(false);
  const [log, setLog] = useState(initialLog);
  const [buffer, setBuffer] = useState('');
  const [pressedKeys, setPressedKeys] = useState([]);

  const appendLog = (msg) => setLog(l => [...l, { t: Date.now(), msg }]);

  const handleCallToggle = (start) => {
    if (start) {
      if (!connected) {
        setConnected(true);
        appendLog('Call connected. Playing greeting...');
        appendLog('"Welcome to AgriChain IVR. Press 1 for Farmer Services, 2 for Market Prices, 3 for Support."');
      }
    } else {
      if (connected) {
        appendLog('Call ended.');
        setConnected(false);
  setBuffer('');
  setPressedKeys([]);
      }
    }
  };

  const handleDigit = (d) => {
    if (!connected) return;
  appendLog(`DTMF: ${d}`);
  setPressedKeys(pk => [...pk, d]);
    // Very basic flow branching
    if (buffer === '' && d === '1') {
      appendLog('You selected Farmer Services. Press 1 for Weather, 2 for Soil, 9 to go Back.');
    } else if (buffer === '' && d === '2') {
      appendLog('You selected Market Prices. Enter crop code (2 digits).');
      setBuffer('2');
      return;
    } else if (buffer === '' && d === '3') {
      appendLog('Connecting you to Support... (simulated)');
    } else if (buffer === '2' && /[0-9]/.test(d)) {
      const code = '2' + d;
      appendLog(`Fetching prices for crop code ${code}... (mock)`);
      appendLog('Result: Wheat ₹2145/quintal, Maize ₹1880/quintal');
      setBuffer('');
      return;
    } else if (d === '9') {
      appendLog('Returning to main menu. Press 1 for Farmer Services, 2 for Market Prices, 3 for Support.');
      setBuffer('');
      return;
    }
  };

  return (
    <div className="split-layout">
      <div className="left-pane">
        <PhoneFrame>
          <div className="ivr-ui">
            <div className="call-status">{connected ? 'CALL ACTIVE' : 'IDLE'}</div>
            <div className="log-window">
              {log.slice(-12).map(entry => (
                <div key={entry.t} className="log-line">{entry.msg}</div>
              ))}
            </div>
            <PhoneUI
              onKeyPress={handleDigit}
              connected={connected}
              onCallToggle={handleCallToggle}
            />
          </div>
        </PhoneFrame>
      </div>
      <div className="right-pane">
        <IVRDescription pressedKeys={pressedKeys} />
      </div>
    </div>
  );
};

export default SimulatorPage;
