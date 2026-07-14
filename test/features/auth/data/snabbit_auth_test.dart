import 'package:flutter_test/flutter_test.dart';
import 'package:caresphere/features/auth/data/services/snabbit_auth_service.dart';

void main() {
  group('Snabbit Auth Authentication Flow Tests', () {
    late SnabbitAuthService authService;

    setUp(() {
      // Re-initialize for isolated test runs
      authService = SnabbitAuthService();
    });

    test('First-Time Login: Deliver OTP and trigger standard verification flow', () async {
      final response = await authService.sendOtp(
        phoneNumber: '+91 9876543210',
        deviceId: 'dev_123',
      );

      expect(response['success'], isTrue);
      expect(response['silent_verification'], isFalse);

      final verifyResponse = await authService.verifyOtp(
        phoneNumber: '+91 9876543210',
        deviceId: 'dev_123',
        otpCode: '123456',
      );

      expect(verifyResponse['success'], isTrue);
      expect(verifyResponse['device_trust_token'], isNotNull);
      expect(verifyResponse['session_jwt'], isNotNull);
    });

    test('Silent Login Bypass: Returning user logs in instantly without SMS dispatch', () async {
      // Step 1: Login initially to establish device linkage & retrieve trust token
      final sendResponse = await authService.sendOtp(
        phoneNumber: '+91 8888888888',
        deviceId: 'dev_returning_user',
      );
      expect(sendResponse['silent_verification'], isFalse);

      final verifyResponse = await authService.verifyOtp(
        phoneNumber: '+91 8888888888',
        deviceId: 'dev_returning_user',
        otpCode: '123456',
      );
      final String trustToken = verifyResponse['device_trust_token'];

      // Step 2: Returning Login with matching credentials -> must trigger silent verification bypass!
      final returningResponse = await authService.sendOtp(
        phoneNumber: '+91 8888888888',
        deviceId: 'dev_returning_user',
        deviceTrustToken: trustToken,
      );

      expect(returningResponse['success'], isTrue);
      // ASSERT: Silent verification bypass matches under the hood
      expect(returningResponse['silent_verification'], isTrue);
      expect(returningResponse['bypass_token'], isNotNull);
    });

    test('Fallback to OTP: Mismatched trust token or device forces WhatsApp/SMS', () async {
      // Link dev_a to number
      final initialVerify = await authService.verifyOtp(
        phoneNumber: '+91 7777777777',
        deviceId: 'dev_a',
        otpCode: '123456',
      );
      final String trustToken = initialVerify['device_trust_token'];

      // Try login on dev_b with dev_a's trust token -> must fallback to standard OTP send
      final mismatchResponse = await authService.sendOtp(
        phoneNumber: '+91 7777777777',
        deviceId: 'dev_b',
        deviceTrustToken: trustToken,
      );

      expect(mismatchResponse['success'], isTrue);
      expect(mismatchResponse['silent_verification'], isFalse);
    });

    test('Rate-Limiting & Toll Fraud: 4 attempts per phone, 5 per device limits', () async {
      final phone = '+91 6666666666';
      final dev = 'dev_rate_limit';

      // Attempts 1 to 4 -> Success
      for (int i = 0; i < 4; i++) {
        final res = await authService.sendOtp(phoneNumber: phone, deviceId: dev);
        expect(res['success'], isTrue);
      }

      // Attempt 5 -> Rate limit block
      final blockedResponse = await authService.sendOtp(phoneNumber: phone, deviceId: dev);
      expect(blockedResponse['success'], isFalse);
      expect(blockedResponse['error'], contains('Too many attempts today'));
    });

    test('Toll Fraud VOIP Filter: Burner numbers are blocked at API level', () async {
      final burnerPhone = '+15551234567';
      final res = await authService.sendOtp(phoneNumber: burnerPhone, deviceId: 'dev_burner');
      
      expect(res['success'], isFalse);
      expect(res['error'], contains('VOIP, virtual, or burner numbers'));
    });
  });
}
