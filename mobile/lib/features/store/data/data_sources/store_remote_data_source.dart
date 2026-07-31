import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../home/data/models/store_model.dart';
import '../../../home/data/models/product_model.dart';

class StoreRemoteDataSource {
  final DioClient _dioClient;
  StoreRemoteDataSource(this._dioClient);

  Future<StoreModel> getStoreDetail(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.storeDetail}$id');
      return StoreModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw const ServerException('فشل تحميل بيانات المتجر');
    }
  }

  Future<List<StoreModel>> getAllStores() async {
    try {
      final response = await _dioClient.get(ApiConstants.stores);
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => StoreModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل المتاجر');
    }
  }

  Future<List<ProductModel>> getStoreProducts(String storeId) async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.storeDetail}$storeId/products',
      );
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل منتجات المتجر');
    }
  }
}
