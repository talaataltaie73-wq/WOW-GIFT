import 'package:equatable/equatable.dart';
import '../../domain/entities/otp_request_entity.dart';

abstract class PhoneVerificationState extends Equatable {
  const PhoneVerificationState();
  @override
  List<Object?> get props => [];
}

class PhoneVerificationInitial extends PhoneVerificationState {}

class PhoneVerificationLoading extends PhoneVerificationState {}

class OtpRequested extends PhoneVerificationState {
  final OtpRequestEntity otpRequest;
  final String phone;
  final String channel;

  const OtpRequested({
    required this.otpRequest,
    required this.phone,
    required this.channel,
  });

  @override
  List<Object?> get props => [otpRequest, phone, channel];
}

class OtpVerifying extends PhoneVerificationState {}

class PhoneVerified extends PhoneVerificationState {
  final String phone;

  const PhoneVerified(this.phone);

  @override
  List<Object?> get props => [phone];
}

class PhoneVerificationError extends PhoneVerificationState {
  final String message;
  final int? statusCode;
  final int? attemptsRemaining;

  const PhoneVerificationError(
    this.message, {
    this.statusCode,
    this.attemptsRemaining,
  });

  @override
  List<Object?> get props => [message, statusCode, attemptsRemaining];
}

class OtpResending extends PhoneVerificationState {}

class OtpExpired extends PhoneVerificationState {}

class RateLimited extends PhoneVerificationState {
  final int retryAfterSeconds;

  const RateLimited(this.retryAfterSeconds);

  @override
  List<Object?> get props => [retryAfterSeconds];
}
