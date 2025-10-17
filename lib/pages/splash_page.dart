import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perisai_mobile/helpers/api_endpoints.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  /// 🔍 Periksa token di SharedPreferences + validasi ke server
  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 1)); // efek transisi

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      _goToLogin();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.user),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // ✅ Token masih valid
        _goToDashboard();
      } else {
        // ❌ Token invalid → hapus dan ke login
        await prefs.clear();
        _goToLogin();
      }
    } catch (e) {
      debugPrint('Gagal memeriksa token: $e');
      _goToLogin();
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/');
  }

  /// 🌈 Tampilan Splash Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade700,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shield, size: 80, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
