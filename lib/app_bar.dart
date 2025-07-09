import 'package:flutter/material.dart';
import 'package:project_mad/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String firstName = 'Loading...';
  String lastName = 'Loading...';
  String email = 'Loading...';
  bool isWaiting = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() {
      isWaiting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.111:3000/profile'),
        headers: {'authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          firstName = data['first_name'] ?? 'N/A';
          lastName = data['last_name'] ?? 'N/A';
          email = data['email'] ?? 'N/A';
        });
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        setState(() {
          firstName = 'Error';
          lastName = 'Error';
          email = 'Error';
        });
      }
    } catch (e) {
      setState(() {
        firstName = 'Error';
        lastName = 'Error';
        email = 'Error';
      });
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('       First Name: $firstName', style: TextStyle(fontSize: 18, color: Colors.white)),
            Text('       Last Name: $lastName', style: TextStyle(fontSize: 18, color: Colors.white)),
            Text('       Email: $email', style: TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 154, 18, 18),
      toolbarHeight: 80,
    );
  }
}
