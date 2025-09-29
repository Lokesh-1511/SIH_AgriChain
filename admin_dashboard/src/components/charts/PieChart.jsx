import React from 'react';
import { ResponsiveContainer, PieChart as RechartsPieChart, Pie, Cell, Tooltip, Legend } from 'recharts';
import { useTheme } from '../../contexts/ThemeContext.jsx';
import './Charts.css';

const PieChart = ({ 
  data = [], 
  title, 
  dataKey = 'value', 
  height = 300,
  showTooltip = true,
  showLegend = true,
  animated = true 
}) => {
  const { colors, isDarkMode } = useTheme();
  const safeData = Array.isArray(data) ? data : [];

  // Agriculture-blockchain color palette with gradients
  const chartColors = [
    colors.primary,    // Organic green
    colors.secondary,  // Fresh leaf green
    colors.accent,     // Harvest gold
    colors.success,    // Bright growth green
    colors.info,       // Earthy teal
    colors.warning,    // Golden wheat
    '#2F6B30',        // Dark forest green
    '#6BB244',        // Vibrant leaf
    '#F6C90E',        // Bright gold
    '#1E5A3E'         // Deep forest
  ];

  const renderCustomTooltip = ({ active, payload }) => {
    if (active && payload && payload.length) {
      const data = payload[0];
      return (
        <div className="agri-chart-tooltip">
          <div className="tooltip-content">
            <div className="tooltip-header">
              <div 
                className="tooltip-color-indicator"
                style={{ 
                  background: `linear-gradient(45deg, ${data.color}, ${data.color}dd)`,
                  boxShadow: `0 0 8px ${data.color}40`
                }}
              />
              <span className="tooltip-label">{data.name}</span>
            </div>
            <div className="tooltip-value-container">
              <span className="tooltip-value">{data.value}</span>
              <span className="tooltip-percentage">
                ({((data.value / safeData.reduce((sum, item) => sum + item[dataKey], 0)) * 100).toFixed(1)}%)
              </span>
            </div>
          </div>
        </div>
      );
    }
    return null;
  };

  const renderCustomLegend = (props) => {
    const { payload } = props;
    return (
      <div className="agri-chart-legend">
        {payload.map((entry, index) => (
          <div key={`legend-${index}`} className="agri-legend-item">
            <div 
              className="agri-legend-color" 
              style={{ 
                background: `linear-gradient(45deg, ${entry.color}, ${entry.color}dd)`,
                boxShadow: `0 0 8px ${entry.color}40`
              }}
            />
            <span className="agri-legend-text">{entry.value}</span>
          </div>
        ))}
      </div>
    );
  };

  if (safeData.length === 0) {
    return (
      <div className="agri-chart-container">
        {title && <div className="agri-chart-header">
          <h3 className="agri-chart-title">{title}</h3>
        </div>}
        <div className="agri-chart-no-data">
          <p>No data available</p>
        </div>
      </div>
    );
  }

  return (
    <div className="agri-chart-container agri-fade-in">
      {title && <div className="agri-chart-header">
        <h3 className="agri-chart-title">{title}</h3>
      </div>}
      
      <div className="agri-chart-wrapper">
        <ResponsiveContainer width="100%" height={height}>
          <RechartsPieChart>
            <Pie
              data={safeData}
              cx="50%"
              cy="50%"
              outerRadius={80}
              innerRadius={20}
              dataKey={dataKey}
              animationBegin={0}
              animationDuration={animated ? 1200 : 0}
              animationEasing="ease-out"
            >
              {safeData.map((entry, index) => (
                <Cell 
                  key={`cell-${index}`} 
                  fill={chartColors[index % chartColors.length]}
                  stroke={isDarkMode ? colors.cardBackground : 'white'}
                  strokeWidth={3}
                  style={{
                    filter: `drop-shadow(0 0 8px ${chartColors[index % chartColors.length]}40)`,
                    transition: 'all 0.3s ease'
                  }}
                />
              ))}
            </Pie>
            
            {showTooltip && (
              <Tooltip content={renderCustomTooltip} />
            )}
            
            {showLegend && (
              <Legend content={renderCustomLegend} />
            )}
          </RechartsPieChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default PieChart;
