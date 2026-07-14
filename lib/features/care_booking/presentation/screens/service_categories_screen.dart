import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ServiceCategoriesScreen extends StatefulWidget {
  const ServiceCategoriesScreen({super.key});

  @override
  State<ServiceCategoriesScreen> createState() => _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen> {
  int _selectedOptionIndex = 1; // Monthly support is pre-selected
  int _currentNavIndex = 1;     // Search tab is active

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.primaryContainer,
          ),
        ),
        title: Text(
          'Care Support',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.containerMargin),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.outlineVariant,
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDXsSqL98eSoPgMpXYOvu21LTJL1TdIe27oAsJzW1dfZXMEJpw18hhyKStgWF7DFPrH8cHyyZ06K3KF0_dlXW1A3zV3arteWxO_mAAGM7ex1tgl4UzOJeKxy_fUDfrypHyE8XwcojLbcfKUn9IdcXk4peFqnMyiqPNJOCGVs6D_Jph1Zoh80w4v_bRjceLuXsBknyfEnFTfHd8YHOfZOjnWh_804ecY0Pvj9EP3BeIkEA-tiDLowCokZmvxfzfX6PB94Jmy6Lk5rSTs',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.account_circle,
                      size: 28,
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
              // 1. Header Section
              Text(
                'Select Care Level',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the frequency and type of support that best fits your household\'s unique needs.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 16.0,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTheme.stackLg),

              // 2. Verified Banner
              Container(
                padding: const EdgeInsets.all(AppTheme.stackMd),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer.withAlpha(51), // 20% opacity
                  borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  border: Border.all(
                    color: AppTheme.secondary.withAlpha(51),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppTheme.stackMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verified Caregivers Only',
                            style: TextStyle(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Every provider in these categories has passed a Tier 3 background check.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.stackLg),

              // 3. Service Options (Visit-based, Monthly, Live-in)
              Column(
                children: [
                  _buildCareOptionCard(
                    index: 0,
                    icon: Icons.event_available,
                    title: 'Visit-based Care',
                    description:
                        'Flexible scheduling for daily check-ins, medication reminders, or occasional assistance. Ideal for independent living.',
                    rateText: 'Starting at \$25/hr',
                    isMostPopular: false,
                  ),
                  const SizedBox(height: 16),
                  _buildCareOptionCard(
                    index: 1,
                    icon: Icons.calendar_month,
                    title: 'Monthly Support',
                    description:
                        'Consistent, dedicated support with the same primary caregiver. Includes 20-40 hours of focused assistance per week.',
                    rateText: 'Billed Monthly',
                    isMostPopular: true,
                  ),
                  const SizedBox(height: 16),
                  _buildCareOptionCard(
                    index: 2,
                    icon: Icons.night_shelter,
                    title: 'Live-in Care',
                    description:
                        '24/7 round-the-clock professional presence. Complete peace of mind for high-dependency care and overnight safety.',
                    rateText: 'Full Premium Service',
                    isMostPopular: false,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.stackXl),

              // 4. Detail Sub-categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Sub-services',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View all',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Sub-services Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildSubServiceChip(Icons.medical_services_outlined, 'Medication'),
                  _buildSubServiceChip(Icons.restaurant_outlined, 'Meal Prep'),
                  _buildSubServiceChip(Icons.accessibility_new, 'Mobility Support'),
                  _buildSubServiceChip(Icons.baby_changing_station, 'Feeding & Nutrition'),
                ],
              ),
              const SizedBox(height: AppTheme.stackXl),

              // 5. Experience Callout Card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.inverseSurface,
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.secondary.withAlpha(26), // 10% opacity secondary
                                Colors.transparent,
                              ],
                              center: Alignment.topRight,
                              radius: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Unsure about what you need?',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Our Care Advisors can help you design a custom support plan that scales as your needs change.',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(204),
                                          fontSize: 14.0,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 192,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCvEGabI3Ec6GG_0z8raFZGKrdXLMBXniUbnU0Lfy_2nwVPv7esQKKnBLQG0IDJaO-Db7tjeP_TY8VNeMe0mHG6xYqS_QoYgZzTkrEp83rbXYtlgUURT504fxr-5WIPOelu7ndiW-E4G9Bw5f8cb7br92OqB3oLBM-jtDgG-jjQrdoT01GHa1mqf1o4OZJCkkw6f_eXg4cPUg8hUj01hOjC_K3KXd8LgbS-8nACRMS4ItOeGjcwB1JGYP1DEUq0tvpVnAOUBHnrvmy6',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppTheme.primaryContainer,
                                      child: const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryFixed,
                                foregroundColor: AppTheme.onSecondaryFixed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Schedule Free Consult',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80), // spacer for bottom nav and FAB
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            String categoryName = 'Monthly Support';
            if (_selectedOptionIndex == 0) {
              categoryName = 'Visit-based Care';
            } else if (_selectedOptionIndex == 2) {
              categoryName = 'Live-in Care';
            }
            Navigator.pushNamed(context, '/provider_listing', arguments: {
              'categoryName': categoryName,
            });
          },
          backgroundColor: AppTheme.primaryContainer,
          foregroundColor: AppTheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
          ),
          child: const Icon(
            Icons.navigate_next,
            size: 32,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 7. Bottom Navigation Bar Shell
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppTheme.inverseSurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.roundedLg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.search, 'Search', 1),
            _buildNavItem(Icons.calendar_today_outlined, 'Bookings', 2),
            _buildNavItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  // Builder for Care Option Cards
  Widget _buildCareOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required String rateText,
    required bool isMostPopular,
  }) {
    final isSelected = _selectedOptionIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _selectOption(index),
      child: Stack(
        children: [
          // Background Card
          Container(
            padding: EdgeInsets.only(
              top: isMostPopular ? 32 : 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppTheme.roundedMd),
              border: Border.all(
                color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x1F1E2A32) : const Color(0x141E2A32),
                  blurRadius: isSelected ? 24.0 : 12.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Check Indicator
                if (isSelected)
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryContainer,
                      size: 20,
                    ),
                  ),

                // Icon Box
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withAlpha(26), // 10% opacity
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: AppTheme.primaryContainer,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Description
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withAlpha(26),
                        borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                      ),
                      child: Text(
                        rateText,
                        style: const TextStyle(
                          color: AppTheme.primaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppTheme.primaryContainer,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Most Popular Label Overlay
          if (isMostPopular)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.roundedMd),
                    bottomRight: Radius.circular(AppTheme.roundedMd),
                  ),
                ),
                child: const Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builder for Sub-service Chip list item
  Widget _buildSubServiceChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
        border: Border.all(
          color: AppTheme.outlineVariant.withAlpha(76),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.secondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Builder for Bottom Nav Icons
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentNavIndex == index;

    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/search',
            (route) => false,
          );
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
            color: isActive ? Colors.white : Colors.white.withAlpha(153),
            size: isActive ? 24 : 22,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withAlpha(153),
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
