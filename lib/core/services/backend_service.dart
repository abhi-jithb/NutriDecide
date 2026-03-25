import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  String get _baseUrl => dotenv.get('BACKEND_URL', fallback: 'https://nutridecide-backend.onrender.com/api');

  /// Performs a fuzzy search for regional foods (manual entry fallback)
  Future<List<Map<String, dynamic>>> searchRegionalFood(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=$query'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Backend Search Error: $e');
      return [];
    }
  }

  /// Health Check (Ping)
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl.replaceAll('/api', '')}/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
