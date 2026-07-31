import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/entities/banner_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> bestDeals;
  final List<ProductEntity> latestProducts;
  final List<ProductEntity> bestSellers;
  final List<StoreEntity> featuredStores;
  final List<BannerEntity> banners;

  const HomeLoaded({
    required this.categories,
    required this.bestDeals,
    required this.latestProducts,
    required this.bestSellers,
    required this.featuredStores,
    required this.banners,
  });

  @override
  List<Object?> get props => [categories, bestDeals, latestProducts, bestSellers, featuredStores, banners];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
