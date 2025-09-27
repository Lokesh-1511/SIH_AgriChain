import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useTheme } from '../contexts/ThemeContext.jsx';
import './Header.css';

const Header = () => {
  const { isDarkMode, toggleTheme } = useTheme();
  const location = useLocation();

  const navItems = [
    { path: '/dashboard', label: 'Dashboard', icon: '📊' },
    { path: '/roles', label: 'Role Management', icon: '👥' },
    { path: '/supply-chain', label: 'Supply Chain', icon: '🔗' },
    { path: '/blockchain', label: 'Blockchain', icon: '⛓️' },
    { path: '/reports', label: 'Reports', icon: '📄' }
  ];

  const isActivePath = (path) => {
    return location.pathname === path || 
           (path === '/dashboard' && location.pathname === '/');
  };

  return (
    <header className="header">
      <div className="header-container">
        {/* Logo and Brand */}
        <div className="header-brand">
          <div className="logo">
            <span className="logo-icon">🌾</span>
            <span className="logo-text">AgriChain</span>
          </div>
          <span className="brand-subtitle">Admin Dashboard</span>
        </div>

        {/* Navigation */}
        <nav className="header-nav">
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={`nav-item ${isActivePath(item.path) ? 'active' : ''}`}
            >
              <span className="nav-icon">{item.icon}</span>
              <span className="nav-label">{item.label}</span>
            </Link>
          ))}
        </nav>

        {/* Theme Toggle and User Actions */}
        <div className="header-actions">
          {/* Theme Toggle Button */}
          <button 
            className="theme-toggle"
            onClick={toggleTheme}
            aria-label={`Switch to ${isDarkMode ? 'light' : 'dark'} mode`}
          >
            <div className="toggle-track">
              <div className="toggle-thumb">
                <span className="toggle-icon">
                  {isDarkMode ? '🌙' : '☀️'}
                </span>
              </div>
            </div>
          </button>

          {/* Notifications */}
          <button className="notification-btn">
            <span className="notification-icon">🔔</span>
            <span className="notification-badge">3</span>
          </button>

          {/* User Menu */}
          <div className="user-menu">
            <div className="user-avatar">
              <span>👤</span>
            </div>
            <div className="user-info">
              <span className="user-name">Admin User</span>
              <span className="user-role">Administrator</span>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;