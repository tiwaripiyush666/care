import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/booking_bloc.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _currentNavIndex = 2; // Bookings tab is active
  String _activeTab = 'Active'; // Active, Past, Cancelled

  bool _isSearching = false;
  String _searchQuery = '';
  String _filterService = 'All';
  String _sortBy = 'Newest';
  final TextEditingController _searchController = TextEditingController();

  int _parseBookingDate(String dateStr) {
    try {
      final months = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
      };
      final clean = dateStr.toLowerCase().replaceAll(',', '');
      final parts = clean.split(' ');
      if (parts.length >= 3) {
        final monthStr = parts[0].substring(0, 3);
        final month = months[monthStr] ?? 1;
        final day = int.tryParse(parts[1]) ?? 1;
        final year = int.tryParse(parts[2]) ?? 2026;
        return DateTime(year, month, day).millisecondsSinceEpoch;
      }
    } catch (_) {}
    return 0;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.roundedLg)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Bookings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _filterService = 'All';
                            _sortBy = 'Newest';
                          });
                        },
                        child: const Text('Reset All', style: TextStyle(color: AppTheme.error)),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.outlineVariant),
                  const SizedBox(height: 12),
                  const Text('SERVICE TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'All',
                      'Elderly Care',
                      'Nursing Care',
                      'Baby Care',
                      'Physiotherapy',
                    ].map((svc) {
                      final selected = _filterService == svc;
                      return ChoiceChip(
                        label: Text(svc, style: TextStyle(color: selected ? Colors.white : AppTheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                        selected: selected,
                        selectedColor: AppTheme.primaryContainer,
                        backgroundColor: Colors.white,
                        onSelected: (val) {
                          setSheetState(() {
                            _filterService = svc;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('SORT BY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Newest First', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          selected: _sortBy == 'Newest',
                          selectedColor: AppTheme.primaryContainer,
                          backgroundColor: Colors.white,
                          onSelected: (val) {
                            setSheetState(() {
                              _sortBy = 'Newest';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Oldest First', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          selected: _sortBy == 'Oldest',
                          selectedColor: AppTheme.primaryContainer,
                          backgroundColor: Colors.white,
                          onSelected: (val) {
                            setSheetState(() {
                              _sortBy = 'Oldest';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.roundedMd)),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingBloc>().add(LoadBookingsEvent());
    });
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
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: AppTheme.primaryContainer),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.containerMargin,
                right: AppTheme.containerMargin,
                top: 20.0,
                bottom: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bookings',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primaryContainer,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your scheduled services and history.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            if (_isSearching) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search by provider or specialty...',
                          hintStyle: const TextStyle(color: AppTheme.outline),
                          prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                            borderSide: const BorderSide(color: AppTheme.primaryContainer),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showFilterSheet,
                      icon: Icon(
                        Icons.filter_list,
                        color: _filterService != 'All' || _sortBy != 'Newest'
                            ? AppTheme.secondary
                            : AppTheme.primaryContainer,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                          side: const BorderSide(color: AppTheme.outlineVariant),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Tab bar selection switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Active'),
                    _buildTabButton('Past'),
                    _buildTabButton('Cancelled'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bookings Cards List
            Expanded(
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryContainer,
                      ),
                    );
                  } else if (state is BookingError) {
                    return Center(
                      child: Text('Error: ${state.message}'),
                    );
                  } else if (state is BookingsLoaded) {
                    return _buildBookingsList(theme, state.bookings);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
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
            _buildNavItem(Icons.calendar_today, 'Bookings', 2),
            _buildNavItem(Icons.person_outline, 'Profile', 3),
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
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
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

  Widget _buildTabButton(String tabTitle) {
    final isActive = _activeTab == tabTitle;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = tabTitle;
          });
        },
        borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              tabTitle,
              style: TextStyle(
                color: isActive ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(ThemeData theme, List<Map<String, dynamic>> allBookings) {
    final filteredBookings = allBookings.where((b) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = b['name']?.toString().toLowerCase() ?? '';
        final specialty = b['specialty']?.toString().toLowerCase() ?? '';
        final date = b['date']?.toString().toLowerCase() ?? '';
        if (!name.contains(query) && !specialty.contains(query) && !date.contains(query)) {
          return false;
        }
      }

      if (_filterService != 'All') {
        final f = _filterService.toLowerCase();
        final specialty = b['specialty']?.toString().toLowerCase() ?? '';
        if (f == 'elderly care') {
          if (!specialty.contains('senior') && !specialty.contains('elderly')) return false;
        } else if (f == 'nursing care') {
          if (!specialty.contains('nurse')) return false;
        } else if (f == 'baby care') {
          if (!specialty.contains('pediatric') && !specialty.contains('baby')) return false;
        } else if (f == 'physiotherapy') {
          if (!specialty.contains('physiotherapist') && !specialty.contains('physio')) return false;
        }
      }
      return true;
    }).toList();

    final activeBookings = filteredBookings.where((b) {
      final status = b['status']?.toString().toLowerCase() ?? 'active';
      return status == 'active';
    }).toList();
    
    final pastBookings = filteredBookings.where((b) {
      final status = b['status']?.toString().toLowerCase() ?? '';
      return status == 'past' || status == 'completed';
    }).toList();
    
    final cancelledBookings = filteredBookings.where((b) {
      final status = b['status']?.toString().toLowerCase() ?? '';
      return status == 'cancelled';
    }).toList();

    int sortComparator(Map<String, dynamic> a, Map<String, dynamic> b) {
      final dateA = _parseBookingDate(a['date']?.toString() ?? '');
      final dateB = _parseBookingDate(b['date']?.toString() ?? '');
      return _sortBy == 'Newest' ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    }

    activeBookings.sort(sortComparator);
    pastBookings.sort(sortComparator);
    cancelledBookings.sort(sortComparator);

    if (_activeTab == 'Active') {
      if (activeBookings.isEmpty) {
        return _buildEmptyState(_searchQuery.isNotEmpty 
            ? 'No active bookings match your search query.'
            : 'No active scheduled bookings found.');
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
        itemCount: activeBookings.length,
        itemBuilder: (context, index) {
          final booking = activeBookings[index];
          return _buildActiveBookingCard(booking, theme);
        },
      );
    } else if (_activeTab == 'Past') {
      if (pastBookings.isEmpty) {
        return _buildEmptyState(_searchQuery.isNotEmpty 
            ? 'No past records match your search query.'
            : 'No completed service records found.');
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
        itemCount: pastBookings.length,
        itemBuilder: (context, index) {
          final booking = pastBookings[index];
          return _buildPastBookingCard(booking, theme);
        },
      );
    } else {
      if (cancelledBookings.isEmpty) {
        return _buildEmptyState(_searchQuery.isNotEmpty 
            ? 'No cancelled bookings match your search query.'
            : 'No cancelled bookings.');
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
        itemCount: cancelledBookings.length,
        itemBuilder: (context, index) {
          final booking = cancelledBookings[index];
          return _buildPastBookingCard(booking, theme);
        },
      );
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 64, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBookingCard(Map<String, dynamic> booking, ThemeData theme) {
    final hasTracking = booking['hasTracking'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.stackMd),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E2A32),
            blurRadius: 12.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceContainer, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: Image.network(
                            booking['avatarUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (booking['isAvailableNow'])
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            booking['name'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppTheme.secondary, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking['specialty'],
                        style: const TextStyle(
                          color: AppTheme.primaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                ),
                child: Text(
                  booking['schedule'],
                  style: const TextStyle(
                    color: AppTheme.onSecondaryContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.outlineVariant, height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppTheme.onSurfaceVariant, size: 16),
              const SizedBox(width: 8),
              Text(
                booking['date'],
                style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.location_on, color: AppTheme.onSurfaceVariant, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking['address'],
                  style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (hasTracking) {
                      Navigator.pushNamed(context, '/track_booking', arguments: {
                        'providerName': booking['name'],
                      });
                    } else {
                      // Reschedule Action
                    }
                  },
                  icon: Icon(
                    hasTracking ? Icons.near_me : Icons.event_note,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: Text(
                    hasTracking ? 'Track' : 'Reschedule',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble, size: 16, color: AppTheme.primaryContainer),
                  label: const Text(
                    'Message',
                    style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastBookingCard(Map<String, dynamic> booking, ThemeData theme) {
    final int rating = booking['rating'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.stackMd),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(204),
        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: Image.network(
                booking['avatarUrl'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  booking['specialty'],
                  style: const TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      Icons.star,
                      size: 14,
                      color: i < rating ? const Color(0xFFC5A059) : AppTheme.outlineVariant,
                    );
                  }),
                ),
              ],
            ),
          ),
          Text(
            booking['date'],
            style: const TextStyle(
              color: AppTheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
