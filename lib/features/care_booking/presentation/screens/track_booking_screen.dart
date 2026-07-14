import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:caresphere/features/care_booking/presentation/bloc/chat_bloc.dart';
import 'package:caresphere/features/care_booking/domain/entities/chat_message.dart';
import '../../../../core/theme/app_theme.dart';

class TrackBookingScreen extends StatefulWidget {
  const TrackBookingScreen({super.key});

  @override
  State<TrackBookingScreen> createState() => _TrackBookingScreenState();
}

class _TrackBookingScreenState extends State<TrackBookingScreen> {
  int _currentNavIndex = 1; // Bookings active

  late final MapController _mapController;
  Timer? _trackingTimer;
  int _currentRouteIndex = 0;

  final LatLng _homeLocation = const LatLng(12.9716, 77.5946); // Indiranagar Bangalore Area
  
  // A path simulating a provider moving closer to the user's home location
  final List<LatLng> _simulatedRoute = [
    const LatLng(12.9780, 77.5850),
    const LatLng(12.9765, 77.5880),
    const LatLng(12.9750, 77.5900),
    const LatLng(12.9735, 77.5925),
    const LatLng(12.9722, 77.5938),
    const LatLng(12.9716, 77.5946), // Final Home Arrival coordinates
  ];

  LatLng? _currentProviderLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentProviderLocation = _simulatedRoute.first;
    _startLiveTracking();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startLiveTracking() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          if (_currentRouteIndex < _simulatedRoute.length - 1) {
            _currentRouteIndex++;
            _currentProviderLocation = _simulatedRoute[_currentRouteIndex];
            // Animate map camera center to follow coordinates
            _mapController.move(_currentProviderLocation!, 15.5);
          } else {
            // Arrived -> Stop updates
            _trackingTimer?.cancel();
          }
        });
      }
    });
  }

  void _openChatOverlay(BuildContext context, String providerName) {
    const String bookingId = 'booking_active_id';
    
    // Load history and subscribe
    context.read<ChatBloc>().add(LoadChatHistory(bookingId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final TextEditingController messageController = TextEditingController();
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (BuildContext scrollContext, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.roundedLg),
                  topRight: Radius.circular(AppTheme.roundedLg),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chat with $providerName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryContainer,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppTheme.outline),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.outlineVariant),
                  
                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatLoading) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryContainer));
                        } else if (state is ChatHistoryLoaded) {
                          final messages = state.messages;
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return Align(
                                alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: message.isMe 
                                        ? AppTheme.primaryContainer 
                                        : AppTheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                          color: message.isMe ? Colors.white : AppTheme.onSurface,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: message.isMe ? Colors.white60 : AppTheme.onSurfaceVariant,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else if (state is ChatError) {
                          return Center(child: Text(state.message));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: AppTheme.outlineVariant),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: messageController,
                              style: const TextStyle(color: AppTheme.onSurface),
                              decoration: const InputDecoration(
                                hintText: 'Type your message...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: AppTheme.primaryContainer),
                            onPressed: () {
                              final text = messageController.text.trim();
                              if (text.isNotEmpty) {
                                final userMsg = ChatMessage(
                                  id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                                  bookingId: bookingId,
                                  senderId: 'client_me',
                                  text: text,
                                  timestamp: DateTime.now(),
                                  isMe: true,
                                );
                                context.read<ChatBloc>().add(SendChatMessage(userMsg));
                                messageController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String providerName = routeArgs?['providerName'] ?? 'Dr. Arjun Mehta';
    final String selectedSlot = routeArgs?['selectedSlot'] ?? 'Afternoon';

    return Scaffold(
      backgroundColor: AppTheme.background, // aligned background
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
        ),
        title: const Text(
          'Track Booking',
          style: TextStyle(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppTheme.primaryContainer),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Live Map Context Section
              Container(
                height: 280,
                color: AppTheme.surfaceContainerHigh,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentProviderLocation ?? _homeLocation,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.caresphere.app',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _simulatedRoute,
                                strokeWidth: 4.0,
                                color: AppTheme.primaryContainer,
                                strokeCap: StrokeCap.round,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              // Destination Marker (Home)
                              Marker(
                                point: _homeLocation,
                                width: 40.0,
                                height: 40.0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.home,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              ),
                              // Live Moving Provider Marker
                              if (_currentProviderLocation != null)
                                Marker(
                                  point: _currentProviderLocation!,
                                  width: 44.0,
                                  height: 44.0,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Soft pulse halo
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryContainer.withAlpha(51),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      // Main indicator circle
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryContainer,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4.0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.directions_car,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Live Tracking badge overlay
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                          border: Border.all(color: AppTheme.outlineVariant),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F1E2A32),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Live Tracking Active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Arrival Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                child: Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                      border: Border.all(color: AppTheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E2A32).withAlpha(20),
                          blurRadius: 16.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ESTIMATED ARRIVAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  selectedSlot == 'Morning' ? '08:15 AM' : '01:10 PM',
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    color: AppTheme.primaryContainer,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withAlpha(26),
                                borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.schedule, color: AppTheme.primaryContainer, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    '10 mins',
                                    style: TextStyle(
                                      color: AppTheme.primaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppTheme.outlineVariant, height: 1),
                        const SizedBox(height: 16),

                        // Professional Details row
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9999),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB_l4wk9vwtJL4pr3z7fzKFriqLyYKtSPg7FyKep_WSy72L_2ciHB77j72pD_ryrrkJrWsXSDIRP-NEIXhh1hsNzG8AocLGipMfnj0UK6BhxXiJPU0RKEJ_O7A0sCOEsCe5SorStHxWEnYFrjzUpntOtxDwIRvjG6x45OjOLPMtwAgW0ztLnRroiu9gkOcDBpQGUlJ34AbGBNt7kQ5l_y-s0Pl5r0TPtzM3It2FhWswsZaHUoAoHALBRH7cUgJvwARtgzG_MzreIOM5',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        providerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFFC5A059),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Specialist Caregiver • 4.9 ★',
                                    style: TextStyle(
                                      color: AppTheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Call / Chat Button Row
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openChatOverlay(context, providerName),
                                icon: const Icon(Icons.chat_bubble, size: 16, color: Colors.white),
                                label: const Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                                icon: const Icon(Icons.call, size: 16, color: AppTheme.onSurface),
                                label: const Text('Call', style: TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.surfaceContainerHigh,
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
                  ),
                ),
              ),

              // 3. Status Timeline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Journey',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Timeline flow
                    _buildTimelineRow(
                      stepNumber: 1,
                      title: 'Booking Confirmed',
                      subtitle: 'Your request was accepted at 11:30 AM',
                      isCompleted: true,
                      isActive: false,
                    ),
                    _buildTimelineRow(
                      stepNumber: 2,
                      title: 'Professional En Route',
                      subtitle: '$providerName is navigating to your location',
                      isCompleted: false,
                      isActive: true,
                      extraWidget: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer.withAlpha(51),
                          borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location, color: AppTheme.secondary, size: 12),
                            SizedBox(width: 6),
                            Text(
                              '0.8 km away',
                              style: TextStyle(
                                color: AppTheme.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildTimelineRow(
                      stepNumber: 3,
                      title: 'Service Started',
                      subtitle: 'Awaiting professional arrival',
                      isCompleted: false,
                      isActive: false,
                    ),
                    _buildTimelineRow(
                      stepNumber: 4,
                      title: 'Service Completed',
                      subtitle: 'Review and confirmation',
                      isCompleted: false,
                      isActive: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Safety Protection Signal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryContainer.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                    border: Border.all(color: AppTheme.tertiaryFixed.withAlpha(76)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.security, color: AppTheme.tertiaryContainer, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peace of Mind Guaranteed',
                              style: TextStyle(
                                color: AppTheme.tertiaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'This service is protected by our \$1M Liability Insurance and includes 24/7 Safety Support.',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
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
            _buildNavItem(Icons.calendar_today_outlined, 'Bookings', 1),
            _buildNavItem(Icons.verified_user_outlined, 'Safety', 2),
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

  Widget _buildTimelineRow({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    Widget? extraWidget,
    bool isLast = false,
  }) {
    Color nodeBg;
    Widget nodeChild;

    if (isCompleted) {
      nodeBg = AppTheme.secondary;
      nodeChild = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isActive) {
      nodeBg = AppTheme.primaryContainer;
      nodeChild = const Icon(Icons.navigation, color: Colors.white, size: 16);
    } else {
      nodeBg = AppTheme.surfaceContainerHigh;
      nodeChild = const SizedBox();
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: nodeBg,
                  shape: BoxShape.circle,
                ),
                child: Center(child: nodeChild),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppTheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive ? AppTheme.primaryContainer : (isCompleted ? AppTheme.secondary : AppTheme.outline),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  extraWidget ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
