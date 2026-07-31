import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../data_sources/search_remote_data_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  SearchRepositoryImpl(this._remoteDataSource, this._networkInfo);

  static final List<ProductEntity> _mockProducts = [
    ProductEntity(
      id: 's1',
      name: 'عطر فرنسي فاخر',
      description: 'عطر فرنسي أصلي برائحة خشبية مميزة تدوم طويلاً',
      price: 85000,
      discountPrice: 72000,
      images: [],
      categoryId: '1',
      categoryName: 'عطور',
      storeId: '1',
      storeName: 'متجر العطور الفاخرة',
      rating: 4.8,
      reviewCount: 124,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      id: 's2',
      name: 'باقة ورد طبيعي فاخرة',
      description: 'باقة من الورود الطبيعية المنسقة بأناقة مع تغليف فاخر',
      price: 45000,
      images: [],
      categoryId: '2',
      categoryName: 'ورود',
      storeId: '2',
      storeName: 'زهور بغداد',
      rating: 4.6,
      reviewCount: 89,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      id: 's3',
      name: 'شوكولاتة بلجيكية فاخرة',
      description: 'علبة شوكولاتة بلجيكية مشكلة بتغليف هدايا أنيق',
      price: 35000,
      discountPrice: 28000,
      images: [],
      categoryId: '3',
      categoryName: 'شوكولاتة',
      storeId: '3',
      storeName: 'حلويات الشرق',
      rating: 4.9,
      reviewCount: 203,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      id: 's4',
      name: 'ساعة يد كلاسيكية',
      description: 'ساعة يد أنيقة بتصميم كلاسيكي مع سوار جلد طبيعي',
      price: 120000,
      images: [],
      categoryId: '5',
      categoryName: 'ساعات',
      storeId: '4',
      storeName: 'ساعات النخبة',
      rating: 4.7,
      reviewCount: 67,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      id: 's5',
      name: 'طقم مجوهرات ذهبي',
      description: 'طقم مجوهرات مطلي بالذهب يتضمن سلسلة وأقراط وخاتم',
      price: 250000,
      discountPrice: 199000,
      images: [],
      categoryId: '11',
      categoryName: 'مجوهرات',
      storeId: '5',
      storeName: 'مجوهرات الماس',
      rating: 4.5,
      reviewCount: 45,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      id: 's6',
      name: 'حقيبة يد نسائية',
      description: 'حقيبة يد نسائية أنيقة من الجلد الطبيعي بتصميم عصري',
      price: 95000,
      images: [],
      categoryId: '4',
      categoryName: 'إكسسوارات',
      storeId: '6',
      storeName: 'أناقة المرأة',
      rating: 4.4,
      reviewCount: 78,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      id: 's7',
      name: 'سماعات لاسلكية احترافية',
      description: 'سماعات بلوتوث لاسلكية بجودة صوت عالية وعزل ضوضاء',
      price: 75000,
      discountPrice: 62000,
      images: [],
      categoryId: '7',
      categoryName: 'إلكترونيات',
      storeId: '7',
      storeName: 'تكنو ستور',
      rating: 4.3,
      reviewCount: 156,
      createdAt: DateTime.now(),
    ),
    ProductEntity(
      id: 's8',
      name: 'بطاقة هدية Wow Gift',
      description: 'بطاقة هدية رقمية بقيمة مختارة صالحة في جميع المتاجر',
      price: 50000,
      images: [],
      categoryId: '12',
      categoryName: 'بطاقات هدايا',
      storeId: '1',
      storeName: 'Wow Gift',
      rating: 5.0,
      reviewCount: 312,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<Either<Failure, List<ProductEntity>>> search(String query) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_filterMock(query));
    }
    try {
      final products = await _remoteDataSource.search(query);
      if (products.isEmpty) {
        return Either.right(_filterMock(query));
      }
      return Either.right(products);
    } on ServerException {
      return Either.right(_filterMock(query));
    }
  }

  List<ProductEntity> _filterMock(String query) {
    if (query.trim().isEmpty) return _mockProducts;
    final q = query.toLowerCase();
    return _mockProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.storeName.toLowerCase().contains(q);
    }).toList();
  }
}
