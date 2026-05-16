import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/api_service.dart';
import 'package:sehatak/presentation/widgets/common_widgets.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
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
      height: 70, decoration: BoxDecoration(color: isDark ? const Color(0xFF111D33) : Colors.white, boxShadow: [BoxShadow(color: isDark ? Colors.black38 : AppColors.primary.withOpacity(0.06), blurRadius: 14)], borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _navItem(0, Icons.home_rounded, 'الرئيسية'), _navItem(1, Icons.person_search_rounded, 'الأطباء'),
        _navItem(2, Icons.local_pharmacy_rounded, 'الصيدلية'), _centerChatButton(),
        _navItem(4, Icons.calendar_month_rounded, 'المواعيد'), _navItem(5, Icons.folder_rounded, 'صحتي'), _navItem(6, Icons.grid_view_rounded, 'المزيد'),
      ])),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final sel = _currentIndex == index;
    final color = sel ? AppColors.primary : AppColors.grey;
    return GestureDetector(
      onTap: () { if (index==3||index==4||index==5) { _requireAuth(()=>setState(()=>_currentIndex=index)); } else { setState(()=>_currentIndex=index); } },
      child: AnimatedContainer(duration: const Duration(milliseconds:200), width:56, child: Column(mainAxisSize:MainAxisSize.min, mainAxisAlignment:MainAxisAlignment.center, children: [
        if(sel) Container(width:24,height:3,decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(2))),
        Icon(icon, color:color, size:22), const SizedBox(height:2),
        Text(label, style:TextStyle(fontSize:10, fontWeight:sel?FontWeight.w600:FontWeight.normal, color:color)),
      ])),
    );
  }

  Widget _centerChatButton() {
    final sel = _currentIndex == 3;
    return GestureDetector(onTap:()=>_requireAuth(()=>setState(()=>_currentIndex=3)), child:Column(mainAxisSize:MainAxisSize.min, children:[
      Container(width:48,height:48,decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),shape:BoxShape.circle,boxShadow:[BoxShadow(color:AppColors.primary.withOpacity(0.35),blurRadius:12)]),child:const Icon(Icons.chat_rounded,color:Colors.white,size:26)),
      const SizedBox(height:2), Text('الدردشة', style:TextStyle(fontSize:9, fontWeight:sel?FontWeight.w600:FontWeight.normal, color:sel?AppColors.primary:AppColors.grey)),
    ]));
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  void _reqAuth(BuildContext c, VoidCallback a) { if(ApiService.isLoggedIn){a();}else{Navigator.push(c,MaterialPageRoute(builder:(_)=>BlocProvider(create:(_)=>AuthBloc(),child:const LoginScreen())));} }
  @override
  Widget build(BuildContext context) {
    final logged = ApiService.isLoggedIn;
    return Scaffold(
      appBar: AppBar(
        title: Text(logged ? 'مرحباً، أحمد' : 'منصة صحتك', style: const TextStyle(fontSize:16, fontWeight:FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.light_mode), onPressed: (){}),
          if (!logged) TextButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BlocProvider(create:(_)=>AuthBloc(),child:const LoginScreen()))), child:const Text('تسجيل', style:TextStyle(color:AppColors.primary,fontWeight:FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(padding:const EdgeInsets.all(14), child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
        if(!logged) LoginPromptBar(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>BlocProvider(create:(_)=>AuthBloc(),child:const LoginScreen())))),
        const SizedBox(height:14), const CustomSearchBar(hint:'بحث عن خدمات، أطباء، مقالات...'), const SizedBox(height:16),
        const ServicesCarousel(), const SizedBox(height:16),
        HeroBannerCard(onTap:(){}), const SizedBox(height:22),
        Text('خدمات سريعة', style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)), const SizedBox(height:10),
        Row(mainAxisAlignment:MainAxisAlignment.spaceAround, children:[
          QuickServiceCard(icon:Icons.local_pharmacy, label:'الصيدلية', color:AppColors.success, onTap:(){}),
          QuickServiceCard(icon:Icons.emergency, label:'الطوارئ', color:AppColors.error, onTap:(){}),
          QuickServiceCard(icon:Icons.near_me, label:'بالقرب منك', color:AppColors.teal, onTap:(){}),
          QuickServiceCard(icon:Icons.shopping_cart, label:'السلة', color:AppColors.orange, onTap:(){}),
          QuickServiceCard(icon:Icons.science, label:'التحاليل', color:AppColors.purple, onTap:(){}),
        ]),
        const SizedBox(height:22),
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[Text('أفضل الأطباء', style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold)), TextButton(onPressed:(){}, child:const Text('عرض الكل ›'))]),
        DoctorCard(name:'د. علي المولد', specialty:'استشاري باطنية وأطفال', experience:'خبرة 20+ سنة', rating:4.9, reviews:328, onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>DoctorDetailsScreen(doctorId:'1')))),
        const SizedBox(height:8),
        DoctorCard(name:'د. حسن رضا', specialty:'طبيب عام', experience:'خبرة 8+ سنوات', rating:4.8, reviews:235, onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>DoctorDetailsScreen(doctorId:'2')))),
        const SizedBox(height:50),
      ])),
    );
  }
}
