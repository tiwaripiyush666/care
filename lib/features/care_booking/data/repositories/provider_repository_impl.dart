import 'package:flutter/foundation.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/repositories/provider_repository.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final SupabaseClientService _supabaseService = SupabaseClientService();

  final List<Map<String, dynamic>> _mockProviders = [
    {
      'name': 'Dr. Arjun Mehta',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuB_l4wk9vwtJL4pr3z7fzKFriqLyYKtSPg7FyKep_WSy72L_2ciHB77j72pD_ryrrkJrWsXSDIRP-NEIXhh1hsNzG8AocLGipMfnj0UK6BhxXiJPU0RKEJ_O7A0sCOEsCe5SorStHxWEnYFrjzUpntOtxDwIRvjG6x45OjOLPMtwAgW0ztLnRroiu9gkOcDBpQGUlJ34AbGBNt7kQ5l_y-s0Pl5r0TPtzM3It2FhWswsZaHUoAoHALBRH7cUgJvwARtgzG_MzreIOM5',
      'rate': 850,
      'rateUnit': '/visit',
      'rating': 4.9,
      'reviews': 120,
      'experience': '8+ Years Experience',
      'languages': 'Hindi, English, Marathi',
      'specialty': 'Post-Surgical Care',
      'tags': ['Bedsore Prevention', 'IV Management', 'Elderly Support'],
      'isTopRated': true,
      'serviceType': 'Visit',
    },
    {
      'name': 'Priya Sharma',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFY1yWY5omLfq8UBWtEQZcDjxA2kdw_32-x1HOZOxOMrleijuOkCVtPSI69zwcGbrAvBHNVqU3BCCOQhccjAUGmcxjbour77bULSJHGP94J-ZNJXIuTD_B9NbAkf9lJ4RcGObXDr1299NJN0Grm4N9pqyjhmmb9JI3fp2xgcJFoMS0LhSH7iR74TwrPVkfefrzSsI-w1mcfFEPKkCMYBTvjFfQS_zVsxs7RF1seyBJUhH2KkGzf5_aWk1bmYORMlYkNOsx93XTO8bE',
      'rate': 600,
      'rateUnit': '/visit',
      'rating': 4.7,
      'reviews': 85,
      'experience': '5 Years Experience',
      'languages': 'Hindi, Punjabi',
      'specialty': 'Companion Care',
      'tags': ['Dementia Support', 'Daily Chores'],
      'isTopRated': false,
      'serviceType': 'Visit',
    },
    {
      'name': 'Vikram Singh',
      'avatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwIK-avMl3yEmIZSauNOnABrDMYoTvSRjYM4R2OMiR_zYDT9thD_vM2abjLpNrMW4kbpWJOdThD5wswTb-rHIzTYdLslWVklAJD48Gr7X6jwijilGbH_yUAmTIqVhbHufr6JNJd420SV_0RmlkVw3hRVv8ameRmLrXjg10cctg_ZulTLk0iSqvQZcdbAfRj7IYWXm41Wd9yik4g0YNQwlfU9m8EJNQ6GH2VunYsYulaS7PaniKPymyAUlQsdDPr7zjZhsJXuMb-vGg',
      'rate': 1200,
      'rateUnit': '/visit',
      'rating': 4.8,
      'reviews': 210,
      'experience': '10+ Years Experience',
      'languages': 'Hindi, English, Bengali',
      'specialty': 'Palliative Care',
      'tags': ['Chronic Pain Mgmt', 'Wound Dressing'],
      'isTopRated': false,
      'serviceType': 'Visit',
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> fetchProviders({
    String? query,
    String? serviceType,
  }) async {
    if (_supabaseService.isInitialized) {
      try {
        var request = _supabaseService.client.from('providers').select();
        
        if (serviceType != null && serviceType != 'All') {
          request = request.eq('service_type', serviceType);
        }
        
        final response = await request;
        final list = List<Map<String, dynamic>>.from(response);

        if (query != null && query.isNotEmpty) {
          final q = query.toLowerCase();
          return list.where((p) {
            final name = p['name']?.toString().toLowerCase() ?? '';
            final specialty = p['specialty']?.toString().toLowerCase() ?? '';
            final tags = List<String>.from(p['tags'] ?? []);
            return name.contains(q) || 
                   specialty.contains(q) || 
                   tags.any((t) => t.toLowerCase().contains(q));
          }).toList();
        }
        return list;
      } catch (e) {
        debugPrint('Supabase fetchProviders error: $e');
        rethrow;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
      Iterable<Map<String, dynamic>> results = _mockProviders;
      
      if (serviceType != null && serviceType != 'All') {
        results = results.where((p) => p['serviceType'] == serviceType);
      }
      
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        results = results.where((p) {
          final name = p['name']?.toString().toLowerCase() ?? '';
          final specialty = p['specialty']?.toString().toLowerCase() ?? '';
          final tags = List<String>.from(p['tags'] ?? []);
          return name.contains(q) || 
                 specialty.contains(q) || 
                 tags.any((t) => t.toLowerCase().contains(q));
        });
      }
      
      return results.toList();
    }
  }
}
