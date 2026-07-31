import 'package:equatable/equatable.dart';

class GiftBoxEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String color;
  final String size;
  final int maxItems;

  const GiftBoxEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.color,
    required this.size,
    this.maxItems = 5,
  });

  @override
  List<Object?> get props => [id, name, price, color, size];
}
