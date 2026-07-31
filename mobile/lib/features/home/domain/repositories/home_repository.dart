import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../entities/store_entity.dart';
import '../entities/banner_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<ProductEntity>>> getBestDeals();
  Future<Either<Failure, List<ProductEntity>>> getLatestProducts();
  Future<Either<Failure, List<ProductEntity>>> getBestSellers();
  Future<Either<Failure, List<StoreEntity>>> getFeaturedStores();
  Future<Either<Failure, List<BannerEntity>>> getBanners();
}
