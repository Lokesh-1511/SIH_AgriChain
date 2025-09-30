import React from 'react';
import { ResponsiveContainer, LineChart as RechartsLineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts';
import { useTheme } from '../../contexts/ThemeContext.jsx';
import './Charts.css';

const LineChart = ({ 
  data, 
  title, 
  dataKey = 'value', 
  nameKey = 'name',
  height = 300,
  showGrid = true,
  showTooltip = true,
  showLegend = false,
  animated = true,
  smooth = true,
  showDots = true
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

  const gradientId = `lineGradient-${Math.random().toString(36).substr(2, 9)}`;

  return (
    <div className={`chart-container ${animated ? 'chart-animated' : ''}`}>
      {title && (
        <h3 className="chart-title">{title}</h3>
      )}
      
      <div className="chart-wrapper">
        <ResponsiveContainer width="100%" height={height}>
          <RechartsLineChart data={data} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
            <defs>
              <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor={colors.primary} stopOpacity={0.8}/>
                <stop offset="95%" stopColor={colors.primary} stopOpacity={0}/>
              </linearGradient>
            </defs>
            
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
                cursor={{ 
                  stroke: colors.primary, 
                  strokeWidth: 1,
                  strokeDasharray: '5 5'
                }}
                wrapperStyle={{ zIndex: 1000 }}
              />
            )}
            
            {showLegend && <Legend />}
            
            <Line 
              type={smooth ? "monotone" : "linear"}
              dataKey={dataKey}
              stroke={colors.primary}
              strokeWidth={3}
              fill={`url(#${gradientId})`}
              dot={showDots ? { r: 4, strokeWidth: 2, stroke: colors.primary, fill: colors.cardBackground } : false}
              activeDot={{ r: 6, stroke: colors.primary, strokeWidth: 2, fill: colors.cardBackground }}
              animationBegin={0}
              animationDuration={animated ? 1500 : 0}
              animationEasing="ease-out"
            />
          </RechartsLineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default LineChart;