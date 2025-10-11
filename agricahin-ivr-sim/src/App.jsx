import React from 'react';
import { Routes, Route, NavLink } from 'react-router-dom';
import HomePage from './pages/HomePage.jsx';
import SimulatorPage from './pages/SimulatorPage.jsx';
import IVRSimulation from './components/IVRSimulation.jsx';

function App() {
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <h1 className="brand">IVR Simulator</h1>
        <nav className="nav">
          <NavLink to="/" end className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>Home</NavLink>
          <NavLink to="/simulator" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>Simulator (Legacy)</NavLink>
          <NavLink to="/ivr" className={({ isActive }) => isActive ? 'nav-link active' : 'nav-link'}>Advanced IVR</NavLink>
        </nav>
      </aside>
      <main className="main">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/simulator" element={<SimulatorPage />} />
          <Route path="/ivr" element={<IVRSimulation />} />
        </Routes>
      </main>
    </div>
  );
}

export default App;
