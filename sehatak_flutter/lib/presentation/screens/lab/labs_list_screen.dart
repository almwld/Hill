import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LabsListScreen extends StatelessWidget {
  const LabsListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المختبرات والتحاليل', style: TextStyle(fontWeight: FontWeight.bold))),
      body: const Center(child: Text('قائمة المختبرات - قيد التطوير', style: TextStyle(fontSize: 16))),
    );
  }
}
