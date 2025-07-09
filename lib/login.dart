// login.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';
import 'browse_dis_staff.dart';
import 'register.dart';
import 'browseroom_user.dart';
import 'browseroom_lecturer.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Widget _currentBody;
  bool isLoginSelected = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? errorMessage;
  String? firstName;
  String? lastName;
  String? email;

  bool isWaiting = false;

  @override
  void initState() {
    super.initState();
    _currentBody = _buildLoginForm();
  }

  void _showRegister() {
    setState(() {
      _currentBody = Register();
      isLoginSelected = false;
    });
  }

  void _showLogin() {
    setState(() {
      _currentBody = _buildLoginForm();
      isLoginSelected = true;
      errorMessage = null;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          errorMessage = 'No internet connection';
        });
        return;
      }

      setState(() {
        isWaiting = true;
      });

      try {
        Uri uri = Uri.parse('http://192.168.1.111:3000/login');
        Map<String, String> account = {
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        };

        http.Response response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode(account),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          String token = response.body;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          Map<String, dynamic> payload = Jwt.parseJwt(token);
          String role = payload['role'];
          firstName = payload['first_name'];
          lastName = payload['last_name'];
          email = payload['email'];

          if (role == 'student') {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Browseroom_user()),
            );
          } else if (role == 'lecturer') {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Browseroom_lecturer()),
            );
          } else if (role == 'staff') {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Browseroom_staff()),
            );
          } else {
            setState(() {
              errorMessage = 'Unknown role';
            });
          }
        } else {
          setState(() {
            errorMessage = response.body;
          });
        }
      } on TimeoutException catch (e) {
        debugPrint(e.toString());
        setState(() {
          errorMessage = 'Timeout error, try again!';
        });
      } catch (e) {
        debugPrint(e.toString());
        setState(() {
          errorMessage = 'Unknown error, try again!';
        });
      } finally {
        setState(() {
          isWaiting = false;
        });
      }
    }
  }

  Widget _buildLoginForm() {
    return Center(
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Login',
                  style:
                      TextStyle(fontSize: 26, fontWeight: FontWeight.normal)),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isWaiting ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 154, 18, 18),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isWaiting
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('Login',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),
              // แสดงข้อความต้อนรับหลังจากล็อกอินสำเร็จ
              if (firstName != null && lastName != null && email != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                      'Welcome, $firstName $lastName! Your email is $email.',
                      style: const TextStyle(fontSize: 14)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Booking Room',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          backgroundColor: const Color.fromARGB(255, 154, 18, 18),
          actions: [
            TextButton(
                onPressed: _showLogin,
                child: _buildNavBarButton('Login', isLoginSelected)),
            TextButton(
                onPressed: _showRegister,
                child: _buildNavBarButton('Register', !isLoginSelected)),
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/room.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.xor),
                ),
              ),
            ),
            _currentBody,
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _buildNavBarButton(String title, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(color: Colors.white)),
        if (isSelected) Container(height: 2, width: 40, color: Colors.white),
      ],
    );
  }
}
