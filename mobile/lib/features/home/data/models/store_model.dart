import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.description,
    required super.logo,
    super.coverImage,
    super.rating,
    super.reviewCount,
    super.productCount,
    super.isFeatured,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      coverImage: json['cover_image'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      productCount: json['product_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
    );
  }
}
