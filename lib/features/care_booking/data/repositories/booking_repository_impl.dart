import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClientService _supabaseService = SupabaseClientService();
  final LocalStorageService _storageService = LocalStorageService();

  final List<Map<String, dynamic>> _defaultBookings = [
    {
      'name': 'Dr. Arjun Mehta',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB_l4wk9vwtJL4pr3z7fzKFriqLyYKtSPg7FyKep_WSy72L_2ciHB77j72pD_ryrrkJrWsXSDIRP-NEIXhh1hsNzG8AocLGipMfnj0UK6BhxXiJPU0RKEJ_O7A0sCOEsCe5SorStHxWEnYFrjzUpntOtxDwIRvjG6x45OjOLPMtwAgW0ztLnRroiu9gkOcDBpQGUlJ34AbGBNt7kQ5l_y-s0Pl5r0TPtzM3It2FhWswsZaHUoAoHALBRH7cUgJvwARtgzG_MzreIOM5',
      'specialty': 'Post-Surgical Care',
      'schedule': 'Today, 2:00 PM',
      'date': 'Oct 24, 2026',
      'address': 'Sector 62, Noida (Home)',
      'isAvailableNow': true,
      'hasTracking': true,
      'status': 'Active',
    },
    {
      'name': 'Priya Sharma',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFY1yWY5omLfq8UBWtEQZcDjxA2kdw_32-x1HOZOxOMrleijuOkCVtPSI69zwcGbrAvBHNVqU3BCCOQhccjAUGmcxjbour77bULSJHGP94J-ZNJXIuTD_B9NbAkf9lJ4RcGObXDr1299NJN0Grm4N9pqyjhmmb9JI3fp2xgcJFoMS0LhSH7iR74TwrPVkfefrzSsI-w1mcfFEPKkCMYBTvjFfQS_zVsxs7RF1seyBJUhH2KkGzf5_aWk1bmYORMlYkNOsx93XTO8bE',
      'specialty': 'Companion Care Support',
      'schedule': 'Sat, Oct 28',
      'date': 'Oct 28, 2026',
      'address': '10:00 AM - 12:00 PM',
      'isAvailableNow': true,
      'hasTracking': false,
      'status': 'Active',
    },
    {
      'name': 'Vikram Singh',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwIK-avMl3yEmIZSauNOnABrDMYoTvSRjYM4R2OMiR_zYDT9thD_vM2abjLpNrMW4kbpWJOdThD5wswTb-rHIzTYdLslWVklAJD48Gr7X6jwijilGbH_yUAmTIqVhbHufr6JNJd420SV_0RmlkVw3hRVv8ameRmLrXjg10cctg_ZulTLk0iSqvQZcdbAfRj7IYWXm41Wd9yik4g0YNQwlfU9m8EJNQ6GH2VunYsYulaS7PaniKPymyAUlQsdDPr7zjZhsJXuMb-vGg',
      'specialty': 'Palliative Support Care',
      'date': 'Completed Oct 12, 2026',
      'rating': 5,
      'status': 'Past',
    }
  ];

  @override
  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    if (_supabaseService.isInitialized) {
      try {
        final userId = _supabaseService.client.auth.currentUser?.id;
        final dataToInsert = {
          ...bookingData,
          'user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        };
        await _supabaseService.client.from('bookings').insert(dataToInsert);
      } catch (e) {
        debugPrint('Supabase createBooking error: $e');
        rethrow;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      final currentBookings = await fetchBookings();
      
      final newBooking = {
        ...bookingData,
        'status': 'Active',
      };
      
      currentBookings.insert(0, newBooking);
      
      // Serialize to local storage
      final jsonString = jsonEncode(currentBookings);
      await _storageService.cacheValue('bookings_list', jsonString);
      debugPrint('Booking locally saved: $newBooking');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBookings() async {
    if (_supabaseService.isInitialized) {
      try {
        final userId = _supabaseService.client.auth.currentUser?.id;
        if (userId == null) return [];
        final response = await _supabaseService.client
            .from('bookings')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);
            
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        debugPrint('Supabase fetchBookings error: $e');
        rethrow;
      }
    } else {
      final cachedJson = _storageService.getCachedValue('bookings_list');
      if (cachedJson == null) {
        return List<Map<String, dynamic>>.from(_defaultBookings);
      }
      try {
        final decoded = jsonDecode(cachedJson as String) as List;
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      } catch (e) {
        debugPrint('Error decoding cached bookings: $e');
        return List<Map<String, dynamic>>.from(_defaultBookings);
      }
    }
  }
}
