import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../../features/auth/data/data_sources/auth_local_data_source.dart';
import '../../features/auth/data/data_sources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/data/data_sources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/product/data/data_sources/product_remote_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/store/data/data_sources/store_remote_data_source.dart';
import '../../features/store/data/repositories/store_repository_impl.dart';
import '../../features/store/domain/repositories/store_repository.dart';
import '../../features/gift_box/data/data_sources/gift_box_remote_data_source.dart';
import '../../features/gift_box/data/repositories/gift_box_repository_impl.dart';
import '../../features/gift_box/domain/repositories/gift_box_repository.dart';
import '../../features/cart/data/data_sources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/orders/data/data_sources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/occasions/data/data_sources/occasions_remote_data_source.dart';
import '../../features/occasions/data/repositories/occasions_repository_impl.dart';
import '../../features/occasions/domain/repositories/occasions_repository.dart';
import '../../features/search/data/data_sources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/phone_verification/data/data_sources/phone_verification_remote_data_source.dart';
import '../../features/phone_verification/data/data_sources/phone_verification_local_data_source.dart';
import '../../features/phone_verification/data/repositories/phone_verification_repository_impl.dart';
import '../../features/phone_verification/domain/repositories/phone_verification_repository.dart';
import '../../features/phone_verification/presentation/cubit/phone_verification_cubit.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late SharedPreferences prefs;
  late DioClient dioClient;
  late NetworkInfo networkInfo;

  // Data sources
  late AuthLocalDataSource authLocalDataSource;

  // Repositories
  late AuthRepository authRepository;
  late HomeRepository homeRepository;
  late ProductRepository productRepository;
  late StoreRepository storeRepository;
  late GiftBoxRepository giftBoxRepository;
  late CartRepository cartRepository;
  late OrdersRepository ordersRepository;
  late OccasionsRepository occasionsRepository;
  late SearchRepository searchRepository;
  late PhoneVerificationRepository phoneVerificationRepository;

  // Cubits
  late AuthCubit authCubit;
  late HomeCubit homeCubit;
  late CartCubit cartCubit;
  late PhoneVerificationCubit phoneVerificationCubit;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    dioClient = DioClient(prefs);
    networkInfo = NetworkInfo(Connectivity());

    // Data sources
    final authRemote = AuthRemoteDataSource(dioClient);
    authLocalDataSource = AuthLocalDataSource(prefs);
    final homeRemote = HomeRemoteDataSource(dioClient);
    final productRemote = ProductRemoteDataSource(dioClient);
    final storeRemote = StoreRemoteDataSource(dioClient);
    final giftBoxRemote = GiftBoxRemoteDataSource(dioClient);
    final cartLocal = CartLocalDataSource(prefs);
    final ordersRemote = OrdersRemoteDataSource(dioClient);
    final occasionsRemote = OccasionsRemoteDataSource(dioClient);
    final searchRemote = SearchRemoteDataSource(dioClient);
    final phoneVerificationRemote = PhoneVerificationRemoteDataSource(dioClient);
    final phoneVerificationLocal = PhoneVerificationLocalDataSource(prefs);

    // Repositories
    authRepository = AuthRepositoryImpl(authRemote, authLocalDataSource, networkInfo);
    homeRepository = HomeRepositoryImpl(homeRemote, networkInfo);
    productRepository = ProductRepositoryImpl(productRemote, networkInfo);
    storeRepository = StoreRepositoryImpl(storeRemote, networkInfo);
    giftBoxRepository = GiftBoxRepositoryImpl(giftBoxRemote, networkInfo);
    cartRepository = CartRepositoryImpl(cartLocal);
    ordersRepository = OrdersRepositoryImpl(ordersRemote, networkInfo);
    occasionsRepository = OccasionsRepositoryImpl(occasionsRemote, networkInfo);
    searchRepository = SearchRepositoryImpl(searchRemote, networkInfo);
    phoneVerificationRepository = PhoneVerificationRepositoryImpl(
      phoneVerificationRemote,
      phoneVerificationLocal,
      authLocalDataSource,
      networkInfo,
    );

    // Cubits
    authCubit = AuthCubit(authRepository);
    homeCubit = HomeCubit(homeRepository);
    cartCubit = CartCubit(cartRepository);
    phoneVerificationCubit = PhoneVerificationCubit(phoneVerificationRepository);
  }
}

final sl = ServiceLocator();
