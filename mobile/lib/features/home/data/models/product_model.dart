import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.discountPrice,
    required super.images,
    required super.categoryId,
    required super.categoryName,
    required super.storeId,
    required super.storeName,
    super.rating,
    super.reviewCount,
    super.isFavorite,
    super.inStock,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discount_price'] != null ? (json['discount_price']).toDouble() : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? json['category']?['name'] ?? '',
      storeId: json['store_id']?.toString() ?? '',
      storeName: json['store_name'] ?? json['store']?['name'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isFavorite: json['is_favorite'] ?? false,
      inStock: json['in_stock'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
