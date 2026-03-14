import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/food_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FoodDatabaseService().initializeDatabase();
  runApp(const MyApp());
}