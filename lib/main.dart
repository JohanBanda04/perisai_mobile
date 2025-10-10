import 'package:flutter/material.dart';
import 'package:perisai_mobile/pages/data_master_page.dart';
import 'screens/login_page.dart';
import 'screens/dashboard_page.dart';

void main() {
  runApp(const PerisaiApp());
}

class PerisaiApp extends StatelessWidget {
  const PerisaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PERISAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/data-master': (context) => const DataMasterPage(),
      },
    );
  }
}
