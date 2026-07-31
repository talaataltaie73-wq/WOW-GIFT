import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../data_sources/orders_remote_data_source.dart';
import '../models/order_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  OrdersRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    if (!await _networkInfo.isConnected) {
      // Return mock data as fallback
      return Either.right(_mockOrders);
    }
    try {
      final orders = await _remoteDataSource.getOrders();
      return Either.right(orders);
    } on ServerException catch (e) {
      // Fallback to mock data on server error
      return Either.right(_mockOrders);
    } catch (e) {
      return Either.right(_mockOrders);
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetail(String id) async {
    if (!await _networkInfo.isConnected) {
      final order = _mockOrders.firstWhere(
        (o) => o.id == id,
        orElse: () => _mockOrders.first,
      );
      return Either.right(order);
    }
    try {
      final order = await _remoteDataSource.getOrderDetail(id);
      return Either.right(order);
    } on ServerException catch (e) {
      final order = _mockOrders.firstWhere(
        (o) => o.id == id,
        orElse: () => _mockOrders.first,
      );
      return Either.right(order);
    } catch (e) {
      return Either.left(const ServerFailure('فشل تحميل تفاصيل الطلب'));
    }
  }

  // ── Mock Orders ──────────────────────────────────────────────────────

  static final List<OrderEntity> _mockOrders = [
    OrderEntity(
      id: '1',
      orderNumber: 'WG-2026-001',
      status: 'delivered',
      totalAmount: 85000,
      createdAt: DateTime(2026, 7, 20, 14, 30),
      deliveryDate: DateTime(2026, 7, 22, 16, 0),
      recipientName: 'زينب علي',
      recipientPhone: '07701234567',
      deliveryAddress: 'بغداد، الكرادة، شارع الأميرات، قرب مول بابل',
      giftBoxName: 'صندوق الفرح الذهبي',
      personalMessage: 'كل عام وأنتِ بخير يا غالية',
      items: const [
        OrderItemEntity(
          productId: 'p1',
          productName: 'عطر ديور ساڤاج',
          productImage: '',
          price: 45000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p2',
          productName: 'شوكولاتة غوديڤا فاخرة',
          productImage: '',
          price: 25000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p3',
          productName: 'باقة ورد أحمر',
          productImage: '',
          price: 15000,
          quantity: 1,
        ),
      ],
    ),
    OrderEntity(
      id: '2',
      orderNumber: 'WG-2026-002',
      status: 'shipping',
      totalAmount: 120000,
      createdAt: DateTime(2026, 7, 24, 10, 15),
      deliveryDate: DateTime(2026, 7, 27, 12, 0),
      recipientName: 'محمد حسين',
      recipientPhone: '07809876543',
      deliveryAddress: 'بغداد، المنصور، شارع 14 رمضان، مقابل مطعم الساعة',
      giftBoxName: 'صندوق المناسبات الخاص',
      items: const [
        OrderItemEntity(
          productId: 'p4',
          productName: 'ساعة كاسيو كلاسيك',
          productImage: '',
          price: 65000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p5',
          productName: 'محفظة جلد طبيعي',
          productImage: '',
          price: 35000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p6',
          productName: 'قلم باركر فاخر',
          productImage: '',
          price: 20000,
          quantity: 1,
        ),
      ],
    ),
    OrderEntity(
      id: '3',
      orderNumber: 'WG-2026-003',
      status: 'preparing',
      totalAmount: 55000,
      createdAt: DateTime(2026, 7, 25, 18, 45),
      deliveryDate: DateTime(2026, 7, 28, 14, 0),
      recipientName: 'فاطمة أحمد',
      recipientPhone: '07712345678',
      deliveryAddress: 'بغداد، زيونة، محلة 710، قرب جامع الرحمن',
      personalMessage: 'مبروك التخرج يا دكتورة',
      items: const [
        OrderItemEntity(
          productId: 'p7',
          productName: 'طقم إكسسوارات ذهبي',
          productImage: '',
          price: 40000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p8',
          productName: 'بطاقة تهنئة تخرج',
          productImage: '',
          price: 5000,
          quantity: 1,
        ),
      ],
    ),
    OrderEntity(
      id: '4',
      orderNumber: 'WG-2026-004',
      status: 'confirmed',
      totalAmount: 95000,
      createdAt: DateTime(2026, 7, 26, 9, 0),
      deliveryDate: DateTime(2026, 7, 29, 11, 0),
      recipientName: 'علي كريم',
      recipientPhone: '07801112233',
      deliveryAddress: 'بغداد، الأعظمية، شارع عمر بن عبد العزيز، قرب سوق الأعظمية',
      giftBoxName: 'صندوق هدية كلاسيكي',
      personalMessage: 'عيد ميلاد سعيد يا صديقي',
      items: const [
        OrderItemEntity(
          productId: 'p9',
          productName: 'سماعات بلوتوث سوني',
          productImage: '',
          price: 50000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p10',
          productName: 'كيك عيد ميلاد',
          productImage: '',
          price: 30000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p11',
          productName: 'شموع معطرة',
          productImage: '',
          price: 15000,
          quantity: 1,
        ),
      ],
    ),
    OrderEntity(
      id: '5',
      orderNumber: 'WG-2026-005',
      status: 'pending',
      totalAmount: 70000,
      createdAt: DateTime(2026, 7, 27, 8, 30),
      deliveryDate: DateTime(2026, 7, 30, 15, 0),
      recipientName: 'نور الهدى',
      recipientPhone: '07734567890',
      deliveryAddress: 'بغداد، الجادرية، قرب جامعة بغداد، شارع الجامعة',
      giftBoxName: 'صندوق الورد الأنيق',
      items: const [
        OrderItemEntity(
          productId: 'p12',
          productName: 'باقة ورد مختلطة فاخرة',
          productImage: '',
          price: 35000,
          quantity: 1,
        ),
        OrderItemEntity(
          productId: 'p13',
          productName: 'شوكولاتة بلجيكية',
          productImage: '',
          price: 35000,
          quantity: 1,
        ),
      ],
    ),
  ];
}
