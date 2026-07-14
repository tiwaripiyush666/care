import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String _selectedAddressType = 'Home';
  bool _isFormValid = false;

  final List<Map<String, dynamic>> _savedAddresses = [
    {
      'type': 'Home',
      'icon': Icons.home,
      'isDefault': true,
      'address': 'Apt 4B, Emerald Heights, Sector 45, Gurgaon, Haryana 122003',
      'details': {
        'house': 'Apt 4B, Emerald Heights',
        'area': 'Sector 45',
        'floor': '4th Floor',
        'landmark': 'Near Central Park',
        'city': 'Gurgaon',
        'state': 'Haryana',
        'pincode': '122003',
      }
    },
    {
      'type': 'Office',
      'icon': Icons.business,
      'isDefault': false,
      'address': 'Tech Park Central, Tower B, Level 12, Financial District, Hyderabad 500032',
      'details': {
        'house': 'Tech Park Central, Tower B, Level 12',
        'area': 'Financial District',
        'floor': '12th Floor',
        'landmark': 'Tech Park',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'pincode': '500032',
      }
    },
    {
      'type': 'Parents',
      'icon': Icons.favorite,
      'isDefault': false,
      'address': 'Villa 12, Rose Garden Society, Near Central Park, Pune 411001',
      'details': {
        'house': 'Villa 12, Rose Garden Society',
        'area': 'Rose Garden',
        'floor': '',
        'landmark': 'Near Central Park',
        'city': 'Pune',
        'state': 'Maharashtra',
        'pincode': '411001',
      }
    },
  ];

  @override
  void initState() {
    super.initState();
    _houseController.addListener(_validateForm);
    _areaController.addListener(_validateForm);
    _cityController.addListener(_validateForm);
    _stateController.addListener(_validateForm);
    _pincodeController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _houseController.dispose();
    _areaController.dispose();
    _floorController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _houseController.text.trim().isNotEmpty &&
          _areaController.text.trim().isNotEmpty &&
          _cityController.text.trim().isNotEmpty &&
          _stateController.text.trim().isNotEmpty &&
          _pincodeController.text.trim().isNotEmpty;
    });
  }

  void _selectSavedAddress(Map<String, dynamic> address) {
    final details = address['details'] as Map<String, String>;
    setState(() {
      _selectedAddressType = address['type'];
      _houseController.text = details['house'] ?? '';
      _areaController.text = details['area'] ?? '';
      _floorController.text = details['floor'] ?? '';
      _landmarkController.text = details['landmark'] ?? '';
      _cityController.text = details['city'] ?? '';
      _stateController.text = details['state'] ?? '';
      _pincodeController.text = details['pincode'] ?? '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected saved address: ${address['type']}'),
        backgroundColor: AppTheme.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
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
          'Set Your Location',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryContainer,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.help_outline,
              color: AppTheme.primaryContainer,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: AppTheme.outlineVariant.withAlpha(128),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ADD ADDRESS MANUALLY Section Header
                const Text(
                  'ADD ADDRESS MANUALLY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.outline,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Address Type Selection Buttons
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedAddressType = 'Home';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedAddressType == 'Home' ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
                        foregroundColor: _selectedAddressType == 'Home' ? Colors.white : AppTheme.onSurfaceVariant,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: _selectedAddressType == 'Home' ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: const Text(
                        'Home',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedAddressType = 'Other';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedAddressType == 'Other' ? AppTheme.primaryContainer : AppTheme.surfaceContainerLow,
                        foregroundColor: _selectedAddressType == 'Other' ? Colors.white : AppTheme.onSurfaceVariant,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: _selectedAddressType == 'Other' ? AppTheme.primaryContainer : AppTheme.outlineVariant,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: const Text(
                        'Other',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // House details
                    const Text(
                      'House / Flat / Building Name *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _houseController,
                      style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'e.g. Apt 4B, Emerald Heights',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primaryContainer, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Area details
                    const Text(
                      'Area / Colony / Sector *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _areaController,
                      style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'e.g. Sector 45',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primaryContainer, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Floor & Landmark Grid row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Floor (Optional)',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _floorController,
                                style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 4th Floor',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.primaryContainer, width: 2.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Landmark (Optional)',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _landmarkController,
                                style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Near Central Park',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.primaryContainer, width: 2.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // City & State Grid row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'City *',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _cityController,
                                style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Gurgaon',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.primaryContainer, width: 2.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'State *',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _stateController,
                                style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Haryana',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: AppTheme.primaryContainer, width: 2.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pincode details
                    const Text(
                      'Pincode *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'e.g. 122003',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primaryContainer, width: 2.0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save & Continue Button
                ElevatedButton(
                  onPressed: _isFormValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.primaryContainer.withAlpha(76),
                    disabledForegroundColor: Colors.white.withAlpha(128),
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save & Continue',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // 2. Saved Addresses Section
                const Text(
                  'SAVED ADDRESSES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.outline,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Saved Address List Cards
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _savedAddresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = _savedAddresses[index];
                    return InkWell(
                      onTap: () => _selectSavedAddress(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppTheme.outlineVariant.withAlpha(128)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: AppTheme.primaryContainer,
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
                                        item['type'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onSurface,
                                        ),
                                      ),
                                      if (item['isDefault']) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondaryContainer,
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: AppTheme.onSecondaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['address'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.onSurfaceVariant,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.more_vert, color: AppTheme.outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),

                // 3. Trust Signal minimal hint footer
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.verified_user,
                        color: AppTheme.tertiary.withAlpha(200),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        width: 280,
                        child: Text(
                          'We use your location to find verified, high-caliber service providers in your hyper-local neighborhood.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.outline,
                            height: 1.4,
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
      ),
    );
  }
}
