import 'package:equatable/equatable.dart';

class OtpRequestEntity extends Equatable {
  final String requestId;
  final String phone;
  final String channel;
  final int expiresInSeconds;
  final int resendAfterSeconds;
  final String? devCode;

  const OtpRequestEntity({
    required this.requestId,
    required this.phone,
    required this.channel,
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
    this.devCode,
  });

  @override
  List<Object?> get props => [requestId, phone, channel, expiresInSeconds, resendAfterSeconds, devCode];
}
