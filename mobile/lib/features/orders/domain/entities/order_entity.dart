import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String id;
  final String orderNumber;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? deliveryDate;
  final String recipientName;
  final String recipientPhone;
  final String deliveryAddress;
  final List<OrderItemEntity> items;
  final String? giftBoxName;
  final String? personalMessage;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.deliveryDate,
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    required this.items,
    this.giftBoxName,
    this.personalMessage,
  });

  @override
  List<Object?> get props => [id, orderNumber, status];
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}
