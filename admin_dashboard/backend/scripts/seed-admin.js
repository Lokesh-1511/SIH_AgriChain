/* eslint-disable no-console */
// Script: seed-admin.js
// Purpose: Creates (or updates) a verified administrator user so the frontend can obtain a backend JWT.
// Usage (from backend directory):
//   node scripts/seed-admin.js
// Reads MONGODB_URI and optional ADMIN_EMAIL / ADMIN_PASSWORD from env.

const path = require('path');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const MONGODB_URI = process.env.MONGODB_URI;
const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'agriadmin@gmail.com';
// Default matches the hash used client-side (1q2w3e4r) but you can override via env.
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || '1q2w3e4r';

if (!MONGODB_URI) {
  console.error('Missing MONGODB_URI in environment.');
  process.exit(1);
}

const User = require('../src/models/user.model');

async function run() {
  console.log('Connecting to Mongo...');
  await mongoose.connect(MONGODB_URI);
  console.log('Connected.');

  const existing = await User.findOne({ email: ADMIN_EMAIL });
  const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 10);

  if (existing) {
    let changed = false;
    if (existing.role !== 'administrator') { existing.role = 'administrator'; changed = true; }
    if (!existing.isVerified) { existing.isVerified = true; changed = true; }
    if (!existing.passwordHash || !(await bcrypt.compare(ADMIN_PASSWORD, existing.passwordHash))) {
      existing.passwordHash = passwordHash; changed = true; }
    if (!existing.name) { existing.name = 'Platform Administrator'; changed = true; }
    if (changed) {
      await existing.save();
      console.log('Updated existing admin user:', existing.email);
    } else {
      console.log('Admin user already up to date:', existing.email);
    }
  } else {
    const created = await User.create({
      name: 'Platform Administrator',
      email: ADMIN_EMAIL,
      role: 'administrator',
      isVerified: true,
      isActive: true,
      passwordHash,
      additionalInfo: { seededAt: new Date().toISOString() }
    });
    console.log('Created admin user:', created.email);
  }

  console.log('Done.');
  await mongoose.disconnect();
  process.exit(0);
}

run().catch(async (e) => {
  console.error('Seeding failed:', e);
  try { await mongoose.disconnect(); } catch (_) {}
  process.exit(1);
});
