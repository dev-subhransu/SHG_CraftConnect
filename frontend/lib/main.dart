import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/ui/features/navigation/views/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArtisanCommerceApp());
}

class ArtisanCommerceApp extends StatelessWidget {
  const ArtisanCommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHG Artisan CraftConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}
