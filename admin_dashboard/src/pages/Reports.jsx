import React, { useState, useEffect } from 'react';
import { useTheme } from '../contexts/ThemeContext.jsx';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Button,
  Grid,
  TextField,
  MenuItem,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  LinearProgress,
  Chip,
  Alert,
  Tabs,
  Tab,
} from '@mui/material';
import {
  Download,
  PictureAsPdf,
  TableChart,
  Assessment,
  DateRange,
  FilterList,
} from '@mui/icons-material';
import { BlockchainService } from '../services/mockData';

// Mock report data
const mockReportData = {
  transactions: [
    {
      id: 'tx_001',
      date: '2024-01-15',
      batchId: 'BATCH_2024_001',
      type: 'Harvest',
      from: 'John Smith',
      to: 'ABC Distribution',
      amount: 1250.00,
      status: 'Completed',
      gasUsed: 21000,
    },
    {
      id: 'tx_002',
      date: '2024-01-16',
      batchId: 'BATCH_2024_001',
      type: 'Transport',
      from: 'ABC Distribution',
      to: 'XYZ Retail',
      amount: 1890.50,
      status: 'Completed',
      gasUsed: 35000,
    },
    {
      id: 'tx_003',
      date: '2024-01-10',
      batchId: 'BATCH_2024_002',
      type: 'Harvest',
      from: 'Mary Johnson',
      to: 'Regional Distributors',
      amount: 950.00,
      status: 'Completed',
      gasUsed: 21000,
    },
  ],
  pricing: [
    {
      batchId: 'BATCH_2024_001',
      crop: 'Wheat',
      farmerPrice: 1200,
      distributorPrice: 1450,
      retailPrice: 1890,
      finalPrice: 2340,
      farmerMargin: 0,
      distributorMargin: 20.8,
      retailMargin: 30.3,
    },
    {
      batchId: 'BATCH_2024_002',
      crop: 'Rice',
      farmerPrice: 950,
      distributorPrice: 1100,
      retailPrice: 1300,
      finalPrice: 1560,
      farmerMargin: 0,
      distributorMargin: 15.8,
      retailMargin: 18.2,
    },
  ],
  anomalies: [
    {
      id: 1,
      date: '2024-01-16',
      type: 'High Margin',
      batchId: 'BATCH_2024_001',
      severity: 'Medium',
      description: 'Distribution margin of 20.8% exceeds threshold',
      resolved: false,
    },
    {
      id: 2,
      date: '2024-01-12',
      type: 'Transport Delay',
      batchId: 'BATCH_2024_002',
      severity: 'Low',
      description: 'Delivery delayed by 4 hours',
      resolved: true,
    },
  ],
};

