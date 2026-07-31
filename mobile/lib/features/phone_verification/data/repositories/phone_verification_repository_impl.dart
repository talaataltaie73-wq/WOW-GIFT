import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/otp_request_entity.dart';
import '../../domain/entities/otp_verify_entity.dart';
import '../../domain/repositories/phone_verification_repository.dart';
import '../data_sources/phone_verification_remote_data_source.dart';
import '../data_sources/phone_verification_local_data_source.dart';
import '../../../auth/data/data_sources/auth_local_data_source.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../models/otp_request_model.dart';
import '../models/otp_verify_model.dart';

class PhoneVerificationRepositoryImpl implements PhoneVerificationRepository {
  final PhoneVerificationRemoteDataSource _remoteDataSource;
  final PhoneVerificationLocalDataSource _localDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final NetworkInfo _networkInfo;

  PhoneVerificationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._authLocalDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, OtpRequestEntity>> requestOtp({
    required String phone,
    required String channel,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure('لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى'));
    }
    try {
      final result = await _remoteDataSource.requestOtp(
        phone: phone,
        channel: channel,
      );
      return Either.right(result);
    } on ServerException catch (e) {
      if (e.statusCode == 429) {
        return Either.left(ServerFailure(e.message, statusCode: 429));
      }
      return Either.left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, OtpVerifyEntity>> verifyOtp({
    required String requestId,
    required String code,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
    try {
      final result = await _remoteDataSource.verifyOtp(
        requestId: requestId,
        code: code,
      );
      await saveVerificationStatus(
        verified: result.verified,
        phone: result.phone,
        verifiedAt: result.phoneVerifiedAt,
      );
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshUserProfile() async {
    if (!await _networkInfo.isConnected) {
      return Either.left(const NetworkFailure());
    }
    try {
      final user = await _remoteDataSource.getUserProfile();
      await _authLocalDataSource.saveUser(user);
      if (user.phoneVerified) {
        await saveVerificationStatus(
          verified: true,
          phone: user.phone,
          verifiedAt: user.phoneVerifiedAt ?? DateTime.now(),
        );
      }
      return Either.right(user);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  bool isPhoneVerified() {
    final localVerified = _localDataSource.isPhoneVerified();
    if (localVerified) return true;
    final user = _authLocalDataSource.getUser();
    return user?.phoneVerified ?? false;
  }

  @override
  String? getVerifiedPhone() {
    final localPhone = _localDataSource.getVerifiedPhone();
    if (localPhone != null) return localPhone;
    final user = _authLocalDataSource.getUser();
    if (user != null && user.phoneVerified) return user.phone;
    return null;
  }

  @override
  Future<void> saveVerificationStatus({
    required bool verified,
    required String phone,
    required DateTime verifiedAt,
  }) async {
    await _localDataSource.saveVerificationStatus(
      verified: verified,
      phone: phone,
      verifiedAt: verifiedAt,
    );
  }

  static OtpRequestEntity mockOtpRequest({
    required String phone,
    required String channel,
  }) {
    return OtpRequestModel(
      requestId: 'mock-request-id-${DateTime.now().millisecondsSinceEpoch}',
      phone: phone,
      channel: channel,
      expiresInSeconds: 300,
      resendAfterSeconds: 60,
      devCode: '123456',
    );
  }

  static OtpVerifyEntity mockOtpVerify(String phone) {
    return OtpVerifyModel(
      verified: true,
      phone: phone,
      phoneVerifiedAt: DateTime.now(),
    );
  }
}
