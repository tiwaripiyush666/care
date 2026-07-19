import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Box _paymentBox;
  bool _isBoxOpen = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _paymentBox = await Hive.openBox('caresphere_payment_methods');
    if (mounted) {
      setState(() {
        _isBoxOpen = true;
      });
    }
  }

  bool _isValidLuhn(String cardNum) {
    final clean = cardNum.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 13 || clean.length > 19) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = clean.length - 1; i >= 0; i--) {
      int n = int.parse(clean[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  void _addUpiDialog() {
    final upiController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.roundedLg)),
          title: const Text(
            'Add UPI ID',
            style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: upiController,
              autofocus: true,
              style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'username@bank',
                hintStyle: TextStyle(color: AppTheme.outline),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryContainer)),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter UPI ID';
                if (!val.contains('@')) return 'Invalid UPI format (must contain @)';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final upi = upiController.text.trim();
                  final itemKey = 'upi_${DateTime.now().millisecondsSinceEpoch}';
                  await _paymentBox.put(itemKey, {
                    'type': 'UPI',
                    'vpa': upi,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.roundedMd)),
              ),
              child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _addCardDialog() {
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.roundedLg)),
          title: const Text(
            'Add Card Details',
            style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      CardNumberInputFormatter(),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      labelStyle: TextStyle(color: AppTheme.onSurfaceVariant),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryContainer)),
                    ),
                    validator: (val) {
                      if (val == null) return 'Please enter card number';
                      final clean = val.replaceAll(' ', '');
                      if (clean.length != 16) return 'Card number must be 16 digits';
                      if (!_isValidLuhn(clean)) return 'Invalid card number (Luhn Check Failed)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: expiryController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            CardExpiryInputFormatter(),
                          ],
                          style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            labelText: 'Expiry (MM/YY)',
                            labelStyle: TextStyle(color: AppTheme.onSurfaceVariant),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryContainer)),
                          ),
                          validator: (val) {
                            if (val == null || !val.contains('/') || val.trim().length != 5) {
                              return 'MM/YY required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            labelStyle: TextStyle(color: AppTheme.onSurfaceVariant),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryContainer)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length != 3) {
                              return 'CVV must be 3 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      labelText: 'Cardholder Name',
                      labelStyle: TextStyle(color: AppTheme.onSurfaceVariant),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryContainer)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final number = numberController.text.trim().replaceAll(' ', '');
                  final masked = '•••• •••• •••• ${number.substring(12)}';
                  final itemKey = 'card_${DateTime.now().millisecondsSinceEpoch}';
                  await _paymentBox.put(itemKey, {
                    'type': 'CARD',
                    'maskedNumber': masked,
                    'expiry': expiryController.text.trim(),
                    'holder': nameController.text.trim(),
                    'brand': number.startsWith('4') ? 'Visa' : (number.startsWith('5') ? 'MasterCard' : 'Generic'),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.roundedMd)),
              ),
              child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.roundedLg)),
        title: const Text('Delete Payment Method', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryContainer)),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _paymentBox.delete(key);
              if (context.mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment method deleted successfully'), backgroundColor: AppTheme.primaryContainer),
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

    final items = _paymentBox.toMap();
    final upiList = items.entries.where((e) => (e.value as Map)['type'] == 'UPI').toList();
    final cardList = items.entries.where((e) => (e.value as Map)['type'] == 'CARD').toList();

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
          'Payment Methods',
          style: TextStyle(color: AppTheme.primaryContainer, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. UPI Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SAVED UPI IDs',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppTheme.onSurfaceVariant),
                  ),
                  TextButton.icon(
                    onPressed: _addUpiDialog,
                    icon: const Icon(Icons.add, size: 16, color: AppTheme.secondary),
                    label: const Text('Add UPI', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (upiList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: const Center(
                    child: Text(
                      'No saved UPI IDs. Add one for quick checkout.',
                      style: TextStyle(fontSize: 13, color: AppTheme.outline, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upiList.length,
                  itemBuilder: (context, index) {
                    final key = upiList[index].key as String;
                    final data = upiList[index].value as Map;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                        side: const BorderSide(color: AppTheme.outlineVariant),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.account_balance_wallet, color: AppTheme.primaryContainer),
                        title: Text(
                          data['vpa'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.onSurface),
                        ),
                        trailing: IconButton(
                          onPressed: () => _confirmDelete(key),
                          icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),

              // 2. Saved Cards Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CREDIT / DEBIT CARDS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppTheme.onSurfaceVariant),
                  ),
                  TextButton.icon(
                    onPressed: _addCardDialog,
                    icon: const Icon(Icons.add, size: 16, color: AppTheme.secondary),
                    label: const Text('Add Card', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (cardList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                    border: Border.all(color: AppTheme.outlineVariant),
                  ),
                  child: const Center(
                    child: Text(
                      'No saved cards. Add one for secure billing.',
                      style: TextStyle(fontSize: 13, color: AppTheme.outline, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cardList.length,
                  itemBuilder: (context, index) {
                    final key = cardList[index].key as String;
                    final data = cardList[index].value as Map;
                    final brand = data['brand'] ?? 'Generic';

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
                          children: [
                            Icon(
                              brand == 'Visa' ? Icons.credit_card : Icons.credit_card_sharp,
                              color: brand == 'Visa' ? Colors.blue : (brand == 'MasterCard' ? Colors.orange : AppTheme.primaryContainer),
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        data['maskedNumber'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.onSurface),
                                      ),
                                      if (brand != 'Generic') ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.outlineVariant,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            brand,
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Expiry: ${data['expiry']} • ${data['holder']}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _confirmDelete(key),
                              icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');
    if (newValue.selection.baseOffset == 0) return newValue;
    
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex == 2 && nonZeroIndex != text.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
