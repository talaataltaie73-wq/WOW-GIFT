import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../home/data/models/product_model.dart';

class ProductRemoteDataSource {
  final DioClient _dioClient;
  ProductRemoteDataSource(this._dioClient);

  Future<ProductModel> getProductDetail(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.productDetail}$id');
      return ProductModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw const ServerException('فشل تحميل تفاصيل المنتج');
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.products,
        queryParameters: {'category_id': categoryId},
      );
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل المنتجات');
    }
  }

  Future<List<ProductModel>> getProductsByStore(String storeId) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.products,
        queryParameters: {'store_id': storeId},
      );
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل المنتجات');
    }
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      await _dioClient.post('${ApiConstants.favorites}/$productId');
    } catch (e) {
      throw const ServerException('فشل تحديث المفضلة');
    }
  }
}
