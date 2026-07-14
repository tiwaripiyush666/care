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
  bool _isPhoneValid = false;
  bool _isLoading = false;
  bool _haveReferral = false;
  final String _selectedCountryCode = '+91';
  final String _selectedFlag = '🇮🇳';

  String? _deviceId;
  String? _deviceTrustToken;

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
    
    if (mounted) {
      setState(() {
        _deviceId = devId;
        _deviceTrustToken = token;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.trim().length == 10;
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

                      // Get OTP CTA Button
                      ElevatedButton(
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
