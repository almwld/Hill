import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/api_service.dart';
import 'package:sehatak/presentation/widgets/common_widgets.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/smart_clinic/smart_clinic_screen.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/screens/payment/payment_methods.dart';
import 'package:sehatak/presentation/screens/shared/notifications_screen.dart';
import 'package:sehatak/presentation/screens/nearby_clinics/nearby_clinics_screen.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/widgets/services_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _HomeTab(), DoctorsListScreen(), PharmacyScreen(),
    ChatScreen(), PatientAppointments(), PatientDashboard(), MoreScreen(),
  ];

  void _requireAuth(VoidCallback action) {
    if (ApiService.isLoggedIn) { action(); }
    else { Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen()))); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D33) : Colors.white,
        boxShadow: [BoxShadow(color: isDark ? Colors.black38 : AppColors.primary.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, -4))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _navItem(0, Icons.home_rounded, 'الرئيسية'),
          _navItem(1, Icons.person_search_rounded, 'الأطباء'),
          _navItem(2, Icons.local_pharmacy_rounded, 'الصيدلية'),
          _centerChatButton(),
          _navItem(4, Icons.calendar_month_rounded, 'المواعيد'),
          _navItem(5, Icons.folder_rounded, 'صحتي'),
          _navItem(6, Icons.grid_view_rounded, 'المزيد'),
        ]),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    final color = selected ? AppColors.primary : AppColors.grey;
    return GestureDetector(
      onTap: () {
        if (index == 3 || index == 4 || index == 5) { _requireAuth(() => setState(() => _currentIndex = index)); }
        else { setState(() => _currentIndex = index); }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
          if (selected) Container(width: 24, height: 3, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: color)),
        ]),
      ),
    );
  }

  Widget _centerChatButton() {
    final selected = _currentIndex == 3;
    return GestureDetector(
      onTap: () => _requireAuth(() => setState(() => _currentIndex = 3)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 12)]),
          child: const Icon(Icons.chat_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 2),
        Text('الدردشة', style: TextStyle(fontSize: 9, fontWeight: selected ? FontWeight.w600 : FontWeight.normal, color: selected ? AppColors.primary : AppColors.grey)),
      ]),
    );
  }
}

// ============================================
// HOME TAB
// ============================================
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  void _requireAuth(BuildContext context, VoidCallback action) {
    if (ApiService.isLoggedIn) { action(); }
    else { Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen()))); }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ApiService.isLoggedIn;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 4),
          _appBarBtn(Icons.account_balance_wallet, AppColors.amber, 'المحفظة', () => _requireAuth(context, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())))),
          _appBarBtn(Icons.smart_toy, AppColors.primary, 'المساعد الذكي', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartClinicScreen())), isGradient: true),
          _appBarBtn(Icons.verified_user, AppColors.success, 'توثيق', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethods()))),
        ]),
        title: Text(isLoggedIn ? 'مرحباً، أحمد' : 'منصة صحتك', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          _appBarBtn(isDark ? Icons.light_mode : Icons.dark_mode, AppColors.primary, 'المظهر', () {
            final themeBloc = context.read<ThemeBloc>();
            themeBloc.add(ThemeToggleEvent());
          }),
          _appBarBtn(Icons.notifications_outlined, AppColors.primary, 'الإشعارات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), badge: '3'),
          _appBarBtn(Icons.shopping_cart_outlined, AppColors.orange, 'السلة', () => _requireAuth(context, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())))),
          _appBarBtn(Icons.workspace_premium, AppColors.purple, 'الباقات', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethods()))),
          if (!isLoggedIn)
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen()))), child: const Text('تسجيل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // شريط تسجيل الدخول
          if (!isLoggedIn)
            LoginPromptBar(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())))),

          const SizedBox(height: 14),
          const CustomSearchBar(hint: 'بحث عن خدمات، أطباء، مقالات...'),
          const SizedBox(height: 16),

          // كاروسيل الخدمات
          const ServicesCarousel(),
          const SizedBox(height: 16),

          // بانر الترحيب
          HeroBannerCard(onTap: () {}),
          const SizedBox(height: 22),

          // خدمات سريعة
          Text('خدمات سريعة', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            QuickServiceCard(icon: Icons.local_pharmacy, label: 'الصيدلية', color: AppColors.success, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PharmacyScreen()))),
            QuickServiceCard(icon: Icons.emergency, label: 'الطوارئ', color: AppColors.error, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyNumbers()))),
            QuickServiceCard(icon: Icons.near_me, label: 'بالقرب منك', color: AppColors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyClinicsScreen()))),
            QuickServiceCard(icon: Icons.shopping_cart, label: 'السلة', color: AppColors.orange, onTap: () => _requireAuth(context, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())))),
            QuickServiceCard(icon: Icons.science, label: 'التحاليل', color: AppColors.purple, onTap: () => _requireAuth(context, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LabsListScreen())))),
          ]),
          const SizedBox(height: 22),

          // أفضل الأطباء
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('أفضل الأطباء', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorsListScreen())), child: const Text('عرض الكل ›'))]),
          const SizedBox(height: 8),
          DoctorCard(name: 'د. علي المولد', specialty: 'استشاري باطنية وأطفال', experience: 'خبرة 20+ سنة', rating: 4.9, reviews: 328, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: '1')))),
          const SizedBox(height: 8),
          DoctorCard(name: 'د. حسن رضا', specialty: 'طبيب عام', experience: 'خبرة 8+ سنوات', rating: 4.8, reviews: 235, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: '2')))),
          const SizedBox(height: 8),
          DoctorCard(name: 'د. عائشة ملك', specialty: 'طبيبة جلدية', experience: 'خبرة 6+ سنوات', rating: 4.9, reviews: 189, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: '9')))),
          const SizedBox(height: 50),
        ]),
      ),
    );
  }

  Widget _appBarBtn(IconData icon, Color color, String tooltip, VoidCallback onTap, {bool isGradient = false, String? badge}) {
    return Stack(children: [
      IconButton(
        icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: isGradient ? null : color.withOpacity(0.1), gradient: isGradient ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]) : null, borderRadius: BorderRadius.circular(9), border: isGradient ? null : Border.all(color: color.withOpacity(0.2))), child: Icon(icon, color: isGradient ? Colors.white : color, size: 18)),
        onPressed: onTap, tooltip: tooltip, constraints: const BoxConstraints(),
      ),
      if (badge != null) Positioned(right: 2, top: 2, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
    ]);
  }
}
