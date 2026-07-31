import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  HomeRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getCategories();
        return Either.right(result);
      } on ServerException catch (_) {
        return Either.right(_mockCategories);
      }
    }
    return Either.right(_mockCategories);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestDeals() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getBestDeals();
        return Either.right(result);
      } on ServerException catch (_) {
        return Either.right(_mockBestDeals);
      }
    }
    return Either.right(_mockBestDeals);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getLatestProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getLatestProducts();
        return Either.right(result);
      } on ServerException catch (_) {
        return Either.right(_mockLatestProducts);
      }
    }
    return Either.right(_mockLatestProducts);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getBestSellers() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getBestSellers();
        return Either.right(result);
      } on ServerException catch (_) {
        return Either.right(_mockBestSellers);
      }
    }
    return Either.right(_mockBestSellers);
  }

  @override
  Future<Either<Failure, List<StoreEntity>>> getFeaturedStores() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getFeaturedStores();
        return Either.right(result);
      } on ServerException catch (_) {
        return Either.right(_mockStores);
      }
    }
    return Either.right(_mockStores);
  }

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getBanners();
        return Either.right(result);
      } on ServerException catch (_) {
        return Either.right(_mockBanners);
      }
    }
    return Either.right(_mockBanners);
  }

  // ─── Mock Data ───────────────────────────────────────────────────────

  static const List<CategoryEntity> _mockCategories = [
    CategoryEntity(id: '1', name: 'عطور', icon: '🧴', productCount: 45),
    CategoryEntity(id: '2', name: 'ورود', icon: '🌹', productCount: 32),
    CategoryEntity(id: '3', name: 'شوكولاتة', icon: '🍫', productCount: 28),
    CategoryEntity(id: '4', name: 'إكسسوارات', icon: '💍', productCount: 56),
    CategoryEntity(id: '5', name: 'ساعات', icon: '⌚', productCount: 19),
    CategoryEntity(id: '6', name: 'ملابس', icon: '👗', productCount: 67),
    CategoryEntity(id: '7', name: 'إلكترونيات', icon: '📱', productCount: 41),
    CategoryEntity(id: '8', name: 'ألعاب', icon: '🧸', productCount: 23),
    CategoryEntity(id: '9', name: 'كتب', icon: '📚', productCount: 35),
    CategoryEntity(id: '10', name: 'ديكور', icon: '🏠', productCount: 18),
    CategoryEntity(id: '11', name: 'مجوهرات', icon: '💎', productCount: 29),
    CategoryEntity(
        id: '12', name: 'بطاقات هدايا', icon: '🎁', productCount: 15),
  ];

  static final List<ProductEntity> _mockBestDeals = [
    ProductEntity(
      id: 'bd1',
      name: 'عطر ديور ساڤاج',
      description: 'عطر رجالي فاخر من ديور بتركيبة عصرية وجذابة',
      price: 125000,
      discountPrice: 89000,
      images: ['https://picsum.photos/seed/perfume1/400/400'],
      categoryId: '1',
      categoryName: 'عطور',
      storeId: 's1',
      storeName: 'متجر العطور الفاخرة',
      rating: 4.8,
      reviewCount: 124,
      inStock: true,
      createdAt: DateTime(2026, 1, 15),
    ),
    ProductEntity(
      id: 'bd2',
      name: 'باقة ورد أحمر فاخرة',
      description: 'باقة من 25 وردة حمراء طبيعية مع تغليف أنيق',
      price: 45000,
      discountPrice: 32000,
      images: ['https://picsum.photos/seed/roses1/400/400'],
      categoryId: '2',
      categoryName: 'ورود',
      storeId: 's2',
      storeName: 'زهور بغداد',
      rating: 4.6,
      reviewCount: 89,
      inStock: true,
      createdAt: DateTime(2026, 2, 10),
    ),
    ProductEntity(
      id: 'bd3',
      name: 'علبة شوكولاتة بلجيكية',
      description: 'علبة فاخرة تحتوي على 24 قطعة شوكولاتة بلجيكية متنوعة',
      price: 65000,
      discountPrice: 48000,
      images: ['https://picsum.photos/seed/choco1/400/400'],
      categoryId: '3',
      categoryName: 'شوكولاتة',
      storeId: 's3',
      storeName: 'حلويات النخبة',
      rating: 4.9,
      reviewCount: 203,
      inStock: true,
      createdAt: DateTime(2026, 3, 5),
    ),
    ProductEntity(
      id: 'bd4',
      name: 'ساعة كاسيو كلاسيكية',
      description: 'ساعة يد كلاسيكية من كاسيو بتصميم أنيق ومقاوم للماء',
      price: 85000,
      discountPrice: 62000,
      images: ['https://picsum.photos/seed/watch1/400/400'],
      categoryId: '5',
      categoryName: 'ساعات',
      storeId: 's4',
      storeName: 'ساعات الخليج',
      rating: 4.5,
      reviewCount: 67,
      inStock: true,
      createdAt: DateTime(2026, 1, 20),
    ),
  ];

  static final List<ProductEntity> _mockLatestProducts = [
    ProductEntity(
      id: 'lp1',
      name: 'سماعات أيربودز برو',
      description: 'سماعات لاسلكية بتقنية إلغاء الضوضاء وجودة صوت عالية',
      price: 175000,
      images: ['https://picsum.photos/seed/airpods1/400/400'],
      categoryId: '7',
      categoryName: 'إلكترونيات',
      storeId: 's1',
      storeName: 'متجر العطور الفاخرة',
      rating: 4.7,
      reviewCount: 156,
      inStock: true,
      createdAt: DateTime(2026, 7, 1),
    ),
    ProductEntity(
      id: 'lp2',
      name: 'دمية دب كبيرة',
      description: 'دمية دب قطيفة بحجم كبير مثالية كهدية للأطفال والكبار',
      price: 35000,
      images: ['https://picsum.photos/seed/teddy1/400/400'],
      categoryId: '8',
      categoryName: 'ألعاب',
      storeId: 's2',
      storeName: 'زهور بغداد',
      rating: 4.4,
      reviewCount: 42,
      inStock: true,
      createdAt: DateTime(2026, 7, 5),
    ),
    ProductEntity(
      id: 'lp3',
      name: 'طقم إكسسوارات ذهبي',
      description: 'طقم إكسسوارات نسائي مطلي بالذهب يتضمن سلسلة وأقراط وخاتم',
      price: 95000,
      images: ['https://picsum.photos/seed/accessory1/400/400'],
      categoryId: '4',
      categoryName: 'إكسسوارات',
      storeId: 's3',
      storeName: 'حلويات النخبة',
      rating: 4.3,
      reviewCount: 31,
      inStock: true,
      createdAt: DateTime(2026, 7, 10),
    ),
    ProductEntity(
      id: 'lp4',
      name: 'كتاب فن العيش',
      description: 'كتاب ملهم عن فن العيش والسعادة بأسلوب سلس وممتع',
      price: 18000,
      images: ['https://picsum.photos/seed/book1/400/400'],
      categoryId: '9',
      categoryName: 'كتب',
      storeId: 's4',
      storeName: 'ساعات الخليج',
      rating: 4.6,
      reviewCount: 78,
      inStock: true,
      createdAt: DateTime(2026, 7, 12),
    ),
  ];

  static final List<ProductEntity> _mockBestSellers = [
    ProductEntity(
      id: 'bs1',
      name: 'عطر شانيل نمبر 5',
      description: 'عطر نسائي كلاسيكي من شانيل برائحة زهرية فاخرة',
      price: 150000,
      discountPrice: 135000,
      images: ['https://picsum.photos/seed/chanel1/400/400'],
      categoryId: '1',
      categoryName: 'عطور',
      storeId: 's1',
      storeName: 'متجر العطور الفاخرة',
      rating: 4.9,
      reviewCount: 312,
      inStock: true,
      createdAt: DateTime(2025, 11, 1),
    ),
    ProductEntity(
      id: 'bs2',
      name: 'باقة ورد مختلطة',
      description: 'باقة ورد طبيعي مختلطة الألوان مع تنسيق احترافي',
      price: 38000,
      images: ['https://picsum.photos/seed/mixflower1/400/400'],
      categoryId: '2',
      categoryName: 'ورود',
      storeId: 's2',
      storeName: 'زهور بغداد',
      rating: 4.7,
      reviewCount: 245,
      inStock: true,
      createdAt: DateTime(2025, 12, 15),
    ),
    ProductEntity(
      id: 'bs3',
      name: 'شمعة معطرة فاخرة',
      description: 'شمعة معطرة بالفانيلا والعنبر في وعاء زجاجي أنيق',
      price: 28000,
      images: ['https://picsum.photos/seed/candle1/400/400'],
      categoryId: '10',
      categoryName: 'ديكور',
      storeId: 's3',
      storeName: 'حلويات النخبة',
      rating: 4.5,
      reviewCount: 189,
      inStock: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    ProductEntity(
      id: 'bs4',
      name: 'بطاقة هدية رقمية',
      description: 'بطاقة هدية رقمية بقيمة 50,000 دينار صالحة لجميع المتاجر',
      price: 50000,
      images: ['https://picsum.photos/seed/giftcard1/400/400'],
      categoryId: '12',
      categoryName: 'بطاقات هدايا',
      storeId: 's4',
      storeName: 'ساعات الخليج',
      rating: 4.8,
      reviewCount: 421,
      inStock: true,
      createdAt: DateTime(2026, 2, 1),
    ),
  ];

  static const List<StoreEntity> _mockStores = [
    StoreEntity(
      id: 's1',
      name: 'متجر العطور الفاخرة',
      description: 'متخصصون في أفخر العطور العالمية والعربية',
      logo: 'https://picsum.photos/seed/store1/200/200',
      coverImage: 'https://picsum.photos/seed/store1cover/800/400',
      rating: 4.8,
      reviewCount: 523,
      productCount: 120,
      isFeatured: true,
    ),
    StoreEntity(
      id: 's2',
      name: 'زهور بغداد',
      description: 'أجمل الورود والباقات الطبيعية مع توصيل سريع',
      logo: 'https://picsum.photos/seed/store2/200/200',
      coverImage: 'https://picsum.photos/seed/store2cover/800/400',
      rating: 4.6,
      reviewCount: 312,
      productCount: 85,
      isFeatured: true,
    ),
    StoreEntity(
      id: 's3',
      name: 'حلويات النخبة',
      description: 'شوكولاتة وحلويات فاخرة من أشهر الماركات العالمية',
      logo: 'https://picsum.photos/seed/store3/200/200',
      coverImage: 'https://picsum.photos/seed/store3cover/800/400',
      rating: 4.9,
      reviewCount: 678,
      productCount: 95,
      isFeatured: true,
    ),
    StoreEntity(
      id: 's4',
      name: 'ساعات الخليج',
      description: 'ساعات أصلية من أرقى الماركات العالمية بضمان حقيقي',
      logo: 'https://picsum.photos/seed/store4/200/200',
      coverImage: 'https://picsum.photos/seed/store4cover/800/400',
      rating: 4.7,
      reviewCount: 234,
      productCount: 60,
      isFeatured: true,
    ),
  ];

  static const List<BannerEntity> _mockBanners = [
    BannerEntity(
      id: 'b1',
      image: 'https://picsum.photos/seed/banner1/800/400',
      title: 'عروض الصيف الحصرية',
      subtitle: 'خصومات تصل إلى 50% على جميع العطور',
      actionUrl: '/products?category=1',
    ),
    BannerEntity(
      id: 'b2',
      image: 'https://picsum.photos/seed/banner2/800/400',
      title: 'هدايا عيد الأضحى',
      subtitle: 'اختر هديتك المثالية لأحبائك',
      actionUrl: '/products?tag=eid',
    ),
    BannerEntity(
      id: 'b3',
      image: 'https://picsum.photos/seed/banner3/800/400',
      title: 'وصل حديثاً',
      subtitle: 'تشكيلة جديدة من الشوكولاتة البلجيكية',
      actionUrl: '/products?category=3',
    ),
  ];
}
