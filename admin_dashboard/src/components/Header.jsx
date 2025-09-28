import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useTheme } from '../contexts/ThemeContext.jsx';
import './Header.css';

const Header = () => {
  const { isDarkMode, toggleTheme } = useTheme();
  const location = useLocation();

  const navItems = [
    { path: '/dashboard', label: 'Dashboard' },
    { path: '/roles', label: 'Role Management'},
    { path: '/supply-chain', label: 'Supply Chain' },
    { path: '/blockchain', label: 'Blockchain' },
    { path: '/reports', label: 'Reports' }
  ];

  const isActivePath = (path) => {
    return location.pathname === path || 
           (path === '/dashboard' && location.pathname === '/');
  };

  return (
    <header className="agri-header">
      {/* Animated background particles */}
      <div className="agri-particles">
        {[...Array(8)].map((_, i) => (
          <div 
            key={i} 
            className="agri-particle" 
            style={{
              left: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 20}s`,
              animationDuration: `${15 + Math.random() * 10}s`
            }}
          />
        ))}
      </div>

      <div className="agri-header-container">
        {/* Enhanced Logo and Brand */}
        <div className="agri-header-brand">
          <div className="agri-logo agri-hover-glow">
            <span className="agri-logo-icon">🌾</span>
            <div className="agri-logo-text">
              <span className="agri-brand-main">AgriChain</span>
              <span className="agri-brand-sub">Admin Dashboard</span>
            </div>
          </div>
        </div>

        {/* Enhanced Navigation with Glassmorphism */}
        <nav className="agri-header-nav">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`agri-nav-link ${isActivePath(item.path) ? 'active' : ''}`}
            >
              
              <span className="agri-nav-label">{item.label}</span>
              <div className="agri-nav-indicator"></div>
            </Link>
          ))}
        </nav>

        {/* Enhanced Theme Toggle and Actions */}
        <div className="agri-header-actions">
          {/* Modern Sun/Moon Theme Toggle Button */}
          <button 
            className="agri-modern-theme-toggle"
            onClick={toggleTheme}
            aria-label={`Switch to ${isDarkMode ? 'light' : 'dark'} mode`}
          >
            <div className="agri-toggle-track">
              <div className={`agri-toggle-slider ${isDarkMode ? 'dark' : 'light'}`}>
                <span className="agri-toggle-icon">
                  {isDarkMode ? '🌙' : '☀️'}
                </span>
              </div>
            </div>
          </button>

          {/* Enhanced Notifications */}
          <button className="agri-notification-btn agri-hover-glow">
            <span className="agri-notification-icon">🔔</span>
            <span className="agri-notification-badge agri-badge">3</span>
          </button>

          {/* User Profile */}
          <div className="agri-user-profile agri-hover-scale">
            <div className="agri-user-info">
              <span className="agri-username">Admin User</span>
              <span className="agri-user-role">Administrator</span>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;