# Firebase & MongoDB Setup Guide

## Firebase Setup

### Step 1: Install FlutterFire CLI
```bash
flutter pub global activate flutterfire_cli
```

### Step 2: Configure Firebase Project
```bash
flutterfire configure
```
This will:
- Create a Firebase project (or select existing one)
- Generate `firebase_options.dart` file
- Configure platform-specific files

### Step 3: Enable Authentication
1. Go to Firebase Console → Authentication
2. Enable Email/Password sign-in method
3. (Optional) Enable other providers if needed

## MongoDB Setup

### Step 1: Create MongoDB Atlas Account
1. Go to https://www.mongodb.com/atlas
2. Create free account
3. Create new cluster

### Step 2: Get Connection String
1. Click "Connect" on your cluster
2. Choose "Connect your application"
3. Copy the connection string
4. Replace `<password>` with your database password

### Step 3: Update MongoDB Service
Replace the connection string in `lib/core/services/mongodb_service.dart`:
```dart
static const String _connectionString = 'your-mongodb-connection-string';
```

### Step 4: Configure Network Access
1. In MongoDB Atlas → Network Access
2. Add IP address (or 0.0.0.0/0 for development)

## Integration Steps

### 1. Update Registration Screens
The registration screens need to be updated to use `AuthIntegrationService` instead of local storage.

### 2. Add Login Screens
Create login screens for each user type that use the authentication service.

### 3. Add User Management
Add features for profile updates, password changes, etc.

## Security Notes

- Never commit real Firebase config to version control
- Use environment variables for sensitive data
- Set up proper security rules for MongoDB
- Enable proper authentication in production

## Testing

1. Test registration flow
2. Test login flow
3. Test data persistence in MongoDB
4. Test offline Aadhaar verification still works