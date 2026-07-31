import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_entity.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../gift_box/domain/entities/gift_box_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> addItem(ProductEntity product);
  Future<Either<Failure, CartEntity>> removeItem(String productId);
  Future<Either<Failure, CartEntity>> updateQuantity(String productId, int quantity);
  Future<Either<Failure, CartEntity>> selectBox(GiftBoxEntity box);
  Future<Either<Failure, CartEntity>> updateCustomization({
    String? greetingCardId,
    String? personalMessage,
    bool? isAnonymous,
    String? senderName,
  });
  Future<Either<Failure, void>> clearCart();
}
