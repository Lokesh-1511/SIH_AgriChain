import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../contexts/ThemeContext.jsx';
import { FloatingInput, ModernButton } from '../components/common/FormComponents';
import { PageContainer } from '../components/common/PageTransitions';
import './LoginPage.css';

const LoginPage = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  const { isDarkMode, toggleTheme } = useTheme();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [errors, setErrors] = useState({});
  const [isLoading, setIsLoading] = useState(false);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.email) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email address';
    }
    
    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters long';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) return;
    
    setIsLoading(true);
    
    try {
      // Attempt login with credentials
      const result = await login({
        email: formData.email,
        password: formData.password,
        rememberMe: true // You can get this from a checkbox if needed
      });
      
      if (result.success) {
        navigate('/dashboard');
      } else {
        setErrors({
          general: result.error || 'Login failed. Please try again.'
        });
      }
    } catch (error) {
      console.error('Login error:', error);
      setErrors({
        general: 'Login failed. Please try again.'
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <PageContainer className="login-page" animate={true}>
      <div className="login-container">
        {/* Theme Toggle */}
        <button className="login-theme-toggle" onClick={toggleTheme}>
          <span className="theme-icon">
            {isDarkMode ? '☀️' : '🌙'}
          </span>
        </button>
        
        {/* Background Elements */}
        <div className="login-background">
          <div className="bg-shape shape-1"></div>
          <div className="bg-shape shape-2"></div>
          <div className="bg-shape shape-3"></div>
        </div>
        
        <div className="login-content">
          {/* Logo Section */}
          <div className="login-header">
            <div className="login-logo">
              <span className="logo-icon">🌾</span>
              <h1 className="logo-text">AgriChain</h1>
            </div>
            <p className="login-subtitle">
              Welcome to the future of agricultural supply chain management
            </p>
          </div>
          
          {/* Login Form */}
          <div className="login-form-container">
            <form onSubmit={handleSubmit} className="login-form">
              <div className="form-header">
                <h2 className="form-title">Sign In</h2>
                <p className="form-description">
                  Access your AgriChain dashboard
                </p>
              </div>
              
              {errors.general && (
                <div className="error-banner">
                  <span className="error-icon">⚠️</span>
                  <span className="error-text">{errors.general}</span>
                </div>
              )}
              
              <div className="form-fields">
                <FloatingInput
                  type="email"
                  name="email"
                  label="Email Address"
                  value={formData.email}
                  onChange={handleInputChange}
                  error={errors.email}
                  required
                  autoComplete="email"
                />
                
                <FloatingInput
                  type="password"
                  name="password"
                  label="Password"
                  value={formData.password}
                  onChange={handleInputChange}
                  error={errors.password}
                  required
                  autoComplete="current-password"
                />
              </div>
              
              <div className="form-options">
                <label className="remember-me">
                  <input type="checkbox" />
                  <span className="checkmark"></span>
                  <span className="label-text">Remember me</span>
                </label>
                
                <a href="#" className="forgot-password">
                  Forgot password?
                </a>
              </div>
              
              <ModernButton
                type="submit"
                variant="primary"
                size="large"
                loading={isLoading}
                fullWidth={true}
                disabled={isLoading}
              >
                {isLoading ? 'Signing In...' : 'Sign In'}
              </ModernButton>
              
              <div className="demo-credentials">
                <h4>Demo Credentials:</h4>
                <p><strong>Email:</strong> admin@agrichain.com</p>
                <p><strong>Password:</strong> password123</p>
              </div>
            </form>
          </div>
          
          {/* Footer */}
          <div className="login-footer">
            <p>&copy; 2024 AgriChain. All rights reserved.</p>
          </div>
        </div>
      </div>
    </PageContainer>
  );
};

export default LoginPage;