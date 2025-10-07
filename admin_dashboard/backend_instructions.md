# Admin Dashboard Backend Instructions (Node.js Edition)

This guide tracks the implementation roadmap for the AgriChain admin backend **as an Express/Mongoose service** that mirrors the Flutter data contracts and feeds the React admin dashboard. It replaces the earlier FastAPI-oriented plan.

---

## 1. Goals & Scope
- Deliver secure REST endpoints to power the admin dashboard widgets (roles, supply chain, analytics, blockchain insights).
- Reuse Flutter mobile data contracts (users, batches, transactions, etc.) so ingestion from the mobile apps is seamless.
- Integrate with supporting systems (Aadhaar KYC microservice, blockchain relay, AI services) as the platform grows.
- Provide a clear backlog for real-time feeds, analytics, reporting, and observability.

### Current Baseline (Already Implemented)
- Express app with Helmet, CORS, rate limiting, structured logging, and JWT middleware.
- Mongoose models for `User`, `Batch`, `Transaction` aligned to Flutter schemas.
- Repository/services/controllers for:
  - **Admin auth** (`POST /api/admin/auth/login`, `GET /api/admin/auth/me`).
  - **Role management** (list, detail, approve).
  - **Batches** (list, detail, stats, transactions).
  - **Transactions** (list, stats).
  - **Dashboard overview & activity feed**.
- Automated health check script (`npm run test:health`).

---

## 2. Data Model Alignment

| Flutter Model | Mongo Collection | Key Fields / Notes | Admin Usage |
| --- | --- | --- | --- |
| `User` & role variants | `users` | `role`, `isVerified`, profile metadata (`farmerProfile`, etc.), Aadhaar info | Role approval, audit, contact data |
| `Batch` | `batches` | Farmer linkage, product, quantity, status, pricing, logistics participants | Supply chain KPIs, drilldowns |
| `Transaction` | `transactions` | `batchId`, `fromUserId`, `toUserId`, `transactionType`, `amount`, blockchain hash | Financial feed, timeline widgets |
| `DeliveryTracking` | `deliveries`, `delivery_tracking_points` *(planned)* | Route progress, vehicle info, timestamps | Shipment map, SLA alerts |
| `BlockchainTransaction`, `TraceabilityRecord`, `Wallet` | `blockchain_transactions`, `traceability_records`, `wallets` *(planned)* | On-chain hash, contract metadata, balances | Compliance, wallet view |
| `AIRecommendation`, `CropAdvisory` | `ai_recommendations`, `crop_advisories` *(planned)* | AI outputs and confidence | AI alerts and advisories |

> Treat Flutter models as the contract. New backend fields must be additive or derived so the mobile apps remain compatible.

---

## 3. Target Architecture (Node.js)
1. **API Layer (Express)**
   - Modules: `auth`, `roles`, `batches`, `transactions`, `dashboard`, `analytics`, `blockchain`, `ai`, `notifications`.
   - Middlewares: JWT auth, role-based access (`administrator`, future `super_admin`), rate limiting, error handling.
2. **Data Layer (MongoDB via Mongoose)**
   - Schemas mirror Flutter models.
   - Repositories encapsulate queries, pagination, and aggregations.
3. **Integration Layer** *(future work)*
   - Aadhaar service REST client (Python service already exists under `backend/main.py`).
   - Blockchain relay (ethers.js/web3.js) for traceability.
   - AI/advisory services.
4. **Background Workers** *(future work)*
   - Node cron jobs / BullMQ queues for analytics, anomaly detection, notifications.
5. **Real-time Channel** *(future work)*
   - Socket.io or Server-Sent Events for live dashboard updates.

---

## 4. Implementation Roadmap (Node)

### Phase A – Foundation ✅ *(Complete)*
- Project scaffold with Express, Nodemon, dotenv configuration.
- Security middleware (Helmet, CORS, rate limiting) and logging.
- Mongo connection helper and base health endpoint.

### Phase B – Authentication & Roles ✅
- JWT auth with password hashing (`bcryptjs`) and role claims.
- Admin login/profile endpoints.
- Role listing, detail, approval updates with audit notes.

### Phase C – Supply Chain Core ✅
- Batch endpoints (filters, detail, transaction timeline, stats).
- Transaction endpoints (filters, stats, pagination).
- Dashboard overview/activity combining user/batch/transaction aggregates.

### Phase D – Security & Compliance �
- ✅ Enforce password policies (length, complexity).
- ✅ Record audit logs for key admin actions (`audit_logs` collection + service).
- ✅ Implement request tracing (correlation IDs) and structured JSON logs.
- ✅ Harden rate limiting for authentication (login-specific limiter with email/IP keying).
- 📌 Extend per-route limiter for approval/rejection flows and add MFA/device-trust hook.
- 📌 Expand audit coverage (reject, metadata updates) and surface audit log queries for compliance teams.

### Phase E – Analytics & Reporting �
- ✅ Expose `/api/admin/analytics/overview` combining user, batch, and transaction KPIs.
- ✅ Provide `/api/admin/analytics/trends?interval=daily|weekly|monthly` aggregations (batches, transactions, amounts).
- 📌 Materialize analytics collections (`analytics_daily_summary`, `analytics_role_distribution`, `analytics_pricing_trends`, `anomalies`).
- 📌 Deliver `/api/admin/anomalies` endpoint backed by anomaly detection logic.
- 📌 Build reporting service for CSV/PDF exports (`/api/admin/reports` with job polling, persisting `report_jobs`).

