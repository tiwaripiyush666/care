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
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppTheme.primaryContainer),
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
    final activeBookings = allBookings.where((b) {
      final status = b['status']?.toString().toLowerCase() ?? 'active';
      return status == 'active';
    }).toList();
    
    final pastBookings = allBookings.where((b) {
      final status = b['status']?.toString().toLowerCase() ?? '';
      return status == 'past' || status == 'completed';
    }).toList();
    
    final cancelledBookings = allBookings.where((b) {
      final status = b['status']?.toString().toLowerCase() ?? '';
      return status == 'cancelled';
    }).toList();

    if (_activeTab == 'Active') {
      if (activeBookings.isEmpty) {
        return _buildEmptyState('No active scheduled bookings found.');
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
        return _buildEmptyState('No completed service records found.');
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
        return _buildEmptyState('No cancelled bookings.');
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
