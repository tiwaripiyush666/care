import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _loadingController;
  late final Animation<double> _pulseScaleAnimation;
  late final Animation<double> _pulseOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation: 4 seconds loop (reverse = true)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Loading slider animation: 2 seconds loop (infinitely forward)
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Transition to onboarding after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  // Reusable Glass Card Widget
  Widget _buildGlassCard({
    required Widget child,
    double borderRadius = 8.0,
    EdgeInsetsGeometry? padding,
    Border? border,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20), // rgba(255, 255, 255, 0.08)
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(
              color: Colors.white.withAlpha(38), // rgba(255, 255, 255, 0.15)
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Radial Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  AppTheme.gradientStart,
                  AppTheme.gradientEnd,
                ],
              ),
            ),
          ),

          // 2. Subtle Background Glows
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25 - 160,
            left: -160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryContainer.withAlpha(26), // opacity 0.1
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25 - 160,
            right: -160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withAlpha(26), // opacity 0.1
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          // 3. Main Content Scrollable to prevent overflow
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.containerMargin,
                        vertical: AppTheme.stackLg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top: Pill-shaped badges
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.stackXl),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildGlassCard(
                                  borderRadius: AppTheme.roundedFull,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.child_care,
                                        color: AppTheme.secondaryFixed,
                                        size: 18,
                                      ),
                                      const SizedBox(width: AppTheme.stackSm),
                                      Text(
                                        'Child Care Specialists',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppTheme.gutterMd),
                                _buildGlassCard(
                                  borderRadius: AppTheme.roundedFull,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppTheme.tertiaryFixedDim,
                                        size: 18,
                                      ),
                                      const SizedBox(width: AppTheme.stackSm),
                                      Text(
                                        '4.9/5 Avg. Rating',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center: Large circular medallion, title, tagline, chips & loader
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Circular Medallion with Pulse Animation
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseScaleAnimation.value,
                                    child: Opacity(
                                      opacity: _pulseOpacityAnimation.value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 176,
                                  height: 176,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(76), // shadow opacity 0.3
                                        blurRadius: 60.0,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: _buildGlassCard(
                                    borderRadius: AppTheme.roundedFull,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(51), // border white/20
                                      width: 2.0,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 144,
                                        height: 144,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withAlpha(26), // border white/10
                                            width: 1.0,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Icon(
                                                Icons.shield,
                                                size: 72,
                                                color: Colors.white24,
                                              ),
                                              Icon(
                                                Icons.home,
                                                size: 44,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Brand Name
                              Text(
                                'Trusted Home',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontSize: 48.0,
                                  fontWeight: FontWeight.w800,
                                  height: 1.0,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'SUPPORT',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppTheme.primaryFixedDim,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6 * 12.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Tagline & Body
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 280),
                                child: Column(
                                  children: [
                                    Text(
                                      'Your Trusted Partner for Every Home Need',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: AppTheme.stackMd),
                                    Text(
                                      'Elite support for families who demand excellence without compromise.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withAlpha(178), // white/70
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Icon Chips Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Chip 1: Fully Insured
                                  Column(
                                    children: [
                                      _buildGlassCard(
                                        borderRadius: AppTheme.roundedMd,
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Icon(
                                          Icons.security,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 60),
                                        child: const Text(
                                          'Fully Insured',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            height: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: AppTheme.stackLg),

                                  // Chip 2: 24/7 Support
                                  Column(
                                    children: [
                                      _buildGlassCard(
                                        borderRadius: AppTheme.roundedMd,
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Icon(
                                          Icons.support_agent,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 60),
                                        child: const Text(
                                          '24/7 Support',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            height: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: AppTheme.stackLg),

                                  // Chip 3: Home Sanitization
                                  Column(
                                    children: [
                                      _buildGlassCard(
                                        borderRadius: AppTheme.roundedMd,
                                        padding: const EdgeInsets.all(12.0),
                                        child: const Icon(
                                          Icons.cleaning_services,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 70),
                                        child: const Text(
                                          'Home Sanitization',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                            height: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Loading Widget (Sliding Track & Pulsing Subtitle)
                              Column(
                                children: [
                                  Container(
                                    width: 200,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(26), // white/10
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: AnimatedBuilder(
                                      animation: _loadingController,
                                      builder: (context, child) {
                                        // Slide from left alignment (-1.5) to right alignment (1.5)
                                        double alignmentX = -1.5 + (_loadingController.value * 3.0);
                                        return Align(
                                          alignment: Alignment(alignmentX, 0.0),
                                          child: Container(
                                            width: 66, // w-1/3 of track
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryFixedDim,
                                              borderRadius: BorderRadius.circular(9999),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _pulseOpacityAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: Text(
                                      'Initializing Secure Care...',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.white.withAlpha(153), // white/60
                                        fontSize: 11,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppTheme.stackLg),

                          // Bottom: Status bar footer
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: _buildGlassCard(
                              borderRadius: AppTheme.roundedLg,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left: Green dot + Active Protection
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4ADE80), // green-400
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4ADE80).withAlpha(153),
                                              blurRadius: 8.0,
                                              spreadRadius: 1.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Active Protection',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.65, // 0.15em
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Divider Line
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: Colors.white.withAlpha(26), // white/10
                                  ),

                                  // Right: verified star badge + Certified Team
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: AppTheme.tertiaryFixedDim,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Certified Team',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.65, // 0.15em
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
