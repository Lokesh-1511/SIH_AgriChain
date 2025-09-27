import React, { useState, useEffect } from 'react';
import { useTheme } from '../contexts/ThemeContext.jsx';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  IconButton,
  Button,
  TextField,
  InputAdornment,
  Grid,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Avatar,
  Tooltip,
  Menu,
  MenuItem,
  Alert,
} from '@mui/material';
import {
  Search,
  FilterList,
  MoreVert,
  CheckCircle,
  Cancel,
  Visibility,
  AccountBalanceWallet,
  LocationOn,
  CalendarToday,
} from '@mui/icons-material';
import { BlockchainService } from '../services/mockData';

const RoleChip = ({ role }) => {
  const colors = {
    Farmer: 'success',
    Distributor: 'primary',
    Retailer: 'warning',
    Consumer: 'secondary',
  };
  
  const icons = {
    Farmer: '👨‍🌾',
    Distributor: '🚛',
    Retailer: '🏪',
    Consumer: '👤',
  };

  return (
    <Chip
      label={role}
      color={colors[role] || 'default'}
      size="small"
      icon={<span>{icons[role]}</span>}
    />
  );
};

const StatusChip = ({ status }) => {
  const colors = {
    Approved: 'success',
    Pending: 'warning',
    Rejected: 'error',
  };

  return (
    <Chip
      label={status}
      color={colors[status] || 'default'}
      size="small"
      variant={status === 'Pending' ? 'outlined' : 'filled'}
    />
  );
};

const RoleDetailsDialog = ({ role, open, onClose, onApprove, onReject }) => {
  if (!role) return null;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Avatar sx={{ bgcolor: 'primary.main' }}>
            {role.name.charAt(0)}
          </Avatar>
          <Box>
            <Typography variant="h6">{role.name}</Typography>
            <RoleChip role={role.role} />
          </Box>
        </Box>
      </DialogTitle>
      
      <DialogContent>
        <Grid container spacing={2} sx={{ mt: 1 }}>
          <Grid item xs={12} sm={6}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
              <AccountBalanceWallet sx={{ color: 'text.secondary' }} />
              <Box>
                <Typography variant="caption" color="text.secondary">
                  Wallet Address
                </Typography>
                <Typography variant="body2" fontFamily="monospace">
                  {role.walletId}
                </Typography>
              </Box>
            </Box>
          </Grid>
          
          <Grid item xs={12} sm={6}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
              <LocationOn sx={{ color: 'text.secondary' }} />
              <Box>
                <Typography variant="caption" color="text.secondary">
                  Location
                </Typography>
                <Typography variant="body2">
                  {role.location}
                </Typography>
              </Box>
            </Box>
          </Grid>
          
          <Grid item xs={12} sm={6}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
              <CalendarToday sx={{ color: 'text.secondary' }} />
              <Box>
                <Typography variant="caption" color="text.secondary">
                  Registration Date
                </Typography>
                <Typography variant="body2">
                  {new Date(role.registrationDate).toLocaleDateString()}
                </Typography>
              </Box>
            </Box>
          </Grid>
          
          <Grid item xs={12} sm={6}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
              <CheckCircle sx={{ color: 'text.secondary' }} />
              <Box>
                <Typography variant="caption" color="text.secondary">
                  Status
                </Typography>
                <Box sx={{ mt: 0.5 }}>
                  <StatusChip status={role.status} />
                </Box>
              </Box>
            </Box>
          </Grid>
        </Grid>
        
        {role.status === 'Pending' && (
          <Alert severity="info" sx={{ mt: 2 }}>
            This registration is pending approval. Review the details and approve or reject.
          </Alert>
        )}
      </DialogContent>
      
      <DialogActions sx={{ px: 3, pb: 2 }}>
        <Button onClick={onClose} variant="outlined">
          Close
        </Button>
        {role.status === 'Pending' && (
          <>
            <Button 
              onClick={() => onReject(role.id)} 
              color="error" 
              variant="outlined"
            >
              Reject
            </Button>
            <Button 
              onClick={() => onApprove(role.id)} 
              color="success" 
              variant="contained"
            >
              Approve
            </Button>
          </>
        )}
      </DialogActions>
    </Dialog>
  );
};

