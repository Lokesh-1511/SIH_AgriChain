/**
 * AgriChain Backend - Node.js Express Server
 * Aadhaar Verification with OTP Generation
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import routes
const aadhaarRoutes = require('./routes/aadhaar');
const otpRoutes = require('./routes/otp');
const healthRoutes = require('./routes/health');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());

// CORS configuration
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS ? 
    process.env.ALLOWED_ORIGINS.split(',') : 
    ['http://localhost:3000', 'http://localhost:8080', '*'],
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: (process.env.RATE_LIMIT_WINDOW_MINUTES || 15) * 60 * 1000,
  max: process.env.MAX_REQUESTS_PER_WINDOW || 10,
  message: {
    error: 'Too many requests from this IP, please try again later.',
    retryAfter: Math.ceil((process.env.RATE_LIMIT_WINDOW_MINUTES || 15) / 60)
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
if (process.env.ENABLE_REQUEST_LOGGING === 'true') {
  app.use(morgan('combined'));
}

// API Routes
app.use('/api/health', healthRoutes);
app.use('/api/aadhaar', aadhaarRoutes);
app.use('/api/otp', otpRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: '🔐 AgriChain Backend Server',
    version: '1.0.0',
    status: 'running',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/api/health',
      aadhaar: '/api/aadhaar',
      otp: '/api/otp'
    }
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    timestamp: new Date().toISOString(),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('🚀 AgriChain Backend Server Started');
  console.log('=' .repeat(50));
  console.log(`📡 Server running on: http://0.0.0.0:${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV}`);
  console.log(`📚 API Documentation: http://localhost:${PORT}/`);
  console.log(`🔍 Health Check: http://localhost:${PORT}/api/health`);
  console.log(`📱 Android Emulator: http://10.0.2.2:${PORT}/api/health`);
  console.log('=' .repeat(50));
  
  if (process.env.NODE_ENV === 'development') {
    console.log('🛠️  Development mode enabled');
    console.log('📝 Request logging: ON');
    console.log('🔓 Debug routes: ENABLED');
  }
});

module.exports = app;