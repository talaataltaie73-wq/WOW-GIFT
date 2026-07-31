import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../data_sources/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource, this._networkInfo);

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final data = await _remoteDataSource.login(email, password);
      final user = UserModel.fromJson(data['user']);
      await _localDataSource.saveToken(data['access_token']);
      if (data['refresh_token'] != null) {
        await _localDataSource.saveRefreshToken(data['refresh_token']);
      }
      await _localDataSource.saveUser(user);
      return Either.right(user);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final data = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      final user = UserModel.fromJson(data['user']);
      await _localDataSource.saveToken(data['access_token']);
      if (data['refresh_token'] != null) {
        await _localDataSource.saveRefreshToken(data['refresh_token']);
      }
      await _localDataSource.saveUser(user);
      return Either.right(user);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    if (!await _networkInfo.isConnected) {
      final cached = _localDataSource.getUser();
      if (cached != null) return Either.right(cached);
      return Either.left(const NetworkFailure());
    }
    try {
      final user = await _remoteDataSource.getProfile();
      await _localDataSource.saveUser(user);
      return Either.right(user);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _localDataSource.clearAuth();
    return Either.right(null);
  }

  @override
  Future<bool> isLoggedIn() async {
    return _localDataSource.isLoggedIn();
  }

  @override
  Future<String?> getToken() async {
    return _localDataSource.getToken();
  }
}
