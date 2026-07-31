import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.status,
    required super.totalAmount,
    required super.createdAt,
    super.deliveryDate,
    required super.recipientName,
    required super.recipientPhone,
    required super.deliveryAddress,
    required super.items,
    super.giftBoxName,
    super.personalMessage,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      deliveryDate: json['delivery_date'] != null ? DateTime.tryParse(json['delivery_date']) : null,
      recipientName: json['recipient_name'] ?? '',
      recipientPhone: json['recipient_phone'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      items: (json['items'] as List? ?? []).map((e) => OrderItemModel.fromJson(e)).toList(),
      giftBoxName: json['gift_box_name'],
      personalMessage: json['personal_message'],
    );
  }
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}
