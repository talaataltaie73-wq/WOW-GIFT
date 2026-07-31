import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      throw const ServerException('فشل تسجيل الدخول');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      return response.data;
    } catch (e) {
      throw const ServerException('فشل إنشاء الحساب');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get(ApiConstants.profile);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw const ServerException('فشل تحميل الملف الشخصي');
    }
  }
}
