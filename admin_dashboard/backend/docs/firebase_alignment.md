# Firebase Alignment

This document records the alignment between the Flutter application's Firebase configuration and the web admin dashboard / backend.

## 1. Provided Android Config
```
apiKey:       AIzaSyCfSIxYp_XkdL-h6SJ4rlIwjry2gy48GoY
appId:        1:797432400385:android:e1166aa272b68bc87f4e00
messagingSenderId: 797432400385
projectId:    agri-chain-sih
storageBucket: agri-chain-sih.firebasestorage.app
```

## 2. Frontend (.env)
The React admin dashboard uses Vite variables (already populated):
- VITE_FIREBASE_API_KEY
- VITE_FIREBASE_AUTH_DOMAIN (derived: agri-chain-sih.firebaseapp.com)
- VITE_FIREBASE_PROJECT_ID
- VITE_FIREBASE_STORAGE_BUCKET
- VITE_FIREBASE_MESSAGING_SENDER_ID
- VITE_FIREBASE_APP_ID

## 3. Backend Preparation
Backend `.env.example` now includes:
- FIREBASE_PROJECT_ID
- FIREBASE_MESSAGING_SENDER_ID
- FIREBASE_STORAGE_BUCKET

A scaffold `src/services/firebaseAdmin.js` was added for future token verification; requires installing `firebase-admin` and providing service account credentials.

## 4. Security Notes
- Do NOT expose service account JSON in the client.
- The `apiKey` is not a secret but still shouldn't be abused; enable only necessary Firebase APIs.
- For backend auth bridging, verify ID tokens and map `firebaseUid` to Mongo user documents (already supported field in User schema).

## 5. Next Steps (Optional)
1. Install firebase-admin in backend: `npm install firebase-admin`.
2. Add middleware to verify incoming Firebase ID tokens, issue internal JWT if required.
3. Enforce role claims either via custom claims or Mongo User role field.
4. Add refresh token handling / session revocation strategy.

---
Generated on 2025-10-07.
