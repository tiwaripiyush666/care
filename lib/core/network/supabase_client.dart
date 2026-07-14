import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();
  factory SupabaseClientService() => _instance;
  SupabaseClientService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;

  SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw StateError('Supabase is not initialized. Please ensure credentials are set.');
    }
    return _client!;
  }

  bool get isInitialized => _isInitialized;

  Future<void> initialize({String? url, String? anonKey}) async {
    final supabaseUrl = url ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final supabaseAnonKey = anonKey ?? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (supabaseUrl.isEmpty || 
        supabaseAnonKey.isEmpty || 
        supabaseUrl == 'SUPABASE_URL' || 
        supabaseAnonKey == 'SUPABASE_ANON_KEY') {
      debugPrint('Supabase credentials are not set or are placeholders. Falling back to local mock storage.');
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase successfully initialized.');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e. Falling back to local mock storage.');
      _isInitialized = false;
    }
  }

  // Auth helper simulation
  Future<void> signInWithOtp(String phone) async {
    if (_isInitialized) {
      await _client?.auth.signInWithOtp(phone: phone);
    }
  }

  // PostGIS location helper simulation
  Future<List<Map<String, dynamic>>> getNearbyProviders(double lat, double lng, double radiusKm) async {
    if (_isInitialized) {
      final response = await _client?.rpc('get_nearby_providers', params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_km': radiusKm,
      });
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
    }
    return [];
  }
}
