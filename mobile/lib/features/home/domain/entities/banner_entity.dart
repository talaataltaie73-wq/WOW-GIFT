import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String image;
  final String title;
  final String? subtitle;
  final String? actionUrl;

  const BannerEntity({
    required this.id,
    required this.image,
    required this.title,
    this.subtitle,
    this.actionUrl,
  });

  @override
  List<Object?> get props => [id, image, title];
}
