import React, { useState, useEffect } from 'react';
import { useTheme } from '../contexts/ThemeContext.jsx';
import {
  Box,
  Card,
  CardContent,
  Typography,
  TextField,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Grid,
  Avatar,
  Divider,
  Alert,
  Pagination,
  InputAdornment,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Tooltip,
  Link
} from '@mui/material';
import {
  Search,
  ExpandMore,
  Block,
  AccountBalanceWallet,
  Schedule,
  TrendingUp,
  Visibility,
  Link as LinkIcon,
  Close as CloseIcon,
  ContentCopy,
  OpenInNew
} from '@mui/icons-material';
import { BlockchainService } from '../services/mockData';

// Extended mock blockchain data
const mockBlockchainTransactions = [
  {
    id: 1,
    hash: '0x1a2b3c4d5e6f789012345678901234567890abcdef',
    batchId: 'BATCH_2024_001',
    blockNumber: 12458392,
    timestamp: '2024-01-15T08:00:00Z',
    from: '0x1234567890abcdef1234567890abcdef12345678',
    to: '0x5678901234567890abcdef1234567890abcdef12',
    value: 1200,
    gasUsed: 21000,
    gasPrice: 20,
    status: 'Success',
    function: 'harvestBatch',
    eventLogs: [
      {
        event: 'BatchHarvested',
        args: {
          batchId: 'BATCH_2024_001',
          farmer: '0x1234567890abcdef1234567890abcdef12345678',
          quantity: '1000',
          crop: 'Wheat'
        }
      }
    ]
  },
  {
    id: 2,
    hash: '0x2b3c4d5e6f789012345678901234567890abcdef1a',
    batchId: 'BATCH_2024_001',
    blockNumber: 12458445,
    timestamp: '2024-01-16T09:00:00Z',
    from: '0x5678901234567890abcdef1234567890abcdef12',
    to: '0x9012345678901234567890abcdef1234567890ab',
    value: 1450,
    gasUsed: 35000,
    gasPrice: 22,
    status: 'Success',
    function: 'transferBatch',
    eventLogs: [
      {
        event: 'BatchTransferred',
        args: {
          batchId: 'BATCH_2024_001',
          from: '0x5678901234567890abcdef1234567890abcdef12',
          to: '0x9012345678901234567890abcdef1234567890ab',
          price: '1450'
        }
      }
    ]
  },
  {
    id: 3,
    hash: '0x3c4d5e6f789012345678901234567890abcdef1a2b',
    batchId: 'BATCH_2024_002',
    blockNumber: 12458234,
    timestamp: '2024-01-10T07:30:00Z',
    from: '0x2468135790abcdef2468135790abcdef24681357',
    to: '0x3579246801abcdef3579246801abcdef35792468',
    value: 950,
    gasUsed: 21000,
    gasPrice: 19,
    status: 'Success',
    function: 'harvestBatch',
    eventLogs: [
      {
        event: 'BatchHarvested',
        args: {
          batchId: 'BATCH_2024_002',
          farmer: '0x2468135790abcdef2468135790abcdef24681357',
          quantity: '800',
          crop: 'Rice'
        }
      }
    ]
  },
  {
    id: 4,
    hash: '0x4d5e6f789012345678901234567890abcdef1a2b3c',
    batchId: 'BATCH_2024_003',
    blockNumber: 12458789,
    timestamp: '2024-01-18T14:30:00Z',
    from: '0x4680246802abcdef4680246802abcdef46802468',
    to: '0x5791357913abcdef5791357913abcdef57913579',
    value: 2340,
    gasUsed: 28000,
    gasPrice: 25,
    status: 'Success',
    function: 'sellBatch',
    eventLogs: [
      {
        event: 'BatchSold',
        args: {
          batchId: 'BATCH_2024_003',
          seller: '0x4680246802abcdef4680246802abcdef46802468',
          buyer: '0x5791357913abcdef5791357913abcdef57913579',
          finalPrice: '2340'
        }
      }
    ]
  }
];

