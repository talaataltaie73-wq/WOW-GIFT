import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';
import '../models/banner_model.dart';

class HomeRemoteDataSource {
  final DioClient _dioClient;

  HomeRemoteDataSource(this._dioClient);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.get(ApiConstants.categories);
      final list = response.data['data'] as List? ?? response.data as List? ?? [];
      return list.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل التصنيفات');
    }
  }

  Future<List<ProductModel>> getBestDeals() async {
    try {
      final response = await _dioClient.get(ApiConstants.bestDeals);
      final list = response.data['data'] as List? ?? response.data as List? ?? [];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل العروض');
    }
  }

  Future<List<ProductModel>> getLatestProducts() async {
    try {
      final response = await _dioClient.get(ApiConstants.latestProducts);
      final list = response.data['data'] as List? ?? response.data as List? ?? [];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل المنتجات');
    }
  }

  Future<List<ProductModel>> getBestSellers() async {
    try {
      final response = await _dioClient.get(ApiConstants.bestSellers);
      final list = response.data['data'] as List? ?? response.data as List? ?? [];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل الأكثر مبيعاً');
    }
  }

  Future<List<StoreModel>> getFeaturedStores() async {
    try {
      final response = await _dioClient.get(ApiConstants.featuredStores);
      final list = response.data['data'] as List? ?? response.data as List? ?? [];
      return list.map((e) => StoreModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل المتاجر');
    }
  }

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _dioClient.get(ApiConstants.banners);
      final list = response.data['data'] as List? ?? response.data as List? ?? [];
      return list.map((e) => BannerModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل البانرات');
    }
  }
}