### Phase F – Deliveries & Geo Tracking 📌
- Collections for deliveries & tracking points with geospatial indexes.
- Endpoints:
  - `GET /api/admin/deliveries` with filters.
  - `GET /api/admin/deliveries/:id` including GeoJSON route.
- Analytics around active shipments, SLA compliance.

### Phase G – Blockchain & Wallets 📌
- Service wrapper (ethers.js or REST relay) for on-chain lookups and submissions.
- Collections: `blockchain_transactions`, `traceability_records`, `wallets`, `wallet_transactions`.
- Endpoints:
  - `GET /api/admin/blockchain/transactions/:hash`
  - `GET /api/admin/blockchain/batches/:batchId`
  - `GET /api/admin/wallets` & `/api/admin/wallets/:id`
- Background sync job to ingest blockchain events.

### Phase H – Real-time & Notifications 📌
- Introduce Redis + BullMQ (or socket.io adapter) for pub/sub.
- WebSocket endpoint (`/api/admin/live-feed`) streaming approvals, transactions, anomalies.
- Email/SMS hooks for escalations (optional, via queue workers).

### Phase I – AI & Advisory 📌
- Wrap existing AI mock service (Node HTTP client) for admin-triggered advisories.
- Endpoints: `/api/admin/ai/recommendations`, `/api/admin/ai/advisories`, `/api/admin/ai/recommendations/:id/resolve`.
- Persist AI interactions/audit history.

### Phase J – Testing & Quality 📌
- Expand tests beyond health check: Jest + Supertest suites covering controllers/services.
- Use MongoMemoryServer for integration tests.
- Set up linting (`eslint`, `prettier`) and CI pipeline (GitHub actions) running lint/test.
- Load testing playbook using `k6` or `artillery`.

### Phase K – Deployment & Ops 📌
- Environment-specific config (`config/env.js` already supports env vars).
- Production-ready logging (Winston/Pino) with log shipping guidance.
- Process manager (PM2/systemd) setup docs.
- Secrets management (Azure Key Vault/AWS Secrets Manager) and rotation policy.
- Observability: integrate Prometheus metrics (e.g., `prom-client`) and `/metrics` endpoint; uptime checks (`/api/health`, `/api/ready`).

Legend: ✅ done · 📌 scheduled/in-progress · 🔄 revisit/iterate as needed.

---

## 5. API Contract Snapshot

### Auth & Session
- `POST /api/admin/auth/login` → `{ token, user }`
- `GET /api/admin/auth/me`

### Roles
- `GET /api/admin/roles?role=&status=&search=&page=&limit=`
- `GET /api/admin/roles/:id`
- `POST /api/admin/roles/:id/approve` (body: `{ notes }`)
- *(Planned)* `POST /api/admin/roles/:id/reject`, `PATCH /api/admin/roles/:id`

### Batches
- `GET /api/admin/batches?status=&farmerId=&search=&page=&limit=`
- `GET /api/admin/batches/:id`
- `GET /api/admin/batches/:id/transactions?limit=`
- `GET /api/admin/batches/stats`

### Transactions
- `GET /api/admin/transactions?batchId=&type=&status=&search=&page=&limit=`
- `GET /api/admin/transactions/stats`

### Dashboard
- `GET /api/admin/dashboard/overview`
- `GET /api/admin/dashboard/activity?limit=`

### Upcoming Modules
- `/api/admin/analytics/*`, `/api/admin/reports/*`, `/api/admin/deliveries/*`, `/api/admin/blockchain/*`, `/api/admin/ai/*`, `/api/admin/notifications/*` (see roadmap).

---

## 6. Background Jobs & Pipelines (Planned)
- **Analytics Builder:** nightly job computing aggregate collections powering dashboard trends.
- **Anomaly Detector:** hourly job evaluating rules on batches/transactions.
- **Blockchain Sync:** listener/cron job ingesting on-chain events.
- **Notification Dispatcher:** sends WebSocket/email/SMS alerts when anomalies or approvals occur.
- **Data Retention Tasks:** archive/compress historical tracking and chat records per policy.

Node tooling options: BullMQ (Redis-backed queues), Agenda, or node-cron combined with service classes.

---

## 7. Security & Compliance Checklist
- Enforce password policy and capture password change history.
- Support MFA hooks for human admins (e.g., TOTP) and IP allow-lists for sensitive endpoints.
- Mask sensitive fields (`aadhaar.last4`) in responses; never log raw PII.
- Encrypt sensitive data at rest (Mongo field encryption or application-level crypto mirroring Aadhaar service patterns).
- Add resource-level RBAC: `administrator`, `super_admin`, `auditor`, `analyst` with a permissions matrix.
- Rate-limit approval/rejection and auth routes aggressively; consider device fingerprinting.
- Maintain tamper-evident audit logs for compliance.

---

## 8. Verification & Handover
- Maintain a Postman collection or OpenAPI spec generated from middleware (e.g., `express-openapi-validator`).
- Smoke-test key flows after each release: admin login, role approval, batch search, dashboard metrics render.
- Produce runbooks for operations (start/stop scripts, log locations, incident procedures).
- Schedule knowledge-transfer sessions covering architecture, data flows, and deployment.

---

## 9. Future Enhancements
- GraphQL or tRPC gateway for complex analytics queries.
- ElasticSearch/OpenSearch for advanced text search across transactions/batches.
- Machine learning-driven anomaly detection beyond static rules.
- Data provenance dashboards linking blockchain confirmations to physical delivery milestones.
- Multi-language support for human-readable strings served to the admin UI.

---

By following this Node-centric roadmap, each sprint stays focused while steadily expanding the backend to cover every dashboard widget, external integration, and compliance requirement.
