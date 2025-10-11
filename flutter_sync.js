// AgriChain User Registration Sync Service
// This file is updated by Flutter app when users register

const AGRICHAIN_SYNC = {
  lastUpdated: null,
  registeredUsers: {
    // Will be populated when users register through Flutter app
    // Format: { userId: { name, email, role, wallet, registrationTime } }
  },
  
  // Method to add user from Flutter app
  addUser: function(userData) {
    this.registeredUsers[userData.userId] = {
      ...userData,
      registrationTime: new Date().toISOString(),
      source: 'flutter_app'
    };
    this.lastUpdated = new Date().toISOString();
    this.saveToLocalStorage();
  },
  
  // Save to localStorage for persistence
  saveToLocalStorage: function() {
    localStorage.setItem('agrichain_flutter_users', JSON.stringify(this));
  },
  
  // Load from localStorage
  loadFromLocalStorage: function() {
    const stored = localStorage.getItem('agrichain_flutter_users');
    if (stored) {
      const data = JSON.parse(stored);
      this.registeredUsers = data.registeredUsers || {};
      this.lastUpdated = data.lastUpdated;
    }
  }
};

// Auto-load on page load
if (typeof window !== 'undefined') {
  AGRICHAIN_SYNC.loadFromLocalStorage();
}