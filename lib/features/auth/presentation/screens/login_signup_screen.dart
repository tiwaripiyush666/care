import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../bloc/auth_bloc.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  bool _isPhoneValid = false;
  bool _isLoading = false;
  bool _haveReferral = false;
  final String _selectedCountryCode = '+91';
  final String _selectedFlag = '🇮🇳';

  String? _deviceId;
  String? _deviceTrustToken;
  bool _isBiometricConfigured = false;

  String? _promoErrorMessage;
  String? _promoSuccessMessage;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final storage = SecureStorageService();
    String? devId = await storage.read('device_id');
    if (devId == null) {
      devId = 'device_snabbit_simulation_${DateTime.now().microsecondsSinceEpoch}';
      await storage.write('device_id', devId);
    }
    final token = await storage.read('device_trust_token');
    final biometricEnabled = await storage.read('biometric_enabled_flag');
    
    if (mounted) {
      setState(() {
        _deviceId = devId;
        _deviceTrustToken = token;
        _isBiometricConfigured = biometricEnabled == 'true';
      });

      if (_isBiometricConfigured) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _triggerBiometricVerification();
        });
      }
    }
  }

  void _triggerBiometricVerification() {
    bool timerStarted = false;
    bool verifying = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!timerStarted) {
              timerStarted = true;
              Timer(const Duration(milliseconds: 1500), () {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    verifying = false;
                  });
                  
                  Timer(const Duration(milliseconds: 800), () {
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushNamedAndRemoveUntil(this.context, '/home', (route) => false);
                    }
                  });
                }
              });
            }

            return AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.roundedLg),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  if (verifying)
                    const SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryContainer,
                        strokeWidth: 3,
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    verifying ? 'Verifying Identity...' : 'Identity Verified!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    verifying 
                        ? 'Confirming device biometrics / lock credentials...' 
                        : 'Welcome back to Caresphere',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (verifying)
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text(
                        'Cancel & Use OTP',
                        style: TextStyle(
                          color: AppTheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.trim().length == 10;
    });
  }

  Future<void> _applyPromoCode() async {
    final code = _referralController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final storage = SecureStorageService();
    if (code == 'WELCOME100') {
      await storage.write('applied_promo_code', 'WELCOME100');
      await storage.write('promo_discount_value', '100');
      setState(() {
        _promoSuccessMessage = '✓ Promo Applied! ₹100 discount added to your next booking.';
        _promoErrorMessage = null;
      });
    } else if (code == 'SNABBIT250') {
      await storage.write('applied_promo_code', 'SNABBIT250');
      await storage.write('promo_discount_value', '250');
      setState(() {
        _promoSuccessMessage = '✓ Promo Applied! ₹250 discount added to your next booking.';
        _promoErrorMessage = null;
      });
    } else {
      setState(() {
        _promoErrorMessage = '✗ Invalid promo code. Try WELCOME100 or SNABBIT250';
        _promoSuccessMessage = null;
      });
    }
  }

  Future<void> _clearPromoCode() async {
    final storage = SecureStorageService();
    await storage.delete('applied_promo_code');
    await storage.delete('promo_discount_value');
    setState(() {
      _promoSuccessMessage = null;
      _promoErrorMessage = null;
      _referralController.clear();
    });
  }

  void _triggerOtpSend() {
    if (!_isPhoneValid || _isLoading) return;
    final phone = '$_selectedCountryCode ${_phoneController.text.trim()}';
    context.read<AuthBloc>().add(AuthSendOtp(
      phone,
      deviceId: _deviceId,
      deviceTrustToken: _deviceTrustToken,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthOtpSent) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushNamed(
            context,
            '/otp_verification',
            arguments: {
              'phone': '$_selectedCountryCode ${_phoneController.text.trim()}',
              'silent': state.silentVerification,
              'bypassToken': state.bypassToken,
              'deviceId': _deviceId,
            },
          );
        } else if (state is AuthError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Image Header (52% of viewport height)
            Stack(
              children: [
                Container(
                  height: size.height * 0.52,
                  width: double.infinity,
                  foregroundDecoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0F5F73).withAlpha(153), // 60% primaryContainer
                        const Color(0xFF0F5F73).withAlpha(51),  // 20% primaryContainer
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida/AP1WRLvKJSZBIuYDHp-F_1EdH1FWcTPcg3fpCvhZaMIGcGrKaEi8MGbRdfRGQTTGjqWeEWB51b5IAcbH2cbkND6H9bHP5ozMG1ZcK9LQu8hz_yxWM_J87Q3X1wGiV7hXm0gSowL3nWd_CfivYcpSaVnVxY_TR_OyXgYvogJ91gqU9J5Wj7O1BCgbuS83B-MKqmU4Xrx4L9o8H5rEqYeEgOOGMSDo4R84Qg02YT7gPT2NL8wSoEW-4jEs8NF5oQg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryContainer,
                              AppTheme.secondaryFixed,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.home_repair_service,
                            color: Colors.white30,
                            size: 80,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Top skip action
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 20,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                    borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                        border: Border.all(color: Colors.white.withAlpha(102)),
                      ),
                      child: const Text(
                        'Skip login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom left branding overlay
                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trusted Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Professional care you can depend on.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              blurRadius: 4.0,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. Login Card (slightly overlapping the bottom of the hero)
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppTheme.surfaceContainer),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F5F73).withAlpha(20),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Log in or Sign up',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter your details to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Mobile number row field
                      Container(
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                          border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              decoration: const BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                border: Border(
                                  right: BorderSide(color: AppTheme.outlineVariant),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    _selectedFlag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedCountryCode,
                                    style: const TextStyle(
                                      color: AppTheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: const TextStyle(
                                    color: AppTheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Mobile number',
                                    counterText: '',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Color(0x6670787C),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Get OTP CTA Button & Biometrics Shortcut Row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isPhoneValid && !_isLoading ? _triggerOtpSend : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryContainer,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppTheme.primaryContainer.withAlpha(76),
                                disabledForegroundColor: Colors.white.withAlpha(128),
                                minimumSize: const Size.fromHeight(60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white.withAlpha(204),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Sending...',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Get OTP',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          if (_isBiometricConfigured) ...[
                            const SizedBox(width: 12),
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                                border: Border.all(color: AppTheme.outlineVariant),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.fingerprint, color: AppTheme.primaryContainer, size: 28),
                                onPressed: _triggerBiometricVerification,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Referral Checkbox Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _haveReferral,
                            activeColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _haveReferral = val;
                                });
                                if (!val) {
                                  _clearPromoCode();
                                }
                              }
                            },
                          ),
                          const Text(
                            'Have a referral code?',
                            style: TextStyle(
                              color: AppTheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (_haveReferral) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                                  border: Border.all(color: AppTheme.outlineVariant),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  controller: _referralController,
                                  textCapitalization: TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter code e.g. WELCOME100',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Color(0x6670787C),
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 13, color: AppTheme.onSurface),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _applyPromoCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryContainer,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_promoErrorMessage != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _promoErrorMessage!,
                              style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                        if (_promoSuccessMessage != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _promoSuccessMessage!,
                              style: const TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 3. Footer Links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                children: [
                  const Text(
                    'By continuing, you agree to our',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: AppTheme.primaryContainer,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Text(
                        ' & ',
                        style: TextStyle(
                          color: AppTheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: AppTheme.primaryContainer,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}
}
