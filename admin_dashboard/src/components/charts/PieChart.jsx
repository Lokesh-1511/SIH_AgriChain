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

  const chartColors = [
    colors.primary,
    colors.success,
    colors.warning,
    colors.error,
    colors.info,
    colors.secondary
  ];

  const renderCustomTooltip = ({ active, payload }) => {
    if (active && payload && payload.length) {
      const data = payload[0];
      return (
        <div className="chart-tooltip">
          <div className="tooltip-content">
            <span className="tooltip-label">{data.name}</span>
            <span className="tooltip-value">{data.value}</span>
          </div>
        </div>
      );
    }
    return null;
  };

  const renderCustomLegend = (props) => {
    const { payload } = props;
    return (
      <div className="chart-legend">
        {payload.map((entry, index) => (
          <div key={`legend-${index}`} className="legend-item">
            <div 
              className="legend-color" 
              style={{ backgroundColor: entry.color }}
            ></div>
            <span className="legend-text">{entry.value}</span>
          </div>
        ))}
      </div>
    );
  };

  if (safeData.length === 0) {
    return (
      <div className="chart-container">
        {title && <h3 className="chart-title">{title}</h3>}
        <div className="chart-no-data">
          <p>No data available</p>
        </div>
      </div>
    );
  }

  return (
    <div className="chart-container">
      {title && <h3 className="chart-title">{title}</h3>}
      
      <div className="chart-wrapper">
        <ResponsiveContainer width="100%" height={height}>
          <RechartsPieChart>
            <Pie
              data={safeData}
              cx="50%"
              cy="50%"
              outerRadius={80}
              dataKey={dataKey}
              animationBegin={0}
              animationDuration={animated ? 800 : 0}
            >
              {safeData.map((entry, index) => (
                <Cell 
                  key={`cell-${index}`} 
                  fill={chartColors[index % chartColors.length]}
                  stroke={isDarkMode ? colors.cardBackground : 'white'}
                  strokeWidth={2}
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