// Export utilities
const exportToPDF = (data, reportType) => {
  // Mock PDF export - in real app, use jsPDF
  const content = generateReportContent(data, reportType);
  const blob = new Blob([content], { type: 'text/plain' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${reportType}_report_${new Date().toISOString().split('T')[0]}.txt`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  window.URL.revokeObjectURL(url);
};

const exportToCSV = (data, reportType) => {
  let csvContent = '';
  
  if (reportType === 'transactions') {
    csvContent = 'ID,Date,Batch ID,Type,From,To,Amount,Status,Gas Used\n';
    data.forEach(row => {
      csvContent += `${row.id},${row.date},${row.batchId},${row.type},${row.from},${row.to},${row.amount},${row.status},${row.gasUsed}\n`;
    });
  } else if (reportType === 'pricing') {
    csvContent = 'Batch ID,Crop,Farmer Price,Distributor Price,Retail Price,Final Price,Distributor Margin,Retail Margin\n';
    data.forEach(row => {
      csvContent += `${row.batchId},${row.crop},${row.farmerPrice},${row.distributorPrice},${row.retailPrice},${row.finalPrice},${row.distributorMargin}%,${row.retailMargin}%\n`;
    });
  } else if (reportType === 'anomalies') {
    csvContent = 'ID,Date,Type,Batch ID,Severity,Description,Resolved\n';
    data.forEach(row => {
      csvContent += `${row.id},${row.date},${row.type},${row.batchId},${row.severity},"${row.description}",${row.resolved}\n`;
    });
  }

  const blob = new Blob([csvContent], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `${reportType}_report_${new Date().toISOString().split('T')[0]}.csv`;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  window.URL.revokeObjectURL(url);
};

const generateReportContent = (data, reportType) => {
  const date = new Date().toLocaleDateString();
  let content = `AgriChain Admin Dashboard - ${reportType.toUpperCase()} REPORT\n`;
  content += `Generated on: ${date}\n\n`;
  
  if (reportType === 'transactions') {
    content += `TRANSACTION HISTORY REPORT\n`;
    content += `Total Transactions: ${data.length}\n`;
    content += `Total Value: $${data.reduce((sum, tx) => sum + tx.amount, 0).toLocaleString()}\n\n`;
    
    data.forEach(tx => {
      content += `Transaction: ${tx.id}\n`;
      content += `Date: ${tx.date}\n`;
      content += `Batch: ${tx.batchId}\n`;
      content += `Type: ${tx.type}\n`;
      content += `From: ${tx.from}\n`;
      content += `To: ${tx.to}\n`;
      content += `Amount: $${tx.amount}\n`;
      content += `Status: ${tx.status}\n`;
      content += `Gas Used: ${tx.gasUsed}\n`;
      content += '---\n';
    });
  }
  
  return content;
};

const ReportPreviewDialog = ({ open, onClose, data, reportType, title }) => {
  return (
    <Dialog open={open} onClose={onClose} maxWidth="lg" fullWidth>
      <DialogTitle>{title} Preview</DialogTitle>
      <DialogContent>
        <TableContainer component={Paper} sx={{ maxHeight: 400 }}>
          <Table size="small">
            <TableHead>
              <TableRow>
                {reportType === 'transactions' && (
                  <>
                    <TableCell>ID</TableCell>
                    <TableCell>Date</TableCell>
                    <TableCell>Batch ID</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>From</TableCell>
                    <TableCell>To</TableCell>
                    <TableCell>Amount</TableCell>
                    <TableCell>Status</TableCell>
                  </>
                )}
                {reportType === 'pricing' && (
                  <>
                    <TableCell>Batch ID</TableCell>
                    <TableCell>Crop</TableCell>
                    <TableCell>Farmer Price</TableCell>
                    <TableCell>Distributor Price</TableCell>
                    <TableCell>Retail Price</TableCell>
                    <TableCell>Final Price</TableCell>
                    <TableCell>Dist. Margin</TableCell>
                    <TableCell>Retail Margin</TableCell>
                  </>
                )}
                {reportType === 'anomalies' && (
                  <>
                    <TableCell>Date</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>Batch ID</TableCell>
                    <TableCell>Severity</TableCell>
                    <TableCell>Description</TableCell>
                    <TableCell>Status</TableCell>
                  </>
                )}
              </TableRow>
            </TableHead>
            <TableBody>
              {data.map((row, index) => (
                <TableRow key={index}>
                  {reportType === 'transactions' && (
                    <>
                      <TableCell>{row.id}</TableCell>
                      <TableCell>{row.date}</TableCell>
                      <TableCell>{row.batchId}</TableCell>
                      <TableCell>{row.type}</TableCell>
                      <TableCell>{row.from}</TableCell>
                      <TableCell>{row.to}</TableCell>
                      <TableCell>${row.amount}</TableCell>
                      <TableCell>
                        <Chip label={row.status} color="success" size="small" />
                      </TableCell>
                    </>
                  )}
                  {reportType === 'pricing' && (
                    <>
                      <TableCell>{row.batchId}</TableCell>
                      <TableCell>{row.crop}</TableCell>
                      <TableCell>${row.farmerPrice}</TableCell>
                      <TableCell>${row.distributorPrice}</TableCell>
                      <TableCell>${row.retailPrice}</TableCell>
                      <TableCell>${row.finalPrice}</TableCell>
                      <TableCell>{row.distributorMargin}%</TableCell>
                      <TableCell>{row.retailMargin}%</TableCell>
                    </>
                  )}
                  {reportType === 'anomalies' && (
                    <>
                      <TableCell>{row.date}</TableCell>
                      <TableCell>{row.type}</TableCell>
                      <TableCell>{row.batchId}</TableCell>
                      <TableCell>
                        <Chip 
                          label={row.severity} 
                          color={row.severity === 'High' ? 'error' : row.severity === 'Medium' ? 'warning' : 'info'}
                          size="small" 
                        />
                      </TableCell>
                      <TableCell>{row.description}</TableCell>
                      <TableCell>
                        <Chip 
                          label={row.resolved ? 'Resolved' : 'Open'} 
                          color={row.resolved ? 'success' : 'warning'}
                          size="small" 
                        />
                      </TableCell>
                    </>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Close</Button>
        <Button 
          variant="contained" 
          startIcon={<TableChart />}
          onClick={() => exportToCSV(data, reportType)}
        >
          Export CSV
        </Button>
        <Button 
          variant="contained" 
          startIcon={<PictureAsPdf />}
          onClick={() => exportToPDF(data, reportType)}
        >
          Export PDF
        </Button>
      </DialogActions>
    </Dialog>
  );
};

const Reports = () => {
  const { colors, isDarkMode } = useTheme();
  const [selectedTab, setSelectedTab] = useState(0);
  const [reportData, setReportData] = useState(mockReportData);
  const [loading, setLoading] = useState(false);
  const [previewDialog, setPreviewDialog] = useState({
    open: false,
    data: [],
    type: '',
    title: '',
  });
  const [filters, setFilters] = useState({
    dateFrom: '',
    dateTo: '',
    batchId: '',
    reportType: 'all',
  });

  const reportTypes = [
    {
      id: 'transactions',
      title: 'Transaction History',
      description: 'Complete transaction history with blockchain details',
      icon: <Assessment />,
      data: reportData.transactions,
    },
    {
      id: 'pricing',
      title: 'Price Breakdown',
      description: 'Price analysis and margin breakdown by supply chain stage',
      icon: <Assessment />,
      data: reportData.pricing,
    },
    {
      id: 'anomalies',
      title: 'Anomaly Report',
      description: 'AI-detected anomalies and fraud alerts',
      icon: <Assessment />,
      data: reportData.anomalies,
    },
  ];

  const handleGenerateReport = async (reportType) => {
    setLoading(true);
    try {
      // Mock data loading
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const report = reportTypes.find(r => r.id === reportType);
      setPreviewDialog({
        open: true,
        data: report.data,
        type: reportType,
        title: report.title,
      });
    } catch (error) {
      console.error('Error generating report:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleQuickExport = (reportType, format) => {
    const report = reportTypes.find(r => r.id === reportType);
    if (format === 'csv') {
      exportToCSV(report.data, reportType);
    } else {
      exportToPDF(report.data, reportType);
    }
  };

  const getReportStats = (reportType) => {
    const report = reportTypes.find(r => r.id === reportType);
    if (!report) return {};

    switch (reportType) {
      case 'transactions':
        return {
          total: report.data.length,
          totalValue: report.data.reduce((sum, tx) => sum + tx.amount, 0),
          successful: report.data.filter(tx => tx.status === 'Completed').length,
        };
      case 'pricing':
        return {
          total: report.data.length,
          avgMargin: (report.data.reduce((sum, p) => sum + p.distributorMargin + p.retailMargin, 0) / (report.data.length * 2)).toFixed(1),
          highestPrice: Math.max(...report.data.map(p => p.finalPrice)),
        };
      case 'anomalies':
        return {
          total: report.data.length,
          resolved: report.data.filter(a => a.resolved).length,
          critical: report.data.filter(a => a.severity === 'High').length,
        };
      default:
        return {};
    }
  };

  return (
    <Box sx={{ 
      backgroundColor: colors.background,
      color: colors.text,
      minHeight: '100vh',
      padding: 2
    }}>
      <Typography 
        variant="h4" 
        gutterBottom 
        fontWeight="bold"
        sx={{ color: colors.text }}
      >
        Reports & Analytics
      </Typography>
      
      {/* Filters Section */}
      <Card sx={{ 
        mb: 3, 
        backgroundColor: colors.cardBackground,
        color: colors.text,
        border: `1px solid ${colors.border}`
      }}>
        <CardContent>
          <Typography 
            variant="h6" 
            gutterBottom
            sx={{ color: colors.text }}
          >
            Report Filters
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                fullWidth
                label="From Date"
                type="date"
                value={filters.dateFrom}
                onChange={(e) => setFilters({ ...filters, dateFrom: e.target.value })}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                fullWidth
                label="To Date"
                type="date"
                value={filters.dateTo}
                onChange={(e) => setFilters({ ...filters, dateTo: e.target.value })}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                fullWidth
                label="Batch ID"
                value={filters.batchId}
                onChange={(e) => setFilters({ ...filters, batchId: e.target.value })}
                placeholder="e.g., BATCH_2024_001"
              />
            </Grid>
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                select
                fullWidth
                label="Report Type"
                value={filters.reportType}
                onChange={(e) => setFilters({ ...filters, reportType: e.target.value })}
              >
                <MenuItem value="all">All Reports</MenuItem>
                <MenuItem value="transactions">Transactions</MenuItem>
                <MenuItem value="pricing">Pricing</MenuItem>
                <MenuItem value="anomalies">Anomalies</MenuItem>
              </TextField>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Report Generation Cards */}
      <Grid container spacing={3}>
        {reportTypes.map((report) => {
          const stats = getReportStats(report.id);
          
          return (
            <Grid item xs={12} md={4} key={report.id}>
              <Card sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
                <CardContent sx={{ flexGrow: 1 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                    {report.icon}
                    <Typography variant="h6" sx={{ ml: 1 }}>
                      {report.title}
                    </Typography>
                  </Box>
                  
                  <Typography variant="body2" color="text.secondary" paragraph>
                    {report.description}
                  </Typography>

                  {/* Report Statistics */}
                  <Box sx={{ mb: 2 }}>
                    {report.id === 'transactions' && (
                      <Grid container spacing={1}>
                        <Grid item xs={6}>
                          <Typography variant="caption" color="text.secondary">Total</Typography>
                          <Typography variant="h6">{stats.total}</Typography>
                        </Grid>
                        <Grid item xs={6}>
                          <Typography variant="caption" color="text.secondary">Value</Typography>
                          <Typography variant="h6">${stats.totalValue?.toLocaleString()}</Typography>
                        </Grid>
                      </Grid>
                    )}
                    {report.id === 'pricing' && (
                      <Grid container spacing={1}>
                        <Grid item xs={6}>
                          <Typography variant="caption" color="text.secondary">Batches</Typography>
                          <Typography variant="h6">{stats.total}</Typography>
                        </Grid>
                        <Grid item xs={6}>
                          <Typography variant="caption" color="text.secondary">Avg Margin</Typography>
                          <Typography variant="h6">{stats.avgMargin}%</Typography>
                        </Grid>
                      </Grid>
                    )}
                    {report.id === 'anomalies' && (
                      <Grid container spacing={1}>
                        <Grid item xs={6}>
                          <Typography variant="caption" color="text.secondary">Total</Typography>
                          <Typography variant="h6">{stats.total}</Typography>
                        </Grid>
                        <Grid item xs={6}>
                          <Typography variant="caption" color="text.secondary">Critical</Typography>
                          <Typography variant="h6" color="error.main">{stats.critical}</Typography>
                        </Grid>
                      </Grid>
                    )}
                  </Box>

                  {loading && <LinearProgress />}
                </CardContent>
                
                <CardContent sx={{ pt: 0 }}>
                  <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                    <Button
                      variant="contained"
                      size="small"
                      onClick={() => handleGenerateReport(report.id)}
                      disabled={loading}
                    >
                      Preview & Export
                    </Button>
                    <Button
                      variant="outlined"
                      size="small"
                      startIcon={<TableChart />}
                      onClick={() => handleQuickExport(report.id, 'csv')}
                    >
                      CSV
                    </Button>
                    <Button
                      variant="outlined"
                      size="small"
                      startIcon={<PictureAsPdf />}
                      onClick={() => handleQuickExport(report.id, 'pdf')}
                    >
                      PDF
                    </Button>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          );
        })}
      </Grid>

      {/* Recent Reports Section */}
      <Card sx={{ mt: 4 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Recent Report Activity
          </Typography>
          <Alert severity="info">
            No recent report downloads. Generate reports using the cards above.
          </Alert>
        </CardContent>
      </Card>

      {/* Preview Dialog */}
      <ReportPreviewDialog
        open={previewDialog.open}
        onClose={() => setPreviewDialog({ ...previewDialog, open: false })}
        data={previewDialog.data}
        reportType={previewDialog.type}
        title={previewDialog.title}
      />
    </Box>
  );
};

export default Reports;