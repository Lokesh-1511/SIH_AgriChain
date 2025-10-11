// Firebase initialization and exports
// Uses Vite env variables prefixed with VITE_
import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

// Basic validation to surface missing env vars early during dev
const missing = Object.entries(firebaseConfig)
  .filter(([_, v]) => !v)
  .map(([k]) => k);
if (missing.length) {
  // eslint-disable-next-line no-console
  console.warn('[Firebase] Missing config values:', missing.join(', '));
}

export const isDemoMode = import.meta.env.VITE_DEMO_MODE === 'true';
export const isFirebaseConfigValid = missing.length === 0;

// Initialize Firebase only once
let app;
try {
  if (isFirebaseConfigValid) {
    app = initializeApp(firebaseConfig);
  }
} catch (e) {
  // eslint-disable-next-line no-console
  console.error('[Firebase] Initialization error:', e);
  // Leave app undefined to trigger demo fallback
}

export const auth = app ? getAuth(app) : null;
export default app;
