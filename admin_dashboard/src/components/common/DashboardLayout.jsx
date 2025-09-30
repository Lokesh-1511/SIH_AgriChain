import React from 'react';
import { Outlet } from 'react-router-dom';
import Header from '../Header';
import { PageContainer } from './PageTransitions';

const DashboardLayout = () => {
  return (
    <div className="dashboard-layout">
      <Header />
      <main className="dashboard-main">
        <PageContainer>
          <Outlet />
        </PageContainer>
      </main>
    </div>
  );
};

export default DashboardLayout;