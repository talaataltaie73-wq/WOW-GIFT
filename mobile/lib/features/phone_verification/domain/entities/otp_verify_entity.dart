import 'package:equatable/equatable.dart';

class OtpVerifyEntity extends Equatable {
  final bool verified;
  final String phone;
  final DateTime phoneVerifiedAt;

  const OtpVerifyEntity({
    required this.verified,
    required this.phone,
    required this.phoneVerifiedAt,
  });

  @override
  List<Object?> get props => [verified, phone, phoneVerifiedAt];
}
