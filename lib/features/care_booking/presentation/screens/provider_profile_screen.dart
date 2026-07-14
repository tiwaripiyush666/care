import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  int _currentNavIndex = 1; // Search active

  // Hardcoded fallback provider details if none passed
  final Map<String, dynamic> _fallbackProvider = {
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
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final provider = routeArgs?['provider'] ?? _fallbackProvider;

    final String name = provider['name'] ?? 'Dr. Arjun Mehta';
    final String avatarUrl = provider['avatarUrl'] ?? '';
    final dynamic rate = provider['rate'] ?? 850;
    final String rateUnit = provider['rateUnit'] ?? '/visit';
    final double rating = (provider['rating'] as num?)?.toDouble() ?? 4.9;
    final int reviews = provider['reviews'] ?? 120;
    final String experience = provider['experience'] ?? '8+ Years Experience';
    final List<String> tags = List<String>.from(provider['tags'] ?? ['Post-Surgical Care', 'Elderly Support']);

    return Scaffold(
      backgroundColor: AppTheme.background, // aligned background
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
        ),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppTheme.primaryContainer),
            const SizedBox(width: 8),
            Text(
              'VibrantCare',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero banner with overlay profile avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Banner
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBLQCRdEpIdGfu_izrqI1MKZ-Igrtev4TrYxGHVSC1I9hZpcb-tqTqRVlj4Is6DJVjjuwIRtkVtPg5ok0PVFTA_RbUhi-Bt9GqYXIiVPTfHaF9XsbxavqLtgWxepCz3SdbCrwkcHQUf2shIWeXKc1C5_M2U7mbHyXfebfpwnNeQx6S9LnVVQ2Sd8-5eSqaqzcdrIvo4ZmGwRqN8uVJGoifcahJNNiGOFB-kLxNgFfCnlEmXH7Hn4DrQMKa0T0bMc-ixqOmDzYmq2DdR',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withAlpha(100), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      // Profile Avatar
                      Positioned(
                        bottom: -48,
                        left: AppTheme.containerMargin,
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(26),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.account_circle,
                                size: 96,
                                color: AppTheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),

                  // 2. Profile Meta Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.tertiaryFixed,
                                borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Color(0xFFB45309), // gold
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Verified',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFFB45309),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Senior Home Support & Care Specialist',
                          style: TextStyle(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFC5A059), size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '$rating ($reviews reviews)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.check_circle, color: AppTheme.secondary, size: 18),
                            const SizedBox(width: 4),
                            const Text(
                              'Background Checked',
                              style: TextStyle(
                                color: AppTheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Bento Grid - About Me
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                        border: Border.all(color: AppTheme.outlineVariant.withAlpha(76)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E2A32).withAlpha(10),
                            blurRadius: 12.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_search, color: AppTheme.primaryContainer, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'About Me',
                                style: TextStyle(
                                  color: AppTheme.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'With over $experience in premium home support, I specialize in creating calm, organized, and high-functioning living environments. My approach is rooted in quiet confidence—I believe that true quality service is felt through the seamless peace it brings to your household. I am fully certified, language-flexible, and committed to absolute discretion and reliability in every visit.',
                            style: const TextStyle(
                              color: AppTheme.onSurface,
                              fontSize: 14.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Bento Grid - Specialized Skills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                        border: Border.all(color: AppTheme.outlineVariant.withAlpha(76)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E2A32).withAlpha(10),
                            blurRadius: 12.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.workspace_premium, color: AppTheme.primaryContainer, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Specialized Skills',
                                style: TextStyle(
                                  color: AppTheme.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tags.map((t) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryContainer.withAlpha(26),
                                  borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                                  border: Border.all(color: AppTheme.primaryContainer.withAlpha(51)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.cleaning_services, size: 14, color: AppTheme.primaryContainer),
                                    const SizedBox(width: 6),
                                    Text(
                                      t,
                                      style: const TextStyle(
                                        color: AppTheme.primaryContainer,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Bento Grid - Pricing
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 12.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.payments, color: Color(0xFFB4EBFF), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Pricing Packages',
                                style: TextStyle(
                                  color: Color(0xFFB4EBFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPricingRow('Standard Visit Session', '₹$rate$rateUnit'),
                          _buildPricingRow('Extended Care Block (4 hrs)', '₹${(rate * 3.5).toInt()} flat'),
                          _buildPricingRow('Assigned Weekly Care (20 hrs)', '₹${(rate * 16).toInt()} /week'),
                          const SizedBox(height: 12),
                          const Text(
                            '* Prices include verified safety protection insurance. No additional hidden convenience charges.',
                            style: TextStyle(
                              color: Color(0x99B4EBFF),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Bento Grid - Availability Calendar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                        border: Border.all(color: AppTheme.outlineVariant.withAlpha(76)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E2A32).withAlpha(10),
                            blurRadius: 12.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_month, color: AppTheme.primaryContainer, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Availability',
                                style: TextStyle(
                                  color: AppTheme.primaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _CalendarHeaderDay('M'),
                              _CalendarHeaderDay('T'),
                              _CalendarHeaderDay('W'),
                              _CalendarHeaderDay('T'),
                              _CalendarHeaderDay('F'),
                              _CalendarHeaderDay('S'),
                              _CalendarHeaderDay('S'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _CalendarSlotBox(isAvailable: true),
                              _CalendarSlotBox(isAvailable: true),
                              _CalendarSlotBox(isAvailable: false),
                              _CalendarSlotBox(isAvailable: true),
                              _CalendarSlotBox(isAvailable: true),
                              _CalendarSlotBox(isAvailable: false),
                              _CalendarSlotBox(isAvailable: false),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _CalendarSlotBox(isAvailable: true),
                              _CalendarSlotBox(isAvailable: false),
                              _CalendarSlotBox(isAvailable: true),
                              _CalendarSlotBox(isAvailable: true),
                              _CalendarSlotBox(isAvailable: false),
                              _CalendarSlotBox(isAvailable: false),
                              _CalendarSlotBox(isAvailable: false),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.secondaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Available Slot', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.surfaceContainer,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Booked / Unavailable', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 7. Floating Book Now Button
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to dynamic booking flow
                    Navigator.pushNamed(context, '/booking_flow', arguments: {
                      'provider': provider,
                    });
                  },
                  icon: const Icon(Icons.add_task, color: Colors.white),
                  label: Text(
                    'Book $name Now',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.primaryContainer.withAlpha(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.inverseSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.roundedMd),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.roundedMd),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
              if (index == 0) {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              } else if (index == 1) {
                Navigator.pushNamedAndRemoveUntil(context, '/search', (route) => false);
              }
            },
            backgroundColor: AppTheme.inverseSurface,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withAlpha(153),
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Bookings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x26B4EBFF))),
        ),
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
            Text(price, style: const TextStyle(color: Color(0xFFB4EBFF), fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeaderDay extends StatelessWidget {
  final String day;
  const _CalendarHeaderDay(this.day);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        day,
        style: const TextStyle(
          color: AppTheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CalendarSlotBox extends StatelessWidget {
  final bool isAvailable;
  const _CalendarSlotBox({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 24,
      decoration: BoxDecoration(
        color: isAvailable ? AppTheme.secondaryContainer : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
