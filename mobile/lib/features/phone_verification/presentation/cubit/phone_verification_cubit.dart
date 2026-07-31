import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/phone_verification_repository.dart';
import '../../domain/entities/otp_request_entity.dart';
import '../../../../core/errors/failures.dart';
import 'phone_verification_state.dart';

const bool kDevMode = true;

class PhoneVerificationCubit extends Cubit<PhoneVerificationState> {
  final PhoneVerificationRepository _repository;

  String _currentPhone = '';
  String _currentChannel = 'sms';
  String _currentRequestId = '';
  OtpRequestEntity? _lastOtpRequest;

  PhoneVerificationCubit(this._repository) : super(PhoneVerificationInitial());

  String get currentPhone => _currentPhone;
  String get currentChannel => _currentChannel;
  String get currentRequestId => _currentRequestId;
  OtpRequestEntity? get lastOtpRequest => _lastOtpRequest;

  bool isPhoneVerified() => _repository.isPhoneVerified();
  String? getVerifiedPhone() => _repository.getVerifiedPhone();

  Future<void> requestOtp({
    required String phone,
    required String channel,
  }) async {
    emit(PhoneVerificationLoading());
    _currentPhone = phone;
    _currentChannel = channel;

    final result = await _repository.requestOtp(
      phone: phone,
      channel: channel,
    );

    result.fold(
      (failure) {
        if (failure is ServerFailure && failure.statusCode == 429) {
          emit(RateLimited(60));
        } else {
          emit(PhoneVerificationError(failure.message));
        }
      },
      (otpRequest) {
        _currentRequestId = otpRequest.requestId;
        _lastOtpRequest = otpRequest;
        emit(OtpRequested(
          otpRequest: otpRequest,
          phone: phone,
          channel: channel,
        ));
      },
    );
  }

  Future<void> verifyOtp(String code) async {
    emit(OtpVerifying());

    final result = await _repository.verifyOtp(
      requestId: _currentRequestId,
      code: code,
    );

    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          if (failure.statusCode == 410) {
            emit(OtpExpired());
          } else if (failure.statusCode == 400) {
            emit(PhoneVerificationError(
              failure.message,
              statusCode: 400,
            ));
          } else if (failure.statusCode == 429) {
            emit(RateLimited(60));
          } else {
            emit(PhoneVerificationError(failure.message));
          }
        } else {
          emit(PhoneVerificationError(failure.message));
        }
      },
      (verifyResult) async {
        await _repository.refreshUserProfile();
        emit(PhoneVerified(verifyResult.phone));
      },
    );
  }

  Future<void> resendOtp({String? channel}) async {
    final useChannel = channel ?? _currentChannel;
    _currentChannel = useChannel;
    emit(OtpResending());

    final result = await _repository.requestOtp(
      phone: _currentPhone,
      channel: useChannel,
    );

    result.fold(
      (failure) {
        if (failure is ServerFailure && failure.statusCode == 429) {
          emit(RateLimited(60));
        } else {
          emit(PhoneVerificationError(failure.message));
        }
      },
      (otpRequest) {
        _currentRequestId = otpRequest.requestId;
        _lastOtpRequest = otpRequest;
        emit(OtpRequested(
          otpRequest: otpRequest,
          phone: _currentPhone,
          channel: useChannel,
        ));
      },
    );
  }

  void reset() {
    _currentPhone = '';
    _currentChannel = 'sms';
    _currentRequestId = '';
    _lastOtpRequest = null;
    emit(PhoneVerificationInitial());
  }
}
