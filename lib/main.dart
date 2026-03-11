import 'package:flutter/material.dart';
import 'app.dart';
import 'core/data/food_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FoodDatabase().loadFoods();
  runApp(const MyApp());
}