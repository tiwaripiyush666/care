import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';

// --- Events ---
abstract class AuthEvent {}

class AuthSendOtp extends AuthEvent {
  final String phone;
  final String? deviceId;
  final String? deviceTrustToken;
  AuthSendOtp(this.phone, {this.deviceId, this.deviceTrustToken});
}

class AuthVerifyOtp extends AuthEvent {
  final String phone;
  final String token;
  final String? deviceId;
  AuthVerifyOtp(this.phone, this.token, {this.deviceId});
}

class AuthRegisterProfile extends AuthEvent {
  final String name;
  final String email;
  final String gender;
  final String? referral;
  AuthRegisterProfile({
    required this.name,
    required this.email,
    required this.gender,
    this.referral,
  });
}

class AuthCheckStatus extends AuthEvent {}

class AuthSignOut extends AuthEvent {}

// --- States ---
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phone;
  final bool silentVerification;
  final String? bypassToken;
  AuthOtpSent(this.phone, {this.silentVerification = false, this.bypassToken});
}

class AuthOtpVerified extends AuthState {
  final String phone;
  AuthOtpVerified(this.phone);
}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> userProfile;
  AuthAuthenticated(this.userProfile);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- Bloc ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthRegisterProfile>(_onRegisterProfile);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthSignOut>(_onSignOut);
  }

  Future<void> _onSendOtp(AuthSendOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.signInWithOtp(
        event.phone,
        deviceId: event.deviceId,
        deviceTrustToken: event.deviceTrustToken,
      );
      
      final isSilent = result['silent_verification'] as bool? ?? false;
      final bypassToken = result['bypass_token'] as String?;

      emit(AuthOtpSent(
        event.phone,
        silentVerification: isSilent,
        bypassToken: bypassToken,
      ));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await authRepository.verifyOtp(
        event.phone,
        event.token,
        deviceId: event.deviceId,
      );
      if (success) {
        final profile = await authRepository.getCurrentUser();
        if (profile != null && profile.containsKey('name')) {
          emit(AuthAuthenticated(profile));
        } else {
          emit(AuthOtpVerified(event.phone));
        }
      } else {
        emit(AuthError('Invalid code. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterProfile(AuthRegisterProfile event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.saveUserProfile(
        name: event.name,
        email: event.email,
        gender: event.gender,
        referral: event.referral,
      );
      final profile = await authRepository.getCurrentUser();
      if (profile != null) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthError('Failed to fetch registered profile.'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    try {
      final profile = await authRepository.getCurrentUser();
      if (profile != null && profile.containsKey('name')) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(AuthUnauthenticated());
  }
}
