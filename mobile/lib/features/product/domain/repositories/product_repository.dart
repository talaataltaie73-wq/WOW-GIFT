import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Either<Failure, ProductEntity>> getProductDetail(String id);
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(String categoryId);
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(String storeId);
  Future<Either<Failure, void>> toggleFavorite(String productId);
}
