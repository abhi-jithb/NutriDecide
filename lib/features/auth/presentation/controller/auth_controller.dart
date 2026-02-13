import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  AuthController(this._authRepository);

  UserEntity? _user;
  bool _isLoading = false;
  String? _error;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    
    try {
      _user = await _authRepository.login(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    _error = null;
    
    try {
      _user = await _authRepository.register(email, password, name);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
