import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../bloc/auth_bloc/auth_bloc.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _otpSent = false;
  String? _devOtp;
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }

  void _sendOTP() async {
    if (_phoneCtrl.text.trim().length < 9) return;
    setState(() => _loading = true);
    try {
      final result = await ApiService.sendOTP(_phoneCtrl.text.trim());
      setState(() { _otpSent = true; _devOtp = result['dev_otp']?.toString(); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _verifyOTP() async {
    if (_otpCtrl.text.trim().length != 6) return;
    setState(() => _loading = true);
    try {
      final result = await ApiService.login(_phoneCtrl.text.trim(), _otpCtrl.text.trim());
      if (result['success'] == true) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: isDark ? [const Color(0xFF0B1121), const Color(0xFF1A2540)] : [Colors.white, AppColors.surfaceContainerLow])),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 30),
              Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15)]), child: const Icon(Icons.health_and_safety, color: Colors.white, size: 42)),
              const SizedBox(height: 12),
              const Text('منصة صحتك', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('الرعاية الصحية في اليمن', style: TextStyle(fontSize: 13, color: AppColors.grey)),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(14)),
                child: TabBar(controller: _tab, indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), labelColor: Colors.white, unselectedLabelColor: AppColors.grey, labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), padding: const EdgeInsets.all(4), tabs: const [Tab(text: '📱 الهاتف'), Tab(text: '📧 البريد')]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 350,
                child: TabBarView(controller: _tab, children: [
                  // تبويب الهاتف
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('تسجيل الدخول برقم الهاتف', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: 'رقم الهاتف', hintText: '777123456', prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A2540) : AppColors.surfaceContainerLow.withOpacity(0.5))),
                    const SizedBox(height: 12),
                    if (_otpSent) ...[
                      TextField(controller: _otpCtrl, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, maxLength: 6, decoration: InputDecoration(labelText: 'رمز التحقق', hintText: '6 أرقام', counterText: '', prefixIcon: const Icon(Icons.lock, color: AppColors.success), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A2540) : AppColors.surfaceContainerLow.withOpacity(0.5))),
                      if (_devOtp != null) Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Text('رمز: $_devOtp', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center)),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(height: 48, child: ElevatedButton(onPressed: _loading ? null : (_otpSent ? _verifyOTP : _sendOTP), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text(_otpSent ? 'تأكيد الرمز' : 'إرسال رمز التحقق', style: const TextStyle(fontSize: 16)))),
                    if (_otpSent) TextButton(onPressed: _sendOTP, child: const Text('إعادة الإرسال')),
                  ]),
                  // تبويب البريد
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Text('تسجيل الدخول بالإيميل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: const Icon(Icons.email_outlined, color: AppColors.info), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A2540) : AppColors.surfaceContainerLow.withOpacity(0.5))),
                    const SizedBox(height: 12),
                    TextField(controller: _passCtrl, obscureText: _obscure, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: 'كلمة المرور', prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A2540) : AppColors.surfaceContainerLow.withOpacity(0.5))),
                    const SizedBox(height: 16),
                    SizedBox(height: 48, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 16)))),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('إنشاء حساب', style: TextStyle(fontWeight: FontWeight.bold))),
                const Text('|', style: TextStyle(color: AppColors.grey)),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())), child: const Text('نسيت كلمة المرور؟')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _tab.dispose(); _phoneCtrl.dispose(); _otpCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
}
