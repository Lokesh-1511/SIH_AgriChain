/* eslint-disable no-console */
// Quick connectivity + health endpoint check.
// Usage: node scripts/connection-check.js

process.env.NODE_ENV = 'test'; // reuse test env behavior without changing DB

const mongoose = require('mongoose');
const fetch = require('node-fetch');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const MONGO_URI = process.env.MONGODB_URI;
const BASE = `http://localhost:${process.env.PORT || 5000}`;

(async () => {
  const start = Date.now();
  let ok = true;
  try {
    if (!MONGO_URI) throw new Error('Missing MONGODB_URI');
    await mongoose.connect(MONGO_URI, { serverSelectionTimeoutMS: 4000 });
    console.log('✓ Mongo connect OK');
  } catch (e) {
    ok = false;
    console.error('✗ Mongo connect FAIL:', e.message);
  } finally {
    try { await mongoose.disconnect(); } catch (_) {}
  }

  try {
    const res = await fetch(`${BASE}/api/health`);
    const body = await res.json().catch(()=>({}));
    if (res.ok && body.status === 'success') {
      console.log('✓ Health endpoint OK');
    } else {
      ok = false;
      console.error('✗ Health endpoint FAIL:', res.status, body);
    }
  } catch (e) {
    ok = false;
    console.error('✗ Health request error:', e.message);
  }

  console.log(`Finished in ${Date.now() - start}ms`);
  process.exit(ok ? 0 : 1);
})();
