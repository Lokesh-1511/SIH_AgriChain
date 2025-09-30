import React, { createContext, useContext, useState, useEffect } from 'react';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is logged in on app start
    const token = localStorage.getItem('authToken');
    const userData = localStorage.getItem('userData');
    
    if (token && userData) {
      setUser(JSON.parse(userData));
    }
    setLoading(false);
  }, []);

  const login = async (userData) => {
    // If userData is passed directly (from successful authentication)
    if (userData && userData.id) {
      const token = 'mock_jwt_token_' + Date.now();
      
      setUser(userData);
      localStorage.setItem('authToken', token);
      localStorage.setItem('userData', JSON.stringify(userData));
      
      return { success: true };
    }
    
    // If credentials are passed for authentication
    const { email, password, username, rememberMe } = userData || {};
    
    // Mock authentication - replace with actual API call
    const validEmail = email === 'admin@agrichain.com' || username === 'admin';
    const validPassword = password === 'password123' || password === 'admin123';
    
    if (validEmail && validPassword) {
      const newUserData = {
        id: 1,
        username: 'admin',
        email: email || 'admin@agrichain.com',
        name: 'Admin User',
        role: 'administrator',
        avatar: null,
        loginTime: new Date().toISOString(),
      };
      
      const token = 'mock_jwt_token_' + Date.now();
      
      setUser(newUserData);
      
      if (rememberMe) {
        localStorage.setItem('authToken', token);
        localStorage.setItem('userData', JSON.stringify(newUserData));
      } else {
        sessionStorage.setItem('authToken', token);
        sessionStorage.setItem('userData', JSON.stringify(newUserData));
      }
      
      return { success: true };
    } else {
      return { 
        success: false, 
        error: 'Invalid email or password' 
      };
    }
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('authToken');
    localStorage.removeItem('userData');
    sessionStorage.removeItem('authToken');
    sessionStorage.removeItem('userData');
  };

  const resetPassword = async (email) => {
    // Mock password reset - replace with actual API call
    console.log('Password reset requested for:', email);
    return { success: true, message: 'Password reset instructions sent to your email' };
  };

  const isAuthenticated = () => {
    return !!user;
  };

  const value = {
    user,
    login,
    logout,
    resetPassword,
    isAuthenticated,
    loading,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};