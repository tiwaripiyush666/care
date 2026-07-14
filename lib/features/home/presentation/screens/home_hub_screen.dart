import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:caresphere/features/auth/data/repositories/auth_repository_impl.dart';

class HomeHubScreen extends StatefulWidget {
  const HomeHubScreen({super.key});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

class _HomeHubScreenState extends State<HomeHubScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricOptIn();
    });
  }

  Future<void> _checkBiometricOptIn() async {
    final storage = SecureStorageService();
    final hasPreference = await storage.read('biometric_preference_configured');
    if (hasPreference == null) {
      _showBiometricOptInDialog();
    }
  }

  void _showBiometricOptInDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
          ),
          title: Row(
            children: [
              const Icon(Icons.fingerprint, color: AppTheme.primaryContainer, size: 28),
              const SizedBox(width: 8),
              Text(
                'Enable Passwordless Login',
                style: TextStyle(
                  color: AppTheme.primaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Would you like to enable Biometrics (Face ID/Fingerprint) or a 4-digit PIN for faster, passwordless logins next time?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final storage = SecureStorageService();
                await storage.write('biometric_enabled_flag', 'false');
                await storage.write('biometric_preference_configured', 'true');
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Preferences saved. You can change this in Account Settings.'),
                    backgroundColor: AppTheme.onSurfaceVariant,
                  ),
                );
              },
              child: const Text(
                'No, Thanks',
                style: TextStyle(
                  color: AppTheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final storage = SecureStorageService();
                await storage.write('biometric_enabled_flag', 'true');
                await storage.write('biometric_preference_configured', 'true');
                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Biometrics / PIN authentication enabled successfully!'),
                    backgroundColor: AppTheme.primaryContainer,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                ),
              ),
              child: const Text('Yes, Enable'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppTheme.primaryContainer,
              size: 20,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR LOCATION',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Indiranagar, Bangalore',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          // Middle app title "Trusted Home"
          Center(
            child: Text(
              'Trusted Home',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryContainer,
                fontWeight: FontWeight.w800,
                fontSize: 20.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Profile image
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.containerMargin),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryFixed,
                  width: 2.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBBH4U5mhaKWA8b5cLcZh71sYtgktSxjUHDjruLP9D9YEmsARU2pKoGRqDsJgs10h9UBaHEFlcBZfe938kq_OKAFzLpA_Dr3Fvti9ksFeMBbBiBH4YL6H-_AgMJ7s5O1rYXFEw6U69R0oXjKXELBOiVOt9xRwG4X3QsriMgJkFPGQsqk1IfTAgFyNGuFVXRBucP5YTYwWiGHwG9HmPgMUp_sFVO2x5vfR7FE6tDE5yJGGMWaXdKCpxJMWEYfsiBwPHreRej3Mw8kERE',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_circle,
                      size: 34,
                      color: AppTheme.primary,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: AppTheme.outlineVariant,
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.containerMargin,
            vertical: AppTheme.stackLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Search Bar Section
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                        border: Border.all(
                          color: AppTheme.outlineVariant,
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.0),
                            child: Icon(
                              Icons.search,
                              color: AppTheme.outline,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              onTap: () {
                                Navigator.pushNamed(context, '/search');
                              },
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.onSurface,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search for tutors, guards, or care...',
                                hintStyle: TextStyle(
                                  color: AppTheme.outline,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryContainer,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.roundedMd - 2.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Text(
                                'Find Care',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.stackLg),

              // 2. Hero Card Banner
              Container(
                height: 192,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5F73), // Primary Container color
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 12.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        top: 0,
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAfpCMrvp8hGM8ZxhDKi_vJ3CpPsEjcNCftdo_YOlWrMjHCU2UO_DfTD8u8zHhgw252uoRTub6LcXEnji3TkG8YGOaU_yO47TZ3qJDq8dJSOLmA3Zeeh2l3pG-aQXl8QAX_C_uZbrPPNjSF72oiy1akoJZIxSITUlDMvGKg7QuQRgm8ORtdKBysrowQ-NOA2kPFqDhc4DcJgsI4Nqfgv08NqYxYMYhIvIrsa0f4GiFi0KywYxCISwUnoYX79ue1WInJMr9UA3QFrOm_',
                          fit: BoxFit.cover,
                          color: const Color(0xFF0F5F73).withAlpha(100),
                          colorBlendMode: BlendMode.dstATop,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.home_repair_service,
                                color: Colors.white,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Compassionate care,\ndelivered at home.',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: const Color(0xFFB4EBFF), // primary-fixed/light text
                                fontWeight: FontWeight.bold,
                                fontSize: 22.0,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Expert medical professionals\njust a tap away.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFFD1E4FB).withAlpha(200),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.stackLg),

              // 3. Service Categories Grid Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Our Services',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 4. Categories Grid Items
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
                children: [
                  _buildCategoryItem(Icons.medical_services_outlined, 'Patient Care'),
                  _buildCategoryItem(Icons.child_care, 'Child Care'),
                  _buildCategoryItem(Icons.school_outlined, 'Tutors'),
                  _buildCategoryItem(Icons.security, 'Security'),
                  _buildCategoryItem(Icons.yard_outlined, 'Gardening'),
                  _buildCategoryItem(Icons.build_outlined, 'Maintenance'),
                  _buildCategoryItem(Icons.cleaning_services_outlined, 'Cleaning'),
                  _buildCategoryItem(Icons.more_horiz, 'More'),
                ],
              ),
              const SizedBox(height: AppTheme.stackLg),

              // 5. Trending Services Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Services',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Explore',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 6. Trending Services Cards Slider
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildTrendingCard(
                      Icons.verified_user_outlined,
                      AppTheme.primaryContainer,
                      'Home Security Audit',
                      'Get a professional safety check for your home.',
                    ),
                    const SizedBox(width: AppTheme.gutterMd),
                    _buildTrendingCard(
                      Icons.psychology_outlined,
                      AppTheme.secondary,
                      'Math Tutors (Grade 10)',
                      'Top rated tutors for board exam prep.',
                    ),
                    const SizedBox(width: AppTheme.gutterMd),
                    _buildTrendingCard(
                      Icons.sanitizer_outlined,
                      AppTheme.primaryContainer,
                      'Deep Cleaning',
                      'Full home sanitization and cleaning.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.stackLg),

              // 7. Top Professionals Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Professionals',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      _buildRoundScrollBtn(Icons.chevron_left),
                      const SizedBox(width: 8),
                      _buildRoundScrollBtn(Icons.chevron_right),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.stackMd),

              // 8. Top Professionals Cards (2-Column Grid/List)
              Column(
                children: [
                  _buildProviderCard(
                    context: context,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDRqDDLs1q_fFaaOPb3qxHdgz5RWHQfABcgHTARdihp5Pay2l-3B6Q4tBp1MRoIDvwnJO_YtBfTrL3F-x8azvaeu6VCjP-BA2iKoPdzckLon6jcJMpglmnwTnlc3y_IRqRANIzyxvQLtuYaiLW3J_Dj7jy0dEo6Rs9XXNK03M0dyYMj1UFKIKZzvMEKH9XHgFiA25uY3epWoSP3gAJSn2DKUqd7uNHCRt_oEGV1uN_lyd-5ztYWKNwuWoDS0-r5brRx34ZrFOmiZ1Ww',
                    name: 'Rajesh Kumar',
                    specialty: 'General Nursing',
                    experience: '8 yrs exp',
                    badgeText: 'ELITE PARTNER',
                    rating: 4.9,
                    price: '₹800',
                    priceUnit: '/visit',
                    isElite: true,
                  ),
                  const SizedBox(height: 16),
                  _buildProviderCard(
                    context: context,
                    imageUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuABVJVdadjG64D0vfRnahoeVp2SWOMxAHauCLZFHyELD8mFV7iPeDupSTojlAgwdX-uhgn0jkNxoKzjmeBa9aQlRH8rKopQ4D-BmJTdikVALdTiEY9Cx9B1pxn4hTIC9mGJtYaJWJQ4kIoKUmnKSLyCHn-wYdnM-EX7nlvglmG5SPm7IDk4eQ6GeElSD28u37AdkrBpfunFWuEOi-cGszNrLcV7JNM6FB_Xhq1KenhgWQLwV5e9cSmBnc2lTl2637I07ywWaibQh0Xq',
                    name: 'Anita Sharma',
                    specialty: 'Pediatric Care',
                    experience: '5 yrs exp',
                    badgeText: 'VERIFIED',
                    rating: 4.8,
                    price: '₹1,200',
                    priceUnit: '/day',
                    isElite: false,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.stackXl),

              // 9. Why Trust VibrantCare/Trusted Home Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 16.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Why thousands trust Trusted Home',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFFB4EBFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTrustBullet(
                          Icons.verified,
                          'Background Checks',
                          'Rigorous 3-step verification including local police reports.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTrustBullet(
                          Icons.support_agent,
                          '24/7 Support',
                          'Personal care managers available for every booking.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTrustBullet(
                          Icons.insights,
                          'Quality Control',
                          'Clinical protocols monitored by senior professionals.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // spacer for bottom nav bar
            ],
          ),
        ),
      ),

      // 10. Quick Care FAB Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quick Care Booking initiated...'),
                backgroundColor: AppTheme.primaryContainer,
              ),
            );
          },
          backgroundColor: AppTheme.primaryContainer,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Book Quick Care',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 11. Solid Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppTheme.inverseSurface,
          border: Border(
            top: BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.search, 'Search', 1),
            _buildNavItem(Icons.calendar_today_outlined, 'Bookings', 2),
            _buildNavItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  // Builder for Category Icons
  Widget _buildCategoryItem(IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == 'Patient Care' || label == 'Child Care' || label == 'Tutors') {
          Navigator.pushNamed(context, '/service_categories');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppTheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Builder for Trending Services Horizontal Slider
  Widget _buildTrendingCard(IconData icon, Color iconColor, String title, String description) {
    return Container(
      width: 256,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
        border: Border.all(
          color: AppTheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 11,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Round Scroll button builder
  Widget _buildRoundScrollBtn(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: AppTheme.outline,
          size: 18,
        ),
      ),
    );
  }

  // Builder for Professional Cards
  Widget _buildProviderCard({
    required BuildContext context,
    required String imageUrl,
    required String name,
    required String specialty,
    required String experience,
    required String badgeText,
    required double rating,
    required String price,
    required String priceUnit,
    required bool isElite,
  }) {
    final theme = Theme.of(context);
    final badgeColor = isElite ? const Color(0xFFC7A15A) : AppTheme.primaryContainer;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/provider_profile', arguments: {
          'provider': {
            'name': name,
            'avatarUrl': imageUrl,
            'rate': double.tryParse(price.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 35.0,
            'rating': rating,
            'reviews': 89,
            'experience': experience,
            'isAvailable': true,
            'specialties': [specialty],
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppTheme.roundedLg),
          border: Border.all(
            color: isElite ? const Color(0xFFC7A15A) : AppTheme.outlineVariant.withAlpha(76),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A162839),
              blurRadius: 16.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Provider Image & Elite Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.roundedLg - 1.0),
                  ),
                  child: SizedBox(
                    height: 176,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.surfaceContainer,
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.outline,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                      border: Border.all(
                        color: badgeColor,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isElite ? Icons.stars : Icons.verified,
                          color: badgeColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Provider Metadata
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withAlpha(26), // 10% opacity
                          borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: badgeColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$specialty • $experience',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.outlineVariant, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STARTS AT',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontSize: 9,
                              letterSpacing: 1.0,
                              color: AppTheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: price,
                              style: const TextStyle(
                                color: AppTheme.primaryContainer,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                              ),
                              children: [
                                TextSpan(
                                  text: priceUnit,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/provider_profile', arguments: {
                            'provider': {
                              'name': name,
                              'avatarUrl': imageUrl,
                              'rate': double.tryParse(price.replaceAll(RegExp(r'[^0-9\.]'), '')) ?? 35.0,
                              'rating': rating,
                              'reviews': 89,
                              'experience': experience,
                              'isAvailable': true,
                              'specialties': [specialty],
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builder for Trust Bullet Rows
  Widget _buildTrustBullet(IconData icon, String title, String description) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26), // 10% opacity
              borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFFC7A15A), // antique gold
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: const Color(0xFFB4EBFF).withAlpha(178), // 70% opacity
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builder for Bottom Nav Icons
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentNavIndex == index;

    if (isActive) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentNavIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.pushNamed(context, '/search');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/bookings');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        } else {
          setState(() {
            _currentNavIndex = index;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white.withAlpha(153),
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(153),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
