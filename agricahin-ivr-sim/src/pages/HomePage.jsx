import React from 'react';

const HomePage = () => {
  return (
    <div className="panel">
      <h2>Welcome</h2>
      <p>This tool simulates an agricultural IVR (Interactive Voice Response) flow. Use the Simulator page to interact with a mock phone UI and see descriptive context in real-time.</p>
      <ul>
        <li>Left side: Phone keypad + call flow display</li>
        <li>Right side: Step descriptions, prompts, and debug info</li>
      </ul>
    </div>
  );
};

export default HomePage;
