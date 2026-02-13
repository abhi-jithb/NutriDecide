import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers ?? _defaultHeaders,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers ?? _defaultHeaders,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers ?? _defaultHeaders,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: headers ?? _defaultHeaders,
    );
    return _handleResponse(response);
  }

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}
