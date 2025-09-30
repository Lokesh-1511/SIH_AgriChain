# Admin Dashboard - Setup & Installation Guide

This is a complete React-based Admin Dashboard for blockchain supply chain analytics built with Vite.

## 🚀 Quick Start

1. **Install Dependencies**
   ```bash
   cd admin_dashboard
   npm install
   ```

2. **Start Development Server**
   ```bash
   npm run dev
   ```
   The app will be available at `http://localhost:3000`

3. **Login Credentials**
   - **Username:** `admin`
   - **Password:** `admin123`

## 📁 Project Structure

```
admin_dashboard/
├── public/                 # Static assets
├── src/
│   ├── assets/            # Images, icons, etc.
│   ├── components/        # Reusable components
│   │   ├── common/        # Layout, navigation
│   │   └── charts/        # Chart components
│   ├── context/           # React contexts
│   │   ├── AuthContext.jsx
│   │   └── ThemeContext.jsx
│   ├── hooks/             # Custom React hooks
│   ├── pages/             # Main page components
│   │   ├── Dashboard.jsx
│   │   ├── LoginPage.jsx
│   │   ├── RoleManagement.jsx
│   │   ├── SupplyChainMonitoring.jsx
│   │   ├── BlockchainExplorer.jsx
│   │   └── Reports.jsx
│   ├── services/          # API and data services
│   ├── styles/            # CSS files
│   ├── utils/             # Utility functions
│   ├── App.jsx
│   └── main.jsx
├── package.json
├── vite.config.js
└── README.md
```

## 🌟 Features

### 1. **Authentication System**
- Modern login page with floating labels
- Dark/Light theme toggle
- Remember me functionality
- Secure credential handling

### 2. **Dashboard Overview**
- Real-time transaction feed
- Summary cards with statistics
- Interactive charts (Bar, Pie, Line)
- AI anomaly detection alerts

### 3. **Role Management**
- Manage Farmers, Distributors, Retailers, Consumers
- Approve/reject registrations
- Search and filter functionality
- Wallet ID verification

### 4. **Supply Chain Monitoring**
- End-to-end batch traceability
- Interactive timeline visualization
- AI anomaly alerts (margin, delays)
- Fraud detection logs

### 5. **Blockchain Explorer**
- Transaction search by hash/batch ID
- Detailed transaction information
- Smart contract interaction logs
- Gas usage analytics

### 6. **Reports & Export**
- Transaction history reports
- Price breakdown analysis
- Anomaly reports
- PDF and CSV export functionality

## 🛠 Technologies Used

- **Frontend:** React 18 + Vite
- **UI Framework:** Material-UI (MUI)
- **Charts:** Recharts
- **Routing:** React Router v6
- **Blockchain:** Ethers.js (ready for integration)
- **Styling:** CSS3 + Material-UI theming

## 🎨 Theme & Styling

- **Light/Dark Mode:** Automatic theme switching
- **Responsive Design:** Mobile, tablet, desktop support
- **Animations:** Smooth transitions and hover effects
- **Color Palette:** Professional blue/green theme

## 📊 Mock Data

The dashboard uses comprehensive mock data for demonstration:
- Transaction history with blockchain details
- Supply chain batch tracking
- Role management data
- Pricing and margin analysis
- AI anomaly detection samples

## 🔗 Blockchain Integration

The app is ready for real blockchain integration:
- Web3 service layer prepared
- Ethers.js integration setup
- Smart contract interaction templates
- Wallet connection utilities

## 📱 Responsive Design

- **Mobile:** < 768px - Collapsed sidebar, touch-friendly
- **Tablet:** 768px - 1024px - Adaptive layout
- **Desktop:** > 1024px - Full layout with all features

## 🚀 Production Build

```bash
npm run build
npm run preview
```

## 🔧 Customization

1. **Theme Colors:** Modify `src/utils/theme.js`
2. **API Integration:** Update `src/services/mockData.js`
3. **Blockchain Setup:** Configure `src/services/web3Service.js`
4. **Components:** Extend or modify components in `src/components/`

## 📝 Development Notes

- All data is currently mocked for demonstration
- Authentication uses local storage for persistence
- Charts are responsive and interactive
- Export functionality downloads sample files
- Real-time updates are simulated with intervals

## 🎯 Future Enhancements

- Real blockchain API integration
- Push notifications for alerts
- Advanced analytics dashboards
- Multi-language support
- Mobile app companion

---

**Demo Purpose:** This dashboard is designed for educational and demonstration purposes. For production use, integrate with real blockchain APIs and implement proper security measures.