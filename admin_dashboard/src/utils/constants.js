// Constants for the application

export const API_ENDPOINTS = {
  BLOCKCHAIN_RPC: process.env.REACT_APP_BLOCKCHAIN_RPC || 'http://localhost:8545',
  BACKEND_API: process.env.REACT_APP_BACKEND_API || 'http://localhost:3001/api',
};

export const CONTRACT_ADDRESSES = {
  SUPPLY_CHAIN: process.env.REACT_APP_SUPPLY_CHAIN_CONTRACT || '0x1234567890123456789012345678901234567890',
  TOKEN: process.env.REACT_APP_TOKEN_CONTRACT || '0x0987654321098765432109876543210987654321',
};

export const ROLES = {
  ADMIN: 'administrator',
  FARMER: 'farmer',
  DISTRIBUTOR: 'distributor',
  RETAILER: 'retailer',
  CONSUMER: 'consumer',
};

export const BATCH_STATUSES = {
  HARVESTED: 'Harvested',
  PROCESSED: 'Processed',
  IN_TRANSIT: 'In Transit',
  DELIVERED: 'Delivered',
  SOLD: 'Sold',
  COMPLETED: 'Completed',
};

export const TRANSACTION_TYPES = {
  HARVEST: 'Harvest',
  PROCESS: 'Process',
  TRANSPORT: 'Transport',
  DELIVER: 'Deliver',
  SELL: 'Sell',
  TRANSFER: 'Transfer',
};

export const ANOMALY_TYPES = {
  HIGH_MARGIN: 'High Margin',
  TRANSPORT_DELAY: 'Transport Delay',
  PRICE_ANOMALY: 'Price Anomaly',
  QUALITY_ISSUE: 'Quality Issue',
  FRAUD_DETECTION: 'Fraud Detection',
};

export const CHART_COLORS = {
  PRIMARY: '#1976d2',
  SECONDARY: '#dc004e',
  SUCCESS: '#4caf50',
  WARNING: '#ff9800',
  ERROR: '#f44336',
  INFO: '#2196f3',
};

export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 10,
  PAGE_SIZE_OPTIONS: [5, 10, 25, 50],
};

export const LOCAL_STORAGE_KEYS = {
  AUTH_TOKEN: 'authToken',
  USER_DATA: 'userData',
  THEME_MODE: 'darkMode',
  USER_PREFERENCES: 'userPreferences',
};

export const DEMO_CREDENTIALS = {
  USERNAME: 'admin',
  PASSWORD: 'admin123',
};