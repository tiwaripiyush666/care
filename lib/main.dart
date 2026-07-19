import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/network/supabase_client.dart';
import 'core/storage/local_storage.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/care_booking/data/repositories/provider_repository_impl.dart';
import 'features/care_booking/presentation/bloc/provider_bloc.dart';
import 'features/care_booking/data/repositories/booking_repository_impl.dart';
import 'features/care_booking/presentation/bloc/booking_bloc.dart';
import 'features/care_booking/data/repositories/chat_repository_impl.dart';
import 'features/care_booking/presentation/bloc/chat_bloc.dart';

import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_signup_screen.dart';
import 'features/auth/presentation/screens/otp_verification_screen.dart';
import 'features/registration/presentation/screens/registration_profile_details_screen.dart';
import 'features/location_selection/presentation/screens/location_selection_screen.dart';
import 'features/location_selection/presentation/screens/location_discovery_screen.dart';
import 'features/home/presentation/screens/home_hub_screen.dart';
import 'features/care_booking/presentation/screens/service_categories_screen.dart';
import 'features/care_booking/presentation/screens/service_search_discovery_screen.dart';
import 'features/care_booking/presentation/screens/provider_listing_screen.dart';
import 'features/care_booking/presentation/screens/provider_profile_screen.dart';
import 'features/care_booking/presentation/screens/booking_flow_screen.dart';
import 'features/care_booking/presentation/screens/booking_confirmation_screen.dart';
import 'features/care_booking/presentation/screens/track_booking_screen.dart';
import 'features/care_booking/presentation/screens/my_bookings_screen.dart';
import 'features/registration/presentation/screens/account_settings_screen.dart';
import 'features/registration/presentation/screens/refer_and_earn_screen.dart';
import 'features/location_selection/presentation/screens/saved_addresses_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await SupabaseClientService().initialize();
  await LocalStorageService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create Repositories
    final authRepository = AuthRepositoryImpl();
    final providerRepository = ProviderRepositoryImpl();
    final bookingRepository = BookingRepositoryImpl();
    final chatRepository = ChatRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository)..add(AuthCheckStatus()),
        ),
        BlocProvider<ProviderBloc>(
          create: (context) => ProviderBloc(providerRepository: providerRepository),
        ),
        BlocProvider<BookingBloc>(
          create: (context) => BookingBloc(bookingRepository: bookingRepository)
            ..add(LoadBookingsEvent())
            ..add(SyncOfflineBookingsEvent()),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(chatRepository: chatRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Trusted Home Support System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginSignupScreen(),
          '/otp_verification': (context) => const OtpVerificationScreen(),
          '/registration': (context) => const RegistrationProfileDetailsScreen(),
          '/location': (context) => const LocationDiscoveryScreen(),
          '/location_manual': (context) => const LocationSelectionScreen(),
          '/home': (context) => const HomeHubScreen(),
          '/service_categories': (context) => const ServiceCategoriesScreen(),
          '/search': (context) => const ServiceSearchDiscoveryScreen(),
          '/provider_listing': (context) => const ProviderListingScreen(),
          '/provider_profile': (context) => const ProviderProfileScreen(),
          '/booking_flow': (context) => const BookingFlowScreen(),
          '/booking_confirmation': (context) => const BookingConfirmationScreen(),
          '/track_booking': (context) => const TrackBookingScreen(),
          '/bookings': (context) => const MyBookingsScreen(),
          '/profile': (context) => const AccountSettingsScreen(),
          '/referral': (context) => const ReferAndEarnScreen(),
          '/saved_addresses': (context) => const SavedAddressesScreen(),
        },
      ),
    );
  }
}
