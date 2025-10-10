import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final kodeController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedRole;
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://127.0.0.1:93/api/login-satker'),
      headers: {'Accept': 'application/json'},
      body: {
        'kode_satker': kodeController.text,
        'password': passwordController.text,
        'role_user': selectedRole ?? '',
      },
    );

    final data = json.decode(response.body);
    print(data);
    setState(() => isLoading = false);

    if (response.statusCode == 200 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['data']['token']);
      await prefs.setString('name', data['data']['satker']['name']);
      await prefs.setString('role_user', data['data']['satker']['roles']);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Login gagal')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Background gradasi
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB), // Ungu lembut
              Color(0xFF2575FC), // Biru cerah
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3F3EA), Color(0xFFF6F7F8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🛡️ Logo PERISAI
                      Image.asset(
                        'assets/images/perisai_logo_kemenkum.png',
                        height: 180,
                        width: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Silakan Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: kodeController,
                        decoration: InputDecoration(
                          labelText: 'Kode Satker',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Pilih Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.people_alt_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'humas_kanwil',
                            child: Text('Humas Kanwil'),
                          ),
                          DropdownMenuItem(
                            value: 'superadmin',
                            child: Text('Administrator'),
                          ),
                        ],
                        onChanged: (val) => setState(() => selectedRole = val),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2575FC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : login,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
