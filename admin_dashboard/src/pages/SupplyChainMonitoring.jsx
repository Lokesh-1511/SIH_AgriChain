import React, { useState, useEffect } from 'react';
import { useTheme } from '../contexts/ThemeContext.jsx';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Grid,
  Paper,
  Stepper,
  Step,
  StepLabel,
  StepContent,
  Avatar,
  Chip,
  TextField,
  Button,
  Alert,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Dialog,
  DialogTitle,
  DialogContent,
  IconButton,
  Tooltip,
  Divider,
} from '@mui/material';
import {
  Search,
  Timeline,
  Warning,
  CheckCircle,
  LocalShipping,
  Agriculture,
  Store,
  ShoppingCart,
  Close,
  TrendingUp,
  Schedule,
  Error,
} from '@mui/icons-material';

// Mock supply chain data
const mockSupplyChainData = {
  'BATCH_2024_001': {
    id: 'BATCH_2024_001',
    crop: 'Wheat',
    quantity: '1000 kg',
    currentStatus: 'In Transit',
    timeline: [
      {
        step: 'Harvest',
        actor: 'John Smith (Farmer)',
        walletId: '0x1234...abcd',
        timestamp: '2024-01-15T08:00:00Z',
        location: 'California Farm #1',
        status: 'completed',
        price: 1200,
        notes: 'High-quality organic wheat harvested',
        verified: true,
      },
      {
        step: 'Processing',
        actor: 'John Smith (Farmer)',
        walletId: '0x1234...abcd',
        timestamp: '2024-01-15T12:00:00Z',
        location: 'On-site Processing',
        status: 'completed',
        price: 1200,
        notes: 'Cleaned and packaged for distribution',
        verified: true,
      },
      {
        step: 'Distribution',
        actor: 'ABC Distribution',
        walletId: '0x5678...efgh',
        timestamp: '2024-01-16T09:00:00Z',
        location: 'Distribution Center A',
        status: 'active',
        price: 1450,
        margin: 20.8, // High margin alert
        notes: 'Currently in transport to retailer',
        verified: false,
      },
      {
        step: 'Retail',
        actor: 'XYZ Retail Chain',
        walletId: '0x9012...ijkl',
        timestamp: null,
        location: 'Pending',
        status: 'pending',
        price: null,
        notes: 'Awaiting delivery',
        verified: false,
      },
      {
        step: 'Consumer',
        actor: 'End Consumer',
        walletId: null,
        timestamp: null,
        location: 'Pending',
        status: 'pending',
        price: null,
        notes: 'Not yet sold',
        verified: false,
      }
    ],
    anomalies: [
      {
        type: 'High Margin',
        severity: 'Medium',
        message: 'Distribution margin of 20.8% exceeds the recommended 15% threshold',
        step: 'Distribution',
        detected: '2024-01-16T10:30:00Z'
      }
    ]
  },
  'BATCH_2024_002': {
    id: 'BATCH_2024_002',
    crop: 'Rice',
    quantity: '800 kg',
    currentStatus: 'Delivered',
    timeline: [
      {
        step: 'Harvest',
        actor: 'Mary Johnson (Farmer)',
        walletId: '0x2468...bcde',
        timestamp: '2024-01-10T07:30:00Z',
        location: 'Texas Rice Farm',
        status: 'completed',
        price: 950,
        verified: true,
      },
      {
        step: 'Distribution',
        actor: 'Regional Distributors',
        walletId: '0x3579...cdef',
        timestamp: '2024-01-12T14:00:00Z',
        location: 'Texas Distribution Hub',
        status: 'completed',
        price: 1100,
        margin: 15.8,
        verified: true,
      },
      {
        step: 'Retail',
        actor: 'Local Market Co.',
        walletId: '0x4680...deff',
        timestamp: '2024-01-14T11:00:00Z',
        location: 'City Market Downtown',
        status: 'completed',
        price: 1300,
        margin: 18.2,
        verified: true,
      }
    ],
    anomalies: [
      {
        type: 'Transport Delay',
        severity: 'Low',
        message: 'Delivery was 4 hours later than scheduled',
        step: 'Distribution',
        detected: '2024-01-12T18:00:00Z'
      }
    ]
  }
};

const getStepIcon = (step) => {
  const icons = {
    Harvest: <Agriculture />,
    Processing: <Agriculture />,
    Distribution: <LocalShipping />,
    Retail: <Store />,
    Consumer: <ShoppingCart />,
  };
  return icons[step] || <Timeline />;
};

const getStatusColor = (status) => {
  const colors = {
    completed: 'success',
    active: 'primary',
    pending: 'default',
  };
  return colors[status] || 'default';
};

