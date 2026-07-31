import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final String storeId;
  final String storeName;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final bool inStock;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.storeId,
    required this.storeName,
    this.rating = 0,
    this.reviewCount = 0,
    this.isFavorite = false,
    this.inStock = true,
    required this.createdAt,
  });

  double get effectivePrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  int get discountPercent => hasDiscount ? ((1 - discountPrice! / price) * 100).round() : 0;
  String get mainImage => images.isNotEmpty ? images.first : '';

  @override
  List<Object?> get props => [id, name, price, discountPrice, storeId, isFavorite];
}
