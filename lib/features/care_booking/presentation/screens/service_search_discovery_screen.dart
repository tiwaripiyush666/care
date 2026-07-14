import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ServiceSearchDiscoveryScreen extends StatefulWidget {
  const ServiceSearchDiscoveryScreen({super.key});

  @override
  State<ServiceSearchDiscoveryScreen> createState() => _ServiceSearchDiscoveryScreenState();
}

class _ServiceSearchDiscoveryScreenState extends State<ServiceSearchDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  int _currentNavIndex = 1; // Search tab is active

  // Mock Providers database
  final List<Map<String, dynamic>> _allProviders = [
    {
      'name': 'Rajesh Kumar',
      'specialty': 'General Nursing',
      'experience': '8 yrs exp',
      'category': 'Patient Care',
      'badgeText': 'ELITE PARTNER',
      'rating': 4.9,
      'price': '₹800',
      'priceUnit': '/visit',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDRqDDLs1q_fFaaOPb3qxHdgz5RWHQfABcgHTARdihp5Pay2l-3B6Q4tBp1MRoIDvwnJO_YtBfTrL3F-x8azvaeu6VCjP-BA2iKoPdzckLon6jcJMpglmnwTnlc3y_IRqRANIzyxvQLtuYaiLW3J_Dj7jy0dEo6Rs9XXNK03M0dyYMj1UFKIKZzvMEKH9XHgFiA25uY3epWoSP3gAJSn2DKUqd7uNHCRt_oEGV1uN_lyd-5ztYWKNwuWoDS0-r5brRx34ZrFOmiZ1Ww',
      'isElite': true,
    },
    {
      'name': 'Anita Sharma',
      'specialty': 'Pediatric Care',
      'experience': '5 yrs exp',
      'category': 'Child Care',
      'badgeText': 'VERIFIED',
      'rating': 4.8,
      'price': '₹1,200',
      'priceUnit': '/day',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuABVJVdadjG64D0vfRnahoeVp2SWOMxAHauCLZFHyELD8mFV7iPeDupSTojlAgwdX-uhgn0jkNxoKzjmeBa9aQlRH8rKopQ4D-BmJTdikVALdTiEY9Cx9B1pxn4hTIC9mGJtYaJWJQ4kIoKUmnKSLyCHn-wYdnM-EX7nlvglmG5SPm7IDk4eQ6GeElSD28u37AdkrBpfunFWuEOi-cGszNrLcV7JNM6FB_Xhq1KenhgWQLwV5e9cSmBnc2lTl2637I07ywWaibQh0Xq',
      'isElite': false,
    },
    {
      'name': 'Vikram Rao',
      'specialty': 'Physiotherapy',
      'experience': '12 yrs exp',
      'category': 'Patient Care',
      'badgeText': 'VERIFIED',
      'rating': 5.0,
      'price': '₹1,500',
      'priceUnit': '/session',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC47P_JpuS5PNxya8EXIyEM1kw3i_bOgBvTYXTqUJk6MkvoDNuwrI7cQJ5qrKzlitkRuqqlKzCI1GA4Q9Jk2UXOjv_uWlPR8bI5fN-WNjZp5CdKW52Ux8KQmsLl_rMur3-W8Wvxa-A9p105SVq31ZzjGdaGmtE1qVhrm3A3q5RhxMn7M8eJ6Fyb3pRdkdnCN-alzt9a3BkoZRTdfJiG81gtiOj1qRIY9TaJuoi2UjTawaHkxrtG8_bNFJpusqWoXPe0vF3ArL-qa47-',
      'isElite': false,
    },
    {
      'name': 'Sanjay Singh',
      'specialty': 'Home Security Guard',
      'experience': '6 yrs exp',
      'category': 'Security',
      'badgeText': 'VERIFIED',
      'rating': 4.7,
      'price': '₹900',
      'priceUnit': '/day',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCLVX9mMxWXL4ZRAmoFP39R65YVqjn40JSDUxXCZBasyPQ0SlCBRpYbmY4nokEngOS0YhXdwpkqCO2rw81VoxAIcJlrr1tTfeQNe9B_4Kyx1JZHfB51S2e--Pbn5ETzwq9EfC6ARTlCEZQPNCOgNPYNApOPniJF5IzWlGRK15S3Rfi2_P2SViz-s9H66pTzkuqCQbB5iDqfWuoYrH4lHp-zil0IJ6_s3-BNkE622H2Ca2RD_GerKpgyQKOU-YwulcrhtQNPpSKxw9gS',
      'isElite': false,
    },
  ];

  List<Map<String, dynamic>> _filteredProviders = [];

  final List<String> _categories = [
    'All',
    'Patient Care',
    'Child Care',
    'Elder Care',
    'Tutors',
    'Security',
  ];

  @override
  void initState() {
    super.initState();
    _filteredProviders = List.from(_allProviders);
    _searchController.addListener(_filterResults);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredProviders = _allProviders.where((provider) {
        final matchesQuery = provider['name'].toLowerCase().contains(query) ||
            provider['specialty'].toLowerCase().contains(query);

        final matchesCategory = _selectedCategory == 'All' ||
            provider['category'] == _selectedCategory;

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterResults();
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
          'Search & Discovery',
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
        child: Column(
          children: [
            // 1. Persistent Search Bar at top
            Container(
              padding: const EdgeInsets.all(AppTheme.containerMargin),
              color: AppTheme.surfaceContainerLowest,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                        border: Border.all(
                          color: AppTheme.outlineVariant,
                          width: 1.0,
                        ),
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
                              controller: _searchController,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search for caregivers, nurses, or japas...',
                                hintStyle: const TextStyle(
                                  color: AppTheme.outline,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                        icon: const Icon(Icons.clear, size: 18),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.stackSm),
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                      border: Border.all(
                        color: AppTheme.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Filters drawer or bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filter options opened...'),
                            backgroundColor: AppTheme.primaryContainer,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.tune,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Horizontal Category Pills list
            Container(
              height: 54,
              color: AppTheme.surfaceContainerLowest,
              padding: const EdgeInsets.only(bottom: 14.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton(
                      onPressed: () => _selectCategory(cat),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? AppTheme.primaryContainer : AppTheme.background,
                        foregroundColor: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                          width: 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        cat,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Dynamic Results list
            Expanded(
              child: _filteredProviders.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppTheme.containerMargin),
                      itemCount: _filteredProviders.length,
                      itemBuilder: (context, index) {
                        final provider = _filteredProviders[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildProviderCard(
                            context: context,
                            imageUrl: provider['imageUrl'],
                            name: provider['name'],
                            specialty: provider['specialty'],
                            experience: provider['experience'],
                            badgeText: provider['badgeText'],
                            rating: provider['rating'],
                            price: provider['price'],
                            priceUnit: provider['priceUnit'],
                            isElite: provider['isElite'],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // 4. Bottom Navigation Bar Shell
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

  // Builder for empty result placeholders
  Widget _buildEmptyState(ThemeData theme) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 64.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                color: AppTheme.outline,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No verified providers found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for another service or adjusting your horizontal category filters.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
    final badgeColor = isElite ? const Color(0xFFC7A15A) : AppTheme.primary;

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
