import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class RegistrationProfileDetailsScreen extends StatefulWidget {
  const RegistrationProfileDetailsScreen({super.key});

  @override
  State<RegistrationProfileDetailsScreen> createState() => _RegistrationProfileDetailsScreenState();
}

class _RegistrationProfileDetailsScreenState extends State<RegistrationProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isFormValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.trim().isNotEmpty;
    });
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthAuthenticated) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/location',
            (route) => false,
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
        backgroundColor: const Color(0xFFF8FAFC), // light slaty background #f8fafc
        appBar: AppBar(
          backgroundColor: Colors.white.withAlpha(204),
          elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.onSurface,
          ),
        ),
        title: Text(
          'Complete Your Profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: AppTheme.outlineVariant.withAlpha(128),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Scrollable Form Content
            Positioned.fill(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 32.0,
                  bottom: 120.0, // space for sticky footer
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Centered Profile Avatar placeholder
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 112,
                                  height: 112,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(15),
                                        blurRadius: 24.0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9999),
                                    child: Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCsyXt3GE82xBLZfQr6Iz8ZgZb4P04uBu98x8otudXBx3modsuszX4W9DZBpD0qHJwcBrQBl2p_IxBx80NJpj_z99QNAYO9v4U2-_jkeZoJYiS8wo025IsferNimEoNQOfhmYChIr3JVf81BL4OC7suMxHCNeAF5tOMu3D9nZMm8F32bEHwE-JnkkgheUheOJRm5VjwEiIX-oFIkepZ8qz-BtaJZoFCVInsWdfn5DX682aqjYP621h5KHcc3Ajzy2QfMgXHozcXG_9l',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Camera profile upload simulation triggered.'),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(9999),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryContainer,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(26),
                                            blurRadius: 8.0,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.photo_camera,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Welcome text
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Welcome to ',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Trusted Home',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tell us a bit more about yourself.',
                              style: TextStyle(
                                color: AppTheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Full Name input field
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'John Doe',
                          prefixIcon: const Icon(Icons.person_outline, color: AppTheme.outline),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email Address input field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppTheme.roundedFull),
                            ),
                            child: const Text(
                              'OPTIONAL',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'example@email.com',
                          prefixIcon: const Icon(Icons.mail_outlined, color: AppTheme.outline),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Gender selection - Custom Segmented Control
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                          border: Border.all(color: AppTheme.outlineVariant.withAlpha(128)),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentedTab('Male'),
                            _buildSegmentedTab('Female'),
                            _buildSegmentedTab('Other'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Verified Identity Card Box
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryContainer.withAlpha(13), // 5% primary opacity
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryContainer.withAlpha(51), width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verified Identity',
                                    style: TextStyle(
                                      color: AppTheme.primaryContainer,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Building trust starts with knowing who you are. We verify all profiles to ensure the safety of our community ecosystem.',
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
                      const SizedBox(height: 16),

                      // Security Note Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            color: AppTheme.outline,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Your profile details are kept secure and used only for service matching.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.outline,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Referral Code Optional Field
                      const Text(
                        'Have a referral code? (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _referralController,
                        style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'e.g. TRUSTED123',
                          prefixIcon: const Icon(Icons.confirmation_number_outlined, color: AppTheme.outline),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                            borderSide: const BorderSide(color: AppTheme.outlineVariant, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Sticky Floating Footer Button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(242), // 95% opacity
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.outlineVariant.withAlpha(128),
                      width: 1.0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(AppTheme.containerMargin),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: ElevatedButton(
                      onPressed: _isFormValid && !_isLoading
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(AuthRegisterProfile(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  gender: _selectedGender,
                                  referral: _referralController.text.trim().isNotEmpty
                                      ? _referralController.text.trim()
                                      : null,
                                ));
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
                          borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Complete Registration',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSegmentedTab(String label) {
    final isSelected = _selectedGender == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectGender(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.roundedDefault),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryContainer : AppTheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
