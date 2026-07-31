import '../../domain/entities/gift_box_entity.dart';

class GiftBoxModel extends GiftBoxEntity {
  const GiftBoxModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.image,
    required super.color,
    required super.size,
    super.maxItems,
  });

  factory GiftBoxModel.fromJson(Map<String, dynamic> json) {
    return GiftBoxModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? 'medium',
      maxItems: json['max_items'] ?? 5,
    );
  }
}
