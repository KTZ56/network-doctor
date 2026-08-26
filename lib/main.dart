import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/network_provider.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NetworkDoctorApp());
}

class NetworkDoctorApp extends StatelessWidget {
  const NetworkDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NetworkProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Network Doctor',
       theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: ThemeMode.system,
        home: const DashboardScreen(),
      ),
    );
  }
}