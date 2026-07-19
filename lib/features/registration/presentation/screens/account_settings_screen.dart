import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  int _currentNavIndex = 3; // Profile active
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = SecureStorageService();
    final enabled = await storage.read('biometric_enabled_flag');
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled == 'true';
      });
    }
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.roundedLg),
          topRight: Radius.circular(AppTheme.roundedLg),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.containerMargin,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Settings & Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryContainer,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.outlineVariant),
                  const SizedBox(height: 16),

                  // Biometrics Switch Row
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          color: AppTheme.primaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Biometric Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Sign in instantly with fingerprint or Face ID',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _biometricEnabled,
                        activeThumbColor: AppTheme.secondary,
                        activeTrackColor: AppTheme.secondaryContainer,
                        inactiveThumbColor: AppTheme.outline,
                        inactiveTrackColor: AppTheme.surfaceContainerHighest,
                        onChanged: (bool value) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final storage = SecureStorageService();
                          await storage.write('biometric_enabled_flag', value.toString());
                          await storage.write('biometric_preference_configured', 'true');
                          
                          setSheetState(() {
                            _biometricEnabled = value;
                          });
                          
                          setState(() {
                            _biometricEnabled = value;
                          });
                          
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                value 
                                    ? 'Biometric login enabled successfully' 
                                    : 'Biometric login disabled successfully',
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppTheme.primaryContainer,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.outlineVariant),
                  const SizedBox(height: 16),

                  // Simulated Push Notifications Switch Row
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: AppTheme.primaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Push Notifications',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Get alerts on provider booking status updates',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: true,
                        activeThumbColor: AppTheme.secondary,
                        activeTrackColor: AppTheme.secondaryContainer,
                        onChanged: (bool value) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background, // aligned background
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppTheme.primaryContainer),
            SizedBox(width: 8),
            Text(
              'VibrantCare',
              style: TextStyle(
                color: AppTheme.primaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppTheme.primaryContainer),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.containerMargin),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD5Oj9__f3t68eu47Ozc7fawCHoIFQ1Ts6eNAOT6xP1R5idTZ25-rLrXSoSYGkU4FqqrkrtLnax0Roam7N7rC5fZAlWpq8ca-0I_ATCL5kZ2HsVldTSDUbb2Vv2LZOJSRPVXLhworwlci_2rftexIeXGl3BL5KFQ8_Hr6wpoIAqw6bqC8IRG3xmMbaVPnbD5thR_Dd5Rf4YLIC_4Qci9TFBQH3KJkPhZA_oA2qXFZ2sYxcxRxD7S_53zbDZr33tWDVt60pia3jyoYBN',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // 1. Profile Header Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuD5Oj9__f3t68eu47Ozc7fawCHoIFQ1Ts6eNAOT6xP1R5idTZ25-rLrXSoSYGkU4FqqrkrtLnax0Roam7N7rC5fZAlWpq8ca-0I_ATCL5kZ2HsVldTSDUbb2Vv2LZOJSRPVXLhworwlci_2rftexIeXGl3BL5KFQ8_Hr6wpoIAqw6bqC8IRG3xmMbaVPnbD5thR_Dd5Rf4YLIC_4Qci9TFBQH3KJkPhZA_oA2qXFZ2sYxcxRxD7S_53zbDZr33tWDVt60pia3jyoYBN',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Eleanor Vance',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, color: AppTheme.secondary, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Premium Member since 2026',
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Trust Stats Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  border: Border.all(color: AppTheme.outlineVariant.withAlpha(76)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '12',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryContainer,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Services',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(color: AppTheme.outlineVariant, width: 1, thickness: 1),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryContainer,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Rating',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VerticalDivider(color: AppTheme.outlineVariant, width: 1, thickness: 1),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '8',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryContainer,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Navigation Menu Items
              const Text(
                'ACCOUNT MANAGEMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              _buildSettingsRow(
                icon: Icons.location_on,
                title: 'Saved Addresses',
                subtitle: 'Manage your service locations',
                onTap: () => Navigator.pushNamed(context, '/saved_addresses'),
              ),
              const SizedBox(height: 8),
              _buildSettingsRow(
                icon: Icons.payment,
                title: 'Payment Methods',
                subtitle: 'Secure checkout and billing',
                onTap: () => Navigator.pushNamed(context, '/payment_methods'),
              ),
              const SizedBox(height: 8),
              _buildSettingsRow(
                icon: Icons.card_giftcard,
                title: 'Refer & Earn',
                subtitle: 'Invite friends and get care credits',
                onTap: () => Navigator.pushNamed(context, '/referral'),
              ),
              const SizedBox(height: 24),

              const Text(
                'SUPPORT & SAFETY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              _buildSettingsRow(
                icon: Icons.help,
                title: 'Help Center',
                subtitle: 'FAQs and direct support line',
                onTap: () => Navigator.pushNamed(context, '/help_center'),
              ),
              const SizedBox(height: 8),
              _buildSettingsRow(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'Privacy and app preferences',
                onTap: _showSettingsModal,
              ),
              const SizedBox(height: 24),

              // 4. Partnership Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Earn with us',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Turn your home service skills into a professional career.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primaryContainer),
                        label: const Text(
                          'Become a Partner',
                          style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Log Out Button
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.search, 'Search', 1),
            _buildNavItem(Icons.calendar_today_outlined, 'Bookings', 2),
            _buildNavItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentNavIndex == index;

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        setState(() {
          _currentNavIndex = index;
        });
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (index == 1) {
          Navigator.pushNamedAndRemoveUntil(context, '/search', (route) => false);
        } else if (index == 2) {
          Navigator.pushNamedAndRemoveUntil(context, '/bookings', (route) => false);
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

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryContainer, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}
