/**
 * Aadhaar Validation Utilities
 */

const crypto = require('crypto');

// In-memory store for demo (use Redis/Database in production)
const validationCache = new Map();

/**
 * Validate Aadhaar number based on configured patterns
 */
function validateAadhaar(aadhaarNumber) {
  try {
    console.log(`🔍 Validating Aadhaar: ****${aadhaarNumber.slice(-4)}`);
    
    // Basic format validation
    if (!aadhaarNumber || aadhaarNumber.length !== 12) {
      return {
        isValid: false,
        reason: 'Invalid Aadhaar format',
        details: 'Aadhaar number must be exactly 12 digits'
      };
    }
    
    if (!/^[0-9]+$/.test(aadhaarNumber)) {
      return {
        isValid: false,
        reason: 'Invalid Aadhaar format',
        details: 'Aadhaar number must contain only digits'
      };
    }
    
    // Check against allowed patterns
    const allowedPatterns = process.env.ALLOWED_AADHAAR_PATTERNS ? 
      process.env.ALLOWED_AADHAAR_PATTERNS.split(',') : [];
    
    let isPatternMatch = false;
    let matchedPattern = null;
    
    for (const pattern of allowedPatterns) {
      if (matchesPattern(aadhaarNumber, pattern.trim())) {
        isPatternMatch = true;
        matchedPattern = pattern;
        break;
      }
    }
    
    if (!isPatternMatch) {
      return {
        isValid: false,
        reason: 'Aadhaar number not authorized',
        details: 'This Aadhaar number is not in the authorized list for AgriChain services'
      };
    }
    
    // Additional business logic validation
    if (aadhaarNumber.startsWith('000000')) {
      return {
        isValid: false,
        reason: 'Invalid Aadhaar number',
        details: 'Aadhaar number cannot start with 000000'
      };
    }
    
    // Check for obviously fake patterns
    const allSameDigit = /^(\d)\1{11}$/.test(aadhaarNumber);
    if (allSameDigit) {
      return {
        isValid: false,
        reason: 'Invalid Aadhaar pattern',
        details: 'Aadhaar number cannot have all same digits'
      };
    }
    
    console.log(`✅ Aadhaar validation successful: Pattern matched - ${matchedPattern}`);
    
    return {
      isValid: true,
      reason: 'Valid Aadhaar number',
      details: 'Aadhaar number is authorized for AgriChain services',
      matchedPattern
    };
    
  } catch (error) {
    console.error('❌ Aadhaar validation error:', error);
    return {
      isValid: false,
      reason: 'Validation error',
      details: 'Failed to validate Aadhaar number'
    };
  }
}

/**
 * Check if Aadhaar matches a pattern (supports wildcards)
 */
function matchesPattern(aadhaar, pattern) {
  // Convert pattern to regex (replace * with \d+)
  const regexPattern = pattern
    .replace(/\*/g, '\\d*')
    .replace(/\+/g, '\\+')
    .replace(/\./g, '\\.');
  
  const regex = new RegExp(`^${regexPattern}$`);
  return regex.test(aadhaar);
}

/**
 * Generate unique transaction ID
 */
function generateTransactionId() {
  const timestamp = Date.now().toString(36);
  const randomBytes = crypto.randomBytes(8).toString('hex');
  return `TXN_${timestamp}_${randomBytes}`.toUpperCase();
}

/**
 * Simulate Aadhaar-to-mobile mapping (mock implementation)
 */
function getMobileNumber(aadhaarNumber) {
  // In real implementation, this would query UIDAI database
  // For demo, generate consistent mobile number based on Aadhaar
  
  const hash = crypto.createHash('md5').update(aadhaarNumber).digest('hex');
  const mobileDigits = hash.substring(0, 10);
  const mobile = `91${mobileDigits}`.replace(/[a-f]/g, (char) => {
    return String.fromCharCode(char.charCodeAt(0) - 'a'.charCodeAt(0) + '0'.charCodeAt(0));
  });
  
  // Ensure it's a valid 10-digit number
  const cleanMobile = mobile.replace(/[^0-9]/g, '').substring(0, 10);
  return `+91${cleanMobile.padEnd(10, '0')}`;
}

/**
 * Get validation statistics (for monitoring)
 */
function getValidationStats() {
  const stats = {
    totalValidations: validationCache.size,
    validCount: 0,
    invalidCount: 0,
    patterns: {}
  };
  
  for (const [aadhaar, validation] of validationCache) {
    if (validation.isValid) {
      stats.validCount++;
      const pattern = validation.matchedPattern || 'unknown';
      stats.patterns[pattern] = (stats.patterns[pattern] || 0) + 1;
    } else {
      stats.invalidCount++;
    }
  }
  
  return stats;
}

module.exports = {
  validateAadhaar,
  generateTransactionId,
  getMobileNumber,
  getValidationStats,
  matchesPattern
};