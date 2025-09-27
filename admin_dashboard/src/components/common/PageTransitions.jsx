import React, { useEffect, useState } from 'react';
import './PageTransitions.css';

export const PageContainer = ({ children, className = '', animate = true }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    if (animate) {
      setTimeout(() => setIsVisible(true), 100);
    } else {
      setIsVisible(true);
    }
  }, [animate]);

  return (
    <div className={`
      page-container 
      ${animate ? 'page-animated' : ''} 
      ${isVisible ? 'page-visible' : 'page-hidden'}
      ${className}
    `}>
      {children}
    </div>
  );
};

export const AnimatedCard = ({ children, delay = 0, className = '' }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setIsVisible(true), delay);
    return () => clearTimeout(timer);
  }, [delay]);

  return (
    <div className={`
      animated-card 
      ${isVisible ? 'card-visible' : 'card-hidden'}
      ${className}
    `}>
      {children}
    </div>
  );
};

export const FadeInElement = ({ children, delay = 0, direction = 'up', className = '' }) => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setIsVisible(true), delay);
    return () => clearTimeout(timer);
  }, [delay]);

  return (
    <div className={`
      fade-element 
      fade-${direction}
      ${isVisible ? 'fade-visible' : 'fade-hidden'}
      ${className}
    `}>
      {children}
    </div>
  );
};

export const StaggeredList = ({ children, staggerDelay = 100, className = '' }) => {
  return (
    <div className={`staggered-list ${className}`}>
      {React.Children.map(children, (child, index) => (
        <FadeInElement delay={index * staggerDelay} direction="up">
          {child}
        </FadeInElement>
      ))}
    </div>
  );
};

export const HoverCard = ({ children, className = '', scale = 1.02 }) => {
  return (
    <div 
      className={`hover-card ${className}`}
      style={{ '--hover-scale': scale }}
    >
      {children}
    </div>
  );
};

export const FloatingButton = ({ 
  children, 
  onClick, 
  position = 'bottom-right',
  color = 'primary',
  size = 'medium',
  className = '' 
}) => {
  const positionClass = {
    'bottom-right': 'fab-bottom-right',
    'bottom-left': 'fab-bottom-left',
    'top-right': 'fab-top-right',
    'top-left': 'fab-top-left'
  }[position];

  return (
    <button 
      className={`
        floating-action-button 
        fab-${color} 
        fab-${size}
        ${positionClass}
        ${className}
      `}
      onClick={onClick}
    >
      {children}
    </button>
  );
};

export const LoadingOverlay = ({ isVisible, message = 'Loading...' }) => {
  if (!isVisible) return null;

  return (
    <div className="loading-overlay">
      <div className="loading-content">
        <div className="loading-spinner-large"></div>
        <p className="loading-message">{message}</p>
      </div>
    </div>
  );
};

export const PulseLoader = ({ size = 'medium', color = 'primary' }) => {
  return (
    <div className={`pulse-loader pulse-${size} pulse-${color}`}>
      <div className="pulse-dot"></div>
      <div className="pulse-dot"></div>
      <div className="pulse-dot"></div>
    </div>
  );
};