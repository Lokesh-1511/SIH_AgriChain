/**
 * OTP Generation and Management Utilities
 */

const crypto = require('crypto');

// In-memory OTP store (use Redis/Database in production)
const otpStore = new Map();

// OTP statistics
let otpStats = {
  generated: 0,
  verified: 0,
  expired: 0,
  invalid: 0
};

/**
 * Generate random OTP
 */
function generateOTP() {
  const length = parseInt(process.env.OTP_LENGTH) || 6;
  const min = Math.pow(10, length - 1);
  const max = Math.pow(10, length) - 1;
  const otp = Math.floor(Math.random() * (max - min + 1)) + min;
  
  otpStats.generated++;
  console.log(`🔢 Generated ${length}-digit OTP`);
  
  return otp.toString();
}

/**
 * Store OTP with transaction details
 */
function storeOTP(transactionId, otpData) {
  try {
    const data = {
      ...otpData,
      storedAt: new Date(),
      isValid: true
    };
    
    otpStore.set(transactionId, data);
    
    // Auto-cleanup expired OTPs
    setTimeout(() => {
      if (otpStore.has(transactionId)) {
        console.log(`🗑️ Auto-removing expired OTP: ${transactionId}`);
        otpStore.delete(transactionId);
        otpStats.expired++;
      }
    }, (process.env.OTP_EXPIRY_MINUTES || 10) * 60 * 1000);
    
    console.log(`💾 Stored OTP for transaction: ${transactionId}`);
    return true;
    
  } catch (error) {
    console.error('❌ Error storing OTP:', error);
    return false;
  }
}

/**
 * Verify OTP against stored data
 */
function verifyOTP(transactionId, providedOTP) {
  try {
    console.log(`🔐 Verifying OTP for transaction: ${transactionId}`);
    
    const storedData = otpStore.get(transactionId);
    
    if (!storedData) {
      otpStats.invalid++;
      return {
        success: false,
        error: 'Invalid transaction ID or OTP expired',
        details: 'Transaction not found in the system'
      };
    }
    
    if (!storedData.isValid) {
      otpStats.invalid++;
      return {
        success: false,
        error: 'OTP already used or invalidated',
        details: 'This OTP has already been verified or cancelled'
      };
    }
    
    // Check expiry
    const now = new Date();
    if (now > storedData.expiresAt) {
      otpStore.delete(transactionId);
      otpStats.expired++;
      return {
        success: false,
        error: 'OTP expired',
        details: 'Please request a new OTP'
      };
    }
    
    // Check max attempts
    const maxAttempts = parseInt(process.env.MAX_OTP_ATTEMPTS) || 3;
    if (storedData.attempts >= maxAttempts) {
      // Invalidate OTP after max attempts
      storedData.isValid = false;
      otpStats.invalid++;
      return {
        success: false,
        error: 'Maximum verification attempts exceeded',
        details: 'Please request a new OTP',
        attemptsRemaining: 0
      };
    }
    
    // Increment attempt count
    storedData.attempts = (storedData.attempts || 0) + 1;
    storedData.lastAttempt = now;
    
    // Verify OTP
    if (storedData.otp !== providedOTP) {
      const attemptsRemaining = maxAttempts - storedData.attempts;
      otpStats.invalid++;
      
      if (attemptsRemaining <= 0) {
        storedData.isValid = false;
      }
      
      return {
        success: false,
        error: 'Invalid OTP',
        details: `OTP does not match. ${attemptsRemaining} attempts remaining.`,
        attemptsRemaining
      };
    }
    
    // OTP is valid
    otpStats.verified++;
    console.log(`✅ OTP verification successful: ${transactionId}`);
    
    return {
      success: true,
      message: 'OTP verified successfully',
      verifiedAt: now,
      aadhaarNumber: storedData.aadhaar_number
    };
    
  } catch (error) {
    console.error('❌ OTP verification error:', error);
    otpStats.invalid++;
    return {
      success: false,
      error: 'Verification failed',
      details: 'Internal error during OTP verification'
    };
  }
}

/**
 * Get stored OTP data (without the OTP itself)
 */
function getStoredOTP(transactionId) {
  const data = otpStore.get(transactionId);
  if (!data) return null;
  
  // Return data without exposing the actual OTP
  const { otp, ...safeData } = data;
  return {
    ...safeData,
    hasOTP: !!otp,
    otpLength: otp ? otp.length : 0
  };
}

/**
 * Update stored OTP data
 */
function updateStoredOTP(transactionId, updateData) {
  const existing = otpStore.get(transactionId);
  if (!existing) return false;
  
  const updated = { ...existing, ...updateData };
  otpStore.set(transactionId, updated);
  
  console.log(`📝 Updated OTP data for transaction: ${transactionId}`);
  return true;
}

/**
 * Invalidate OTP (mark as used)
 */
function invalidateOTP(transactionId) {
  const data = otpStore.get(transactionId);
  if (data) {
    data.isValid = false;
    data.invalidatedAt = new Date();
    console.log(`🚫 Invalidated OTP: ${transactionId}`);
    return true;
  }
  return false;
}

/**
 * Clean up expired OTPs manually
 */
function cleanupExpiredOTPs() {
  const now = new Date();
  let cleanedCount = 0;
  
  for (const [transactionId, data] of otpStore) {
    if (now > data.expiresAt) {
      otpStore.delete(transactionId);
      cleanedCount++;
      otpStats.expired++;
    }
  }
  
  if (cleanedCount > 0) {
    console.log(`🧹 Cleaned up ${cleanedCount} expired OTPs`);
  }
  
  return cleanedCount;
}

/**
 * Get OTP statistics
 */
function getOTPStats() {
  return {
    ...otpStats,
    activeOTPs: otpStore.size,
    timestamp: new Date().toISOString()
  };
}

/**
 * Simulate SMS sending (mock implementation)
 */
function simulateSMSSend(mobileNumber, otp, aadhaarLast4) {
  const message = `Your AgriChain verification OTP is: ${otp}. Valid for ${process.env.OTP_EXPIRY_MINUTES || 10} minutes. Ref: ****${aadhaarLast4}`;
  
  console.log('📱 MOCK SMS SENT:');
  console.log(`   To: ${mobileNumber}`);
  console.log(`   Message: ${message}`);
  
  // In real implementation, this would integrate with SMS providers
  return {
    success: true,
    messageId: `SMS_${Date.now()}_${Math.random().toString(36).substring(7)}`,
    provider: 'mock',
    cost: '₹0.00 (mock)',
    deliveryStatus: 'sent'
  };
}

module.exports = {
  generateOTP,
  storeOTP,
  verifyOTP,
  getStoredOTP,
  updateStoredOTP,
  invalidateOTP,
  cleanupExpiredOTPs,
  getOTPStats,
  simulateSMSSend
};