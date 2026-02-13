import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

class NutriDecideApp extends StatelessWidget {
  const NutriDecideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriDecide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRouter.initial,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
