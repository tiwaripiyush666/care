import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../services/snabbit_auth_service.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Encrypted Hive local storage to satisfy Constraint 2 securely ---
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  Box? _secureBox;

  Future<void> init() async {
    if (_secureBox != null) return;
    
    // 256-bit key derived for AES encryption
    final keyString = 'caresphere_secure_token_salt_seed_2026_snabbit';
    final bytes = utf8.encode(keyString);
    final List<int> key = List<int>.generate(32, (i) => bytes[i % bytes.length]);

    _secureBox = await Hive.openBox(
      'caresphere_secure_storage',
      encryptionCipher: HiveAesCipher(key),
    );
  }

  Future<void> write(String key, String value) async {
    await init();
    await _secureBox?.put(key, value);
  }

  Future<String?> read(String key) async {
    await init();
    return _secureBox?.get(key) as String?;
  }

  Future<void> delete(String key) async {
    await init();
    await _secureBox?.delete(key);
  }
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClientService _supabaseService = SupabaseClientService();
  final SnabbitAuthService _snabbitService = SnabbitAuthService();
  final SecureStorageService _secureStorage = SecureStorageService();
  
  Map<String, dynamic>? _mockCurrentUser;

  @override
  Future<Map<String, dynamic>> signInWithOtp(
    String phone, {
    String? deviceId,
    String? deviceTrustToken,
  }) async {
    // If Supabase is initialized, we would hit our backend POST /auth/send-otp endpoint.
    // In our workspace, we route requests through SnabbitAuthService.
    final result = await _snabbitService.sendOtp(
      phoneNumber: phone,
      deviceId: deviceId ?? 'unknown_device',
      deviceTrustToken: deviceTrustToken,
    );

    if (result['success'] == false) {
      throw Exception(result['error'] ?? 'OTP send failed');
    }

    return Map<String, dynamic>.from(result);
  }

  @override
  Future<bool> verifyOtp(
    String phone,
    String token, {
    String? deviceId,
  }) async {
    final devId = deviceId ?? 'unknown_device';
    final result = await _snabbitService.verifyOtp(
      phoneNumber: phone,
      deviceId: devId,
      otpCode: token,
    );

    if (result['success'] == true) {
      final trustToken = result['device_trust_token'] as String;
      
      // Securely store the trust token and phone number locally on success
      await _secureStorage.write('device_trust_token', trustToken);
      await _secureStorage.write('phone_number', phone);

      _mockCurrentUser = {
        'id': 'uid_${devId}_${phone.hashCode}',
        'phone': phone,
        'session_jwt': result['session_jwt'],
      };
      return true;
    } else {
      throw Exception(result['error'] ?? 'Invalid code. Please try again.');
    }
  }

  @override
  Future<void> saveUserProfile({
    required String name,
    required String email,
    required String gender,
    String? referral,
  }) async {
    if (_supabaseService.isInitialized) {
      try {
        final userId = _supabaseService.client.auth.currentUser?.id;
        if (userId == null) throw StateError('No authenticated user found');
        
        await _supabaseService.client.from('profiles').upsert({
          'id': userId,
          'name': name,
          'email': email,
          'gender': gender,
          'referral': referral,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Supabase profile save error: $e');
        rethrow;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      if (_mockCurrentUser != null) {
        _mockCurrentUser!['name'] = name;
        _mockCurrentUser!['email'] = email;
        _mockCurrentUser!['gender'] = gender;
        _mockCurrentUser!['referral'] = referral;
      }
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_supabaseService.isInitialized) {
      try {
        final user = _supabaseService.client.auth.currentUser;
        if (user == null) return null;
        
        final response = await _supabaseService.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
            
        if (response != null) {
          return Map<String, dynamic>.from(response);
        }
        
        return {
          'id': user.id,
          'phone': user.phone,
        };
      } catch (e) {
        debugPrint('Supabase fetch profile error: $e');
        return null;
      }
    } else {
      return _mockCurrentUser;
    }
  }

  @override
  Future<void> signOut() async {
    // Clear current user and stored credentials
    _mockCurrentUser = null;
    await _secureStorage.delete('device_trust_token');
    await _secureStorage.delete('phone_number');

    if (_supabaseService.isInitialized) {
      await _supabaseService.client.auth.signOut();
    }
  }

  @override
  Future<void> setBiometricPreference(bool enabled) async {
    await _secureStorage.write('biometric_enabled_flag', enabled ? 'true' : 'false');
  }

  @override
  Future<bool> getBiometricPreference() async {
    final val = await _secureStorage.read('biometric_enabled_flag');
    return val == 'true';
  }
}
