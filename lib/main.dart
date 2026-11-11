import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GlamStudioApp());
}

/// Alias de compatibilidad con el proyecto original.
typedef TechStoreApp = GlamStudioApp;

/// Aplicación principal Glam Studio - Tienda Virtual de Maquillaje y Belleza.
/// Desarrollada en Flutter para Android y Web con el sistema de diseño Haute Beauté.
class GlamStudioApp extends StatelessWidget {
  const GlamStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glam Studio - Tienda de Maquillaje y Belleza',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
