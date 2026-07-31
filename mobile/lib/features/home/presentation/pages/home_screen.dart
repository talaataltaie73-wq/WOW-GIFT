import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/store_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/occasion_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_product_card.dart';
import '../widgets/store_card.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeCubit _homeCubit;
  int _selectedOccasionIndex = -1;

  static const List<String> _occasionLabels = [
    'عيد ميلاد',
    'زواج',
    'خطوبة',
    'تخرج',
    'مولود جديد',
    'عيد الأم',
    'عيد الأب',
    'عيد الحب',
    'النجاح',
    'الشكر',
    'التهنئة',
    'أخرى',
  ];

  static const List<_CategoryData> _defaultCategories = [
    _CategoryData(id: '1', name: 'عطور', icon: '🧴'),
    _CategoryData(id: '2', name: 'ورود', icon: '🌹'),
    _CategoryData(id: '3', name: 'شوكولاتة', icon: '🍫'),
    _CategoryData(id: '4', name: 'إكسسوارات', icon: '💍'),
    _CategoryData(id: '5', name: 'ساعات', icon: '⌚'),
    _CategoryData(id: '6', name: 'ملابس', icon: '👔'),
    _CategoryData(id: '7', name: 'إلكترونيات', icon: '📱'),
    _CategoryData(id: '8', name: 'ألعاب', icon: '🎮'),
    _CategoryData(id: '9', name: 'كتب', icon: '📚'),
    _CategoryData(id: '10', name: 'ديكور', icon: '🏠'),
    _CategoryData(id: '11', name: 'مجوهرات', icon: '💎'),
    _CategoryData(id: '12', name: 'بطاقات هدايا', icon: '🎁'),
  ];

  @override
  void initState() {
    super.initState();
    _homeCubit = sl.homeCubit;
    _homeCubit.loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        title: Text(
          'Wow Gift',
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/orders');
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        bloc: _homeCubit,
        builder: (context, state) {
          if (state is HomeError) {
            return _buildErrorState(state);
          }

          final isLoading = state is HomeLoading || state is HomeInitial;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => _homeCubit.loadHome(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Search bar
                  _buildSearchBar(context),
                  const SizedBox(height: 16),
                  // Banner carousel
                  if (isLoading)
                    _buildShimmerBanner()
                  else if (state is HomeLoaded)
                    PromoBannerCarousel(
                      banners: state.banners,
                      onBannerTap: (banner) {
                        if (banner.actionUrl != null && banner.actionUrl!.isNotEmpty) {
                          Navigator.of(context).pushNamed('/search');
                        }
                      },
                    ),
                  const SizedBox(height: 20),
                  // Occasion chips
                  _buildOccasionChips(),
                  const SizedBox(height: 20),
                  // Category grid
                  _buildCategorySection(state),
                  const SizedBox(height: 16),
                  // Best deals
                  SectionHeader(
                    title: 'أفضل العروض',
                    onViewAll: () {
                      Navigator.of(context).pushNamed('/search');
                    },
                  ),
                  if (isLoading)
                    _buildShimmerProductList()
                  else if (state is HomeLoaded)
                    _buildProductList(state.bestDeals),
                  const SizedBox(height: 16),
                  // Featured stores
                  SectionHeader(
                    title: 'المتاجر المميزة',
                    onViewAll: () {
                      Navigator.of(context).pushNamed('/search');
                    },
                  ),
                  if (isLoading)
                    _buildShimmerStoreList()
                  else if (state is HomeLoaded)
                    _buildStoreList(state.featuredStores),
                  const SizedBox(height: 16),
                  // Latest products
                  SectionHeader(
                    title: 'أحدث المنتجات',
                    onViewAll: () {
                      Navigator.of(context).pushNamed('/search');
                    },
                  ),
                  if (isLoading)
                    _buildShimmerProductList()
                  else if (state is HomeLoaded)
                    _buildProductList(state.latestProducts),
                  const SizedBox(height: 16),
                  // Best sellers
                  SectionHeader(
                    title: 'الأكثر مبيعاً',
                    onViewAll: () {
                      Navigator.of(context).pushNamed('/search');
                    },
                  ),
                  if (isLoading)
                    _buildShimmerProductList()
                  else if (state is HomeLoaded)
                    _buildProductList(state.bestSellers),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // Navigate to search screen
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'ابحث عن هدية مميزة...',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _occasionLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return OccasionChip(
            label: _occasionLabels[index],
            isSelected: _selectedOccasionIndex == index,
            onTap: () {
              setState(() {
                if (_selectedOccasionIndex == index) {
                  _selectedOccasionIndex = -1;
                } else {
                  _selectedOccasionIndex = index;
                }
              });
              // Navigate to occasions screen (tab index 1 in MainNavigationScreen)
              MainNavigationScreen.switchTab(context, 1);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(HomeState state) {
    List<CategoryEntity> categories;

    if (state is HomeLoaded && state.categories.isNotEmpty) {
      categories = state.categories;
    } else {
      categories = _defaultCategories
          .map((c) => CategoryEntity(
                id: c.id,
                name: c.name,
                icon: c.icon,
              ))
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length > 12 ? 12 : categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryGridItem(
            category: category,
            onTap: () {
              Navigator.of(context).pushNamed('/search');
            },
          );
        },
      ),
    );
  }

  Widget _buildProductList(List<ProductEntity> products) {
    if (products.isEmpty) {
      return _buildEmptySection();
    }
    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              // Navigate to product detail
            },
            onFavoriteTap: () {
              // Toggle favorite
            },
          );
        },
      ),
    );
  }

  Widget _buildStoreList(List<StoreEntity> stores) {
    if (stores.isEmpty) {
      return _buildEmptySection();
    }
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stores.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final store = stores[index];
          return StoreCard(
            store: store,
            onTap: () {
              // Navigate to store detail
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          height: 170,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProductList() {
    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return const ShimmerProductCard();
        },
      ),
    );
  }

  Widget _buildShimmerStoreList() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptySection() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'لا توجد بيانات حالياً',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(HomeError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل البيانات',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _homeCubit.loadHome(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(
                'إعادة المحاولة',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String id;
  final String name;
  final String icon;

  const _CategoryData({
    required this.id,
    required this.name,
    required this.icon,
  });
}
