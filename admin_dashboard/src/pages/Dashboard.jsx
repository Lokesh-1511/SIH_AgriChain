import React, { useState, useEffect } from 'react';
import { useTheme } from '../contexts/ThemeContext.jsx';
import StatCard from '../components/common/StatCard';
import { AnimatedCard, StaggeredList } from '../components/common/PageTransitions';
import ErrorBoundary from '../components/common/ErrorBoundary';
import PieChart from '../components/charts/PieChart';
import BarChart from '../components/charts/BarChart';
import LineChart from '../components/charts/LineChart';
import { BlockchainService } from '../services/mockData';
import './Dashboard.css';

const Dashboard = () => {
  const { colors } = useTheme();
  const [dashboardData, setDashboardData] = useState({
    stats: {},
    transactions: [],
    analytics: {},
    loading: true
  });

  useEffect(() => {
    const loadDashboardData = async () => {
      try {
        // Simulate API calls
        const [transactions, batches] = await Promise.all([
          BlockchainService.getTransactions(),
          BlockchainService.getBatches()
        ]);

        const stats = {
          totalBatches: batches.length,
          activeBatches: batches.filter(b => b.status === 'In Transit').length,
          completedBatches: batches.filter(b => b.status === 'Delivered').length,
          totalValue: batches.reduce((sum, b) => sum + b.value, 0),
          avgProcessingTime: '24h',
          successRate: 98.5
        };

        const chartData = {
          batchStatus: [
            { name: 'Completed', value: stats.completedBatches, color: colors.success },
            { name: 'In Transit', value: stats.activeBatches, color: colors.primary },
            { name: 'Processing', value: 12, color: colors.warning },
            { name: 'Issues', value: 3, color: colors.error }
          ],
          monthlyTrends: [
            { name: 'Jan', batches: 120, value: 2400000 },
            { name: 'Feb', batches: 145, value: 2890000 },
            { name: 'Mar', batches: 132, value: 2640000 },
            { name: 'Apr', batches: 167, value: 3340000 },
            { name: 'May', batches: 189, value: 3780000 },
            { name: 'Jun', batches: 156, value: 3120000 }
          ],
          regionData: [
            { name: 'North', batches: 234, value: 4680000 },
            { name: 'South', batches: 189, value: 3780000 },
            { name: 'East', batches: 167, value: 3340000 },
            { name: 'West', batches: 145, value: 2900000 }
          ]
        };

        setDashboardData({
          stats,
          transactions: transactions.slice(0, 10),
          analytics: chartData,
          loading: false
        });
      } catch (error) {
        console.error('Failed to load dashboard data:', error);
        setDashboardData(prev => ({ ...prev, loading: false }));
      }
    };

    loadDashboardData();
    
    // Set up real-time updates
    const interval = setInterval(loadDashboardData, 30000); // Update every 30 seconds
    return () => clearInterval(interval);
  }, [colors]);

  const getStatusColor = (status) => {
    switch (status) {
      case 'Delivered': return colors.success;
      case 'In Transit': return colors.primary;
      case 'Processing': return colors.warning;
      case 'Issue': return colors.error;
      default: return colors.textSecondary;
    }
  };

  const formatCurrency = (value) => {
    return new Intl.NumberFormat('en-IN', {
      style: 'currency',
      currency: 'INR',
      minimumFractionDigits: 0
    }).format(value);
  };

  if (dashboardData.loading) {
    return (
      <div className="dashboard-loading">
        <div className="loading-spinner-large"></div>
        <p>Loading dashboard data...</p>
      </div>
    );
  }

  return (
    <div className="dashboard-container">
      <div className="dashboard-header">
        <h1 className="dashboard-title">AgriChain Dashboard</h1>
        <p className="dashboard-subtitle">Real-time supply chain monitoring and analytics</p>
      </div>

      {/* Key Statistics */}
      <section className="dashboard-section">
        <StaggeredList className="stats-grid">
          <AnimatedCard>
            <StatCard
              title="Total Batches"
              value={dashboardData.stats.totalBatches?.toLocaleString()}
              subtitle="Tracked this month"
              icon="📦"
              trend={{ direction: 'up', value: '+12%' }}
              color="primary"
              gradient={true}
              animated={true}
            />
          </AnimatedCard>
          
          <AnimatedCard delay={200}>
            <StatCard
              title="Active Shipments"
              value={dashboardData.stats.activeBatches}
              subtitle="Currently in transit"
              icon="🚛"
              trend={{ direction: 'up', value: '+8%' }}
              color="secondary"
              animated={true}
            />
          </AnimatedCard>
          
          <AnimatedCard delay={400}>
            <StatCard
              title="Total Value"
              value={formatCurrency(dashboardData.stats.totalValue)}
              subtitle="Supply chain value"
              icon="💰"
              trend={{ direction: 'up', value: '+15%' }}
              color="success"
              gradient={true}
              animated={true}
            />
          </AnimatedCard>
          
          <AnimatedCard delay={600}>
            <StatCard
              title="Success Rate"
              value={`${dashboardData.stats.successRate}%`}
              subtitle="Delivery success rate"
              icon="✅"
              trend={{ direction: 'up', value: '+2.1%' }}
              color="info"
              animated={true}
            />
          </AnimatedCard>
        </StaggeredList>
      </section>

      {/* Analytics Charts */}
      <section className="dashboard-section">
        <div className="charts-grid">
          <AnimatedCard delay={800} className="chart-card">
            <ErrorBoundary>
              <PieChart
                data={dashboardData.analytics.batchStatus}
                title="Batch Status Distribution"
                height={300}
                showLegend={true}
                animated={true}
              />
            </ErrorBoundary>
          </AnimatedCard>
          
          <AnimatedCard delay={1000} className="chart-card">
            <LineChart
              data={dashboardData.analytics.monthlyTrends}
              title="Monthly Processing Trends"
              dataKey="batches"
              nameKey="name"
              height={300}
              animated={true}
              smooth={true}
            />
          </AnimatedCard>
          
          <AnimatedCard delay={1200} className="chart-card large-chart">
            <BarChart
              data={dashboardData.analytics.regionData}
              title="Regional Performance"
              dataKey="batches"
              nameKey="name"
              height={350}
              gradient={true}
              animated={true}
            />
          </AnimatedCard>
        </div>
      </section>

      {/* Real-time Transaction Feed */}
      <section className="dashboard-section">
        <AnimatedCard delay={1400} className="transaction-feed-card">
          <div className="card transaction-feed">
            <div className="card-header">
              <h3 className="card-title">🔄 Real-time Transaction Feed</h3>
              <div className="live-indicator">
                <div className="live-dot"></div>
                <span>Live</span>
              </div>
            </div>
            
            <div className="card-body">
              <div className="transaction-list">
                {dashboardData.transactions.map((tx, index) => (
                  <div key={tx.id} className="transaction-item">
                    <div className="transaction-icon">
                      {tx.type === 'Harvest' && '🌾'}
                      {tx.type === 'Transport' && '🚛'}
                      {tx.type === 'Processing' && '⚙️'}
                      {tx.type === 'Sale' && '💰'}
                    </div>
                    
                    <div className="transaction-details">
                      <div className="transaction-header">
                        <span className="batch-id">{tx.batchId}</span>
                        <span className="transaction-type">{tx.type}</span>
                      </div>
                      <div className="transaction-meta">
                        <span className="timestamp">{new Date(tx.timestamp).toLocaleTimeString()}</span>
                        <span 
                          className="status-badge" 
                          style={{ backgroundColor: getStatusColor(tx.status) }}
                        >
                          {tx.status}
                        </span>
                      </div>
                    </div>
                    
                    <div className="transaction-amount">
                      {tx.amount && formatCurrency(tx.amount)}
                    </div>
                  </div>
                ))}
              </div>
              
              <div className="feed-footer">
                <button className="btn btn-secondary">
                  View All Transactions
                </button>
              </div>
            </div>
          </div>
        </AnimatedCard>
      </section>
    </div>
  );
};

export default Dashboard;