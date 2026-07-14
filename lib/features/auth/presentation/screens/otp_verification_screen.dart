import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../registration/presentation/screens/registration_profile_details_screen.dart';
import '../bloc/auth_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    this.phoneNumber = '+91 98765 43210',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  int _secondsRemaining = 45;
  late Timer _timer;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _didInitSilent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitSilent) {
      _didInitSilent = true;
      final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final bool isSilent = arguments?['silent'] as bool? ?? false;
      final String? bypassToken = arguments?['bypassToken'] as String?;
      final String? deviceId = arguments?['deviceId'] as String?;
      
      if (isSilent && bypassToken != null) {
        _triggerSilentBypass(bypassToken, deviceId);
      }
    }
  }

  void _triggerSilentBypass(String bypassToken, String? deviceId) {
    setState(() {
      _isVerifying = true;
    });
    
    // Exactly 1 second delay to mimic active processing
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final String phone = arguments?['phone'] ?? widget.phoneNumber;
        
        context.read<AuthBloc>().add(AuthVerifyOtp(
          phone,
          bypassToken,
          deviceId: deviceId,
        ));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Add auto-focus shift listeners
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 45;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _timer.cancel();
          _canResend = true;
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _resendCode() {
    if (!_canResend) return;
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully! Use code 123456.'),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }

  void _verifyOtp() {
    if (_isVerifying) return;
    
    String enteredOtp = _controllers.map((c) => c.text).join();
    
    if (enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String displayPhone = arguments?['phone'] ?? widget.phoneNumber;
    final String? deviceId = arguments?['deviceId'] as String?;
    context.read<AuthBloc>().add(AuthVerifyOtp(displayPhone, enteredOtp, deviceId: deviceId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String displayPhone = arguments?['phone'] ?? widget.phoneNumber;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isVerifying = true;
          });
        } else if (state is AuthOtpVerified) {
          setState(() {
            _isVerifying = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrationProfileDetailsScreen(),
            ),
          );
        } else if (state is AuthAuthenticated) {
          setState(() {
            _isVerifying = false;
          });
          Navigator.pushNamedAndRemoveUntil(context, '/location', (route) => false);
        } else if (state is AuthError) {
          setState(() {
            _isVerifying = false;
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
            color: AppTheme.primary,
          ),
        ),
        title: Text(
          'Verify Number',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.containerMargin),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppTheme.containerMargin * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section: Header Info & Grid
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          'Verify Your Number',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.stackSm),
                        // Subtitle with Edit Action
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Enter the 6-digit code sent to $displayPhone',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // OTP 6-Digit Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: (constraints.maxWidth - AppTheme.containerMargin * 2 - 40) / 6,
                              height: 56,
                              child: TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: AppTheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: AppTheme.surfaceContainerLowest,
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                                    borderSide: const BorderSide(
                                      color: AppTheme.outlineVariant,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                                    borderSide: const BorderSide(
                                      color: AppTheme.primary,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    // Bottom Section: Verify Button & Timer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        // Verify and Proceed Button
                        ElevatedButton(
                          onPressed: _isVerifying ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryContainer,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                            ),
                            elevation: 0,
                          ),
                          child: _isVerifying
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white.withAlpha(204),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Verifying...'),
                                  ],
                                )
                              : const Text(
                                  'Verify & Proceed',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Resend timer text
                        Center(
                          child: _canResend
                              ? TextButton(
                                  onPressed: _resendCode,
                                  child: const Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Resend Code in 0:${_secondsRemaining.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: AppTheme.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 40),

                        // Info trust banner
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                            border: Border.all(color: AppTheme.outlineVariant.withAlpha(51)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.tertiary,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Didn't receive the code? Check your spam or try again.",
                                  style: TextStyle(
                                    color: AppTheme.onSurfaceVariant,
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Dashed visual circle
                        Center(
                          child: Opacity(
                            opacity: 0.4,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.secondaryContainer.withAlpha(76),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.verified_user,
                                  color: AppTheme.secondary,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
}
