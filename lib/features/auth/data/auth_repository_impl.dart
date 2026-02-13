import '../domain/auth_repository.dart';
import '../domain/entities/user_entity.dart';
import 'auth_api_service.dart';
import 'models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<UserEntity> login(String email, String password) async {
    final response = await _authApiService.login(email, password);
    return UserModel.fromJson(response);
  }

  @override
  Future<UserEntity> register(String email, String password, String name) async {
    final response = await _authApiService.register(email, password, name);
    return UserModel.fromJson(response);
  }

  @override
  Future<void> logout() async {
    await _authApiService.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _authApiService.isLoggedIn();
  }
}