const TransactionDetailsDialog = ({ transaction, open, onClose }) => {
  if (!transaction) return null;

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text);
    // You could add a toast notification here
  };

  const formatHash = (hash) => {
    return `${hash.slice(0, 6)}...${hash.slice(-4)}`;
  };

  const formatAddress = (address) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Block color="primary" />
            <Typography variant="h6">Transaction Details</Typography>
          </Box>
          <IconButton onClick={onClose} size="small">
            <CloseIcon />
          </IconButton>
        </Box>
      </DialogTitle>
      
      <DialogContent>
        <Grid container spacing={3}>
          {/* Transaction Hash */}
          <Grid item xs={12}>
            <Box sx={{ p: 2, bgcolor: 'grey.50', borderRadius: 2 }}>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                Transaction Hash
              </Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Typography variant="body2" fontFamily="monospace" sx={{ flex: 1, wordBreak: 'break-all' }}>
                  {transaction.hash}
                </Typography>
                <Tooltip title="Copy Hash">
                  <IconButton size="small" onClick={() => copyToClipboard(transaction.hash)}>
                    <ContentCopy fontSize="small" />
                  </IconButton>
                </Tooltip>
              </Box>
            </Box>
          </Grid>

          {/* Basic Info */}
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Block Number
            </Typography>
            <Typography variant="h6" color="primary">
              #{transaction.blockNumber.toLocaleString()}
            </Typography>
          </Grid>
          
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Timestamp
            </Typography>
            <Typography variant="body1">
              {new Date(transaction.timestamp).toLocaleString()}
            </Typography>
          </Grid>

          {/* Addresses */}
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              From Address
            </Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, p: 1, bgcolor: 'grey.50', borderRadius: 1 }}>
              <AccountBalanceWallet color="action" fontSize="small" />
              <Typography variant="body2" fontFamily="monospace" sx={{ flex: 1 }}>
                {formatAddress(transaction.from)}
              </Typography>
              <Tooltip title="Copy Address">
                <IconButton size="small" onClick={() => copyToClipboard(transaction.from)}>
                  <ContentCopy fontSize="small" />
                </IconButton>
              </Tooltip>
            </Box>
          </Grid>
          
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              To Address
            </Typography>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, p: 1, bgcolor: 'grey.50', borderRadius: 1 }}>
              <AccountBalanceWallet color="action" fontSize="small" />
              <Typography variant="body2" fontFamily="monospace" sx={{ flex: 1 }}>
                {formatAddress(transaction.to)}
              </Typography>
              <Tooltip title="Copy Address">
                <IconButton size="small" onClick={() => copyToClipboard(transaction.to)}>
                  <ContentCopy fontSize="small" />
                </IconButton>
              </Tooltip>
            </Box>
          </Grid>

          {/* Transaction Details */}
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Value
            </Typography>
            <Typography variant="h6" color="success.main">
              ${transaction.value.toLocaleString()}
            </Typography>
          </Grid>
          
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Status
            </Typography>
            <Chip 
              label={transaction.status}
              color={transaction.status === 'Success' ? 'success' : 'error'}
              sx={{ fontWeight: 'bold' }}
            />
          </Grid>

          {/* Gas Information */}
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Gas Used
            </Typography>
            <Typography variant="body1">
              {transaction.gasUsed.toLocaleString()}
            </Typography>
          </Grid>
          
          <Grid item xs={12} md={6}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Gas Price
            </Typography>
            <Typography variant="body1">
              {transaction.gasPrice} Gwei
            </Typography>
          </Grid>

          {/* Function Called */}
          <Grid item xs={12}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Function Called
            </Typography>
            <Box sx={{ p: 1, bgcolor: 'primary.50', borderRadius: 1, border: '1px solid', borderColor: 'primary.200' }}>
              <Typography variant="body2" fontFamily="monospace" color="primary.main">
                {transaction.function}
              </Typography>
            </Box>
          </Grid>

          {/* Event Logs */}
          <Grid item xs={12}>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom sx={{ mb: 2 }}>
              Event Logs ({transaction.eventLogs.length})
            </Typography>
            {transaction.eventLogs.map((log, index) => (
              <Accordion key={index} variant="outlined" sx={{ mb: 1 }}>
                <AccordionSummary expandIcon={<ExpandMore />}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Typography variant="subtitle2" color="primary">
                      {log.event}
                    </Typography>
                    <Chip label={`Log ${index + 1}`} size="small" variant="outlined" />
                  </Box>
                </AccordionSummary>
                <AccordionDetails>
                  <Grid container spacing={2}>
                    {Object.entries(log.args).map(([key, value]) => (
                      <Grid item xs={12} sm={6} key={key}>
                        <Typography variant="caption" color="text.secondary" display="block">
                          {key}
                        </Typography>
                        <Typography variant="body2" fontFamily="monospace" sx={{ wordBreak: 'break-all' }}>
                          {value}
                        </Typography>
                      </Grid>
                    ))}
                  </Grid>
                </AccordionDetails>
              </Accordion>
            ))}
          </Grid>
        </Grid>
      </DialogContent>
      
      <DialogActions>
        <Button onClick={onClose}>
          Close
        </Button>
        <Button 
          variant="contained" 
          startIcon={<OpenInNew />}
          onClick={() => {
            // Open in blockchain explorer
            window.open(`https://etherscan.io/tx/${transaction.hash}`, '_blank');
          }}
        >
          View on Etherscan
        </Button>
      </DialogActions>
    </Dialog>
  );
};

