import React from 'react';
import { Link } from 'react-router-dom';

const Unauthorized = () => {
  return (
    <div style={{padding:'4rem', textAlign:'center'}}>
      <h1>403 - Unauthorized</h1>
      <p>You do not have permission to view this resource.</p>
      <Link to="/dashboard">Return to dashboard</Link>
    </div>
  );
};

export default Unauthorized;
