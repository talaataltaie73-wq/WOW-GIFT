import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String? image;
  final int productCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    this.image,
    this.productCount = 0,
  });

  @override
  List<Object?> get props => [id, name, icon, image, productCount];
}
