import '../../domain/entities/otp_verify_entity.dart';

class OtpVerifyModel extends OtpVerifyEntity {
  const OtpVerifyModel({
    required super.verified,
    required super.phone,
    required super.phoneVerifiedAt,
  });

  factory OtpVerifyModel.fromJson(Map<String, dynamic> json) {
    return OtpVerifyModel(
      verified: json['verified'] ?? false,
      phone: json['phone'] ?? '',
      phoneVerifiedAt: DateTime.tryParse(json['phone_verified_at'] ?? '') ?? DateTime.now(),
    );
  }
}
