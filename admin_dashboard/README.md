# AgriChain Admin Dashboard

A modern React-based admin dashboard for blockchain supply chain analytics, built with Vite and Material-UI.

## ✨ Features

### 🔐 Authentication
Single-admin, password-hash based authentication (no external identity provider).

| Property | Value |
|----------|-------|
| Email    | `agriadmin@gmail.com` |
| Password | Managed via bcrypt hash inside `AuthContext` (plaintext not stored) |

Details:
- Bcrypt hash embedded in `src/context/AuthContext.jsx`.
- Credential check performed entirely client-side (sufficient for isolated admin deployment). 
- Session persisted in `localStorage` (`single_admin_session`).
- Password reset / demo fallback / Firebase features removed.
- For stronger security in multi-user scenarios, integrate backend-issued JWT instead of this mode.

### 📊 Dashboard Analytics
- **Real-time Transaction Feed** with live blockchain updates
- **Interactive Charts** (Bar, Pie, Line) using Recharts
- **Summary Cards** showing key metrics and KPIs
- **AI-powered Anomaly Detection** with alerts

### 👥 Role Management
- **Multi-role Support** (Farmers, Distributors, Retailers, Consumers)
- **Registration Approval** workflow with detailed user profiles
- **Advanced Search & Filtering** by name, wallet, location
- **Wallet Address Verification** and status management

### 🔗 Supply Chain Monitoring
- **End-to-end Batch Traceability** with interactive timeline
- **AI Anomaly Detection** for pricing, delays, and fraud
- **Interactive Supply Chain Visualization**
- **Complete Audit Trail** with blockchain verification

### 🔍 Blockchain Explorer
- **Transaction Search** by hash, batch ID, or wallet address
- **Detailed Transaction Views** with expandable information
- **Smart Contract Event Logs** with decoded parameters
- **Gas Usage Analytics** and optimization insights

### 📈 Reports & Analytics
- **Comprehensive Report Generation** (Transactions, Pricing, Anomalies)
- **Export to PDF/CSV** with custom formatting
- **Interactive Data Preview** before download

## 🛠 Technology Stack

- **Frontend:** React 18 + Vite
- **UI Framework:** Material-UI (MUI) v5
- **Charts:** Recharts for responsive data visualization
- **Routing:** React Router v6
- **State Management:** React Context API
- **Blockchain:** Ethers.js for Web3 integration
- **Styling:** CSS3 with Material-UI theming
- **Build Tool:** Vite for fast development and building

## 🚀 Quick Start

### Installation

1. **Navigate to the project:**
   ```bash
   cd admin_dashboard
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start development server:**
   ```bash
   npm run dev
   ```

4. **Open in browser:**
   Visit `http://localhost:3000`

5. **Login:** Use the single administrator credentials (see table above). No additional configuration required.

### Build for Production

```bash
npm run build
npm run preview
```

## 📁 Project Structure

```
admin_dashboard/
├── public/                     # Static assets
├── src/
│   ├── components/            # Reusable components
│   │   ├── common/           # Layout, navigation, dialogs
│   │   └── charts/           # Chart components
│   ├── context/              # React context providers
│   ├── hooks/                # Custom React hooks
│   ├── pages/                # Main application pages
│   ├── services/             # API and data services
│   ├── styles/               # CSS stylesheets
│   ├── utils/                # Utility functions
│   ├── App.jsx               # Main app component
│   └── main.jsx              # Application entry point
├── package.json              # Dependencies and scripts
├── vite.config.js           # Vite configuration
└── README.md                # Project documentation
```

## 🎨 Features Overview

- **Responsive Design** for desktop, tablet, and mobile
- **Dark/Light Theme** with smooth transitions
- **Modern UI/UX** with Material Design principles
- **Interactive Data Visualization** with Recharts
- **Real-time Updates** simulation for demo purposes
- **Export Functionality** for reports in PDF/CSV format
- **Search and Filter** capabilities across all sections
- **Professional Animations** and hover effects

## 🔧 Mock Data

The dashboard still uses mock blockchain / analytics data for visualization (see `src/services/mockData.js`). Replace those service calls with real API calls as backend endpoints become available.

### Role-Based Guard
`<ProtectedRoute roles={["administrator"]}>` enforces administrator-only access. In single-admin mode the role is fixed (`administrator`).

## 🚀 Ready for Production

The dashboard is built with production-ready practices:
- Clean, modular code structure
- Responsive design for all screen sizes
- Error handling and loading states
- Accessibility considerations
- SEO-friendly routing
- Performance optimizations

---

**Built for the AgriChain ecosystem - Complete blockchain supply chain analytics dashboard**