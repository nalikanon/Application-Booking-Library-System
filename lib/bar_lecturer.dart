//bar_lecturer.dart
import 'package:flutter/material.dart';
import 'app_bar.dart';

class BarLecturer extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final String firstName; // เพิ่มพารามิเตอร์สำหรับชื่อ
  final String lastName;  // เพิ่มพารามิเตอร์สำหรับนามสกุล
  final String email;     // เพิ่มพารามิเตอร์สำหรับอีเมล
  final String role;      // เพิ่มพารามิเตอร์สำหรับสถานะ

  const BarLecturer({
    Key? key,
    required this.body,
    required this.selectedIndex,
    required this.onTap,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(

      ), // ส่งค่าที่จำเป็นไปยัง CustomAppBar
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: body, // ใช้ body ที่ส่งมา
        ),
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 75),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 15,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              _buildNavItem(icon: Icons.home, index: 0),
              _buildNavItem(icon: Icons.checklist_outlined, index: 1),
              _buildNavItem(icon: Icons.dashboard, index: 2),
              _buildNavItem(icon: Icons.exit_to_app_rounded, index: 3),
            ],
            currentIndex: selectedIndex,
            backgroundColor: Colors.white,
            iconSize: 50,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: onTap, // เรียกฟังก์ชัน onTap ที่ส่งมา
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({required IconData icon, required int index}) {
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (selectedIndex == index)
            Container(
              height: 3,
              width: 100,
              color: const Color.fromARGB(255, 154, 18, 18),
            ),
          Icon(icon, color: Colors.black),
        ],
      ),
      label: ' ',
    );
  }
}
