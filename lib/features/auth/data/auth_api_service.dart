import '../../../core/services/api_service.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService(this._apiService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await _apiService.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'name': name,
      },
    );
    return response as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _apiService.post('/auth/logout');
  }

  Future<bool> isLoggedIn() async {
    // TODO: Implement token check
    return false;
  }
}
