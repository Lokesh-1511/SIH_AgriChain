import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './contexts/ThemeContext.jsx';
import './styles/mui-theme-overrides.css';
import LoginPage from './pages/LoginPage';
import DashboardLayout from './components/common/DashboardLayout';
import Dashboard from './pages/Dashboard';
import RoleManagement from './pages/RoleManagement';
import SupplyChainMonitoring from './pages/SupplyChainMonitoring';
import BlockchainExplorer from './pages/BlockchainExplorer';
import Reports from './pages/Reports';
import ProtectedRoute from './components/common/ProtectedRoute';

// Import global styles
import './styles/globals.css';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <Router>
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/" element={
              <ProtectedRoute>
                <DashboardLayout />
              </ProtectedRoute>
            }>
              <Route index element={<Navigate to="/dashboard" replace />} />
              <Route path="dashboard" element={<Dashboard />} />
              <Route path="roles" element={<RoleManagement />} />
              <Route path="supply-chain" element={<SupplyChainMonitoring />} />
              <Route path="blockchain" element={<BlockchainExplorer />} />
              <Route path="reports" element={<Reports />} />
            </Route>
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;