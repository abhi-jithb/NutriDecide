import 'auth_repository.dart';
import 'entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> call(String email, String password) async {
    return _repository.login(email, password);
  }
}
