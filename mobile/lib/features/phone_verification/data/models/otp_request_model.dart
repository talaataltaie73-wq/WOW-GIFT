import '../../domain/entities/otp_request_entity.dart';

class OtpRequestModel extends OtpRequestEntity {
  const OtpRequestModel({
    required super.requestId,
    required super.phone,
    required super.channel,
    required super.expiresInSeconds,
    required super.resendAfterSeconds,
    super.devCode,
  });

  factory OtpRequestModel.fromJson(Map<String, dynamic> json) {
    return OtpRequestModel(
      requestId: json['request_id'] ?? '',
      phone: json['phone'] ?? '',
      channel: json['channel'] ?? 'sms',
      expiresInSeconds: json['expires_in_seconds'] ?? 300,
      resendAfterSeconds: json['resend_after_seconds'] ?? 60,
      devCode: json['dev_code'],
    );
  }
}
