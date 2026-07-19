import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/location/location_service.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  late Box _addressBox;
  bool _isBoxOpen = false;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _addressBox = await Hive.openBox('caresphere_saved_addresses');
    if (mounted) {
      setState(() {
        _isBoxOpen = true;
      });
    }
  }

  void _showAddressDialog({String? key, Map<dynamic, dynamic>? existingData}) {
    final labelController = TextEditingController(text: existingData?['label'] ?? '');
    final addressController = TextEditingController(text: existingData?['addressText'] ?? '');
    bool isDetecting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.roundedLg),
              ),
              title: Text(
                key == null ? 'Add Address' : 'Edit Address',
                style: const TextStyle(
                  color: AppTheme.primaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'Label (e.g. Home, Work, Gym)',
                        labelStyle: TextStyle(color: AppTheme.onSurfaceVariant),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryContainer),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                        labelStyle: TextStyle(color: AppTheme.onSurfaceVariant),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.primaryContainer),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: isDetecting
                          ? null
                          : () async {
                              setDialogState(() => isDetecting = true);
                              try {
                                final pos = await _locationService.getCurrentUserPosition();
                                final addr = await _locationService.getAddressFromCoordinates(
                                  pos.latitude,
                                  pos.longitude,
                                );
                                setDialogState(() {
                                  addressController.text = addr;
                                  isDetecting = false;
                                });
                              } catch (e) {
                                setDialogState(() => isDetecting = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to detect location: $e'),
                                      backgroundColor: AppTheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                      icon: isDetecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondary),
                            )
                          : const Icon(Icons.my_location, size: 16, color: AppTheme.secondary),
                      label: Text(
                        isDetecting ? 'Detecting Location...' : 'Use Current Location',
                        style: const TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final label = labelController.text.trim();
                    final addr = addressController.text.trim();
                    if (label.isEmpty || addr.isEmpty) return;

                    final itemKey = key ?? 'addr_${DateTime.now().millisecondsSinceEpoch}';
                    await _addressBox.put(itemKey, {
                      'label': label,
                      'addressText': addr,
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                    ),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAddress(String key) async {
    await _addressBox.delete(key);
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address deleted successfully'),
          backgroundColor: AppTheme.primaryContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBoxOpen) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryContainer),
        ),
      );
    }

    final items = _addressBox.toMap();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
        ),
        title: const Text(
          'Saved Addresses',
          style: TextStyle(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: AppTheme.outline),
                    const SizedBox(height: 16),
                    const Text(
                      'No Saved Addresses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add locations to easily select them during booking.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppTheme.containerMargin),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final key = items.keys.elementAt(index) as String;
                  final data = items[key] as Map<dynamic, dynamic>;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                      side: BorderSide(color: AppTheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer.withAlpha(26),
                              borderRadius: BorderRadius.circular(AppTheme.roundedSm),
                            ),
                            child: Text(
                              data['label']?.toString().toUpperCase() ?? 'OTHER',
                              style: const TextStyle(
                                color: AppTheme.primaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['addressText'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _showAddressDialog(key: key, existingData: data),
                            icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryContainer),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _deleteAddress(key),
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressDialog(),
        backgroundColor: AppTheme.primaryContainer,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
