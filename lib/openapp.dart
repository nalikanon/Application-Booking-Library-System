import 'package:flutter/material.dart';
import 'login.dart'; // อย่าลืม import หน้า login.dart ของคุณ

class Open_app extends StatelessWidget {
  const Open_app({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ Future.delayed เพื่อนำทางไปยังหน้า login หลังจาก 5 วินาที
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(_createRoute());
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/openapp.png'),
            fit: BoxFit.cover, // ปรับให้เต็มพื้นที่
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Login(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeIn;

        var tween = Tween<double>(begin: begin, end: end).chain(CurveTween(curve: curve));
        var opacityAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: opacityAnimation,
          child: child,
        );
      },
    );
  }
}
