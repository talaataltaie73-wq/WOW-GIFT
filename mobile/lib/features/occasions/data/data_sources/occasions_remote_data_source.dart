import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/occasion_reminder_model.dart';

class OccasionsRemoteDataSource {
  final DioClient _dioClient;
  OccasionsRemoteDataSource(this._dioClient);

  Future<List<OccasionReminderModel>> getReminders() async {
    try {
      final response = await _dioClient.get(ApiConstants.occasionReminders);
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => OccasionReminderModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل التذكيرات');
    }
  }

  Future<OccasionReminderModel> addReminder(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post(ApiConstants.occasionReminders, data: data);
      return OccasionReminderModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw const ServerException('فشل إضافة التذكير');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _dioClient.delete('${ApiConstants.occasionReminders}/$id');
    } catch (e) {
      throw const ServerException('فشل حذف التذكير');
    }
  }
}
