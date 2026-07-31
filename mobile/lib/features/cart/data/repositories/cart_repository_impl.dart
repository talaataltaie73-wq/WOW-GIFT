import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../gift_box/domain/entities/gift_box_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;
  CartEntity _cart = const CartEntity();

  CartRepositoryImpl(this._localDataSource) {
    _loadFromCache();
  }

  void _loadFromCache() {
    final cached = _localDataSource.getCart();
    if (cached != null) {
      _cart = _deserializeCart(cached);
    }
  }

  Future<void> _persist() async {
    try {
      await _localDataSource.saveCart(_serializeCart(_cart));
    } catch (_) {
      // Silently fail on cache errors
    }
  }

  Map<String, dynamic> _serializeCart(CartEntity cart) {
    return {
      'selectedBox': cart.selectedBox != null
          ? {
              'id': cart.selectedBox!.id,
              'name': cart.selectedBox!.name,
              'description': cart.selectedBox!.description,
              'price': cart.selectedBox!.price,
              'image': cart.selectedBox!.image,
              'color': cart.selectedBox!.color,
              'size': cart.selectedBox!.size,
              'maxItems': cart.selectedBox!.maxItems,
            }
          : null,
      'items': cart.items
          .map((item) => {
                'product': {
                  'id': item.product.id,
                  'name': item.product.name,
                  'description': item.product.description,
                  'price': item.product.price,
                  'discountPrice': item.product.discountPrice,
                  'images': item.product.images,
                  'categoryId': item.product.categoryId,
                  'categoryName': item.product.categoryName,
                  'storeId': item.product.storeId,
                  'storeName': item.product.storeName,
                  'rating': item.product.rating,
                  'reviewCount': item.product.reviewCount,
                  'isFavorite': item.product.isFavorite,
                  'inStock': item.product.inStock,
                  'createdAt': item.product.createdAt.toIso8601String(),
                },
                'quantity': item.quantity,
              })
          .toList(),
      'greetingCardId': cart.greetingCardId,
      'personalMessage': cart.personalMessage,
      'isAnonymous': cart.isAnonymous,
      'senderName': cart.senderName,
    };
  }

  CartEntity _deserializeCart(Map<String, dynamic> json) {
    GiftBoxEntity? box;
    if (json['selectedBox'] != null) {
      final b = json['selectedBox'] as Map<String, dynamic>;
      box = GiftBoxEntity(
        id: b['id'] ?? '',
        name: b['name'] ?? '',
        description: b['description'] ?? '',
        price: (b['price'] ?? 0).toDouble(),
        image: b['image'] ?? '',
        color: b['color'] ?? '',
        size: b['size'] ?? '',
        maxItems: b['maxItems'] ?? 5,
      );
    }

    final itemsList = (json['items'] as List?)
            ?.map((e) {
              final p = e['product'] as Map<String, dynamic>;
              final product = ProductEntity(
                id: p['id'] ?? '',
                name: p['name'] ?? '',
                description: p['description'] ?? '',
                price: (p['price'] ?? 0).toDouble(),
                discountPrice: p['discountPrice'] != null
                    ? (p['discountPrice']).toDouble()
                    : null,
                images: List<String>.from(p['images'] ?? []),
                categoryId: p['categoryId'] ?? '',
                categoryName: p['categoryName'] ?? '',
                storeId: p['storeId'] ?? '',
                storeName: p['storeName'] ?? '',
                rating: (p['rating'] ?? 0).toDouble(),
                reviewCount: p['reviewCount'] ?? 0,
                isFavorite: p['isFavorite'] ?? false,
                inStock: p['inStock'] ?? true,
                createdAt: DateTime.tryParse(p['createdAt'] ?? '') ?? DateTime.now(),
              );
              return CartItemEntity(
                product: product,
                quantity: e['quantity'] ?? 1,
              );
            })
            .toList() ??
        [];

    return CartEntity(
      selectedBox: box,
      items: itemsList,
      greetingCardId: json['greetingCardId'] as String?,
      personalMessage: json['personalMessage'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      senderName: json['senderName'] as String?,
    );
  }

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    return Either.right(_cart);
  }

  @override
  Future<Either<Failure, CartEntity>> addItem(ProductEntity product) async {
    final existingIndex =
        _cart.items.indexWhere((item) => item.product.id == product.id);

    List<CartItemEntity> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = List.from(_cart.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedItems = [..._cart.items, CartItemEntity(product: product)];
    }

    _cart = _cart.copyWith(items: updatedItems);
    await _persist();
    return Either.right(_cart);
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem(String productId) async {
    final updatedItems =
        _cart.items.where((item) => item.product.id != productId).toList();
    _cart = _cart.copyWith(items: updatedItems);
    await _persist();
    return Either.right(_cart);
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity(
      String productId, int quantity) async {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = _cart.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _cart = _cart.copyWith(items: updatedItems);
    await _persist();
    return Either.right(_cart);
  }

  @override
  Future<Either<Failure, CartEntity>> selectBox(GiftBoxEntity box) async {
    _cart = _cart.copyWith(selectedBox: box);
    await _persist();
    return Either.right(_cart);
  }

  @override
  Future<Either<Failure, CartEntity>> updateCustomization({
    String? greetingCardId,
    String? personalMessage,
    bool? isAnonymous,
    String? senderName,
  }) async {
    _cart = _cart.copyWith(
      greetingCardId: greetingCardId ?? _cart.greetingCardId,
      personalMessage: personalMessage ?? _cart.personalMessage,
      isAnonymous: isAnonymous ?? _cart.isAnonymous,
      senderName: senderName ?? _cart.senderName,
    );
    await _persist();
    return Either.right(_cart);
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    _cart = const CartEntity();
    await _localDataSource.clearCart();
    return Either.right(null);
  }
}
