// Mock data for demonstration purposes
// In a real application, this would connect to your blockchain and backend APIs

export const mockTransactions = [
  {
    id: 'tx_001',
    batchId: 'BATCH_2024_001',
    type: 'Harvest',
    from: 'Farmer John Smith',
    to: 'Distributor ABC',
    timestamp: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
    amount: 1250.00,
    status: 'Completed',
    hash: '0x1234567890abcdef...',
  },
  {
    id: 'tx_002',
    batchId: 'BATCH_2024_002',
    type: 'Transport',
    from: 'Distributor ABC',
    to: 'Retailer XYZ',
    timestamp: new Date(Date.now() - 1000 * 60 * 60).toISOString(),
    amount: 1890.50,
    status: 'In Transit',
    hash: '0xabcdef1234567890...',
  },
  {
    id: 'tx_003',
    batchId: 'BATCH_2024_003',
    type: 'Sale',
    from: 'Retailer XYZ',
    to: 'Consumer Market',
    timestamp: new Date(Date.now() - 1000 * 60 * 90).toISOString(),
    amount: 2340.75,
    status: 'Completed',
    hash: '0x567890abcdef1234...',
  },
];

export const mockBatches = [
  { id: 'BATCH_2024_001', status: 'In Transit', crop: 'Wheat', quantity: 1000, farmer: 'John Smith', value: 15000 },
  { id: 'BATCH_2024_002', status: 'Delivered', crop: 'Rice', quantity: 800, farmer: 'Mary Johnson', value: 12000 },
  { id: 'BATCH_2024_003', status: 'In Transit', crop: 'Corn', quantity: 1200, farmer: 'Robert Davis', value: 18000 },
  { id: 'BATCH_2024_004', status: 'Delivered', crop: 'Barley', quantity: 900, farmer: 'Alice Brown', value: 13500 },
  { id: 'BATCH_2024_005', status: 'In Transit', crop: 'Soybeans', quantity: 1100, farmer: 'David Wilson', value: 16500 },
  { id: 'BATCH_2024_006', status: 'Delivered', crop: 'Oats', quantity: 750, farmer: 'Emma Martinez', value: 11250 },
];

export const mockRoles = [
  {
    id: 1,
    name: 'John Smith',
    role: 'Farmer',
    walletId: '0x1234...abcd',
    status: 'Approved',
    registrationDate: '2024-01-15',
    location: 'California, USA',
  },
  {
    id: 2,
    name: 'ABC Distribution',
    role: 'Distributor',
    walletId: '0x5678...efgh',
    status: 'Approved',
    registrationDate: '2024-01-20',
    location: 'Texas, USA',
  },
  {
    id: 3,
    name: 'XYZ Retail Chain',
    role: 'Retailer',
    walletId: '0x9012...ijkl',
    status: 'Pending',
    registrationDate: '2024-02-01',
    location: 'New York, USA',
  },
];

export const mockAnalytics = {
  totalBatches: { active: 45, delivered: 32, sold: 28 },
  todayTransactions: 24,
  totalRevenue: 125430.50,
  averagePrice: 1450.25,
  roleDistribution: [
    { role: 'Farmers', count: 15, transactions: 45 },
    { role: 'Distributors', count: 8, transactions: 32 },
    { role: 'Retailers', count: 12, transactions: 28 },
    { role: 'Consumers', count: 150, transactions: 15 },
  ],
  pricingTrends: [
    { date: '2024-01-01', price: 1200 },
    { date: '2024-01-02', price: 1250 },
    { date: '2024-01-03', price: 1180 },
    { date: '2024-01-04', price: 1320 },
    { date: '2024-01-05', price: 1450 },
    { date: '2024-01-06', price: 1380 },
    { date: '2024-01-07', price: 1420 },
  ],
};

export const mockAnomalies = [
  {
    id: 1,
    type: 'High Margin',
    batchId: 'BATCH_2024_001',
    message: 'Margin exceeds 25% threshold',
    severity: 'Medium',
    timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(),
  },
  {
    id: 2,
    type: 'Transport Delay',
    batchId: 'BATCH_2024_002',
    message: 'Delivery delayed by 24 hours',
    severity: 'High',
    timestamp: new Date(Date.now() - 1000 * 60 * 60 * 4).toISOString(),
  },
];

// Mock blockchain service
export class BlockchainService {
  static async getTransactions(limit = 10) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 500));
    return mockTransactions.slice(0, limit);
  }
  
  static async getBatches(limit = 50) {
    // Simulate API delay
    await new Promise(resolve => setTimeout(resolve, 300));
    return mockBatches.slice(0, limit);
  }
  
  static async getBatchDetails(batchId) {
    await new Promise(resolve => setTimeout(resolve, 300));
    return mockBatches.find(batch => batch.id === batchId);
  }
  
  static async getAnalytics() {
    await new Promise(resolve => setTimeout(resolve, 400));
    return mockAnalytics;
  }
  
  static async getRoles() {
    await new Promise(resolve => setTimeout(resolve, 300));
    return mockRoles;
  }
  
  static async getAnomalies() {
    await new Promise(resolve => setTimeout(resolve, 200));
    return mockAnomalies;
  }
  
  static async approveRole(roleId) {
    await new Promise(resolve => setTimeout(resolve, 500));
    // Mock approval logic
    const role = mockRoles.find(r => r.id === roleId);
    if (role) {
      role.status = 'Approved';
    }
    return { success: true };
  }
  
  static async searchTransaction(query) {
    await new Promise(resolve => setTimeout(resolve, 300));
    return mockTransactions.filter(tx => 
      tx.batchId.toLowerCase().includes(query.toLowerCase()) ||
      tx.hash.toLowerCase().includes(query.toLowerCase())
    );
  }
}