const RoleManagement = () => {
  const { colors, isDarkMode } = useTheme();
  const [roles, setRoles] = useState([]);
  const [filteredRoles, setFilteredRoles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedRole, setSelectedRole] = useState(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [anchorEl, setAnchorEl] = useState(null);
  const [selectedRowId, setSelectedRowId] = useState(null);
  const [roleFilter, setRoleFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');

  useEffect(() => {
    fetchRoles();
  }, []);

  useEffect(() => {
    filterRoles();
  }, [roles, searchQuery, roleFilter, statusFilter]);

  const fetchRoles = async () => {
    try {
      const data = await BlockchainService.getRoles();
      setRoles(data);
    } catch (error) {
      console.error('Error fetching roles:', error);
    } finally {
      setLoading(false);
    }
  };

  const filterRoles = () => {
    let filtered = roles;

    // Search filter
    if (searchQuery) {
      filtered = filtered.filter(role =>
        role.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        role.walletId.toLowerCase().includes(searchQuery.toLowerCase()) ||
        role.location.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }

    // Role filter
    if (roleFilter !== 'All') {
      filtered = filtered.filter(role => role.role === roleFilter);
    }

    // Status filter
    if (statusFilter !== 'All') {
      filtered = filtered.filter(role => role.status === statusFilter);
    }

    setFilteredRoles(filtered);
  };

  const handleMenuOpen = (event, roleId) => {
    setAnchorEl(event.currentTarget);
    setSelectedRowId(roleId);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
    setSelectedRowId(null);
  };

  const handleViewDetails = (role) => {
    setSelectedRole(role);
    setDialogOpen(true);
    handleMenuClose();
  };

  const handleApprove = async (roleId) => {
    try {
      await BlockchainService.approveRole(roleId);
      await fetchRoles(); // Refresh data
      setDialogOpen(false);
      // Show success message
    } catch (error) {
      console.error('Error approving role:', error);
    }
  };

  const handleReject = async (roleId) => {
    try {
      // Mock reject logic
      const roleIndex = roles.findIndex(r => r.id === roleId);
      if (roleIndex !== -1) {
        const updatedRoles = [...roles];
        updatedRoles[roleIndex].status = 'Rejected';
        setRoles(updatedRoles);
      }
      setDialogOpen(false);
    } catch (error) {
      console.error('Error rejecting role:', error);
    }
  };

  const roleTypes = ['All', 'Farmer', 'Distributor', 'Retailer', 'Consumer'];
  const statusTypes = ['All', 'Approved', 'Pending', 'Rejected'];

  if (loading) {
    return <Typography>Loading roles...</Typography>;
  }

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
        Role Management
      </Typography>
      
      {/* Filters and Search */}
      <Card sx={{ 
        mb: 3,
        backgroundColor: colors.cardBackground,
        color: colors.text,
        border: `1px solid ${colors.border}`
      }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} md={4}>
              <TextField
                fullWidth
                placeholder="Search by name, wallet, or location..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Search />
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
            
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                select
                fullWidth
                label="Role"
                value={roleFilter}
                onChange={(e) => setRoleFilter(e.target.value)}
              >
                {roleTypes.map(type => (
                  <MenuItem key={type} value={type}>
                    {type}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                select
                fullWidth
                label="Status"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                {statusTypes.map(status => (
                  <MenuItem key={status} value={status}>
                    {status}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            
            <Grid item xs={12} md={2}>
              <Typography variant="body2" color="text.secondary">
                {filteredRoles.length} of {roles.length} roles
              </Typography>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* Roles Table */}
      <Card>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Name</TableCell>
                <TableCell>Role</TableCell>
                <TableCell>Wallet ID</TableCell>
                <TableCell>Location</TableCell>
                <TableCell>Registration Date</TableCell>
                <TableCell>Status</TableCell>
                <TableCell align="center">Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredRoles.map((role) => (
                <TableRow key={role.id} hover>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Avatar sx={{ width: 32, height: 32, bgcolor: 'primary.main' }}>
                        {role.name.charAt(0)}
                      </Avatar>
                      <Typography variant="body2" fontWeight="medium">
                        {role.name}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <RoleChip role={role.role} />
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" fontFamily="monospace">
                      {role.walletId}
                    </Typography>
                  </TableCell>
                  <TableCell>{role.location}</TableCell>
                  <TableCell>
                    {new Date(role.registrationDate).toLocaleDateString()}
                  </TableCell>
                  <TableCell>
                    <StatusChip status={role.status} />
                  </TableCell>
                  <TableCell align="center">
                    <IconButton
                      onClick={(e) => handleMenuOpen(e, role.id)}
                      size="small"
                    >
                      <MoreVert />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Card>

      {/* Context Menu */}
      <Menu
        anchorEl={anchorEl}
        open={Boolean(anchorEl)}
        onClose={handleMenuClose}
      >
        <MenuItem 
          onClick={() => {
            const role = roles.find(r => r.id === selectedRowId);
            handleViewDetails(role);
          }}
        >
          <Visibility sx={{ mr: 1 }} />
          View Details
        </MenuItem>
        {roles.find(r => r.id === selectedRowId)?.status === 'Pending' && (
          <>
            <MenuItem 
              onClick={() => handleApprove(selectedRowId)}
              sx={{ color: 'success.main' }}
            >
              <CheckCircle sx={{ mr: 1 }} />
              Approve
            </MenuItem>
            <MenuItem 
              onClick={() => handleReject(selectedRowId)}
              sx={{ color: 'error.main' }}
            >
              <Cancel sx={{ mr: 1 }} />
              Reject
            </MenuItem>
          </>
        )}
      </Menu>

      {/* Role Details Dialog */}
      <RoleDetailsDialog
        role={selectedRole}
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        onApprove={handleApprove}
        onReject={handleReject}
      />
    </Box>
  );
};

export default RoleManagement;