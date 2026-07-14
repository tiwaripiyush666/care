import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/provider_bloc.dart';

class ProviderListingScreen extends StatefulWidget {
  const ProviderListingScreen({super.key});

  @override
  State<ProviderListingScreen> createState() => _ProviderListingScreenState();
}

class _ProviderListingScreenState extends State<ProviderListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentNavIndex = 1; // Search tab active
  String _selectedServiceType = 'All'; // Visit, Monthly, Live-in



  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderBloc>().add(LoadProviders(serviceType: 'All'));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ProviderBloc>().add(LoadProviders(
      query: _searchController.text.trim(),
      serviceType: _selectedServiceType,
    ));
  }

  void _toggleServiceType(String type) {
    setState(() {
      if (_selectedServiceType == type) {
        _selectedServiceType = 'All';
      } else {
        _selectedServiceType = type;
      }
    });
    context.read<ProviderBloc>().add(LoadProviders(
      query: _searchController.text.trim(),
      serviceType: _selectedServiceType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final categoryName = routeArgs?['categoryName'] ?? 'Patient Care';

    return Scaffold(
      backgroundColor: AppTheme.background, // aligned background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppTheme.primaryContainer,
            ),
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
        actions: [
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
        child: BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, state) {
            List<Map<String, dynamic>> providers = [];
            bool isLoading = false;
            String? errorMsg;

            if (state is ProviderLoading) {
              isLoading = true;
            } else if (state is ProviderError) {
              errorMsg = state.message;
            } else if (state is ProviderLoaded) {
              providers = state.providers;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // List Header
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppTheme.containerMargin,
                    right: AppTheme.containerMargin,
                    top: 20.0,
                    bottom: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: AppTheme.primaryContainer,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoading
                            ? 'Loading verified professionals...'
                            : '${providers.length} Verified professionals in your nearby area',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                      border: Border.all(color: const Color(0xFFD9D6CF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E2A32).withAlpha(10),
                          blurRadius: 12.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by name or specialty...',
                        hintStyle: TextStyle(
                          color: Color(0x6670787C),
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF70787C)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Horizontal Services Filters Row
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                    children: [
                      // Filter Type
                      Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.tune, size: 16),
                          label: const Text('All Filters'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.primaryContainer,
                            foregroundColor: Colors.white,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                            ),
                          ),
                        ),
                      ),

                      // Service Category Pills
                      _buildServiceTypeChip('Visit'),
                      _buildServiceTypeChip('Monthly'),
                      _buildServiceTypeChip('Live-in'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Summary text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Showing ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: isLoading ? '...' : '${providers.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryContainer,
                              ),
                            ),
                            const TextSpan(text: ' available providers'),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Text(
                          'Sort by: Featured',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryContainer,
                          ),
                        ),
                        label: const Icon(Icons.expand_more, size: 16, color: AppTheme.primaryContainer),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Providers List View
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryContainer,
                          ),
                        )
                      : errorMsg != null
                          ? Center(
                              child: Text(
                                'Error: $errorMsg',
                                style: const TextStyle(color: AppTheme.error),
                              ),
                            )
                          : providers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: AppTheme.outlineVariant,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No matched providers found',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: AppTheme.containerMargin,
                                    right: AppTheme.containerMargin,
                                    bottom: 80, // nav bar spacer
                                  ),
                                  itemCount: providers.length,
                                  itemBuilder: (context, index) {
                                    final provider = providers[index];
                                    return _buildProviderCard(provider, theme);
                                  },
                                ),
                ),
              ],
            );
          },
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

  Widget _buildServiceTypeChip(String type) {
    final isSelected = _selectedServiceType == type;

    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton(
        onPressed: () => _toggleServiceType(type),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.tertiaryFixed : Colors.white,
          foregroundColor: isSelected ? AppTheme.onTertiaryFixedVariant : AppTheme.onSurface,
          side: BorderSide(
            color: isSelected ? AppTheme.tertiary : const Color(0xFFD9D6CF),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.roundedFull),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          type,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }



  Widget _buildProviderCard(Map<String, dynamic> provider, ThemeData theme) {
    final isTopRated = provider['isTopRated'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
        border: Border.all(
          color: isTopRated ? AppTheme.primaryContainer.withAlpha(51) : const Color(0xFFD9D6CF),
          width: isTopRated ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A32).withAlpha(13),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/provider_profile', arguments: {
            'provider': provider,
          });
        },
        borderRadius: BorderRadius.circular(AppTheme.roundedLg),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Portrait details row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portrait Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
                      child: Image.network(
                        provider['avatarUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: AppTheme.outline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Detail columns
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider['name'],
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppTheme.primaryContainer,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isTopRated)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.star, color: AppTheme.onSecondaryContainer, size: 10),
                                    SizedBox(width: 2),
                                    Text(
                                      'Top Rated',
                                      style: TextStyle(
                                        color: AppTheme.onSecondaryContainer,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              color: AppTheme.primaryContainer,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppTheme.primaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Subtitle metadata
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: AppTheme.secondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              provider['experience'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.translate, color: AppTheme.secondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              provider['languages'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.medical_services, color: AppTheme.secondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Specialization: ${provider['specialty']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.secondary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${provider['rating']} (${provider['reviews']}+ Reviews)',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Specialties Chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (provider['tags'] as List<String>).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.tertiaryFixed,
                      borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: AppTheme.onTertiaryFixedVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppTheme.outlineVariant, height: 1),
              const SizedBox(height: 12),

              // Starting Price & View Profile Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Starting from',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          text: '₹${provider['rate']}',
                          style: const TextStyle(
                            color: AppTheme.primaryContainer,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: provider['rateUnit'],
                              style: const TextStyle(
                                fontSize: 14,
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
                        'provider': provider,
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
                      'View Profile',
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
      ),
    );
  }
}
