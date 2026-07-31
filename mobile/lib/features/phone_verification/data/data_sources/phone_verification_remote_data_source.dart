import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/otp_request_model.dart';
import '../models/otp_verify_model.dart';
import '../../../auth/data/models/user_model.dart';

class PhoneVerificationRemoteDataSource {
  final DioClient _dioClient;

  PhoneVerificationRemoteDataSource(this._dioClient);

  Future<OtpRequestModel> requestOtp({
    required String phone,
    required String channel,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.requestOtp,
        data: {'phone': phone, 'channel': channel},
      );
      return OtpRequestModel.fromJson(response.data);
    } on ServerException catch (e) {
      if (e.statusCode == 429) {
        final data = e.message;
        throw ServerException(data, statusCode: 429);
      }
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('فشل إرسال رمز التحقق');
    }
  }

  Future<OtpVerifyModel> verifyOtp({
    required String requestId,
    required String code,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.verifyOtp,
        data: {'request_id': requestId, 'code': code},
      );
      return OtpVerifyModel.fromJson(response.data);
    } on ServerException catch (e) {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('فشل التحقق من الرمز');
    }
  }

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dioClient.get(ApiConstants.usersMe);
      return UserModel.fromJson(response.data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('فشل تحميل بيانات المستخدم');
    }
  }
}
