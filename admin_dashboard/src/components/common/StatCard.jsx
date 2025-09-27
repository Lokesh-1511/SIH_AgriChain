import React from 'react';
import { useTheme } from '../../contexts/ThemeContext.jsx';
import './StatCard.css';

const StatCard = ({ 
  title, 
  value, 
  subtitle, 
  icon, 
  trend, 
  color = 'primary',
  loading = false,
  onClick,
  gradient = false,
  animated = true
}) => {
  const { colors } = useTheme();
  
  const getTrendIcon = () => {
    if (!trend) return null;
    if (trend.direction === 'up') return '📈';
    if (trend.direction === 'down') return '📉';
    return '➡️';
  };

  const getTrendColor = () => {
    if (!trend) return colors.textSecondary;
    if (trend.direction === 'up') return colors.success;
    if (trend.direction === 'down') return colors.error;
    return colors.textSecondary;
  };

  const cardClass = `
    stat-card 
    ${gradient ? 'stat-card-gradient' : ''} 
    ${animated ? 'stat-card-animated' : ''}
    ${onClick ? 'stat-card-clickable' : ''}
    ${color ? `stat-card-${color}` : ''}
  `.trim();

  return (
    <div className={cardClass} onClick={onClick}>
      {gradient && <div className="stat-card-gradient-overlay"></div>}
      
      <div className="stat-card-content">
        <div className="stat-card-header">
          <div className="stat-card-title-section">
            <h3 className="stat-card-title">{title}</h3>
            {icon && <div className="stat-card-icon">{icon}</div>}
          </div>
        </div>
        
        <div className="stat-card-body">
          {loading ? (
            <div className="stat-card-loading">
              <div className="loading-spinner"></div>
            </div>
          ) : (
            <div className="stat-card-value-container">
              <span className="stat-card-value">{value}</span>
              {trend && (
                <div 
                  className="stat-card-trend"
                  style={{ color: getTrendColor() }}
                >
                  <span className="trend-icon">{getTrendIcon()}</span>
                  <span className="trend-value">{trend.value}</span>
                </div>
              )}
            </div>
          )}
          
          {subtitle && (
            <p className="stat-card-subtitle">{subtitle}</p>
          )}
        </div>
      </div>
      
      {animated && (
        <div className="stat-card-shine"></div>
      )}
    </div>
  );
};

export default StatCard;