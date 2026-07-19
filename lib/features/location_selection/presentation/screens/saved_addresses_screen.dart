import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  late Box _addressBox;
  bool _isBoxOpen = false;

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

  Future<void> _navigateToAddEdit({String? key, Map<dynamic, dynamic>? existingData}) async {
    final result = await Navigator.pushNamed(
      context,
      '/location_manual',
      arguments: {
        'isManageMode': true,
        'label': existingData?['label'],
        'initialDetails': existingData?['details'],
      },
    ) as Map<dynamic, dynamic>?;

    if (result != null) {
      final itemKey = key ?? 'addr_${DateTime.now().millisecondsSinceEpoch}';
      await _addressBox.put(itemKey, result);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(key == null ? 'Address added successfully' : 'Address updated successfully'),
            backgroundColor: AppTheme.primaryContainer,
          ),
        );
      }
    }
  }

  void _confirmDelete(String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.roundedLg)),
        title: const Text('Delete Address', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        content: const Text('Are you sure you want to delete this address? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _addressBox.delete(key);
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address deleted successfully'), backgroundColor: AppTheme.primaryContainer),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBoxOpen) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryContainer)),
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
          style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: AppTheme.outline),
                    const SizedBox(height: 16),
                    const Text('No Saved Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Add locations to easily select them during booking.', style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppTheme.containerMargin),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final key = items.keys.elementAt(index) as String;
                  final data = items[key] as Map<dynamic, dynamic>;
                  final label = data['label']?.toString().toUpperCase() ?? 'OTHER';

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                      side: const BorderSide(color: AppTheme.outlineVariant),
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
                              label,
                              style: const TextStyle(color: AppTheme.primaryContainer, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data['addressText'] ?? '',
                              style: const TextStyle(fontSize: 13, color: AppTheme.onSurface, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _navigateToAddEdit(key: key, existingData: data),
                            icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryContainer),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _confirmDelete(key),
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
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: AppTheme.primaryContainer,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
