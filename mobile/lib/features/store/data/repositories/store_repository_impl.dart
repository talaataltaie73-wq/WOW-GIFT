import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../data_sources/store_remote_data_source.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  StoreRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, StoreEntity>> getStoreDetail(String id) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockStore(id));
    }
    try {
      final store = await _remoteDataSource.getStoreDetail(id);
      return Either.right(store);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StoreEntity>>> getAllStores() async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockStoreList());
    }
    try {
      final stores = await _remoteDataSource.getAllStores();
      return Either.right(stores);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getStoreProducts(
      String storeId) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockStoreProducts(storeId));
    }
    try {
      final products = await _remoteDataSource.getStoreProducts(storeId);
      return Either.right(products);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  StoreEntity _mockStore(String id) {
    return StoreEntity(
      id: id,
      name: 'متجر الهدايا الذهبية',
      description:
          'متجر متخصص في الهدايا الفاخرة والمميزة لجميع المناسبات. نقدم أفضل المنتجات المحلية والعالمية بأسعار منافسة مع خدمة تغليف هدايا احترافية.',
      logo: 'https://picsum.photos/seed/store_logo/200/200',
      coverImage: 'https://picsum.photos/seed/store_cover/800/400',
      rating: 4.8,
      reviewCount: 256,
      productCount: 48,
      isFeatured: true,
    );
  }

  List<StoreEntity> _mockStoreList() {
    final names = [
      'متجر الهدايا الذهبية',
      'متجر الورود والأزهار',
      'متجر الشوكولاتة الفاخرة',
      'متجر العطور المميزة',
      'متجر الحلويات الشرقية',
      'متجر الإكسسوارات الأنيقة',
    ];
    final descriptions = [
      'هدايا فاخرة لجميع المناسبات',
      'أجمل باقات الورد الطبيعي والصناعي',
      'شوكولاتة بلجيكية وسويسرية فاخرة',
      'عطور فرنسية وعربية أصلية',
      'حلويات شرقية تقليدية وعصرية',
      'إكسسوارات وساعات أنيقة للرجال والنساء',
    ];

    return List.generate(6, (i) {
      return StoreEntity(
        id: 'store_${i + 1}',
        name: names[i],
        description: descriptions[i],
        logo: 'https://picsum.photos/seed/slogo${i + 1}/200/200',
        coverImage: 'https://picsum.photos/seed/scover${i + 1}/800/400',
        rating: 4.2 + (i % 8) / 10,
        reviewCount: 50 + i * 40,
        productCount: 15 + i * 8,
        isFeatured: i < 3,
      );
    });
  }

  List<ProductEntity> _mockStoreProducts(String storeId) {
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
        id: 'sp_${storeId}_${i + 1}',
        name: names[i],
        description: 'وصف المنتج ${names[i]} - منتج عالي الجودة مناسب للإهداء',
        price: prices[i],
        discountPrice: discounts[i],
        images: [
          'https://picsum.photos/seed/sp${storeId}_${i + 1}/400/400',
        ],
        categoryId: 'cat_${(i % 3) + 1}',
        categoryName: 'تصنيف ${(i % 3) + 1}',
        storeId: storeId,
        storeName: 'متجر الهدايا الذهبية',
        rating: 4.0 + (i % 10) / 10,
        reviewCount: 20 + i * 15,
        isFavorite: i.isEven,
        inStock: true,
        createdAt: DateTime.now().subtract(Duration(days: i * 3)),
      );
    });
  }
}
