import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // High-performance parallel startup (DotEnv, Firebase, Hive, Database)
  await AppInitializer().initialize();
  
  runApp(const MyApp());
}