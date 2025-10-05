# AgriChain Node.js Backend

A Node.js Express backend for AgriChain Aadhaar verification with OTP generation.

## 🚀 Features

- **Aadhaar Validation**: Pattern-based validation with configurable rules
- **OTP Generation**: Secure 6-digit OTP with expiry and attempt limits
- **Rate Limiting**: Protection against spam requests
- **CORS Support**: Cross-origin requests for Flutter frontend
- **Mock SMS**: Development-friendly SMS simulation
- **Health Monitoring**: System health and performance metrics
- **Security**: Helmet.js security headers and input validation

## 📋 Prerequisites

- Node.js (v14.0.0 or higher)
- npm or yarn package manager

## 🛠️ Installation

1. **Install Dependencies**:
   ```bash
   cd backend
   npm install
   ```

2. **Environment Setup**:
   ```bash
   cp .env.example .env
   # Edit .env with your configurations
   ```

3. **Start Development Server**:
   ```bash
   npm run dev
   ```

4. **Start Production Server**:
   ```bash
   npm start
   ```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `NODE_ENV` | Environment mode | `development` |
| `ALLOWED_AADHAAR_PATTERNS` | Comma-separated Aadhaar patterns | `123456*,999999*` |
| `OTP_LENGTH` | OTP digit length | `6` |
| `OTP_EXPIRY_MINUTES` | OTP expiry time | `10` |
| `MAX_OTP_ATTEMPTS` | Maximum verification attempts | `3` |

### Aadhaar Patterns

Configure allowed Aadhaar patterns in `.env`:
```env
ALLOWED_AADHAAR_PATTERNS=123456*,999999*,555555*,789012*
```

Supports wildcards (`*`) for flexible pattern matching.

## 📡 API Endpoints

### Health Check
```
GET /api/health
```

### Aadhaar Validation
```
POST /api/aadhaar/validate
```
**Body:**
```json
{
  "aadhaar_number": "123456789012",
  "user_id": "user123",
  "user_role": "farmer"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP generated successfully",
  "transaction_id": "TXN_ABC123",
  "mobile_number": "+91XXXXXX1234",
  "debug_otp": "123456"
}
```

### OTP Verification
```
POST /api/otp/verify
```
**Body:**
```json
{
  "transaction_id": "TXN_ABC123",
  "otp": "123456"
}
```

**Response:**
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "aadhaar_verified": true,
  "verified_at": "2025-10-06T12:00:00.000Z"
}
```

### OTP Resend
```
POST /api/otp/resend
```
**Body:**
```json
{
  "transaction_id": "TXN_ABC123"
}
```

## 🧪 Testing

### Valid Aadhaar Numbers (Development)

Use these patterns for testing:
- `123456789012` - Pattern: 123456*
- `999999990123` - Pattern: 999999*
- `555555555555` - Pattern: 555555*
- `789012345678` - Pattern: 789012*

### API Testing with curl

1. **Validate Aadhaar**:
   ```bash
   curl -X POST http://localhost:3000/api/aadhaar/validate \
     -H "Content-Type: application/json" \
     -d '{"aadhaar_number": "123456789012"}'
   ```

2. **Verify OTP**:
   ```bash
   curl -X POST http://localhost:3000/api/otp/verify \
     -H "Content-Type: application/json" \
     -d '{"transaction_id": "TXN_ABC123", "otp": "123456"}'
   ```

## 🔒 Security Features

- **Rate Limiting**: 10 requests per 15 minutes per IP
- **Input Validation**: Joi schema validation
- **CORS Protection**: Configurable origins
- **Helmet.js**: Security headers
- **OTP Security**: Expiry, attempt limits, auto-cleanup

## 📊 Monitoring

### Health Endpoint
```
GET /api/health
```
Returns server status, uptime, and memory usage.

### Development Endpoints
```
GET /api/aadhaar/patterns  # View allowed patterns
GET /api/otp/status/:id    # Check OTP status
```

## 🚀 Production Deployment

1. **Environment**:
   ```env
   NODE_ENV=production
   ALLOWED_ORIGINS=https://your-domain.com
   ```

2. **Process Management**:
   ```bash
   # Using PM2
   npm install -g pm2
   pm2 start server.js --name agrichain-backend
   ```

3. **Reverse Proxy** (Nginx):
   ```nginx
   location /api {
     proxy_pass http://localhost:3000;
     proxy_set_header Host $host;
     proxy_set_header X-Real-IP $remote_addr;
   }
   ```

## 🛠️ Development

### Project Structure
```
backend/
├── server.js           # Main server file
├── routes/            # API route handlers
│   ├── health.js      # Health check routes
│   ├── aadhaar.js     # Aadhaar validation routes
│   └── otp.js         # OTP verification routes
├── utils/             # Utility functions
│   ├── aadhaar.js     # Aadhaar validation logic
│   └── otp.js         # OTP generation and management
├── package.json       # Dependencies and scripts
├── .env.example       # Environment template
└── README.md          # This file
```

### Adding New Features

1. **New Route**: Add to `routes/` directory
2. **Business Logic**: Add to `utils/` directory
3. **Middleware**: Add to `server.js`
4. **Tests**: Add to `tests/` directory

## 📝 License

MIT License - see LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request