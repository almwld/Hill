import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_models/user_model.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
class OTPVerified extends AuthState {}
class PasswordResetSent extends AuthState {}

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  const LoginRequested({required this.phone, required this.password});
  @override
  List<Object?> get props => [phone, password];
}
class RegisterRequested extends AuthEvent {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String? nationalId;
  const RegisterRequested({required this.fullName, required this.phone, required this.email, required this.password, this.nationalId});
  @override
  List<Object?> get props => [fullName, phone, email, password, nationalId];
}
class LogoutRequested extends AuthEvent {}
class ForgotPasswordRequested extends AuthEvent {
  final String phone;
  const ForgotPasswordRequested(this.phone);
  @override
  List<Object?> get props => [phone];
}
class VerifyOTPRequested extends AuthEvent {
  final String phone;
  final String otp;
  const VerifyOTPRequested({required this.phone, required this.otp});
  @override
  List<Object?> get props => [phone, otp];
}
class ResetPasswordRequested extends AuthEvent {
  final String phone;
  final String otp;
  final String newPassword;
  const ResetPasswordRequested({required this.phone, required this.otp, required this.newPassword});
  @override
  List<Object?> get props => [phone, otp, newPassword];
}
class ResendOTPRequested extends AuthEvent {
  final String phone;
  const ResendOTPRequested(this.phone);
  @override
  List<Object?> get props => [phone];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyOTPRequested>(_onVerifyOTPRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ResendOTPRequested>(_onResendOTPRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // Check if user is logged in
    // final isLoggedIn = await LocalStorageService().isLoggedIn();
    // if (isLoggedIn) {
    //   final userData = LocalStorageService().getUserData();
    //   if (userData != null) {
    //     emit(AuthAuthenticated(UserModel.fromJson(userData)));
    //     return;
    //   }
    // }
    emit(AuthUnauthenticated());
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      final user = UserModel(
        id: '1',
        fullName: 'أحمد محمد',
        email: 'ahmed@example.com',
        phone: event.phone,
        userType: 'patient',
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول: $e'));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل إنشاء الحساب: $e'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل إرسال رمز التحقق: $e'));
    }
  }

  Future<void> _onVerifyOTPRequested(VerifyOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(OTPVerified());
    } catch (e) {
      emit(AuthError('رمز التحقق غير صحيح'));
    }
  }

  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError('فشل إعادة تعيين كلمة المرور'));
    }
  }

  Future<void> _onResendOTPRequested(ResendOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('فشل إعادة إرسال الرمز'));
    }
  }
}
