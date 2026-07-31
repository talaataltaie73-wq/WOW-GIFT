import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit(this._repository) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getBestDeals(),
        _repository.getLatestProducts(),
        _repository.getBestSellers(),
        _repository.getFeaturedStores(),
        _repository.getBanners(),
      ]);

      final categories = results[0].fold((f) => [], (r) => r);
      final bestDeals = results[1].fold((f) => [], (r) => r);
      final latestProducts = results[2].fold((f) => [], (r) => r);
      final bestSellers = results[3].fold((f) => [], (r) => r);
      final featuredStores = results[4].fold((f) => [], (r) => r);
      final banners = results[5].fold((f) => [], (r) => r);

      emit(HomeLoaded(
        categories: List.from(categories),
        bestDeals: List.from(bestDeals),
        latestProducts: List.from(latestProducts),
        bestSellers: List.from(bestSellers),
        featuredStores: List.from(featuredStores),
        banners: List.from(banners),
      ));
    } catch (e) {
      emit(const HomeError('فشل تحميل البيانات'));
    }
  }

  Future<void> refresh() async {
    await loadHome();
  }
}
