import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../home/data/models/product_model.dart';

class SearchRemoteDataSource {
  final DioClient _dioClient;
  SearchRemoteDataSource(this._dioClient);

  Future<List<ProductModel>> search(String query) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.search,
        queryParameters: {'q': query},
      );
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل البحث');
    }
  }
}
