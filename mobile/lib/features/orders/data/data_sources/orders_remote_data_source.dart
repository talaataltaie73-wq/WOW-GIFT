import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/order_model.dart';

class OrdersRemoteDataSource {
  final DioClient _dioClient;
  OrdersRemoteDataSource(this._dioClient);

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dioClient.get(ApiConstants.orders);
      final list = response.data['data'] as List? ?? [];
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('فشل تحميل الطلبات');
    }
  }

  Future<OrderModel> getOrderDetail(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.orderDetail}$id');
      return OrderModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw const ServerException('فشل تحميل تفاصيل الطلب');
    }
  }
}
