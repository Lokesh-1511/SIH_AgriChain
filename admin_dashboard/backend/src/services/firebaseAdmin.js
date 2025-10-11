// Firebase Admin initialization placeholder
// To fully enable Firebase token verification, download a service account JSON
// from Firebase Console > Project Settings > Service Accounts and set
// GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccount.json
// Or load credentials from env vars.

let admin; // Lazy import to avoid dependency if not yet installed

function getAdmin() {
  if (!admin) {
    try {
      // eslint-disable-next-line global-require
      admin = require('firebase-admin');
    } catch (e) {
      throw new Error('firebase-admin package not installed. Run npm install firebase-admin');
    }
  }
  return admin;
}

let appInstance;
function initFirebaseAdmin() {
  if (appInstance) return appInstance;
  const adminLib = getAdmin();
  if (adminLib.apps.length === 0) {
    adminLib.initializeApp({
      // Credentials will auto load from GOOGLE_APPLICATION_CREDENTIALS if set
      projectId: process.env.FIREBASE_PROJECT_ID,
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET
    });
  }
  appInstance = adminLib.app();
  return appInstance;
}

async function verifyIdToken(idToken) {
  const adminLib = getAdmin();
  initFirebaseAdmin();
  return adminLib.auth().verifyIdToken(idToken);
}

module.exports = {
  initFirebaseAdmin,
  verifyIdToken
};
