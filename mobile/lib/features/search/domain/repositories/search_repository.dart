import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/product_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<ProductEntity>>> search(String query);
}
