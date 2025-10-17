import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:perisai_mobile/helpers/app_colors.dart';
import 'package:perisai_mobile/helpers/api_endpoints.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? name;
  String? role;
  bool isLoggingOut = false;
  String? _pressedMenu;
  int _activeIndex = 0;

  final List<String> bannerImages = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  /// 🔹 Ambil data user dari SharedPreferences
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'User';
      role = prefs.getString('role_user') ?? '';
    });
  }

  Future<void> _confirmLogout() async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Konfirmasi Logout',
      desc: 'Apakah Anda yakin ingin keluar dari aplikasi?',
      btnCancelText: 'Batal',
      btnOkText: 'Ya, Logout',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _performLogout();
      },
      btnCancelColor: Colors.green,
      btnOkColor: Colors.redAccent,
      titleTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      descTextStyle: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
    ).show();
  }


  Future<void> _performLogout() async {
    setState(() => isLoggingOut = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.logoutSatker),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await prefs.clear();
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil Logout')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Logout: $e')),
      );
    } finally {
      setState(() => isLoggingOut = false);
    }
  }

  /// 🔹 Widget menu icon bundar (gaya OVO) + animasi bounce + font besar
  Widget buildMenuIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedMenu = label),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 150),
                () => setState(() => _pressedMenu = null));
        if (onTap != null) onTap();
      },
      onTapCancel: () => setState(() => _pressedMenu = null),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _pressedMenu == label ? 0.9 : 1.0,
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: _pressedMenu == label
                        ? AppColors.primary.withOpacity(0.4)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15, // 🔹 lebih besar & tegas
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Banner slider promosi
  Widget buildBannerCarousel() {
    return Column(
      children: [
        cs.CarouselSlider.builder(
          itemCount: bannerImages.length,
          options: cs.CarouselOptions(
            height: 170,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) =>
                setState(() => _activeIndex = index),
          ),
          itemBuilder: (context, index, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                bannerImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        AnimatedSmoothIndicator(
          activeIndex: _activeIndex,
          count: bannerImages.length,
          effect: const ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Colors.deepPurple,
            dotColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Logout',
            onPressed: isLoggingOut ? null : _confirmLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Header gradient (seperti OVO)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERISAI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selamat Datang, $name!',
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PERISAI Account',
                          style:
                          TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Aktif',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Grid Menu (rapi & adaptif)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 🔹 ubah ke 3 agar label muat lebih besar
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9, // 🔹 biar proporsional
                ),
                itemCount: (role == 'superadmin') ? 6 : 5,
                itemBuilder: (context, index) {
                  final menus = [
                    {'icon': Icons.dashboard, 'label': 'Dashboard'},
                    {'icon': Icons.group, 'label': 'Media\nPartners'},
                    {'icon': Icons.article, 'label': 'Data\nBerita'},
                    {'icon': Icons.bar_chart, 'label': 'Laporan'},
                    {'icon': Icons.settings, 'label': 'Konfigurasi'},
                  ];

                  if (role == 'superadmin') {
                    menus.add({'icon': Icons.data_object, 'label': 'Data\nMaster'});
                  }

                  final menu = menus[index];
                  return buildMenuIcon(
                    menu['icon'] as IconData,
                    menu['label'] as String,
                    onTap: () {
                      if (menu['label'] == 'Data\nMaster') {
                        Navigator.pushNamed(context, '/data-master');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Menu ${menu['label']} diklik'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Banner Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buildBannerCarousel(),
            ),
          ],
        ),
      ),
    );
  }
}
