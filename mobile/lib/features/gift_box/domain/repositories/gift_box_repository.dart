import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/gift_box_entity.dart';

abstract class GiftBoxRepository {
  Future<Either<Failure, List<GiftBoxEntity>>> getGiftBoxes();
  Future<Either<Failure, GiftBoxEntity>> getGiftBoxDetail(String id);
}
