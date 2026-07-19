import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Get unique code from active AuthState
    final authState = context.read<AuthBloc>().state;
    String rawToken = 'USER';
    if (authState is AuthAuthenticated) {
      rawToken = authState.userProfile['id']?.toString() ?? 'USER';
    }
    
    // Generate distinct code from token payload
    final String referralCode = rawToken.length > 8 
        ? 'CARE_${rawToken.substring(rawToken.length - 8).toUpperCase()}'
        : 'CARE_${rawToken.toUpperCase()}';

    final String referralLink = 'https://caresphere.com/signup?ref=$referralCode';

    // Mock referral history list mapping
    final List<Map<String, dynamic>> referralHistory = [
      {'name': 'Aarav Sharma', 'status': 'Completed', 'bonus': '₹250'},
      {'name': 'Priya Patel', 'status': 'Pending', 'bonus': '₹0'},
      {'name': 'Amit Verma', 'status': 'Completed', 'bonus': '₹250'},
    ];

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
          'Refer & Earn',
          style: TextStyle(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Promo Presentation Box
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryContainer, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F0F5F73),
                      blurRadius: 16.0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Give ₹250, Get ₹250',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share Caresphere with your friends. Once they complete their first booking, both of you will receive ₹250 care credits.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Your Referral Code Section
              const Text(
                'YOUR REFERRAL CODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      referralCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: referralCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Referral code copied to clipboard!'),
                            backgroundColor: AppTheme.primaryContainer,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16, color: AppTheme.secondary),
                      label: const Text(
                        'Copy',
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Native Share Trigger Button
              ElevatedButton.icon(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'Join me on Caresphere! Use my code $referralCode to sign up and get ₹250 off your first service. Download now: $referralLink',
                    ),
                  );
                },
                icon: const Icon(Icons.share, size: 18, color: Colors.white),
                label: const Text(
                  'Share Referral Link',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 32),

              // 4. Referral Invites List
              const Text(
                'REFERRAL ACTIVITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: referralHistory.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.outlineVariant),
                  itemBuilder: (context, index) {
                    final item = referralHistory[index];
                    final isCompleted = item['status'] == 'Completed';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCompleted ? AppTheme.secondary : AppTheme.outline,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item['status'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? AppTheme.secondary : AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            item['bonus'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? AppTheme.primaryContainer : AppTheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
