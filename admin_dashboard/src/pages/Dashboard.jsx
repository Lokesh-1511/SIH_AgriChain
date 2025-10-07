import React, { useState, useEffect } from 'react';
import { useTheme } from '../contexts/ThemeContext.jsx';
import StatCard from '../components/common/StatCard';
import { AnimatedCard, StaggeredList } from '../components/common/PageTransitions';
import ErrorBoundary from '../components/common/ErrorBoundary';
import PieChart from '../components/charts/PieChart';
import BarChart from '../components/charts/BarChart';
import LineChart from '../components/charts/LineChart';
import { BlockchainService } from '../services/mockData';
import { dashboardApi } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { 
  Dialog, 
  DialogTitle, 
  DialogContent, 
  DialogActions, 
  Button, 
  Table, 
  TableBody, 
  TableCell, 
  TableContainer, 
  TableHead, 
  TableRow, 
  Paper,
  Chip,
  IconButton
} from '@mui/material';
import { Close as CloseIcon } from '@mui/icons-material';
import './Dashboard.css';

const Dashboard = () => {
  const { colors } = useTheme();
  const { user } = useAuth();
  const [dashboardData, setDashboardData] = useState({
    stats: {},
    transactions: [],
    analytics: {},
    loading: true,
    backend: { attempted: false, used: false, error: null }
  });
  const [showAllTransactions, setShowAllTransactions] = useState(false);
  const [allTransactions, setAllTransactions] = useState([]);

  useEffect(() => {
    const loadDashboardData = async () => {
      try {
        // Always attempt backend first
        try {
          const [overviewRes, activityRes] = await Promise.all([
            dashboardApi.overview(),
            dashboardApi.activity()
          ]);

          const overview = overviewRes?.data || {};
          const activity = activityRes?.data || {};

          // Backend returns { users, batches, transactions }
          const batchStats = overview.batches || {};
          const userStats = overview.users || {};
          const txStats = overview.transactions || {};

          // Derive frontend-facing stats
            const byStatus = Array.isArray(batchStats.byStatus) ? batchStats.byStatus : [];
          const findStatus = (name) => byStatus.find(s => s.status === name) || { count: 0 };
          const delivered = findStatus('delivered').count;
          const inTransit = findStatus('in_transit').count;
          const totalBatches = batchStats.totalBatches || 0;
          const totalValue = (batchStats.totals && (batchStats.totals.currentValue || batchStats.totals.baseValue)) || 0;

          const stats = {
            totalBatches,
            activeBatches: inTransit,
            completedBatches: delivered,
            totalValue,
            avgProcessingTime: '—', // Not yet implemented in backend
            successRate: txStats.totalTransactions ? 100 : 0 // Placeholder
          };

          // Transactions from backend activity { transactions }
          const backendTx = Array.isArray(activity.transactions) ? activity.transactions : [];
          const mappedTx = backendTx.slice(0, 10).map(t => ({
            id: t.id || t._id,
            batchId: (t.batchId && (t.batchId.batchCode || t.batchId.productName)) || t.batch_id || '—',
            type: t.transactionType || t.transaction_type || '—',
            timestamp: t.occurredAt || t.timestamp || t.createdAt || new Date().toISOString(),
            status: t.status || 'pending',
            amount: t.amount
          }));

          // Basic analytics mapping using available batch status counts
          const analytics = {
            batchStatus: byStatus.map(s => ({
              name: s.status,
              value: s.count,
              color: colors.primary
            })),
            monthlyTrends: [],
            regionData: []
          };

          setDashboardData({
            stats,
            transactions: mappedTx,
            analytics,
            loading: false,
            backend: { attempted: true, used: true, error: null }
          });
          return; // Skip fallback
        } catch (be) {
          console.warn('[Dashboard] Backend fetch failed, using mock fallback:', be.message);
          setDashboardData(prev => ({ ...prev, backend: { attempted: true, used: false, error: be.message } }));
        }

        // Fallback to mock data only if backend failed
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
        setDashboardData(prev => ({
          stats,
          transactions: transactions.slice(0, 10),
          analytics: chartData,
          loading: false,
          backend: { attempted: true, used: false, error: prev.backend.error }
        }));
      } catch (error) {
        console.error('Failed to load dashboard data:', error);
        setDashboardData(prev => ({ ...prev, loading: false }));
      }
    };

    loadDashboardData();
    const interval = setInterval(loadDashboardData, 30000);
    return () => clearInterval(interval);
  }, [colors, user]);

  const handleViewAllTransactions = async () => {
    try {
      const allTx = await BlockchainService.getTransactions();
      setAllTransactions(allTx);
      setShowAllTransactions(true);
    } catch (error) {
      console.error('Failed to load all transactions:', error);
    }
  };

  // StatCard click handlers
  const handleTotalBatchesClick = () => {
    // Navigate to supply chain monitoring with filter for all batches
    window.location.href = '/supply-chain';
  };

  const handleActiveShipmentsClick = () => {
    // Navigate to supply chain monitoring with filter for active batches
    window.location.href = '/supply-chain?filter=active';
  };

  const handleTotalValueClick = () => {
    // Navigate to reports page with financial summary
    window.location.href = '/reports?view=financial';
  };

  const handleSuccessRateClick = () => {
    // Navigate to reports page with delivery analytics
    window.location.href = '/reports?view=delivery';
  };

  const getStatusColor = (status) => {
    const s = (status || '').toLowerCase();
    switch (s) {
      case 'delivered': return colors.success;
      case 'in transit':
      case 'in_transit': return colors.primary;
      case 'processing':
      case 'pending': return colors.warning;
      case 'issue':
      case 'error': return colors.error;
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

  // All Transactions Modal Component
  const AllTransactionsModal = () => (
    <Dialog 
      open={showAllTransactions} 
      onClose={() => setShowAllTransactions(false)}
      maxWidth="lg"
      fullWidth
    >
      <DialogTitle>
        All Transactions
        <IconButton
          aria-label="close"
          onClick={() => setShowAllTransactions(false)}
          sx={{ position: 'absolute', right: 8, top: 8 }}
        >
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Transaction ID</TableCell>
                <TableCell>Batch ID</TableCell>
                <TableCell>Type</TableCell>
                <TableCell>Timestamp</TableCell>
                <TableCell>Status</TableCell>
                <TableCell>Amount</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {allTransactions.map((tx) => (
                <TableRow key={tx.id}>
                  <TableCell>{tx.id}</TableCell>
                  <TableCell>{tx.batchId}</TableCell>
                  <TableCell>{tx.type}</TableCell>
                  <TableCell>{new Date(tx.timestamp).toLocaleString()}</TableCell>
                  <TableCell>
                    <Chip 
                      label={tx.status} 
                      size="small"
                      style={{ 
                        backgroundColor: getStatusColor(tx.status),
                        color: 'white'
                      }}
                    />
                  </TableCell>
                  <TableCell>
                    {tx.amount ? formatCurrency(tx.amount) : 'N/A'}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </DialogContent>
      <DialogActions>
        <Button onClick={() => setShowAllTransactions(false)}>
          Close
        </Button>
      </DialogActions>
    </Dialog>
  );

  return (
    <div className="dashboard-container">
      {dashboardData.backend.attempted && !dashboardData.backend.used && (
        <div style={{
          background: '#fff3cd',
          color: '#664d03',
          padding: '8px 12px',
          border: '1px solid #ffecb5',
          borderRadius: 6,
          marginBottom: 16,
          fontSize: 14
        }}>
          Using mock data (backend unreachable or disabled).
          {dashboardData.backend.error && (
            <span style={{ marginLeft: 8 }}>
              Last error: {dashboardData.backend.error}
            </span>
          )}
        </div>
      )}
      <AllTransactionsModal />
      
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
              
              trend={{ direction: 'up', value: '+12%' }}
              color="primary"
              gradient={true}
              animated={true}
              onClick={handleTotalBatchesClick}
            />
          </AnimatedCard>
          
          <AnimatedCard delay={200}>
            <StatCard
              title="Active Shipments"
              value={dashboardData.stats.activeBatches}
              subtitle="Currently in transit"
             
              trend={{ direction: 'up', value: '+8%' }}
              color="secondary"
              animated={true}
              onClick={handleActiveShipmentsClick}
            />
          </AnimatedCard>
          
          <AnimatedCard delay={400}>
            <StatCard
              title="Total Value"
              value={formatCurrency(dashboardData.stats.totalValue)}
              subtitle="Supply chain value"
              
              trend={{ direction: 'up', value: '+15%' }}
              color="success"
              gradient={true}
              animated={true}
              onClick={handleTotalValueClick}
            />
          </AnimatedCard>
          
          <AnimatedCard delay={600}>
            <StatCard
              title="Success Rate"
              value={`${dashboardData.stats.successRate}%`}
              subtitle="Delivery success rate"
              
              trend={{ direction: 'up', value: '+2.1%' }}
              color="info"
              animated={true}
              onClick={handleSuccessRateClick}
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
              <h3 className="card-title">Real-time Transaction Feed</h3>
              <div className="live-indicator">
                <div className="live-dot"></div>
                <span>Live</span>
              </div>
            </div>
            
            <div className="card-body">
              {dashboardData.backend.used && dashboardData.transactions.length === 0 && (
                <div style={{ padding: '24px', textAlign: 'center', opacity: 0.8 }}>
                  <p style={{ margin: 0, fontWeight: 500 }}>No transactions yet</p>
                  <p style={{ marginTop: 4, fontSize: 14 }}>Seed data or perform actions in the system to see real-time activity.</p>
                </div>
              )}
              <div className="transaction-list">
                {dashboardData.transactions.map((tx) => (
                  <div key={tx.id} className="transaction-item">
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
                <button 
                  className="btn btn-secondary"
                  onClick={handleViewAllTransactions}
                >
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