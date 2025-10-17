import 'package:flutter/material.dart';
import 'package:perisai_mobile/pages/data_master_page.dart';
import 'package:perisai_mobile/pages/splash_page.dart';
import 'package:perisai_mobile/screens/dashboard_page.dart';
import 'package:perisai_mobile/screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PERISAI App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/data-master': (context) => const DataMasterPage(),
      },
    );
  }
}
