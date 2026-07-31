import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/gift_box_model.dart';

class GiftBoxRemoteDataSource {
  final DioClient _dioClient;
  GiftBoxRemoteDataSource(this._dioClient);

  Future<List<GiftBoxModel>> getGiftBoxes() async {
    try {
      final response = await _dioClient.get(ApiConstants.giftBoxes);
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => GiftBoxModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل صناديق الهدايا');
    }
  }

  Future<GiftBoxModel> getGiftBoxDetail(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.giftBoxDetail}$id');
      return GiftBoxModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw const ServerException('فشل تحميل تفاصيل الصندوق');
    }
  }
}
