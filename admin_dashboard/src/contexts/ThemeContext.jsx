import React, { createContext, useContext, useState, useEffect } from 'react';

const ThemeContext = createContext();

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};

// Agriculture-Blockchain Theme Configuration 🌱⛓️
export const themeConfig = {
  light: {
    mode: 'light',
    colors: {
      // Core agriculture-inspired palette with improved contrast
      background: '#FAFBF8',      // Very light mint background
      primary: '#2D5A2D',         // Darker forest green for better contrast
      secondary: '#5B9E5B',       // Balanced medium green
      accent: '#E8A317',          // Rich golden harvest
      cardBackground: '#FFFFFF',
      text: '#0D1A0D',            // Very dark green-black
      textSecondary: '#3A4A3A',   // Darker secondary text
      headerText: '#1A2E1A',      // Dark text specifically for header
      headerTextSecondary: '#2D4A2D', // Secondary text for header
      border: '#B8C8B8',          // Subtle green border
      shadow: 'rgba(45, 90, 45, 0.2)',
      success: '#22C55E',         // Clear success green
      error: '#DC2626',           // Clear error red
      warning: '#D97706',         // Rich amber warning
      info: '#0F766E',            // Strong teal info
      hover: 'rgba(45, 90, 45, 0.1)',
      
      // Advanced gradient system with excellent header contrast
      gradient: {
        primary: 'linear-gradient(135deg, #2D5A2D 0%, #5B9E5B 50%, #0F766E 100%)',
        secondary: 'linear-gradient(135deg, #5B9E5B 0%, #E8A317 50%, #2D5A2D 100%)',
        accent: 'linear-gradient(135deg, #E8A317 0%, #D97706 100%)',
        hero: 'linear-gradient(135deg, rgba(91, 158, 91, 0.3) 0%, rgba(126, 200, 80, 0.25) 30%, rgba(184, 226, 184, 0.2) 70%, rgba(139, 195, 139, 0.3) 100%)',
        card: 'linear-gradient(135deg, rgba(255, 255, 255, 0.98) 0%, rgba(250, 251, 248, 0.9) 100%)',
        cardBorder: 'linear-gradient(135deg, rgba(45, 90, 45, 0.25) 0%, rgba(91, 158, 91, 0.35) 100%)',
        button: 'linear-gradient(135deg, #2D5A2D 0%, #5B9E5B 100%)',
        buttonHover: 'linear-gradient(135deg, #1E3E1E 0%, #4A8A4A 100%)'
      },
      
      // Glow effects for blockchain elements
      glow: {
        green: '0 0 20px rgba(45, 90, 45, 0.4)',
        gold: '0 0 20px rgba(232, 163, 23, 0.5)',
        teal: '0 0 20px rgba(15, 118, 110, 0.4)'
      }
    }
  },
  dark: {
    mode: 'dark',
    colors: {
      // Dark forest-inspired palette
      background: '#0F1C0F',       // Deep forest green
      primary: '#4ADE80',          // Vibrant neon green
      secondary: '#2F855A',        // Earthy teal
      accent: '#F6C90E',           // Golden wheat
      cardBackground: '#1A2A1A',   // Dark forest card background
      text: '#E8F5E9',
      textSecondary: '#A7C9A8',    // Muted green text
      border: '#2F4F2F',           // Dark forest border
      shadow: 'rgba(0, 0, 0, 0.4)',
      success: '#4ADE80',
      error: '#EF4444',
      warning: '#F6C90E',
      info: '#2F855A',
      hover: 'rgba(74, 222, 128, 0.12)',
      
      // Dark mode gradient system
      gradient: {
        primary: 'linear-gradient(135deg, #4ADE80 0%, #2F855A 50%, #1E5A3E 100%)',
        secondary: 'linear-gradient(135deg, #2F855A 0%, #F6C90E 50%, #4ADE80 100%)',
        accent: 'linear-gradient(135deg, #F6C90E 0%, #FFD166 100%)',
        hero: 'linear-gradient(135deg, #0F1C0F 0%, #1A2A1A 30%, #2F4F2F 70%, #1E5A3E 100%)',
        card: 'linear-gradient(135deg, rgba(26, 42, 26, 0.95) 0%, rgba(15, 28, 15, 0.8) 100%)',
        cardBorder: 'linear-gradient(135deg, rgba(74, 222, 128, 0.3) 0%, rgba(47, 133, 90, 0.4) 100%)',
        button: 'linear-gradient(135deg, #4ADE80 0%, #2F855A 100%)',
        buttonHover: 'linear-gradient(135deg, #5EE794 0%, #3A9964 100%)'
      },
      
      // Enhanced glow effects for dark theme
      glow: {
        green: '0 0 25px rgba(74, 222, 128, 0.5)',
        gold: '0 0 25px rgba(246, 201, 14, 0.6)',
        teal: '0 0 25px rgba(47, 133, 90, 0.5)'
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