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
}
class AuthUnauthenticated extends AuthState {}
class OTPSent extends AuthState {
  final String phone;
  final String? devOtp;
  const OTPSent({required this.phone, this.devOtp});
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class CheckAuth extends AuthEvent {
  @override
  List<Object?> get props => [];
}
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
class Logout extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuth>(_onCheckAuth);
    on<SendOTP>(_onSendOTP);
    on<LoginWithOTP>(_onLoginWithOTP);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuth event, Emitter<AuthState> emit) async {
    await ApiService.init();
    emit(ApiService.isLoggedIn ? AuthAuthenticated(phone: '') : AuthUnauthenticated());
  }

  Future<void> _onSendOTP(SendOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.sendOTP(event.phone);
      if (result['success'] == true) {
        emit(OTPSent(phone: event.phone, devOtp: result['dev_otp']?.toString()));
      } else {
        emit(AuthError(result['error'] ?? 'فشل الإرسال'));
      }
    } catch (e) {
      emit(AuthError('خطأ في الاتصال بالسيرفر'));
    }
  }

  Future<void> _onLoginWithOTP(LoginWithOTP event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await ApiService.login(event.phone, event.otp);
      if (result['success'] == true) {
        emit(AuthAuthenticated(phone: event.phone, name: result['user']?['name']));
      } else {
        emit(AuthError(result['error'] ?? 'رمز غير صحيح'));
      }
    } catch (e) {
      emit(AuthError('خطأ في الاتصال بالسيرفر'));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    await ApiService.logout();
    emit(AuthUnauthenticated());
  }
}
