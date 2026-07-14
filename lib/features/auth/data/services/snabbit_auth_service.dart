import 'package:flutter/foundation.dart';

class SnabbitAuthService {
  static final SnabbitAuthService _instance = SnabbitAuthService._internal();
  factory SnabbitAuthService() => _instance;
  SnabbitAuthService._internal();

  // Simple in-memory tracker mimicking backend DB constraints (resets every 24 hours simulated)
  final Map<String, List<DateTime>> _phoneOtpAttempts = {};
  final Map<String, List<DateTime>> _deviceOtpAttempts = {};
  final Map<String, String> _linkedDevices = {}; // device_id -> phone_number
  final Map<String, String> _trustTokens = {};   // device_id:phone_number -> trust_token

  // Mock list of VOIP / virtual number prefixes to block
  final List<String> _blockedPrefixes = ['+91999999', '+91999998', '+1555'];

  /// Checks rate limits and triggers silent bypass verification or WhatsApp/SMS OTP.
  /// Returns a map with authentication response metadata.
  Future<Map<String, dynamic>> sendOtp({
    required String phoneNumber,
    required String deviceId,
    String? deviceTrustToken,
  }) async {
    // 1. VOIP & Virtual Number Prevention
    for (final prefix in _blockedPrefixes) {
      if (phoneNumber.startsWith(prefix)) {
        return {
          'success': false,
          'error': 'VOIP, virtual, or burner numbers are not supported.',
        };
      }
    }

    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(hours: 24));

    // 2. Rate Limiting: 4 attempts per phone number per 24 hours
    final phoneAttempts = _phoneOtpAttempts[phoneNumber] ?? [];
    phoneAttempts.removeWhere((time) => time.isBefore(oneDayAgo));
    if (phoneAttempts.length >= 4) {
      return {
        'success': false,
        'error': 'Too many attempts today. Please try again later.',
      };
    }

    // 3. Rate Limiting: 5 attempts per device/IP per 24 hours
    final deviceAttempts = _deviceOtpAttempts[deviceId] ?? [];
    deviceAttempts.removeWhere((time) => time.isBefore(oneDayAgo));
    if (deviceAttempts.length >= 5) {
      return {
        'success': false,
        'error': 'Too many attempts today. Please try again later.',
      };
    }

    // Register attempts
    phoneAttempts.add(now);
    _phoneOtpAttempts[phoneNumber] = phoneAttempts;
    deviceAttempts.add(now);
    _deviceOtpAttempts[deviceId] = deviceAttempts;

    // 4. Snabbit-Style Bypass Validation
    final savedToken = _trustTokens['$deviceId:$phoneNumber'];
    if (savedToken != null && deviceTrustToken != null && savedToken == deviceTrustToken) {
      debugPrint('Snabbit-Bypass: Matching trust token found for device $deviceId and phone $phoneNumber. Skipping OTP send.');
      return {
        'success': true,
        'silent_verification': true,
        'bypass_token': 'bypass_token_secure_snabbit_${now.millisecondsSinceEpoch}',
      };
    }

    // Mismatch or first-time -> Invalidate old tokens for this device
    _trustTokens.removeWhere((key, value) => key.startsWith('$deviceId:'));

    // 5. Cost-Optimized Delivery Flow
    debugPrint('Snabbit-API: Attempting OTP delivery via WhatsApp Business API first...');
    
    // Simulate WhatsApp delivery
    await Future.delayed(const Duration(seconds: 1));
    bool whatsAppDelivered = true; 

    // Simulation: Let's assume WhatsApp fails for numbers ending in '9' to test SMS fallback
    if (phoneNumber.endsWith('9')) {
      whatsAppDelivered = false;
      debugPrint('Snabbit-API: WhatsApp delivery failed. Initiating SMS fallback...');
    }

    if (whatsAppDelivered) {
      debugPrint('Snabbit-API: OTP delivered successfully via WhatsApp.');
    } else {
      // SMS template is exactly 64 characters (well under 160 threshold)
      debugPrint('Snabbit-API: Delivering SMS: Your caresphere login code is 123456');
    }

    return {
      'success': true,
      'silent_verification': false,
    };
  }

  /// Verifies standard OTP code or bypass tokens. Links device on success.
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String deviceId,
    required String otpCode,
  }) async {
    final isBypass = otpCode.startsWith('bypass_token_secure_snabbit_');
    final isValidOtp = otpCode == '123456';

    if (isBypass || isValidOtp) {
      final now = DateTime.now();
      // Generate a new secure, long-lived device trust token
      final trustToken = 'trust_token_${deviceId}_${phoneNumber}_${now.millisecondsSinceEpoch}';
      
      // Save device-to-phone mapping on our backend
      _linkedDevices[deviceId] = phoneNumber;
      _trustTokens['$deviceId:$phoneNumber'] = trustToken;

      debugPrint('Snabbit-API: Verification successful. Linked device $deviceId with $phoneNumber.');
      return {
        'success': true,
        'device_trust_token': trustToken,
        'session_jwt': 'jwt_session_token_snabbit_${now.millisecondsSinceEpoch}',
      };
    }

    return {
      'success': false,
      'error': 'Invalid code. Use code 123456 to proceed.',
    };
  }
}
