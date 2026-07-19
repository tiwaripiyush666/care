import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/booking_bloc.dart';

import '../../../auth/data/repositories/auth_repository_impl.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 1; // 1: Schedule, 2: Location, 3: Details
  int _selectedDayIndex = 1; // Tue 15 is pre-selected
  String _selectedSlot = 'Afternoon'; // Afternoon slot pre-selected
  final TextEditingController _aptController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  String _entryMethod = 'I\'ll be home to let them in';
  String _paymentMethod = 'UPI';
  String _paymentStatus = 'Pending';
  String? _promoCode;
  int _discountValue = 0;

  @override
  void initState() {
    super.initState();
    _loadPromoData();
    Hive.openBox('caresphere_payment_methods');
  }

  Future<void> _loadPromoData() async {
    final storage = SecureStorageService();
    final code = await storage.read('applied_promo_code');
    final val = await storage.read('promo_discount_value');
    if (mounted && code != null && val != null) {
      setState(() {
        _promoCode = code;
        _discountValue = int.tryParse(val) ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _aptController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _nextStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _showCheckoutSheet(BuildContext context, Map<String, dynamic> baseBookingData) {
    String paymentMethod = 'UPI'; // UPI, Card, COD
    String paymentStatus = 'select'; // select, processing, success
    final cardNoController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final upiIdController = TextEditingController();
    String selectedUpiKey = 'new';
    String selectedCardKey = 'new';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final double rate = (baseBookingData['rate'] as num?)?.toDouble() ?? 850;
            final Box paymentBox = Hive.box('caresphere_payment_methods');
            final Map<dynamic, dynamic> savedMethods = paymentBox.toMap();
            final List<MapEntry<dynamic, dynamic>> savedCards = savedMethods.entries
                .where((e) => (e.value as Map)['type'] == 'CARD')
                .toList();
            final List<MapEntry<dynamic, dynamic>> savedUpis = savedMethods.entries
                .where((e) => (e.value as Map)['type'] == 'UPI')
                .toList();

            if (paymentStatus == 'processing') {
              return Container(
                height: 380,
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.roundedLg),
                    topRight: Radius.circular(AppTheme.roundedLg),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryContainer),
                      SizedBox(height: 20),
                      Text(
                        'Securing payment via gateway...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (paymentStatus == 'success') {
              return Container(
                height: 380,
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.roundedLg),
                    topRight: Radius.circular(AppTheme.roundedLg),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppTheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Txn ID: TXN_CONF_${DateTime.now().millisecondsSinceEpoch}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.roundedLg),
                    topRight: Radius.circular(AppTheme.roundedLg),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
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
                    const Divider(color: AppTheme.outlineVariant),
                    const SizedBox(height: 10),
                    
                    RadioListTile<String>(
                      title: const Text('UPI (GPay / PhonePe / Paytm)', style: TextStyle(color: AppTheme.onSurface)),
                      value: 'UPI',
                      groupValue: paymentMethod,
                      activeColor: AppTheme.primaryContainer,
                      onChanged: (val) => setSheetState(() => paymentMethod = val!),
                    ),
                    if (paymentMethod == 'UPI') ...[
                      if (savedUpis.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedUpiKey,
                            dropdownColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: 'Select Saved UPI ID',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              ...savedUpis.map((e) => DropdownMenuItem<String>(
                                    value: e.key as String,
                                    child: Text(
                                      (e.value as Map)['vpa'] ?? '',
                                      style: const TextStyle(color: AppTheme.onSurface),
                                    ),
                                  )),
                              const DropdownMenuItem<String>(
                                value: 'new',
                                child: Text('Enter New UPI ID', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            onChanged: (val) {
                              setSheetState(() {
                                selectedUpiKey = val!;
                                if (val != 'new') {
                                  upiIdController.text = (savedMethods[val] as Map)['vpa'] ?? '';
                                } else {
                                  upiIdController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      if (selectedUpiKey == 'new')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                          child: TextField(
                            controller: upiIdController,
                            style: const TextStyle(color: AppTheme.onSurface),
                            decoration: const InputDecoration(
                              labelText: 'Enter UPI ID',
                              hintText: 'username@bank',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                      
                    RadioListTile<String>(
                      title: const Text('Credit or Debit Card', style: TextStyle(color: AppTheme.onSurface)),
                      value: 'Card',
                      groupValue: paymentMethod,
                      activeColor: AppTheme.primaryContainer,
                      onChanged: (val) => setSheetState(() => paymentMethod = val!),
                    ),
                    if (paymentMethod == 'Card') ...[
                      if (savedCards.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedCardKey,
                            dropdownColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: 'Select Saved Card',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              ...savedCards.map((e) => DropdownMenuItem<String>(
                                    value: e.key as String,
                                    child: Text(
                                      (e.value as Map)['maskedNumber'] ?? '',
                                      style: const TextStyle(color: AppTheme.onSurface),
                                    ),
                                  )),
                              const DropdownMenuItem<String>(
                                value: 'new',
                                child: Text('Enter New Card Details', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            onChanged: (val) {
                              setSheetState(() {
                                selectedCardKey = val!;
                              });
                            },
                          ),
                        ),
                      if (selectedCardKey == 'new')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: cardNoController,
                                style: const TextStyle(color: AppTheme.onSurface),
                                decoration: const InputDecoration(
                                  labelText: 'Card Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: expiryController,
                                      style: const TextStyle(color: AppTheme.onSurface),
                                      decoration: const InputDecoration(
                                        labelText: 'Expiry (MM/YY)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: cvvController,
                                      style: const TextStyle(color: AppTheme.onSurface),
                                      decoration: const InputDecoration(
                                        labelText: 'CVV',
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],

                    RadioListTile<String>(
                      title: const Text('Pay After Service (Cash/COD)', style: TextStyle(color: AppTheme.onSurface)),
                      value: 'COD',
                      groupValue: paymentMethod,
                      activeColor: AppTheme.primaryContainer,
                      onChanged: (val) => setSheetState(() => paymentMethod = val!),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (paymentMethod == 'UPI') {
                          if (selectedUpiKey == 'new') {
                            final upiText = upiIdController.text.trim();
                            if (upiText.isEmpty || !upiText.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter a valid UPI ID (e.g. user@bank).')),
                              );
                              return;
                            }
                            final itemKey = 'upi_${DateTime.now().millisecondsSinceEpoch}';
                            paymentBox.put(itemKey, {
                              'type': 'UPI',
                              'vpa': upiText,
                            });
                          }
                        } else if (paymentMethod == 'Card') {
                          if (selectedCardKey == 'new') {
                            final cardNum = cardNoController.text.trim().replaceAll(' ', '');
                            final expiry = expiryController.text.trim();
                            final cvv = cvvController.text.trim();
                            if (cardNum.length != 16) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Card number must be 16 digits.')),
                              );
                              return;
                            }
                            if (expiry.length != 5 || !expiry.contains('/')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expiry must be MM/YY.')),
                              );
                              return;
                            }
                            if (cvv.length != 3) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('CVV must be 3 digits.')),
                              );
                              return;
                            }
                            final masked = '•••• •••• •••• ${cardNum.substring(12)}';
                            final itemKey = 'card_${DateTime.now().millisecondsSinceEpoch}';
                            paymentBox.put(itemKey, {
                              'type': 'CARD',
                              'maskedNumber': masked,
                              'expiry': expiry,
                              'holder': 'Cardholder',
                            });
                          }
                        }

                        setSheetState(() => paymentStatus = 'processing');
                        
                        Timer(const Duration(milliseconds: 1500), () {
                          if (sheetContext.mounted) {
                            setSheetState(() => paymentStatus = 'success');
                            
                            Timer(const Duration(seconds: 1), () {
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                                
                                final finalBooking = Map<String, dynamic>.from(baseBookingData);
                                final statusVal = paymentMethod == 'COD' ? 'Pending' : 'Paid';
                                finalBooking['paymentStatus'] = statusVal;
                                finalBooking['paymentMethod'] = paymentMethod;
                                finalBooking['transactionId'] = 'TXN_CONF_${DateTime.now().millisecondsSinceEpoch}';

                                if (mounted) {
                                  setState(() {
                                    _paymentMethod = paymentMethod;
                                    _paymentStatus = statusVal;
                                  });
                                  this.context.read<BookingBloc>().add(CreateBookingEvent(finalBooking));
                                }
                              }
                            });
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                        ),
                      ),
                      child: Text('Pay ₹${(rate - _discountValue).toInt()} & Confirm Booking'),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final provider = routeArgs?['provider'] ?? {
      'name': 'Dr. Arjun Mehta',
      'rate': 850,
      'rateUnit': '/visit',
    };

    final String providerName = provider['name'] ?? 'Dr. Arjun Mehta';
    final int providerRate = provider['rate'] ?? 850;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          // Reload local cache list so they appear in bookings tab
          context.read<BookingBloc>().add(LoadBookingsEvent());
          
          Navigator.pushNamed(context, '/booking_confirmation', arguments: {
            'providerName': providerName,
            'totalEstimate': providerRate - _discountValue,
            'selectedDay': _selectedDayIndex + 14,
            'selectedSlot': _selectedSlot,
            'address': 'Sector 62, Noida, UP',
            'entryMethod': _entryMethod,
            'paymentMethod': _paymentMethod,
            'paymentStatus': _paymentStatus,
          });
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background, // aligned background
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceContainerLowest,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () {
              if (_currentStep > 1) {
                _nextStep(_currentStep - 1);
              } else {
                Navigator.pop(context);
              }
            },
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
          child: Column(
            children: [
              // 1. Progress Stepper Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: [
                    _buildStepIndicator(1, 'Schedule'),
                    _buildStepDivider(1),
                    _buildStepIndicator(2, 'Location'),
                    _buildStepDivider(2),
                    _buildStepIndicator(3, 'Details'),
                  ],
                ),
              ),
  
              // 2. Step Contents
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerMargin),
                  child: _buildStepContent(theme),
                ),
              ),
  
              // 3. Fixed Bottom Estimate & Confirm Panel
              _buildBottomPanel(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String title) {
    final isCompleted = _currentStep > stepNumber;
    final isActive = _currentStep == stepNumber;

    Color bg;
    Widget child;
    Color textColor;

    if (isCompleted) {
      bg = AppTheme.secondary;
      child = const Icon(Icons.check, color: Colors.white, size: 16);
      textColor = AppTheme.secondary;
    } else if (isActive) {
      bg = AppTheme.primaryContainer;
      child = Text(
        '$stepNumber',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      );
      textColor = AppTheme.primaryContainer;
    } else {
      bg = AppTheme.surfaceContainerHighest;
      child = Text(
        '$stepNumber',
        style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
      );
      textColor = AppTheme.onSurfaceVariant;
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int afterStep) {
    final isCompleted = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isCompleted ? AppTheme.secondary : AppTheme.outlineVariant,
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 1:
        return _buildScheduleStep(theme);
      case 2:
        return _buildLocationStep(theme);
      case 3:
        return _buildDetailsStep(theme);
      default:
        return _buildScheduleStep(theme);
    }
  }

  Widget _buildScheduleStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'When do you need help?',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 16),

        // Simple Calendar Grid Week Mock
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCalendarDayButton(0, 'MON', '14'),
            _buildCalendarDayButton(1, 'TUE', '15'),
            _buildCalendarDayButton(2, 'WED', '16'),
            _buildCalendarDayButton(3, 'THU', '17'),
            _buildCalendarDayButton(4, 'FRI', '18'),
            _buildCalendarDayButton(5, 'SAT', '19'),
            _buildCalendarDayButton(6, 'SUN', '20'),
          ],
        ),
        const SizedBox(height: 24),

        const Text(
          'Available Time Slots',
          style: TextStyle(
            color: AppTheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Time Slots
        Row(
          children: [
            Expanded(
              child: _buildTimeSlotCard(
                slotName: 'Morning',
                timeRange: '08:00 AM - 12:00 PM',
                icon: Icons.wb_sunny,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeSlotCard(
                slotName: 'Afternoon',
                timeRange: '01:00 PM - 05:00 PM',
                icon: Icons.wb_twilight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: () => _nextStep(2),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryContainer,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.roundedMd),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
          ),
          child: const Text(
            'Continue to Address',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDayButton(int index, String dayName, String dayNum) {
    final isSelected = _selectedDayIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: Container(
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryContainer : const Color(0xFFD9D6CF),
          ),
        ),
        child: Column(
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: isSelected ? Colors.white.withAlpha(204) : AppTheme.onSurfaceVariant.withAlpha(153),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard({
    required String slotName,
    required String timeRange,
    required IconData icon,
  }) {
    final isSelected = _selectedSlot == slotName;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSlot = slotName;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer.withAlpha(26) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryContainer : const Color(0xFFD9D6CF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryContainer, size: 24),
            const SizedBox(height: 12),
            Text(
              slotName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeRange,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Confirm Service Address',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 16),

        // Map Mock Container
        Container(
          height: 192,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.roundedLg - 1),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAWH5TtdWQBebdsl8_eGZ1egji-12ExPFX_RqQZIdpobtZt2EKkj9u90Xp88PG7llXJwEaOe6PusTGn7lWCGrPXJ2wIQZzQjBuh2zXUnJcAuq93M7He5CQuQp5zHsQIeoz1mAJouFB64RLc2yk6VvqpCe1gSU0cjFtgj9kDWHLWsStmWOBgSYgtdTv2TnGxSyTXJSKrgDG4R4xysnaXkvESNB5MrYELVDtxTzvUDdBaM7S23ad-3MPKqrlNMS5D4OM3rwgRWNEkhDnI',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on, color: AppTheme.primaryContainer, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sector 62, Noida, UP, 201301',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: AppTheme.primaryContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Apartment / Suite (Optional)',
          style: TextStyle(
            color: AppTheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
            border: Border.all(color: const Color(0xFFD9D6CF)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _aptController,
              decoration: const InputDecoration(
                hintText: 'e.g. Apt 4B, Tower C',
                hintStyle: TextStyle(color: Color(0x661E293B), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info, color: AppTheme.primaryContainer, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Our service providers are verified for this area. Expect professional and safe arrivals.',
                  style: TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _nextStep(1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.onSurface,
                  side: const BorderSide(color: Color(0xFFD9D6CF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _nextStep(3),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text(
                  'Add Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          'Final Details',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Special Instructions for Provider',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
            border: Border.all(color: const Color(0xFFD9D6CF)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _instructionsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Mention pets, gate codes, or specific focus areas...',
                hintStyle: TextStyle(color: Color(0x661E293B), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Entry Method',
          style: TextStyle(
            color: AppTheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        RadioGroup<String>(
          groupValue: _entryMethod,
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _entryMethod = val;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEntryRadioRow('I\'ll be home to let them in', Icons.person),
              const SizedBox(height: 8),
              _buildEntryRadioRow('Use hidden key / Digital lock', Icons.key),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Background Check Notification
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user, color: AppTheme.primaryContainer, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Background Checked Professional',
                      style: TextStyle(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'All support staff have undergone rigorous identity and safety verification.',
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
        const SizedBox(height: 32),

        OutlinedButton(
          onPressed: () => _nextStep(2),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.onSurface,
            side: const BorderSide(color: Color(0xFFD9D6CF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.roundedMd),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Back to Location',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryRadioRow(String label, IconData icon) {
    final isSelected = _entryMethod == label;

    return InkWell(
      onTap: () {
        setState(() {
          _entryMethod = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryContainer.withAlpha(26) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryContainer : const Color(0xFFD9D6CF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Radio<String>(
              value: label,
              activeColor: AppTheme.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(Map<String, dynamic> provider) {
    final name = provider['name'] ?? 'Dr. Arjun Mehta';
    final rate = provider['rate'] ?? 850;
    final avatarUrl = provider['avatarUrl'] ?? '';
    final specialty = provider['specialty'] ?? '';
    final displayTotal = rate - _discountValue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.inverseSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 12.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Total Estimate',
                    style: TextStyle(
                      color: Color(0xCCB4EBFF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (_discountValue > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$_promoCode APPLIED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.help_outline, color: Color(0x99B4EBFF), size: 13),
                ],
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  text: _discountValue > 0 ? '₹$rate ' : '',
                  style: const TextStyle(
                    color: Color(0x66B4EBFF),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                  ),
                  children: [
                    TextSpan(
                      text: '₹$displayTotal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const TextSpan(
                      text: ' / visit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0x99B4EBFF),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              final isLoading = state is BookingLoading;
              return ElevatedButton.icon(
                onPressed: isLoading ? null : () {
                  final bookingData = {
                    'name': name,
                    'avatarUrl': avatarUrl,
                    'specialty': specialty,
                    'schedule': 'Today, 2:00 PM',
                    'date': 'Oct ${_selectedDayIndex + 14}, 2026',
                    'address': 'Sector 62, Noida (Home)',
                    'isAvailableNow': true,
                    'hasTracking': true,
                    'rate': rate - _discountValue,
                    'entryMethod': _entryMethod,
                  };
                  _showCheckoutSheet(context, bookingData);
                },
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppTheme.onSecondaryContainer,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Icon(Icons.lock, size: 16, color: AppTheme.onSecondaryContainer),
                label: Text(
                  isLoading ? 'Booking...' : 'Confirm Booking',
                  style: const TextStyle(
                    color: AppTheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryFixed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 4,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
