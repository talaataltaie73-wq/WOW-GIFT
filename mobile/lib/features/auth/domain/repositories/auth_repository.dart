import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<Either<Failure, UserEntity>> getProfile();
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
}
