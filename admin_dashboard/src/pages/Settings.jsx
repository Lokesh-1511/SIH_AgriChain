import React, { useState } from 'react';
import { useTheme } from '../contexts/ThemeContext.jsx';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Switch,
  FormControlLabel,
  Button,
  Grid,
  Divider,
  Alert,
  TextField,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Chip,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Paper,
  Tabs,
  Tab
} from '@mui/material';
import {
  Settings,
  Palette,
  Notifications,
  Security,
  Language,
  Storage,
  Backup,
  Download,
  Upload,
  Delete,
  Warning,
  Check,
  Info
} from '@mui/icons-material';
import { AnimatedCard } from '../components/common/PageTransitions';

const SettingsPage = () => {
  const { colors, isDarkMode, toggleTheme } = useTheme();
  
  const [activeTab, setActiveTab] = useState(0);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  
  const [appSettings, setAppSettings] = useState({
    darkMode: isDarkMode,
    language: 'English',
    timezone: 'Asia/Kolkata',
    currency: 'INR',
    dateFormat: 'DD/MM/YYYY',
    autoSave: true,
    compactMode: false,
    highContrast: false
  });

  const [notificationSettings, setNotificationSettings] = useState({
    emailNotifications: true,
    pushNotifications: true,
    smsNotifications: false,
    batchUpdates: true,
    systemAlerts: true,
    reportReady: true,
    securityAlerts: true,
    marketingEmails: false,
    weeklyDigest: true
  });

  const [securitySettings, setSecuritySettings] = useState({
    twoFactorAuth: false,
    sessionTimeout: 30,
    loginAlerts: true,
    passwordExpiry: 90,
    backupCodes: false
  });

  const [dataSettings, setDataSettings] = useState({
    autoBackup: true,
    backupFrequency: 'daily',
    dataRetention: 365,
    exportFormat: 'csv',
    compressionEnabled: true
  });

  const handleSettingChange = (category, key, value) => {
    const setters = {
      app: setAppSettings,
      notification: setNotificationSettings,
      security: setSecuritySettings,
      data: setDataSettings
    };
    
    setters[category](prev => ({
      ...prev,
      [key]: value
    }));

    // Handle special cases
    if (category === 'app' && key === 'darkMode' && value !== isDarkMode) {
      toggleTheme();
    }
  };

  const handleExportData = () => {
    // Simulate data export
    const exportData = {
      userSettings: { appSettings, notificationSettings, securitySettings },
      exportDate: new Date().toISOString()
    };
    
    const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'agrichain-settings.json';
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleImportData = (event) => {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        try {
          const data = JSON.parse(e.target.result);
          if (data.userSettings) {
            setAppSettings(data.userSettings.appSettings || appSettings);
            setNotificationSettings(data.userSettings.notificationSettings || notificationSettings);
            setSecuritySettings(data.userSettings.securitySettings || securitySettings);
            alert('Settings imported successfully!');
          }
        } catch (error) {
          alert('Error importing settings. Please check the file format.');
        }
      };
      reader.readAsText(file);
    }
  };

  const handleResetSettings = () => {
    setShowDeleteDialog(false);
    // Reset to default values
    setAppSettings({
      darkMode: false,
      language: 'English',
      timezone: 'Asia/Kolkata',
      currency: 'INR',
      dateFormat: 'DD/MM/YYYY',
      autoSave: true,
      compactMode: false,
      highContrast: false
    });
    alert('Settings reset to default values!');
  };

  return (
    <Box sx={{ p: 3, maxWidth: 1200, mx: 'auto' }}>
      {/* Header */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 'bold', color: colors.primary, mb: 1 }}>
          Settings
        </Typography>
        <Typography variant="body1" color="textSecondary">
          Customize your AgriChain dashboard experience
        </Typography>
      </Box>

      {/* Tabs */}
      <Paper sx={{ mb: 3 }}>
        <Tabs
          value={activeTab}
          onChange={(e, newValue) => setActiveTab(newValue)}
          variant="fullWidth"
        >
          <Tab icon={<Palette />} label="Appearance" />
          <Tab icon={<Notifications />} label="Notifications" />
          <Tab icon={<Security />} label="Security" />
          <Tab icon={<Storage />} label="Data & Backup" />
        </Tabs>
      </Paper>

      {/* Appearance Settings */}
      {activeTab === 0 && (
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <AnimatedCard>
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Palette /> Theme & Display
                  </Typography>
                  
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={appSettings.darkMode}
                          onChange={(e) => handleSettingChange('app', 'darkMode', e.target.checked)}
                        />
                      }
                      label="Dark Mode"
                    />
                    
                    <FormControlLabel
                      control={
                        <Switch
                          checked={appSettings.compactMode}
                          onChange={(e) => handleSettingChange('app', 'compactMode', e.target.checked)}
                        />
                      }
                      label="Compact Mode"
                    />
                    
                    <FormControlLabel
                      control={
                        <Switch
                          checked={appSettings.highContrast}
                          onChange={(e) => handleSettingChange('app', 'highContrast', e.target.checked)}
                        />
                      }
                      label="High Contrast"
                    />
                  </Box>
                </CardContent>
              </Card>
            </AnimatedCard>
          </Grid>

          <Grid item xs={12} md={6}>
            <AnimatedCard delay={200}>
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Language /> Localization
                  </Typography>
                  
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                    <FormControl fullWidth>
                      <InputLabel>Language</InputLabel>
                      <Select
                        value={appSettings.language}
                        label="Language"
                        onChange={(e) => handleSettingChange('app', 'language', e.target.value)}
                      >
                        <MenuItem value="English">English</MenuItem>
                        <MenuItem value="Hindi">हिन्दी</MenuItem>
                        <MenuItem value="Marathi">मराठी</MenuItem>
                      </Select>
                    </FormControl>

                    <FormControl fullWidth>
                      <InputLabel>Timezone</InputLabel>
                      <Select
                        value={appSettings.timezone}
                        label="Timezone"
                        onChange={(e) => handleSettingChange('app', 'timezone', e.target.value)}
                      >
                        <MenuItem value="Asia/Kolkata">Asia/Kolkata (IST)</MenuItem>
                        <MenuItem value="Asia/Delhi">Asia/Delhi</MenuItem>
                        <MenuItem value="UTC">UTC</MenuItem>
                      </Select>
                    </FormControl>

                    <FormControl fullWidth>
                      <InputLabel>Currency</InputLabel>
                      <Select
                        value={appSettings.currency}
                        label="Currency"
                        onChange={(e) => handleSettingChange('app', 'currency', e.target.value)}
                      >
                        <MenuItem value="INR">INR (₹)</MenuItem>
                        <MenuItem value="USD">USD ($)</MenuItem>
                        <MenuItem value="EUR">EUR (€)</MenuItem>
                      </Select>
                    </FormControl>

                    <FormControl fullWidth>
                      <InputLabel>Date Format</InputLabel>
                      <Select
                        value={appSettings.dateFormat}
                        label="Date Format"
                        onChange={(e) => handleSettingChange('app', 'dateFormat', e.target.value)}
                      >
                        <MenuItem value="DD/MM/YYYY">DD/MM/YYYY</MenuItem>
                        <MenuItem value="MM/DD/YYYY">MM/DD/YYYY</MenuItem>
                        <MenuItem value="YYYY-MM-DD">YYYY-MM-DD</MenuItem>
                      </Select>
                    </FormControl>
                  </Box>
                </CardContent>
              </Card>
            </AnimatedCard>
          </Grid>
        </Grid>
      )}

      {/* Notification Settings */}
      {activeTab === 1 && (
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <AnimatedCard>
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3 }}>
                    General Notifications
                  </Typography>
                  
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={notificationSettings.emailNotifications}
                          onChange={(e) => handleSettingChange('notification', 'emailNotifications', e.target.checked)}
                        />
                      }
                      label="Email Notifications"
                    />
                    <FormControlLabel
                      control={
                        <Switch
                          checked={notificationSettings.pushNotifications}
                          onChange={(e) => handleSettingChange('notification', 'pushNotifications', e.target.checked)}
                        />
                      }
                      label="Push Notifications"
                    />
                    <FormControlLabel
                      control={
                        <Switch
                          checked={notificationSettings.smsNotifications}
                          onChange={(e) => handleSettingChange('notification', 'smsNotifications', e.target.checked)}
                        />
                      }
                      label="SMS Notifications"
                    />
                  </Box>
                </CardContent>
              </Card>
            </AnimatedCard>
          </Grid>

          <Grid item xs={12} md={6}>
            <AnimatedCard delay={200}>
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3 }}>
                    Specific Alerts
                  </Typography>
                  
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={notificationSettings.batchUpdates}
                          onChange={(e) => handleSettingChange('notification', 'batchUpdates', e.target.checked)}
                        />
                      }
                      label="Batch Status Updates"
                    />
                    <FormControlLabel
                      control={
                        <Switch
                          checked={notificationSettings.systemAlerts}
                          onChange={(e) => handleSettingChange('notification', 'systemAlerts', e.target.checked)}
                        />
                      }
                      label="System Alerts"
                    />
                    <FormControlLabel
                      control={
                        <Switch
                          checked={notificationSettings.reportReady}
                          onChange={(e) => handleSettingChange('notification', 'reportReady', e.target.checked)}
                        />
                      }
                      label="Report Ready Notifications"
                    />
                    <FormControlLabel
                      control={
                        <Switch
                          checked={notificationSettings.securityAlerts}
                          onChange={(e) => handleSettingChange('notification', 'securityAlerts', e.target.checked)}
                        />
                      }
                      label="Security Alerts"
                    />
                  </Box>
                </CardContent>
              </Card>
            </AnimatedCard>
          </Grid>
        </Grid>
      )}

      {/* Security Settings */}
      {activeTab === 2 && (
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <AnimatedCard>
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Security /> Security & Privacy
                  </Typography>
                  
                  <Alert severity="info" sx={{ mb: 3 }}>
                    These settings help protect your account and data. Some changes may require re-authentication.
                  </Alert>

                  <Grid container spacing={3}>
                    <Grid item xs={12} md={6}>
                      <FormControlLabel
                        control={
                          <Switch
                            checked={securitySettings.twoFactorAuth}
                            onChange={(e) => handleSettingChange('security', 'twoFactorAuth', e.target.checked)}
                          />
                        }
                        label="Two-Factor Authentication"
                      />
                      <Typography variant="caption" display="block" sx={{ ml: 4, color: 'textSecondary' }}>
                        Add an extra layer of security to your account
                      </Typography>
                    </Grid>

                    <Grid item xs={12} md={6}>
                      <FormControlLabel
                        control={
                          <Switch
                            checked={securitySettings.loginAlerts}
                            onChange={(e) => handleSettingChange('security', 'loginAlerts', e.target.checked)}
                          />
                        }
                        label="Login Alerts"
                      />
                      <Typography variant="caption" display="block" sx={{ ml: 4, color: 'textSecondary' }}>
                        Get notified when someone logs into your account
                      </Typography>
                    </Grid>

                    <Grid item xs={12} md={6}>
                      <TextField
                        fullWidth
                        type="number"
                        label="Session Timeout (minutes)"
                        value={securitySettings.sessionTimeout}
                        onChange={(e) => handleSettingChange('security', 'sessionTimeout', parseInt(e.target.value))}
                        inputProps={{ min: 5, max: 480 }}
                      />
                    </Grid>

                    <Grid item xs={12} md={6}>
                      <TextField
                        fullWidth
                        type="number"
                        label="Password Expiry (days)"
                        value={securitySettings.passwordExpiry}
                        onChange={(e) => handleSettingChange('security', 'passwordExpiry', parseInt(e.target.value))}
                        inputProps={{ min: 30, max: 365 }}
                      />
                    </Grid>
                  </Grid>
                </CardContent>
              </Card>
            </AnimatedCard>
          </Grid>
        </Grid>
      )}

      {/* Data & Backup Settings */}
      {activeTab === 3 && (
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <AnimatedCard>
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Backup /> Backup Settings
                  </Typography>
                  
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={dataSettings.autoBackup}
                          onChange={(e) => handleSettingChange('data', 'autoBackup', e.target.checked)}
                        />
                      }
                      label="Automatic Backup"
                    />

                    <FormControl fullWidth>
                      <InputLabel>Backup Frequency</InputLabel>
                      <Select
                        value={dataSettings.backupFrequency}
                        label="Backup Frequency"
                        onChange={(e) => handleSettingChange('data', 'backupFrequency', e.target.value)}
                        disabled={!dataSettings.autoBackup}
                      >
                        <MenuItem value="daily">Daily</MenuItem>
                        <MenuItem value="weekly">Weekly</MenuItem>
                        <MenuItem value="monthly">Monthly</MenuItem>
                      </Select>
                    </FormControl>

                    <TextField
                      fullWidth
                      type="number"
                      label="Data Retention (days)"
                      value={dataSettings.dataRetention}
                      onChange={(e) => handleSettingChange('data', 'dataRetention', parseInt(e.target.value))}
                      inputProps={{ min: 30, max: 2555 }}
                    />
                  </Box>
                </CardContent>
              </Card>
            </AnimatedCard>
          </Grid>

          <Grid item xs={12} md={6}>
            <AnimatedCard delay={200}>
              <Card>
                <CardContent>
                  <Typography variant="h6" sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <Download /> Data Management
                  </Typography>
                  
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                    <Button
                      variant="outlined"
                      startIcon={<Download />}
                      onClick={handleExportData}
                      fullWidth
                    >
                      Export Settings
                    </Button>

                    <input
                      type="file"
                      accept=".json"
                      onChange={handleImportData}
                      style={{ display: 'none' }}
                      id="import-settings"
                    />
                    <label htmlFor="import-settings">
                      <Button
                        variant="outlined"
                        startIcon={<Upload />}
                        component="span"
                        fullWidth
                      >
                        Import Settings
                      </Button>
                    </label>

                    <Divider sx={{ my: 2 }} />

                    <Button
                      variant="outlined"
                      color="error"
                      startIcon={<Warning />}
                      onClick={() => setShowDeleteDialog(true)}
                      fullWidth
                    >
                      Reset to Default
                    </Button>
                  </Box>
                </CardContent>
              </Card>
            </AnimatedCard>
          </Grid>
        </Grid>
      )}

      {/* Reset Confirmation Dialog */}
      <Dialog open={showDeleteDialog} onClose={() => setShowDeleteDialog(false)}>
        <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Warning color="error" />
          Reset Settings
        </DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to reset all settings to their default values? This action cannot be undone.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowDeleteDialog(false)}>
            Cancel
          </Button>
          <Button onClick={handleResetSettings} color="error" variant="contained">
            Reset Settings
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default SettingsPage;