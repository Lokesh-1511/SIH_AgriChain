/**
 * OTP Verification Routes
 */

const express = require('express');
const Joi = require('joi');
const router = express.Router();
const { verifyOTP, getStoredOTP, invalidateOTP } = require('../utils/otp');

// OTP verification schema
const otpSchema = Joi.object({
  transaction_id: Joi.string().required().messages({
    'any.required': 'Transaction ID is required'
  }),
  otp: Joi.string()
    .length(parseInt(process.env.OTP_LENGTH) || 6)
    .pattern(/^[0-9]+$/)
    .required()
    .messages({
      'string.length': `OTP must be exactly ${process.env.OTP_LENGTH || 6} digits`,
      'string.pattern.base': 'OTP must contain only digits',
      'any.required': 'OTP is required'
    }),
  // Allow optional fields from Flutter app
  aadhaar_number: Joi.string().optional(),
  user_id: Joi.string().optional()
});

// POST /api/otp/verify
router.post('/verify', async (req, res) => {
  try {
    console.log('🔐 OTP verification request:', { 
      transaction_id: req.body.transaction_id,
      otp: '***' + (req.body.otp || '').slice(-2)
    });
    
    // Validate request body
    const { error, value } = otpSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: error.details[0].message
      });
    }
    
    const { transaction_id, otp } = value;
    
    // Verify OTP
    const verification = await verifyOTP(transaction_id, otp);
    
    if (!verification.success) {
      console.log('❌ OTP verification failed:', verification.error);
      return res.status(400).json({
        success: false,
        error: verification.error,
        details: verification.details,
        attempts_remaining: verification.attemptsRemaining
      });
    }
    
    console.log('✅ OTP verification successful for transaction:', transaction_id);
    
    // Get user details from stored OTP data
    const otpData = getStoredOTP(transaction_id);
    
    // Invalidate the OTP after successful verification
    invalidateOTP(transaction_id);
    
    // Generate mock KYC details for development
    const aadhaarNumber = otpData?.aadhaarNumber || '';
    const mockKycDetails = {
      name: 'John Doe',
      date_of_birth: '1990-01-01',
      gender: 'M',
      address: {
        care_of: 'S/O John Smith',
        house: '123',
        street: 'Main Street',
        locality: 'City Center',
        village_town_city: 'Mumbai',
        sub_district: 'Mumbai Suburban',
        district: 'Mumbai',
        state: 'Maharashtra',
        post_office: 'Mumbai Central',
        pincode: '400001'
      },
      masked_aadhaar: `XXXX-XXXX-${aadhaarNumber.slice(-4)}`,
      photo_url: null
    };
    
    res.json({
      success: true,
      message: 'OTP verified successfully',
      aadhaar_verified: true,
      user_id: otpData?.user_id,
      user_role: otpData?.user_role,
      verified_at: new Date().toISOString(),
      data: {
        kyc_details: mockKycDetails
      }
    });
    
  } catch (error) {
    console.error('❌ OTP verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: 'Failed to verify OTP'
    });
  }
});

// POST /api/otp/resend
router.post('/resend', async (req, res) => {
  try {
    const { transaction_id } = req.body;
    
    if (!transaction_id) {
      return res.status(400).json({
        success: false,
        error: 'Transaction ID is required'
      });
    }
    
    console.log('🔄 OTP resend request for transaction:', transaction_id);
    
    // Get stored OTP data
    const otpData = getStoredOTP(transaction_id);
    
    if (!otpData) {
      return res.status(404).json({
        success: false,
        error: 'Invalid transaction ID or OTP expired'
      });
    }
    
    // Check retry delay
    const now = new Date();
    const lastAttempt = otpData.lastAttempt || otpData.createdAt;
    const delaySeconds = process.env.OTP_RETRY_DELAY_SECONDS || 30;
    const timeDiff = (now - lastAttempt) / 1000;
    
    if (timeDiff < delaySeconds) {
      return res.status(429).json({
        success: false,
        error: 'Please wait before requesting another OTP',
        retry_after_seconds: Math.ceil(delaySeconds - timeDiff)
      });
    }
    
    // Generate new OTP (in real implementation, this would trigger SMS)
    const { generateOTP, updateStoredOTP } = require('../utils/otp');
    const newOTP = generateOTP();
    
    updateStoredOTP(transaction_id, {
      otp: newOTP,
      lastAttempt: now,
      attempts: 0 // Reset attempts for new OTP
    });
    
    console.log(`✅ New OTP generated for transaction ${transaction_id}: ${newOTP}`);
    
    res.json({
      success: true,
      message: 'New OTP sent successfully',
      expires_in_minutes: process.env.OTP_EXPIRY_MINUTES || 10,
      // Show OTP in development
      ...(process.env.NODE_ENV === 'development' && { 
        debug_otp: newOTP,
        debug_note: 'OTP shown for development only'
      })
    });
    
  } catch (error) {
    console.error('❌ OTP resend error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: 'Failed to resend OTP'
    });
  }
});

// GET /api/otp/status/:transaction_id (development only)
router.get('/status/:transaction_id', (req, res) => {
  if (process.env.NODE_ENV !== 'development') {
    return res.status(403).json({
      error: 'OTP status only available in development mode'
    });
  }
  
  const { transaction_id } = req.params;
  const otpData = getStoredOTP(transaction_id);
  
  if (!otpData) {
    return res.status(404).json({
      success: false,
      error: 'Transaction not found or expired'
    });
  }
  
  res.json({
    success: true,
    transaction_id,
    status: 'active',
    created_at: otpData.createdAt,
    expires_at: otpData.expiresAt,
    attempts: otpData.attempts,
    max_attempts: process.env.MAX_OTP_ATTEMPTS || 3,
    debug_otp: otpData.otp
  });
});

module.exports = router;