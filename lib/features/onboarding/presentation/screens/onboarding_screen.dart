import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // Final Premium Light Refinement Slide Data
  final List<Map<String, String>> _slides = [
    {
      'tag': 'CHILD CARE',
      'title': 'Nurturing Care for Your Little Ones',
      'desc': 'Verified Professionals - Rigorous 5-point identity and background verification for absolute peace of mind.',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA1heavNISqed3mdd3TQSQbxijnHKGJNwnj4LfH00TJt3Yty5VVu5gw680azRoWU3OdCXCPLxeTJxqaRQPk7cxn6-inb0R1oUM1W6f56borV6lbaB7Ag9ploo-K_Z4Ozewdcw-fpVTrwr9IwwQsYmI3YfLFzDcQ2XLsZ_H0_IJ4Xpf8lDRWdwCnZdfLoUuTxf1RwAT7pkAE7gv3_ovb71n0Fe3RxUHYqseYzyUVXJdyvArwfdm0xsylvrK3zYVES0r9GpDiNqtbJ3EU',
    },
    {
      'tag': 'ELDER CARE',
      'title': 'Dignity & Support for Your Elders',
      'desc': 'Specialized companions focused on wellness, mobility, and providing a higher quality of daily life at home.',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAG7BeHBwGjN3bkfGjneef2lf-CGeRKxm0fYhh_HmKyspCpJ4Qgy4JMfigjaCmebYD4S0XfRiMYjbYXQCayLnrWY9VjfxD6eTvouFG6gsQsglwcus1HUBjXCfAU6c5DCEJ7q3z-7mQl06o5nRZ37oCAoke25n3MTKQHvQ-lxcB2ERltWOExSJhuAe_nfgwOJ8Wsrm0r_xiFwbRkQaXk32uxlid--fHIlWTSns1rGIHNb9t0lSbwFLctGkfkH8p1ukSa593RIl-vOZ4n',
    },
    {
      'tag': 'HOME SUPPORT',
      'title': 'Personalized Help for Every Home',
      'desc': 'Experience quiet luxury with household management that allows you to focus on what truly matters most.',
      'imageUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtrRpRJ-XQacljcBPdMyltUM48h0epL-MxXjoKKIEf1IzIwZCllBCk4cPKUGkJFXjn85gOu9x9i8cVPkW9nYeJI1b58SVLC8zJj3O_v9CtDLjAw_YjGfFpPofx0rZYhJGHGz-wnpX_2jxLMy3ZsN1L-Iq30mJIznEY--q7JlIncQVQH3p752ZzSUlmN4M70oTYRt2MSCYLwA17fRK1PTDo27lGeXDG09pY94yLEj120kj5D47jDOnkbwhP2hUHd2o7LlvlTdkX7Ih4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < _slides.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Scrollable Main Content (behind header)
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spacing for sticky top header
                    const SizedBox(height: 72),

                    // High-End Aspect ratio image carousel
                    GestureDetector(
                      onPanDown: (_) => _stopAutoScroll(),
                      child: SizedBox(
                        height: 380,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemCount: _slides.length,
                          itemBuilder: (context, index) {
                            final slide = _slides[index];
                            return Image.network(
                              slide['imageUrl']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.primaryContainer,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Overlapping Rounded Information Sheet Card
                    Transform.translate(
                      offset: const Offset(0, -48), // -mt-12 overlap translation
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLowest,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E2A32).withAlpha(20), // 8% opacity shadow
                              blurRadius: 24.0,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.only(
                          top: 36.0,
                          bottom: 24.0,
                          left: 24.0,
                          right: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Tag Pill Category
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer.withAlpha(26), // 10% opacity
                                borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                                border: Border.all(
                                  color: AppTheme.primaryContainer.withAlpha(51), // 20% opacity
                                  width: 1.0,
                                ),
                              ),
                              child: Text(
                                _slides[_currentPage]['tag']!,
                                style: const TextStyle(
                                  color: AppTheme.primaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Headline
                            SizedBox(
                              height: 72,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.0, 0.15),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  _slides[_currentPage]['title']!,
                                  key: ValueKey<int>(_currentPage),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    color: AppTheme.primary,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.25,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtitle
                            SizedBox(
                              height: 64,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  _slides[_currentPage]['desc']!,
                                  key: ValueKey<int>(_currentPage),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.secondary,
                                    fontSize: 15.0,
                                    height: 1.45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Indicator dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_slides.length, (index) {
                                final isActive = _currentPage == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                  height: 6.0,
                                  width: isActive ? 28.0 : 6.0,
                                  decoration: BoxDecoration(
                                    color: isActive ? AppTheme.primary : AppTheme.outlineVariant,
                                    borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 36),

                            // CTAs Buttons Row
                            ElevatedButton(
                              onPressed: () {
                                _stopAutoScroll();
                                Navigator.pushNamed(context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryContainer,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                                ),
                              ),
                              child: const Text(
                                'Join Trusted Home',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.secondary,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Log in',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _stopAutoScroll();
                                          Navigator.pushNamed(context, '/login');
                                        },
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Bottom Trust Divider
                            const Divider(color: AppTheme.outlineVariant, height: 1),
                            const SizedBox(height: 24),

                            // Bottom Trust Grid
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.tertiaryFixed,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.verified_user,
                                            color: AppTheme.onTertiaryFixedVariant,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Verified & Background Checked',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.secondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.tertiaryFixed,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.gpp_good,
                                            color: AppTheme.onTertiaryFixedVariant,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Safety First Focus',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.secondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
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

            // 2. Sticky Header floating at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 72,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.outlineVariant,
                      width: 1.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.containerMargin,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trusted Home',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _stopAutoScroll();
                        Navigator.pushNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