const BatchTraceabilityDialog = ({ batch, open, onClose }) => {
  if (!batch) return null;

  const activeStepIndex = batch.timeline.findIndex(step => step.status === 'active');
  const completedSteps = batch.timeline.filter(step => step.status === 'completed').length;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Box>
            <Typography variant="h6">Batch Traceability: {batch.id}</Typography>
            <Typography variant="body2" color="text.secondary">
              {batch.crop} - {batch.quantity}
            </Typography>
          </Box>
          <IconButton onClick={onClose}>
            <Close />
          </IconButton>
        </Box>
      </DialogTitle>
      
      <DialogContent>
        {/* Progress Overview */}
        <Card sx={{ mb: 3, bgcolor: 'primary.50' }}>
          <CardContent>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
              <Typography variant="h6">Supply Chain Progress</Typography>
              <Chip 
                label={batch.currentStatus} 
                color={batch.currentStatus === 'Completed' ? 'success' : 'primary'} 
              />
            </Box>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              {completedSteps} of {batch.timeline.length} steps completed
            </Typography>
          </CardContent>
        </Card>

        {/* Anomalies Alert */}
        {batch.anomalies && batch.anomalies.length > 0 && (
          <Alert severity="warning" sx={{ mb: 3 }}>
            <Typography variant="subtitle2" gutterBottom>
              {batch.anomalies.length} Anomal{batch.anomalies.length > 1 ? 'ies' : 'y'} Detected
            </Typography>
            {batch.anomalies.map((anomaly, index) => (
              <Typography key={index} variant="body2">
                • {anomaly.message}
              </Typography>
            ))}
          </Alert>
        )}

        {/* Timeline Stepper */}
        <Stepper 
          activeStep={activeStepIndex >= 0 ? activeStepIndex : completedSteps} 
          orientation="vertical"
          sx={{ mt: 2 }}
        >
          {batch.timeline.map((step, index) => (
            <Step key={index} completed={step.status === 'completed'}>
              <StepLabel
                StepIconComponent={() => (
                  <Avatar
                    sx={{
                      bgcolor: step.status === 'completed' ? 'success.main' : 
                              step.status === 'active' ? 'primary.main' : 'grey.300',
                      width: 40,
                      height: 40,
                    }}
                  >
                    {getStepIcon(step.step)}
                  </Avatar>
                )}
              >
                <Box sx={{ ml: 1 }}>
                  <Typography variant="h6">{step.step}</Typography>
                  <Typography variant="body2" color="text.secondary">
                    {step.actor}
                  </Typography>
                </Box>
              </StepLabel>
              <StepContent>
                <Card variant="outlined" sx={{ p: 2, mt: 1, mb: 2 }}>
                  <Grid container spacing={2}>
                    <Grid item xs={12} md={6}>
                      <Typography variant="body2" color="text.secondary">
                        Location
                      </Typography>
                      <Typography variant="body1" gutterBottom>
                        {step.location}
                      </Typography>
                      
                      {step.timestamp && (
                        <>
                          <Typography variant="body2" color="text.secondary">
                            Timestamp
                          </Typography>
                          <Typography variant="body1" gutterBottom>
                            {new Date(step.timestamp).toLocaleString()}
                          </Typography>
                        </>
                      )}
                    </Grid>
                    
                    <Grid item xs={12} md={6}>
                      {step.price && (
                        <>
                          <Typography variant="body2" color="text.secondary">
                            Price
                          </Typography>
                          <Typography variant="body1" gutterBottom>
                            ${step.price.toLocaleString()}
                          </Typography>
                        </>
                      )}
                      
                      {step.margin && (
                        <>
                          <Typography variant="body2" color="text.secondary">
                            Margin
                          </Typography>
                          <Typography 
                            variant="body1" 
                            color={step.margin > 20 ? 'error.main' : 'text.primary'}
                            gutterBottom
                          >
                            {step.margin}%
                            {step.margin > 20 && ' ⚠️'}
                          </Typography>
                        </>
                      )}
                      
                      {step.walletId && (
                        <>
                          <Typography variant="body2" color="text.secondary">
                            Wallet ID
                          </Typography>
                          <Typography variant="body2" fontFamily="monospace" gutterBottom>
                            {step.walletId}
                          </Typography>
                        </>
                      )}
                    </Grid>
                    
                    {step.notes && (
                      <Grid item xs={12}>
                        <Typography variant="body2" color="text.secondary">
                          Notes
                        </Typography>
                        <Typography variant="body2">
                          {step.notes}
                        </Typography>
                      </Grid>
                    )}
                  </Grid>
                  
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mt: 2 }}>
                    <Chip
                      label={step.status}
                      color={getStatusColor(step.status)}
                      size="small"
                    />
                    {step.verified && (
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                        <CheckCircle color="success" fontSize="small" />
                        <Typography variant="caption" color="success.main">
                          Verified
                        </Typography>
                      </Box>
                    )}
                  </Box>
                </Card>
              </StepContent>
            </Step>
          ))}
        </Stepper>
      </DialogContent>
    </Dialog>
  );
};

