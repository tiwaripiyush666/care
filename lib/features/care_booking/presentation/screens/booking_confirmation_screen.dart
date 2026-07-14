import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String providerName = routeArgs?['providerName'] ?? 'Dr. Arjun Mehta';
    final int displayTotal = routeArgs?['totalEstimate'] ?? 850;
    final int selectedDay = routeArgs?['selectedDay'] ?? 15;
    final String selectedSlot = routeArgs?['selectedSlot'] ?? 'Afternoon';
    final String address = routeArgs?['address'] ?? 'Sector 62, Noida, UP';
    final String paymentMethod = routeArgs?['paymentMethod'] ?? 'UPI';
    final String paymentStatus = routeArgs?['paymentStatus'] ?? 'Paid';

    final String slotTimeRange = selectedSlot == 'Morning'
        ? '08:00 AM - 12:00 PM'
        : '01:00 PM - 05:00 PM';

    return Scaffold(
      backgroundColor: AppTheme.background, // aligned background
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
        ),
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // 1. Success checkmark icon & header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1F1E2A32),
                            blurRadius: 12.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: AppTheme.secondary,
                          size: 56,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Booking Confirmed!',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: AppTheme.primaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Your care professional $providerName is scheduled for Oct $selectedDay at ${selectedSlot == 'Morning' ? '08:00 AM' : '01:00 PM'}.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 15.0,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  border: Border.all(color: AppTheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E2A32).withAlpha(10),
                      blurRadius: 16.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Provider Header Info Row
                    Row(
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
                                      color: AppTheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    color: AppTheme.secondary,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Verified Specialist',
                                style: TextStyle(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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

                    // Detail Rows
                    _buildSummaryDetailRow(
                      icon: Icons.home_repair_service,
                      title: 'Service Type',
                      value: 'Post-Operative Care Support',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryDetailRow(
                      icon: Icons.calendar_today,
                      title: 'Time & Date',
                      value: 'Oct $selectedDay • $slotTimeRange',
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryDetailRow(
                      icon: Icons.location_on,
                      title: 'Address',
                      value: address,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryDetailRow(
                      icon: Icons.payments,
                      title: paymentStatus == 'Paid' ? 'Total Paid' : 'Payment Status',
                      value: paymentStatus == 'Paid' ? '₹$displayTotal via $paymentMethod' : '₹$displayTotal (Pending - COD)',
                    ),

                    const SizedBox(height: 20),

                    // Insured Label Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                        border: Border.all(color: AppTheme.outlineVariant.withAlpha(51)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Row(
                            children: [
                              Icon(Icons.shield_outlined, color: AppTheme.primaryContainer, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Insured & Protected',
                                style: TextStyle(
                                  color: AppTheme.primaryContainer,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.workspace_premium, color: AppTheme.primaryContainer, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Top Rated',
                                style: TextStyle(
                                  color: AppTheme.primaryContainer,
                                  fontSize: 11,
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
              ),
              const SizedBox(height: 32),

              // 3. Action buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/track_booking', arguments: {
                    'providerName': providerName,
                    'selectedDay': selectedDay,
                    'selectedSlot': selectedSlot,
                    'address': address,
                  });
                },
                icon: const Icon(Icons.trending_flat, color: Colors.white),
                label: const Text(
                  'Track My Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.onSurface,
                  side: const BorderSide(color: Color(0xFFD9D6CF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'A confirmation email and receipt have been sent to your registered email address.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer.withAlpha(26),
            borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
          ),
          child: Icon(icon, color: AppTheme.primaryContainer, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
