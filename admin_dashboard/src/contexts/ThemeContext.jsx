import React, { createContext, useContext, useState, useEffect } from 'react';

const ThemeContext = createContext();

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};

// Theme configuration with specified color palettes
export const themeConfig = {
  light: {
    mode: 'light',
    colors: {
      background: '#F5F7FA',
      primary: '#4A90E2',
      secondary: '#50E3C2',
      cardBackground: '#FFFFFF',
      text: '#1F2937',
      textSecondary: '#6B7280',
      border: '#E5E7EB',
      shadow: 'rgba(0, 0, 0, 0.1)',
      success: '#10B981',
      error: '#EF4444',
      warning: '#F59E0B',
      info: '#3B82F6',
      hover: 'rgba(74, 144, 226, 0.08)',
      gradient: {
        primary: 'linear-gradient(135deg, #4A90E2 0%, #50E3C2 100%)',
        secondary: 'linear-gradient(135deg, #50E3C2 0%, #4A90E2 100%)',
        card: 'linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(255, 255, 255, 0.6) 100%)'
      }
    }
  },
  dark: {
    mode: 'dark',
    colors: {
      background: '#1F2937',
      primary: '#4A90E2',
      secondary: '#50E3C2',
      cardBackground: '#2A2F3A',
      text: '#E5E7EB',
      textSecondary: '#9CA3AF',
      border: '#374151',
      shadow: 'rgba(0, 0, 0, 0.3)',
      success: '#10B981',
      error: '#EF4444',
      warning: '#F59E0B',
      info: '#3B82F6',
      hover: 'rgba(74, 144, 226, 0.12)',
      gradient: {
        primary: 'linear-gradient(135deg, #4A90E2 0%, #50E3C2 100%)',
        secondary: 'linear-gradient(135deg, #50E3C2 0%, #4A90E2 100%)',
        card: 'linear-gradient(135deg, rgba(42, 47, 58, 0.9) 0%, rgba(42, 47, 58, 0.6) 100%)'
      }
    }
  }
};

export const ThemeProvider = ({ children }) => {
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isTransitioning, setIsTransitioning] = useState(false);

  // Check for saved theme preference or default to 'light' mode
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      setIsDarkMode(savedTheme === 'dark');
    } else {
      // Check system preference
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      setIsDarkMode(prefersDark);
    }
  }, []);

  // Update CSS variables and localStorage when theme changes
  useEffect(() => {
    const theme = isDarkMode ? themeConfig.dark : themeConfig.light;
    const root = document.documentElement;
    
    // Set CSS variables for dynamic theming
    Object.entries(theme.colors).forEach(([key, value]) => {
      if (typeof value === 'object') {
        Object.entries(value).forEach(([subKey, subValue]) => {
          root.style.setProperty(`--color-${key}-${subKey}`, subValue);
        });
      } else {
        root.style.setProperty(`--color-${key}`, value);
      }
    });
    
    localStorage.setItem('theme', isDarkMode ? 'dark' : 'light');
    document.body.className = isDarkMode ? 'dark-theme' : 'light-theme';
  }, [isDarkMode]);

  const toggleTheme = () => {
    setIsTransitioning(true);
    setIsDarkMode(prev => !prev);
    
    // Reset transition state after animation completes
    setTimeout(() => {
      setIsTransitioning(false);
    }, 300);
  };

  const currentTheme = isDarkMode ? themeConfig.dark : themeConfig.light;

  const value = {
    isDarkMode,
    toggleTheme,
    theme: currentTheme,
    isTransitioning,
    colors: currentTheme.colors,
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};