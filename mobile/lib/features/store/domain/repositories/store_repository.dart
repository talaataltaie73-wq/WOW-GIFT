import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/store_entity.dart';
import '../../../home/domain/entities/product_entity.dart';

abstract class StoreRepository {
  Future<Either<Failure, StoreEntity>> getStoreDetail(String id);
  Future<Either<Failure, List<StoreEntity>>> getAllStores();
  Future<Either<Failure, List<ProductEntity>>> getStoreProducts(String storeId);
}