const SupplyChainMonitoring = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBatch, setSelectedBatch] = useState(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [allAnomalies, setAllAnomalies] = useState([]);

  useEffect(() => {
    // Collect all anomalies from all batches
    const anomalies = [];
    Object.values(mockSupplyChainData).forEach(batch => {
      if (batch.anomalies) {
        batch.anomalies.forEach(anomaly => {
          anomalies.push({
            ...anomaly,
            batchId: batch.id,
            crop: batch.crop,
          });
        });
      }
    });
    setAllAnomalies(anomalies);
  }, []);

  const handleSearch = () => {
    if (!searchQuery.trim()) return;
    
    const batch = mockSupplyChainData[searchQuery.toUpperCase()];
    if (batch) {
      setSelectedBatch(batch);
      setDialogOpen(true);
    } else {
      alert('Batch not found. Try BATCH_2024_001 or BATCH_2024_002');
    }
  };

  const handleBatchClick = (batchId) => {
    const batch = mockSupplyChainData[batchId];
    if (batch) {
      setSelectedBatch(batch);
      setDialogOpen(true);
    }
  };

  const getSeverityColor = (severity) => {
    const colors = {
      High: 'error',
      Medium: 'warning',
      Low: 'info',
    };
    return colors[severity] || 'default';
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom fontWeight="bold">
        Supply Chain Monitoring
      </Typography>
      
      {/* Search Section */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Batch Traceability Search
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
            <TextField
              placeholder="Enter Batch ID (e.g., BATCH_2024_001)"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              sx={{ flexGrow: 1 }}
              InputProps={{
                startAdornment: <Search sx={{ mr: 1, color: 'text.secondary' }} />
              }}
              onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            />
            <Button variant="contained" onClick={handleSearch}>
              Trace Batch
            </Button>
          </Box>
        </CardContent>
      </Card>

      {/* AI Anomaly Alerts */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
            <Warning color="warning" />
            <Typography variant="h6">AI Anomaly Detection</Typography>
            <Chip 
              label={`${allAnomalies.length} Active`} 
              color="warning" 
              size="small" 
            />
          </Box>
          
          <List>
            {allAnomalies.map((anomaly, index) => (
              <ListItem key={index} divider={index < allAnomalies.length - 1}>
                <ListItemIcon>
                  {anomaly.severity === 'High' ? (
                    <Error color="error" />
                  ) : anomaly.severity === 'Medium' ? (
                    <Warning color="warning" />
                  ) : (
                    <Schedule color="info" />
                  )}
                </ListItemIcon>
                <ListItemText
                  primary={
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Typography variant="subtitle2">
                        {anomaly.type} - {anomaly.batchId}
                      </Typography>
                      <Chip
                        label={anomaly.severity}
                        color={getSeverityColor(anomaly.severity)}
                        size="small"
                      />
                    </Box>
                  }
                  secondary={
                    <Box>
                      <Typography variant="body2" color="text.secondary">
                        {anomaly.message}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        Detected: {new Date(anomaly.detected).toLocaleString()}
                      </Typography>
                    </Box>
                  }
                />
                <Button 
                  variant="outlined" 
                  size="small"
                  onClick={() => handleBatchClick(anomaly.batchId)}
                >
                  View Batch
                </Button>
              </ListItem>
            ))}
          </List>
        </CardContent>
      </Card>

      {/* Active Batches Overview */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Active Batch Overview
          </Typography>
          
          <Grid container spacing={2}>
            {Object.values(mockSupplyChainData).map((batch) => (
              <Grid item xs={12} md={6} key={batch.id}>
                <Card 
                  variant="outlined" 
                  sx={{ 
                    cursor: 'pointer',
                    transition: 'transform 0.2s, box-shadow 0.2s',
                    '&:hover': {
                      transform: 'translateY(-2px)',
                      boxShadow: 3,
                    }
                  }}
                  onClick={() => handleBatchClick(batch.id)}
                >
                  <CardContent>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', mb: 2 }}>
                      <Box>
                        <Typography variant="h6">{batch.id}</Typography>
                        <Typography variant="body2" color="text.secondary">
                          {batch.crop} - {batch.quantity}
                        </Typography>
                      </Box>
                      <Chip 
                        label={batch.currentStatus} 
                        color={batch.currentStatus === 'Completed' ? 'success' : 'primary'}
                        size="small"
                      />
                    </Box>
                    
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
                      <Timeline color="primary" />
                      <Typography variant="body2">
                        {batch.timeline.filter(s => s.status === 'completed').length} of {batch.timeline.length} steps completed
                      </Typography>
                    </Box>
                    
                    {batch.anomalies && batch.anomalies.length > 0 && (
                      <Alert severity="warning" size="small">
                        {batch.anomalies.length} anomal{batch.anomalies.length > 1 ? 'ies' : 'y'} detected
                      </Alert>
                    )}
                  </CardContent>
                </Card>
              </Grid>
            ))}
          </Grid>
        </CardContent>
      </Card>

      {/* Batch Details Dialog */}
      <BatchTraceabilityDialog
        batch={selectedBatch}
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
      />
    </Box>
  );
};

export default SupplyChainMonitoring;