const BlockchainExplorer = () => {
  const [transactions, setTransactions] = useState([]);
  const [filteredTransactions, setFilteredTransactions] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedTransaction, setSelectedTransaction] = useState(null);
  const [showDetails, setShowDetails] = useState(false);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const transactionsPerPage = 10;

  useEffect(() => {
    loadTransactions();
  }, []);

  useEffect(() => {
    filterTransactions();
  }, [transactions, searchQuery]);

  const loadTransactions = async () => {
    setLoading(true);
    try {
      // Mock loading - in real app this would call blockchain API
      await new Promise(resolve => setTimeout(resolve, 500));
      setTransactions(mockBlockchainTransactions);
      setTotalPages(Math.ceil(mockBlockchainTransactions.length / transactionsPerPage));
    } catch (error) {
      console.error('Error loading transactions:', error);
    } finally {
      setLoading(false);
    }
  };

  const filterTransactions = () => {
    if (!searchQuery.trim()) {
      setFilteredTransactions(transactions);
      return;
    }

    const filtered = transactions.filter(tx =>
      tx.hash.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.batchId.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.from.toLowerCase().includes(searchQuery.toLowerCase()) ||
      tx.to.toLowerCase().includes(searchQuery.toLowerCase())
    );
    
    setFilteredTransactions(filtered);
    setTotalPages(Math.ceil(filtered.length / transactionsPerPage));
    setPage(1);
  };

  const handleSearch = () => {
    filterTransactions();
  };

  const handleViewTransaction = (transaction) => {
    setSelectedTransaction(transaction);
    setShowDetails(true);
  };

  const getCurrentPageTransactions = () => {
    const startIndex = (page - 1) * transactionsPerPage;
    const endIndex = startIndex + transactionsPerPage;
    return filteredTransactions.slice(startIndex, endIndex);
  };

  const formatAddress = (address) => {
    return `${address.slice(0, 6)}...${address.slice(-4)}`;
  };

  const getContractStats = () => {
    const totalValue = transactions.reduce((sum, tx) => sum + tx.value, 0);
    const totalGasUsed = transactions.reduce((sum, tx) => sum + tx.gasUsed, 0);
    const successfulTx = transactions.filter(tx => tx.status === 'Success').length;
    
    return {
      totalTransactions: transactions.length,
      totalValue: totalValue,
      totalGasUsed: totalGasUsed,
      successRate: ((successfulTx / transactions.length) * 100).toFixed(1)
    };
  };

  const stats = getContractStats();

  return (
    <Box>
      <Typography variant="h4" gutterBottom fontWeight="bold">
        Blockchain Explorer
      </Typography>
      
      {/* Statistics Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Avatar sx={{ bgcolor: 'primary.main' }}>
                  <Block />
                </Avatar>
                <Box>
                  <Typography variant="h6">{stats.totalTransactions}</Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Transactions
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Avatar sx={{ bgcolor: 'success.main' }}>
                  <TrendingUp />
                </Avatar>
                <Box>
                  <Typography variant="h6">${stats.totalValue.toLocaleString()}</Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Value
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Avatar sx={{ bgcolor: 'warning.main' }}>
                  <Schedule />
                </Avatar>
                <Box>
                  <Typography variant="h6">{stats.totalGasUsed.toLocaleString()}</Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Gas Used
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Avatar sx={{ bgcolor: 'info.main' }}>
                  <AccountBalanceWallet />
                </Avatar>
                <Box>
                  <Typography variant="h6">{stats.successRate}%</Typography>
                  <Typography variant="caption" color="text.secondary">
                    Success Rate
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Search Section */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Search Transactions
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
            <TextField
              placeholder="Enter transaction hash, batch ID, or wallet address"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              sx={{ flexGrow: 1 }}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Search />
                  </InputAdornment>
                )
              }}
              onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            />
            <Button variant="contained" onClick={handleSearch}>
              Search
            </Button>
          </Box>
          
          {filteredTransactions.length !== transactions.length && (
            <Alert severity="info" sx={{ mt: 2 }}>
              Showing {filteredTransactions.length} of {transactions.length} transactions
            </Alert>
          )}
        </CardContent>
      </Card>

      {/* Transactions Table */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Recent Transactions
          </Typography>
          
          <TableContainer component={Paper} variant="outlined">
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Hash</TableCell>
                  <TableCell>Batch ID</TableCell>
                  <TableCell>Block</TableCell>
                  <TableCell>From</TableCell>
                  <TableCell>To</TableCell>
                  <TableCell>Value</TableCell>
                  <TableCell>Function</TableCell>
                  <TableCell>Status</TableCell>
                  <TableCell>Time</TableCell>
                  <TableCell align="center">Action</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {loading ? (
                  <TableRow>
                    <TableCell colSpan={10} align="center">
                      Loading transactions...
                    </TableCell>
                  </TableRow>
                ) : getCurrentPageTransactions().length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={10} align="center">
                      No transactions found
                    </TableCell>
                  </TableRow>
                ) : (
                  getCurrentPageTransactions().map((tx) => (
                    <TableRow key={tx.id} hover>
                      <TableCell>
                        <Typography variant="body2" fontFamily="monospace">
                          {formatAddress(tx.hash)}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Chip label={tx.batchId} size="small" variant="outlined" />
                      </TableCell>
                      <TableCell>{tx.blockNumber.toLocaleString()}</TableCell>
                      <TableCell>
                        <Typography variant="body2" fontFamily="monospace">
                          {formatAddress(tx.from)}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" fontFamily="monospace">
                          {formatAddress(tx.to)}
                        </Typography>
                      </TableCell>
                      <TableCell>${tx.value.toLocaleString()}</TableCell>
                      <TableCell>
                        <Chip label={tx.function} size="small" />
                      </TableCell>
                      <TableCell>
                        <Chip 
                          label={tx.status} 
                          color={tx.status === 'Success' ? 'success' : 'error'}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Typography variant="caption">
                          {new Date(tx.timestamp).toLocaleString()}
                        </Typography>
                      </TableCell>
                      <TableCell align="center">
                        <Button
                          size="small"
                          variant="outlined"
                          startIcon={<Visibility />}
                          onClick={() => handleViewTransaction(tx)}
                        >
                          View
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
          
          {/* Pagination */}
          {totalPages > 1 && (
            <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
              <Pagination
                count={totalPages}
                page={page}
                onChange={(_, newPage) => setPage(newPage)}
                color="primary"
              />
            </Box>
          )}
        </CardContent>
      </Card>

      {/* Transaction Details */}
      {showDetails && selectedTransaction && (
        <TransactionDetailsDialog
          transaction={selectedTransaction}
          open={showDetails}
          onClose={() => setShowDetails(false)}
        />
      )}
    </Box>
  );
};

export default BlockchainExplorer;