import React from 'react';
import { ResponsiveContainer, BarChart as RechartsBarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts';
import { useTheme } from '../../contexts/ThemeContext.jsx';
import './Charts.css';

const BarChart = ({ 
  data, 
  title, 
  dataKey = 'value', 
  nameKey = 'name',
  height = 300,
  showGrid = true,
  showTooltip = true,
  showLegend = false,
  animated = true,
  gradient = false
}) => {
  const { colors, isDarkMode } = useTheme();

  const renderCustomTooltip = ({ active, payload, label }) => {
    if (active && payload && payload.length) {
      return (
        <div className="chart-tooltip">
          <div className="tooltip-content">
            <span className="tooltip-label">{label}</span>
            {payload.map((entry, index) => (
              <div key={`tooltip-${index}`} className="tooltip-entry">
                <span 
                  className="tooltip-color" 
                  style={{ backgroundColor: entry.color }}
                ></span>
                <span className="tooltip-name">{entry.dataKey}</span>
                <span className="tooltip-value">{entry.value.toLocaleString()}</span>
              </div>
            ))}
          </div>
        </div>
      );
    }
    return null;
  };

  const gradientId = `barGradient-${Math.random().toString(36).substr(2, 9)}`;

  return (
    <div className={`chart-container ${animated ? 'chart-animated' : ''}`}>
      {title && (
        <h3 className="chart-title">{title}</h3>
      )}
      
      <div className="chart-wrapper">
        <ResponsiveContainer width="100%" height={height}>
          <RechartsBarChart data={data} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
            {gradient && (
              <defs>
                <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor={colors.primary} stopOpacity={0.8}/>
                  <stop offset="95%" stopColor={colors.primary} stopOpacity={0.3}/>
                </linearGradient>
              </defs>
            )}
            
            {showGrid && (
              <CartesianGrid 
                strokeDasharray="3 3" 
                stroke={colors.border}
                opacity={0.3}
              />
            )}
            
            <XAxis 
              dataKey={nameKey}
              tick={{ fontSize: 12, fill: colors.textSecondary }}
              axisLine={{ stroke: colors.border }}
              tickLine={{ stroke: colors.border }}
            />
            
            <YAxis 
              tick={{ fontSize: 12, fill: colors.textSecondary }}
              axisLine={{ stroke: colors.border }}
              tickLine={{ stroke: colors.border }}
            />
            
            {showTooltip && (
              <Tooltip 
                content={renderCustomTooltip}
                cursor={{ fill: colors.hover }}
                wrapperStyle={{ zIndex: 1000 }}
              />
            )}
            
            {showLegend && <Legend />}
            
            <Bar 
              dataKey={dataKey}
              fill={gradient ? `url(#${gradientId})` : colors.primary}
              radius={[4, 4, 0, 0]}
              animationBegin={0}
              animationDuration={animated ? 1000 : 0}
              animationEasing="ease-out"
            />
          </RechartsBarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default BarChart;