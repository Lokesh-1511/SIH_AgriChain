import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ThemeProvider } from './contexts/ThemeContext.jsx';

// Import agriculture-blockchain theme styles
import './styles/agri-theme.css';
import './styles/mui-theme-overrides.css';
import './styles/globals.css';

import LoginPage from './pages/LoginPage';
import DashboardLayout from './components/common/DashboardLayout';
import Dashboard from './pages/Dashboard';
import RoleManagement from './pages/RoleManagement';
import SupplyChainMonitoring from './pages/SupplyChainMonitoring';
import BlockchainExplorer from './pages/BlockchainExplorer';
import Reports from './pages/Reports';
import Profile from './pages/Profile';
import Settings from './pages/Settings';
import ProtectedRoute from './components/common/ProtectedRoute';
import Unauthorized from './pages/Unauthorized';

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
              <Route path="roles" element={<ProtectedRoute roles={["administrator"]}><RoleManagement /></ProtectedRoute>} />
              <Route path="supply-chain" element={<SupplyChainMonitoring />} />
              <Route path="blockchain" element={<BlockchainExplorer />} />
              <Route path="reports" element={<Reports />} />
              <Route path="profile" element={<Profile />} />
              <Route path="settings" element={<Settings />} />
            </Route>
            <Route path="unauthorized" element={<Unauthorized />} />
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;