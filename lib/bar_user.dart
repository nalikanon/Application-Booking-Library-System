// bar_user.dart
import 'package:flutter/material.dart';
import 'app_bar.dart'; // Make sure you have CustomAppBar defined in app_bar.dart

class BarUser extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  // เพิ่มพารามิเตอร์สำหรับสถานะ

  const BarUser({
    Key? key,
    required this.body,
    required this.selectedIndex,
    required this.onTap,

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
              _buildNavItem(icon: Icons.exit_to_app_rounded, index: 2, showUnderline: false),
            ],
            currentIndex: selectedIndex,
            backgroundColor: Colors.white,
            iconSize: 50,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({required IconData icon, required int index, bool showUnderline = true}) {
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (selectedIndex == index && showUnderline)
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
