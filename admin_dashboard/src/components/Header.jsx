import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useTheme } from '../contexts/ThemeContext.jsx';
import { 
  Menu, 
  MenuItem, 
  Badge,
  List,
  ListItem,
  ListItemText,
  Typography,
  Divider,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  IconButton,
  Box,
  Chip,
  Avatar,
  ListItemIcon
} from '@mui/material';
import { 
  Close as CloseIcon,
  AccountCircle,
  Settings,
  ExitToApp,
  Person,
  Security,
  Help
} from '@mui/icons-material';
import './Header.css';

const Header = () => {
  const { isDarkMode, toggleTheme } = useTheme();
  const location = useLocation();
  const navigate = useNavigate();
  const [notificationAnchor, setNotificationAnchor] = useState(null);
  const [showAllNotifications, setShowAllNotifications] = useState(false);
  const [profileAnchor, setProfileAnchor] = useState(null);

  // Mock notifications - expanded list
  const notifications = [
    { id: 1, title: 'Batch #2024-001 delivered successfully', time: '2 min ago', type: 'success', description: 'Batch containing 500kg wheat delivered to ABC Distribution Center.' },
    { id: 2, title: 'Temperature anomaly detected', time: '15 min ago', type: 'warning', description: 'Cold storage temperature exceeded 4°C for batch #2024-003.' },
    { id: 3, title: 'New batch registered', time: '1 hour ago', type: 'info', description: 'Farmer John Smith registered new organic rice batch for processing.' },
    { id: 4, title: 'Payment processed', time: '2 hours ago', type: 'success', description: 'Payment of ₹45,000 processed for batch #2024-002.' },
    { id: 5, title: 'Quality check failed', time: '3 hours ago', type: 'error', description: 'Batch #2024-004 failed quality inspection at processing facility.' },
    { id: 6, title: 'Transport delayed', time: '4 hours ago', type: 'warning', description: 'Delivery for batch #2024-005 delayed due to weather conditions.' },
    { id: 7, title: 'Blockchain verification complete', time: '5 hours ago', type: 'success', description: 'All transactions for batch #2024-001 verified on blockchain.' },
    { id: 8, title: 'New supplier onboarded', time: '1 day ago', type: 'info', description: 'Green Valley Farms added as verified supplier in the network.' }
  ];

  const recentNotifications = notifications.slice(0, 3);

  const handleNotificationClick = (event) => {
    setNotificationAnchor(event.currentTarget);
  };

  const handleNotificationClose = () => {
    setNotificationAnchor(null);
  };

  const handleViewAllNotifications = () => {
    setNotificationAnchor(null);
    setShowAllNotifications(true);
  };

  const handleProfileClick = (event) => {
    setProfileAnchor(event.currentTarget);
  };

  const handleProfileClose = () => {
    setProfileAnchor(null);
  };

  const handleLogout = () => {
    setProfileAnchor(null);
    // Add logout logic here
    if (window.confirm('Are you sure you want to logout?')) {
      localStorage.removeItem('authToken');
      navigate('/login');
    }
  };

  const handleProfile = () => {
    setProfileAnchor(null);
    navigate('/profile');
  };

  const handleSettings = () => {
    setProfileAnchor(null);
    navigate('/settings');
  };

  const handleSecurity = () => {
    setProfileAnchor(null);
    navigate('/profile'); // Navigate to profile page with security tab
  };

  const handleHelp = () => {
    setProfileAnchor(null);
    // Could open help modal or navigate to help page
    window.open('https://help.agrichain.com', '_blank');
  };

  const getNotificationIcon = (type) => {
    switch (type) {
      case 'success': return '✅';
      case 'warning': return '⚠️';
      case 'error': return '❌';
      case 'info': return 'ℹ️';
      default: return '🔔';
    }
  };

  const getNotificationColor = (type) => {
    switch (type) {
      case 'success': return '#4CAF50';
      case 'warning': return '#FF9800';
      case 'error': return '#F44336';
      case 'info': return '#2196F3';
      default: return '#757575';
    }
  };

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
          <button 
            className="agri-notification-btn agri-hover-glow"
            onClick={handleNotificationClick}
          >
            <span className="agri-notification-icon">🔔</span>
            <span className="agri-notification-badge agri-badge">{notifications.length}</span>
          </button>

          {/* Notifications Menu */}
          <Menu
            anchorEl={notificationAnchor}
            open={Boolean(notificationAnchor)}
            onClose={handleNotificationClose}
            PaperProps={{
              style: {
                maxHeight: 400,
                width: 350,
                marginTop: 8
              }
            }}
          >
            <MenuItem disabled>
              <Typography variant="h6" component="div">
                Notifications ({notifications.length})
              </Typography>
            </MenuItem>
            <Divider />
            {recentNotifications.map((notification) => (
              <MenuItem key={notification.id} onClick={handleNotificationClose}>
                <div style={{ display: 'flex', alignItems: 'flex-start', width: '100%', gap: '8px' }}>
                  <span style={{ fontSize: '16px', marginTop: '2px' }}>
                    {getNotificationIcon(notification.type)}
                  </span>
                  <div style={{ width: '100%' }}>
                    <Typography variant="body2" component="div" style={{ fontWeight: 500 }}>
                      {notification.title}
                    </Typography>
                    <Typography variant="caption" color="textSecondary">
                      {notification.time}
                    </Typography>
                  </div>
                </div>
              </MenuItem>
            ))}
            <Divider />
            <MenuItem onClick={handleViewAllNotifications}>
              <Typography variant="body2" color="primary" style={{ fontWeight: 500 }}>
                View All Notifications
              </Typography>
            </MenuItem>
          </Menu>

          {/* All Notifications Modal */}
          <Dialog 
            open={showAllNotifications} 
            onClose={() => setShowAllNotifications(false)}
            maxWidth="md"
            fullWidth
          >
            <DialogTitle>
              All Notifications
              <IconButton
                aria-label="close"
                onClick={() => setShowAllNotifications(false)}
                sx={{ position: 'absolute', right: 8, top: 8 }}
              >
                <CloseIcon />
              </IconButton>
            </DialogTitle>
            <DialogContent>
              <List>
                {notifications.map((notification, index) => (
                  <React.Fragment key={notification.id}>
                    <ListItem alignItems="flex-start" sx={{ padding: '12px 0' }}>
                      <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, width: '100%' }}>
                        <Box sx={{ fontSize: '20px', marginTop: '4px' }}>
                          {getNotificationIcon(notification.type)}
                        </Box>
                        <Box sx={{ flex: 1 }}>
                          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 1 }}>
                            <Typography variant="subtitle1" sx={{ fontWeight: 500 }}>
                              {notification.title}
                            </Typography>
                            <Chip 
                              label={notification.type.toUpperCase()} 
                              size="small"
                              sx={{ 
                                backgroundColor: getNotificationColor(notification.type),
                                color: 'white',
                                fontSize: '10px',
                                height: '20px'
                              }}
                            />
                          </Box>
                          <Typography variant="body2" color="textSecondary" sx={{ marginBottom: 1 }}>
                            {notification.description}
                          </Typography>
                          <Typography variant="caption" color="textSecondary">
                            {notification.time}
                          </Typography>
                        </Box>
                      </Box>
                    </ListItem>
                    {index < notifications.length - 1 && <Divider />}
                  </React.Fragment>
                ))}
              </List>
            </DialogContent>
            <DialogActions>
              <Button onClick={() => setShowAllNotifications(false)}>
                Close
              </Button>
              <Button variant="contained" onClick={() => setShowAllNotifications(false)}>
                Mark All as Read
              </Button>
            </DialogActions>
          </Dialog>

          {/* Enhanced User Profile */}
          <button 
            className="agri-user-profile agri-hover-scale"
            onClick={handleProfileClick}
            style={{ background: 'none', border: 'none', cursor: 'pointer' }}
          >
            <Avatar 
              sx={{ 
                width: 40, 
                height: 40, 
                bgcolor: 'primary.main',
                fontSize: '18px',
                fontWeight: 'bold'
              }}
            >
              AU
            </Avatar>
            <div className="agri-user-info">
              <span className="agri-username">Admin User</span>
              <span className="agri-user-role">Administrator</span>
            </div>
          </button>

          {/* Profile Menu */}
          <Menu
            anchorEl={profileAnchor}
            open={Boolean(profileAnchor)}
            onClose={handleProfileClose}
            PaperProps={{
              style: {
                width: 280,
                marginTop: 8
              }
            }}
            transformOrigin={{ horizontal: 'right', vertical: 'top' }}
            anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
          >
            {/* Profile Header */}
            <Box sx={{ p: 2, bgcolor: 'grey.50' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                <Avatar 
                  sx={{ 
                    width: 50, 
                    height: 50, 
                    bgcolor: 'primary.main',
                    fontSize: '20px',
                    fontWeight: 'bold'
                  }}
                >
                  AU
                </Avatar>
                <Box>
                  <Typography variant="subtitle1" sx={{ fontWeight: 600 }}>
                    Admin User
                  </Typography>
                  <Typography variant="body2" color="textSecondary">
                    admin@agrichain.com
                  </Typography>
                  <Chip 
                    label="Administrator" 
                    size="small" 
                    color="primary"
                    sx={{ mt: 0.5, fontSize: '10px', height: '20px' }}
                  />
                </Box>
              </Box>
            </Box>
            
            <Divider />
            
            {/* Profile Menu Items */}
            <MenuItem onClick={handleProfile}>
              <ListItemIcon>
                <Person />
              </ListItemIcon>
              <ListItemText 
                primary="My Profile" 
                secondary="View and edit profile information"
              />
            </MenuItem>
            
            <MenuItem onClick={handleSettings}>
              <ListItemIcon>
                <Settings />
              </ListItemIcon>
              <ListItemText 
                primary="Settings" 
                secondary="Account preferences and configuration"
              />
            </MenuItem>
            
            <MenuItem onClick={handleSecurity}>
              <ListItemIcon>
                <Security />
              </ListItemIcon>
              <ListItemText 
                primary="Security" 
                secondary="Password and security settings"
              />
            </MenuItem>
            
            <MenuItem onClick={handleHelp}>
              <ListItemIcon>
                <Help />
              </ListItemIcon>
              <ListItemText 
                primary="Help & Support" 
                secondary="Get help and contact support"
              />
            </MenuItem>
            
            <Divider />
            
            <MenuItem onClick={handleLogout} sx={{ color: 'error.main' }}>
              <ListItemIcon sx={{ color: 'error.main' }}>
                <ExitToApp />
              </ListItemIcon>
              <ListItemText 
                primary="Sign Out" 
                secondary="Logout from your account"
              />
            </MenuItem>
          </Menu>
        </div>
      </div>
    </header>
  );
};

export default Header;