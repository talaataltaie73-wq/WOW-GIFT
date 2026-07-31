import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../gift_box/domain/entities/gift_box_entity.dart';

class CartEntity extends Equatable {
  final GiftBoxEntity? selectedBox;
  final List<CartItemEntity> items;
  final String? greetingCardId;
  final String? personalMessage;
  final bool isAnonymous;
  final String? senderName;

  const CartEntity({
    this.selectedBox,
    this.items = const [],
    this.greetingCardId,
    this.personalMessage,
    this.isAnonymous = false,
    this.senderName,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get boxPrice => selectedBox?.price ?? 0;
  double get total => subtotal + boxPrice;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartEntity copyWith({
    GiftBoxEntity? selectedBox,
    List<CartItemEntity>? items,
    String? greetingCardId,
    String? personalMessage,
    bool? isAnonymous,
    String? senderName,
  }) {
    return CartEntity(
      selectedBox: selectedBox ?? this.selectedBox,
      items: items ?? this.items,
      greetingCardId: greetingCardId ?? this.greetingCardId,
      personalMessage: personalMessage ?? this.personalMessage,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      senderName: senderName ?? this.senderName,
    );
  }

  @override
  List<Object?> get props => [selectedBox, items, greetingCardId, personalMessage, isAnonymous, senderName];
}

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.effectivePrice * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity];
}
