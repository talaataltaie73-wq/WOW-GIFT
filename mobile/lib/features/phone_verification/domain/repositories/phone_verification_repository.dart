import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/otp_request_entity.dart';
import '../entities/otp_verify_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class PhoneVerificationRepository {
  Future<Either<Failure, OtpRequestEntity>> requestOtp({
    required String phone,
    required String channel,
  });

  Future<Either<Failure, OtpVerifyEntity>> verifyOtp({
    required String requestId,
    required String code,
  });

  Future<Either<Failure, UserEntity>> refreshUserProfile();

  bool isPhoneVerified();

  String? getVerifiedPhone();

  Future<void> saveVerificationStatus({
    required bool verified,
    required String phone,
    required DateTime verifiedAt,
  });
}
