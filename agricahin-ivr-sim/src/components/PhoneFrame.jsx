import React from 'react';

const PhoneFrame = ({ children }) => {
  return (
    <div className="phone-frame">
      <div className="phone-notch" />
      <div className="phone-screen">
        {children}
      </div>
    </div>
  );
};

export default PhoneFrame;
