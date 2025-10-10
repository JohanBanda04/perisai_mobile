import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perisai_mobile/helpers/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? name;
  String? role;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'User';
      role = prefs.getString('role_user') ?? '';
    });
  }

  Future<void> logout() async {
    setState(() => isLoggingOut = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:93/api/logout-satker'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await prefs.clear();

      setState(() => isLoggingOut = false);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Berhasil Logout')));
    } catch (e) {
      setState(() => isLoggingOut = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal Logout: $e')));
    }
  }

  /// Widget menu (icon + label)
  Widget buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: isLoggingOut ? null : logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Selamat Datang
            Text(
              'Selamat Datang, $name!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 20),

            // 🔹 Menu Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildMenuButton(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu Dashboard diklik')),
                      );
                    },
                  ),
                  buildMenuButton(
                    icon: Icons.group,
                    title: 'Data Media Partners',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu Media Partners diklik')),
                      );
                    },
                  ),
                  buildMenuButton(
                    icon: Icons.article,
                    title: 'Data Berita',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu Data Berita diklik')),
                      );
                    },
                  ),
                  buildMenuButton(
                    icon: Icons.bar_chart,
                    title: 'Laporan',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu Laporan diklik')),
                      );
                    },
                  ),
                  buildMenuButton(
                    icon: Icons.settings,
                    title: 'Konfigurasi Berita',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu Konfigurasi Berita diklik')),
                      );
                    },
                  ),

                  // ✅ Tampilkan ini hanya untuk Superadmin
                  if (role == 'superadmin')
                    buildMenuButton(
                      icon: Icons.data_object,
                      title: 'Data Master',
                      onTap: () {
                        Navigator.pushNamed(context, '/data-master');
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
