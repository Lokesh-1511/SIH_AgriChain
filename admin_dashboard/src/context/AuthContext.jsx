import React, { createContext, useContext, useState, useCallback } from 'react';
import bcrypt from 'bcryptjs';
import { adminAuthApi } from '../services/api';

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem('single_admin_session');
    return stored ? JSON.parse(stored) : null;
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Hardcoded single admin credentials
  const ADMIN_EMAIL = 'agriadmin@gmail.com';
  const ADMIN_HASH = '$2a$10$4mc5irY7GoIHVi8lJ3RipOfGU2/4.sazBvCQHviGhVoZQwnZnx83e'; // bcrypt hash for 1q2w3e4r

  const persistUser = (u) => {
    if (u) localStorage.setItem('single_admin_session', JSON.stringify(u));
    else localStorage.removeItem('single_admin_session');
  };

  const login = useCallback(async ({ email, password }) => {
    setError(null);
    if (email !== ADMIN_EMAIL) {
      const message = 'Invalid credentials';
      setError(message);
      return { success: false, error: message };
    }
    const match = bcrypt.compareSync(password, ADMIN_HASH);
    if (!match) {
      const message = 'Invalid credentials';
      setError(message);
      return { success: false, error: message };
    }
    const sessionUser = {
      id: 'single-admin',
      email: ADMIN_EMAIL,
      name: 'Platform Administrator',
      role: 'administrator',
      avatar: null,
      loginTime: new Date().toISOString()
    };
    setUser(sessionUser);
    persistUser(sessionUser);
    // Try backend auth (if backend seeded) to obtain JWT
    try {
      const resp = await adminAuthApi.login(email, password);
      if (resp?.data?.token) {
        localStorage.setItem('admin_backend_jwt', resp.data.token);
      }
    } catch (e) {
      // Non-blocking: backend might not yet have admin user
      console.warn('[Auth] Backend admin login skipped/failed:', e.message);
    }
    return { success: true };
  }, []);

  const logout = useCallback(async () => {
    setUser(null);
    persistUser(null);
    localStorage.removeItem('admin_backend_jwt');
  }, []);

  const resetPassword = useCallback(async () => ({ success: false, error: 'Password reset disabled' }), []);

  const isAuthenticated = useCallback(() => !!user, [user]);

  const value = {
    user,
    login,
    logout,
    resetPassword,
    isAuthenticated,
    loading,
    authError: error,
    authMode: 'single-admin'
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};