import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../gift_box/domain/entities/gift_box_entity.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;

  CartCubit(this._repository) : super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    final result = await _repository.getCart();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> addItem(ProductEntity product) async {
    final result = await _repository.addItem(product);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> removeItem(String productId) async {
    final result = await _repository.removeItem(productId);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final result = await _repository.updateQuantity(productId, quantity);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> selectBox(GiftBoxEntity box) async {
    final result = await _repository.selectBox(box);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> updateCustomization({
    String? greetingCardId,
    String? personalMessage,
    bool? isAnonymous,
    String? senderName,
  }) async {
    final result = await _repository.updateCustomization(
      greetingCardId: greetingCardId,
      personalMessage: personalMessage,
      isAnonymous: isAnonymous,
      senderName: senderName,
    );
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> clearCart() async {
    await _repository.clearCart();
    emit(CartLoaded(const CartEntity()));
  }
}
