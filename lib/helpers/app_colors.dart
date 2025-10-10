import 'package:flutter/material.dart';

class AppColors{
  //  Warna utama aplikasi (kamu bisa sesuaikan)
  static const Color primary = Color(0xFF6A11CB); // Ungu lembut
  static const Color secondary = Color(0xFF2575FC); // Biru terang

  //  Warna gradasi (contoh untuk background)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  //  Warna teks utama
  static const Color textPrimary = Colors.black87;

  //  Warna teks di atas background gelap
  static const Color textOnPrimary = Colors.white;

  //  Warna untuk tombol logout atau aksi berbahaya
  static const Color danger = Colors.redAccent;

  // Warna latar belakang lembut (misal di Dashboard)
  static const Color backgroundWhite = Color(0xFFF8F6FC);


  // 💡 Warna latar belakang biru donker (navy blue)
  static const Color background = Color(0xFF0D1B2A);


  //  Warna abu netral untuk border atau placeholder
  static const Color neutral = Color(0xFFB0BEC5);

}