import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import { LoadingOverlay } from './PageTransitions';

const ProtectedRoute = ({ children, roles }) => {
  const { isAuthenticated, loading, user, authMode } = useAuth();
  const location = useLocation();

  if (loading) {
    return <LoadingOverlay isVisible={true} message="Checking authentication..." />;
  }

  if (!isAuthenticated()) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (roles && roles.length) {
    const allowed = roles.includes(user?.role);
    if (!allowed) {
      // eslint-disable-next-line no-console
      console.warn(`[Auth] Role '${user?.role}' blocked for route. Required: ${roles.join(', ')} (mode=${authMode})`);
      return <Navigate to="/unauthorized" replace />;
    }
  }

  return children;
};

export default ProtectedRoute;