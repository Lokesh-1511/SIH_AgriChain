const mongoose = require('mongoose');

const roles = ['farmer', 'distributor', 'retailer', 'consumer', 'administrator'];

const farmerProfileSchema = new mongoose.Schema({
  farmerId: { type: String },
  landOwnership: { type: String },
  landSize: { type: Number },
  landDocuments: { type: String },
  agriScore: { type: Number, default: 0 }
}, { _id: false });

const distributorProfileSchema = new mongoose.Schema({
  distributorId: { type: String },
  vehicleDetails: { type: String },
  licenseNumber: { type: String },
  rating: { type: Number, default: 0 }
}, { _id: false });

const retailerProfileSchema = new mongoose.Schema({
  retailerId: { type: String },
  shopName: { type: String },
  location: { type: String },
  rating: { type: Number, default: 0 }
}, { _id: false });

const consumerProfileSchema = new mongoose.Schema({
  consumerId: { type: String },
  preferences: { type: [String], default: [] },
  hasActiveSubscriptions: { type: Boolean, default: false }
}, { _id: false });

const userSchema = new mongoose.Schema({
  // Core identity fields
  firebaseUid: { type: String, index: true }, // Flutter expects this in user documents
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  phone: { type: String },
  role: { type: String, enum: roles, required: true },
  address: { type: String, default: '' },
  isVerified: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true }, // Flutter createUser sets isActive
  passwordHash: { type: String, required: true },
  // KYC / compliance
  kycDetails: { type: mongoose.Schema.Types.Mixed }, // Map<String,dynamic> expected in Flutter
  additionalInfo: { type: mongoose.Schema.Types.Mixed },
  // Role specific embedded sub-documents
  farmerProfile: farmerProfileSchema,
  distributorProfile: distributorProfileSchema,
  retailerProfile: retailerProfileSchema,
  consumerProfile: consumerProfileSchema,
  aadhaar: {
    verified: { type: Boolean, default: false },
    last4: { type: String },
    verifiedAt: { type: Date }
  }
}, {
  timestamps: true
});

userSchema.index({ role: 1, isVerified: 1 });
userSchema.index({ createdAt: -1 });

userSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    // Flutter model AgriChainUser expects _id (optionally) – keep both id & _id? We'll expose only id for clarity.
    delete ret._id;
    delete ret.__v;
    delete ret.passwordHash;
    // Provide consistent timestamps naming for Flutter expectations if needed (createdAt / updatedAt already match)
    // Ensure firebaseUid & kycDetails & isActive present even if undefined
    if (!('firebaseUid' in ret)) ret.firebaseUid = undefined;
    if (!('kycDetails' in ret)) ret.kycDetails = {};
    if (!('isActive' in ret)) ret.isActive = true;
    return ret;
  }
});

module.exports = mongoose.model('User', userSchema);
