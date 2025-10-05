/**
 * Aadhaar Validation Routes
 */

const express = require('express');
const Joi = require('joi');
const router = express.Router();
const { validateAadhaar, generateTransactionId } = require('../utils/aadhaar');
const { generateOTP, storeOTP } = require('../utils/otp');

// Aadhaar validation schema
const aadhaarSchema = Joi.object({
  aadhaar_number: Joi.string()
    .length(12)
    .pattern(/^[0-9]+$/)
    .required()
    .messages({
      'string.length': 'Aadhaar number must be exactly 12 digits',
      'string.pattern.base': 'Aadhaar number must contain only digits',
      'any.required': 'Aadhaar number is required'
    }),
  user_id: Joi.string().optional(),
  user_role: Joi.string().valid('farmer', 'distributor', 'retailer', 'consumer', 'admin').optional()
});

// POST /api/aadhaar/validate
router.post('/validate', async (req, res) => {
  try {
    console.log('📱 Aadhaar validation request:', req.body);
    
    // Validate request body
    const { error, value } = aadhaarSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: error.details[0].message
      });
    }
    
    const { aadhaar_number, user_id, user_role } = value;
    
    // Validate Aadhaar number
    const validation = await validateAadhaar(aadhaar_number);
    
    if (!validation.isValid) {
      console.log('❌ Aadhaar validation failed:', validation.reason);
      return res.status(400).json({
        success: false,
        error: validation.reason,
        details: validation.details || 'Aadhaar number does not meet validation criteria'
      });
    }
    
    // Generate OTP if Aadhaar is valid
    const otp = generateOTP();
    const transactionId = generateTransactionId();
    const expiresAt = new Date(Date.now() + (process.env.OTP_EXPIRY_MINUTES || 10) * 60 * 1000);
    
    // Store OTP for verification
    storeOTP(transactionId, {
      otp,
      aadhaar_number,
      user_id,
      user_role,
      attempts: 0,
      createdAt: new Date(),
      expiresAt
    });
    
    console.log(`✅ OTP generated for Aadhaar ****${aadhaar_number.slice(-4)}: ${otp}`);
    
    // Mock mobile number generation
    const mockMobile = `+91${Math.floor(Math.random() * 9000000000 + 1000000000)}`;
    
    res.json({
      success: true,
      message: 'OTP generated successfully',
      transaction_id: transactionId,
      mobile_number: `${mockMobile.slice(0, -4)}****`,
      otp_length: otp.length,
      expires_in_minutes: process.env.OTP_EXPIRY_MINUTES || 10,
      // In development, show the actual OTP
      ...(process.env.NODE_ENV === 'development' && { 
        debug_otp: otp,
        debug_note: 'OTP shown for development only'
      })
    });
    
  } catch (error) {
    console.error('❌ Aadhaar validation error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: 'Failed to process Aadhaar validation'
    });
  }
});

// GET /api/aadhaar/patterns (development only)
router.get('/patterns', (req, res) => {
  if (process.env.NODE_ENV !== 'development') {
    return res.status(403).json({
      error: 'Pattern info only available in development mode'
    });
  }
  
  const patterns = process.env.ALLOWED_AADHAAR_PATTERNS ? 
    process.env.ALLOWED_AADHAAR_PATTERNS.split(',') : [];
  
  res.json({
    allowed_patterns: patterns,
    examples: [
      '123456789012',
      '999999990123',
      '555555555555',
      '789012345678'
    ],
    note: 'These patterns are for development and testing only'
  });
});

module.exports = router;