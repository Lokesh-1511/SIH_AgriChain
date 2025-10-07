# AgriChain Admin Dashboard Backend (Node.js)

This service provides REST APIs and integrations that power the AgriChain admin dashboard. It is implemented with **Express.js** (no TypeScript) and mirrors the data contracts already defined in the Flutter mobile application.

## Prerequisites
- Node.js >= 18
- npm >= 9
- MongoDB running locally or accessible via connection string

## Getting Started
1. **Install dependencies**
   ```powershell
   cd admin_dashboard/backend
   npm install
   ```

2. **Configure environment**
   - Copy `.env.example` to `.env`
   - Update the values as needed (Mongo connection string, JWT secret, log level)

3. **Run the server**
   ```powershell
   npm run dev
   ```
  The API listens on `http://localhost:5000` by default. A health check is available at `/api/health`.

## NPM Scripts
- `npm run dev` – Start the server with hot reload via nodemon
- `npm start` – Start the server in production mode

## Project Structure
```
backend/
  package.json
  scripts/
    health-check.js
  src/
    app.js
    server.js
    config/
      env.js
    controllers/
      healthController.js
      admin/
        authController.js
        analyticsController.js
        batchController.js
        roleController.js
        transactionController.js
    db/
      mongoose.js
    middleware/
      auth.js
      loginRateLimiter.js
      errorHandler.js
      notFound.js
      requestContext.js
      requestLogger.js
      rateLimiter.js
    models/
      auditLog.model.js
      batch.model.js
      transaction.model.js
      user.model.js
      index.js
    repositories/
      auditLog.repository.js
      batch.repository.js
      transaction.repository.js
      user.repository.js
      index.js
    routes/
      health.routes.js
      index.js
      admin/
        auth.routes.js
        analytics.routes.js
        batches.routes.js
        roles.routes.js
        transactions.routes.js
    services/
      analyticsService.js
      auditService.js
      authService.js
      batchService.js
      roleService.js
      transactionService.js
    utils/
      logger.js
      pagination.js
```

## Authentication & Authorization
- Admin users authenticate via `POST /api/admin/auth/login` with email/password credentials. Successful responses return a JWT that must be sent as a `Bearer` token in the `Authorization` header.
- `GET /api/admin/auth/me` returns the current admin’s profile. All other admin routes require the JWT middleware and will reject non-admin or unverified accounts.

## Admin APIs

### Roles
- `GET /api/admin/roles` – List users filtered by role, verification status, and search query.
- `GET /api/admin/roles/:id` – Retrieve a single user record.
- `POST /api/admin/roles/:id/approve` – Mark a pending user as verified with optional review notes.

### Batches
- `GET /api/admin/batches` – Paginated list of crop batches with optional `status`, `farmerId`, and search filters.
- `GET /api/admin/batches/:id` – Detailed batch view including related participants.
- `GET /api/admin/batches/:id/transactions` – Recent transaction timeline for a batch.
- `GET /api/admin/batches/stats` – Aggregate counts, quantities, and valuations grouped by status.

### Transactions
- `GET /api/admin/transactions` – Paginated transactions with filters for `batchId`, `type`, `status`, and text search.
- `GET /api/admin/transactions/stats` – Aggregated metrics grouped by transaction status and type.

### Dashboard
- `GET /api/admin/dashboard/overview`
- `GET /api/admin/dashboard/activity?limit=`

### Analytics
- `GET /api/admin/analytics/overview`
- `GET /api/admin/analytics/trends?interval=daily|weekly|monthly`

## Next Steps
- Implement real-time streaming (WebSocket or SSE) if the dashboard requires live updates.
- Add automated Jest/Supertest suites beyond the included health check.
- Integrate monitoring (e.g., Prometheus metrics or centralized logging).

## Troubleshooting
- Ensure MongoDB is running before starting the server; otherwise start-up will fail with a connection error.
- Set `LOG_LEVEL=debug` in `.env` to see verbose logs.

## Seeding the Administrator User
The frontend single-admin login embeds a local email/password. To access protected admin routes with real data you need a verified administrator in the database.

Seed (or update) the admin user:
```powershell
npm run seed:admin
```
Environment overrides (optional):
```
ADMIN_EMAIL=agriadmin@gmail.com
ADMIN_PASSWORD=1q2w3e4r
```
If you change the password here you must update the frontend `AuthContext.jsx` (bcrypt hash corresponds to `1q2w3e4r`).

### First-Time Flow
1. Put `MONGODB_URI` and `JWT_SECRET` in `.env`.
2. Run `npm run seed:admin`.
3. Start backend `npm run dev`.
4. Start frontend, log in; a backend JWT is stored in `localStorage` as `admin_backend_jwt`.
5. With no batches/transactions yet you will see an empty state instead of mock data.
