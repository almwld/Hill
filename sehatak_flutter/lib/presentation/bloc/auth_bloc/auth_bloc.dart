import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/api_service.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final String phone;
  final String? name;
  const AuthAuthenticated({required this.phone, this.name});
  @override
  List<Object?> get props => [phone, name];
}
class AuthUnauthenticated extends AuthState {}
class OTPSent extends AuthState {
  final String phone;
  final String? devOtp;
  const OTPSent({required this.phone, this.devOtp});
  @override
  List<Object?> get props => [phone, devOtp];
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuth extends AuthEvent {}
class SendOTP extends AuthEvent {
  final String phone;
  const SendOTP(this.phone);
  @override
  List<Object?> get props => [phone];
}
class LoginWithOTP extends AuthEvent {
  final String phone;
  final String otp;
  const LoginWithOTP({required this.phone, required this.otp});
  @override
  List<Object?> get props => [phone, otp];
}
class Logout extends AuthEvent {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuth>(_onCheckAuth);
    on<SendOTP>(_onSendOTP);
    on<LoginWithOTP>(_onLoginWithOTP);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuth e, Emitter<AuthState> emit) async {
    await ApiService.init();
    emit(ApiService.isLoggedIn ? AuthAuthenticated(phone: '') : AuthUnauthenticated());
  }

  Future<void> _onSendOTP(SendOTP e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.sendOTP(e.phone);
      if (result['success'] == true) {
        emit(OTPSent(phone: e.phone, devOtp: result['dev_otp']?.toString()));
      } else {
        emit(AuthError(result['error'] ?? 'فشل الإرسال'));
      }
    } catch (ex) {
      emit(AuthError('خطأ في الاتصال'));
    }
  }

  Future<void> _onLoginWithOTP(LoginWithOTP e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.login(e.phone, e.otp);
      if (result['success'] == true) {
        emit(AuthAuthenticated(phone: e.phone));
      } else {
        emit(AuthError(result['error'] ?? 'رمز غير صحيح'));
      }
    } catch (ex) {
      emit(AuthError('خطأ في الاتصال'));
    }
  }

  Future<void> _onLogout(Logout e, Emitter<AuthState> emit) async {
    await ApiService.logout();
    emit(AuthUnauthenticated());
  }
}
