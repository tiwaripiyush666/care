import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:caresphere/core/location/location_service.dart';
import 'package:caresphere/core/storage/local_storage.dart';

class LocationDiscoveryScreen extends StatefulWidget {
  const LocationDiscoveryScreen({super.key});

  @override
  State<LocationDiscoveryScreen> createState() => _LocationDiscoveryScreenState();
}

class _LocationDiscoveryScreenState extends State<LocationDiscoveryScreen> {
  bool _isLocating = false;

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final position = await LocationService().getCurrentUserPosition();
      final address = await LocationService().getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Save to cache storage
      final storage = LocalStorageService();
      await storage.cacheValue('precise_user_address', address);

      if (mounted) {
        setState(() {
          _isLocating = false;
        });
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Located: $address'),
            backgroundColor: AppTheme.secondary,
          ),
        );
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Location Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 1. Premium Background Image & Overlay
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAu4Bg6zcnz_nitjc4vH6mzzu1rvB7r7kDQmqdwisWGAxYxYTi-XB1xm_WjEGdNrbFOeyCzsoWsA7ISd8kAegOkIi6HFJsyLsLPGRLkYSVVBaHNJqKaYpB39HWmpj0LJx4KtL5-dOgoWv1nepZXFq7jfM88vBILG3feSW9USAUH7xrLmWdxf-U8hw7E_sdisEN9vJNHJFvk7ELPlU1DMOf7ryu96KXL_eClxgw869UNmvtXVnNT56cHh53upjPbqnZ9uFbpHF2hstu8',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F5F73).withAlpha(102), // 40% primaryContainer
                    const Color(0xFF0F5F73).withAlpha(217), // 85% primaryContainer
                  ],
                ),
              ),
            ),
          ),

          // 2. Header and Text Info (upper area)
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Translucent Shield Lock Icon Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26), // white/10
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(51)), // white/20
                  ),
                  child: const Icon(
                    Icons.lock_person_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Find trusted support\nfor your home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle description
                Text(
                  'Connect with verified professionals to maintain and protect your living space. We need your location to find local experts near you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(230),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          // 3. Action Sheet (bottom area)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Secure Location Label Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                      border: Border.all(color: AppTheme.outlineVariant.withAlpha(128)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.primary,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'SECURE LOCATION ACCESS',
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Use Current Location CTA Button
                  ElevatedButton.icon(
                    onPressed: _isLocating ? null : _useCurrentLocation,
                    icon: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.near_me, size: 18),
                    label: Text(
                      _isLocating ? 'Locating...' : 'Use current location',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Enter Location Manually Outlined Button
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/location_manual');
                    },
                    icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                    label: const Text(
                      'Enter location manually',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.onSurface,
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Privacy disclaimer
                  const Text(
                    'Your location data is encrypted and used only to match you with local service providers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
