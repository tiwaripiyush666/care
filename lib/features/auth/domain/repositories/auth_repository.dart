abstract class AuthRepository {
  Future<Map<String, dynamic>> signInWithOtp(
    String phone, {
    String? deviceId,
    String? deviceTrustToken,
  });
  
  Future<bool> verifyOtp(
    String phone,
    String token, {
    String? deviceId,
  });

  Future<void> saveUserProfile({
    required String name,
    required String email,
    required String gender,
    String? referral,
  });

  Future<Map<String, dynamic>?> getCurrentUser();
  Future<void> signOut();

  // Biometrics Opt-in preferences
  Future<void> setBiometricPreference(bool enabled);
  Future<bool> getBiometricPreference();
}
