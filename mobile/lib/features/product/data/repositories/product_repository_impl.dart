import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../data_sources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ProductRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, ProductEntity>> getProductDetail(String id) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockProduct(id));
    }
    try {
      final product = await _remoteDataSource.getProductDetail(id);
      return Either.right(product);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
      String categoryId) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockProductList());
    }
    try {
      final products = await _remoteDataSource.getProductsByCategory(categoryId);
      return Either.right(products);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(
      String storeId) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockProductList());
    }
    try {
      final products = await _remoteDataSource.getProductsByStore(storeId);
      return Either.right(products);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String productId) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(null);
    }
    try {
      await _remoteDataSource.toggleFavorite(productId);
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  ProductEntity _mockProduct(String id) {
    return ProductEntity(
      id: id,
      name: 'طقم هدية فاخر',
      description:
          'طقم هدية فاخر يحتوي على مجموعة مميزة من الشوكولاتة البلجيكية الفاخرة مع باقة ورد طبيعية وبطاقة تهنئة مخصصة. يأتي في صندوق أنيق مزين بشريط ذهبي. مناسب لجميع المناسبات السعيدة.',
      price: 75000,
      discountPrice: 59000,
      images: [
        'https://picsum.photos/seed/gift1/600/600',
        'https://picsum.photos/seed/gift2/600/600',
        'https://picsum.photos/seed/gift3/600/600',
        'https://picsum.photos/seed/gift4/600/600',
      ],
      categoryId: 'cat_1',
      categoryName: 'هدايا فاخرة',
      storeId: 'store_1',
      storeName: 'متجر الهدايا الذهبية',
      rating: 4.7,
      reviewCount: 128,
      isFavorite: false,
      inStock: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    );
  }

  List<ProductEntity> _mockProductList() {
    final names = [
      'باقة ورد طبيعية',
      'شوكولاتة بلجيكية فاخرة',
      'عطر فرنسي مميز',
      'ساعة يد أنيقة',
      'طقم أكواب سيراميك',
      'صندوق حلويات مشكلة',
    ];
    final prices = [35000.0, 28000.0, 95000.0, 120000.0, 22000.0, 45000.0];
    final discounts = [null, 22000.0, 79000.0, null, 18000.0, 38000.0];

    return List.generate(6, (i) {
      return ProductEntity(
        id: 'mock_${i + 1}',
        name: names[i],
        description: 'وصف المنتج ${names[i]} - منتج عالي الجودة مناسب للإهداء',
        price: prices[i],
        discountPrice: discounts[i],
        images: [
          'https://picsum.photos/seed/product${i + 1}/400/400',
        ],
        categoryId: 'cat_${(i % 3) + 1}',
        categoryName: 'تصنيف ${(i % 3) + 1}',
        storeId: 'store_${(i % 2) + 1}',
        storeName: i.isEven ? 'متجر الهدايا الذهبية' : 'متجر الورود',
        rating: 4.0 + (i % 10) / 10,
        reviewCount: 20 + i * 15,
        isFavorite: i.isEven,
        inStock: true,
        createdAt: DateTime.now().subtract(Duration(days: i * 3)),
      );
    });
  }
}
