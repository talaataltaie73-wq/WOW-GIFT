import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String logo;
  final String? coverImage;
  final double rating;
  final int reviewCount;
  final int productCount;
  final bool isFeatured;

  const StoreEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
    this.coverImage,
    this.rating = 0,
    this.reviewCount = 0,
    this.productCount = 0,
    this.isFeatured = false,
  });

  @override
  List<Object?> get props => [id, name, rating, isFeatured];
}
