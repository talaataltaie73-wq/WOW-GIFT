import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../../home/domain/entities/store_entity.dart';

class StoreScreen extends StatefulWidget {
  final String storeId;

  const StoreScreen({super.key, required this.storeId});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late final StoreEntity _store;
  late final List<ProductEntity> _products;

  @override
  void initState() {
    super.initState();
    _store = StoreEntity(
      id: widget.storeId,
      name: 'متجر الهدايا الذهبية',
      description:
          'متجر متخصص في الهدايا الفاخرة والمميزة لجميع المناسبات. نقدم أفضل المنتجات المحلية والعالمية بأسعار منافسة مع خدمة تغليف هدايا احترافية.',
      logo: 'https://picsum.photos/seed/store_logo_d/200/200',
      coverImage: 'https://picsum.photos/seed/store_cover_d/800/400',
      rating: 4.8,
      reviewCount: 256,
      productCount: 48,
      isFeatured: true,
    );

    final names = [
      'باقة ورد طبيعية',
      'شوكولاتة بلجيكية فاخرة',
      'عطر فرنسي مميز',
      'ساعة يد أنيقة',
      'طقم أكواب سيراميك',
      'صندوق حلويات مشكلة',
      'دمية محشوة فاخرة',
      'طقم شموع معطرة',
    ];
    final prices = [35000.0, 28000.0, 95000.0, 120000.0, 22000.0, 45000.0, 18000.0, 32000.0];
    final discounts = [null, 22000.0, 79000.0, null, 18000.0, 38000.0, null, 25000.0];

    _products = List.generate(names.length, (i) {
      return ProductEntity(
        id: 'store_p_${i + 1}',
        name: names[i],
        description: 'وصف المنتج ${names[i]}',
        price: prices[i],
        discountPrice: discounts[i],
        images: [
          'https://picsum.photos/seed/storep${i + 1}/400/400',
        ],
        categoryId: 'cat_${(i % 3) + 1}',
        categoryName: 'تصنيف ${(i % 3) + 1}',
        storeId: widget.storeId,
        storeName: _store.name,
        rating: 4.0 + (i % 10) / 10,
        reviewCount: 20 + i * 12,
        isFavorite: i.isEven,
        inStock: true,
        createdAt: DateTime.now().subtract(Duration(days: i * 2)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildStoreInfo()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: _buildProductsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
        ),
      ),
      title: Text(
        _store.name,
        style: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            CachedNetworkImage(
              imageUrl: _store.coverImage ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.primaryDark,
              ),
              errorWidget: (context, url, error) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            // Store logo overlay
            Positioned(
              bottom: 16,
              right: 20,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: CachedNetworkImage(
                        imageUrl: _store.logo,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.shimmerBase,
                          child: const Icon(Icons.store, color: AppColors.textHint),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primary,
                          child: const Icon(Icons.store, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _store.name,
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      if (_store.isFeatured)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'متجر مميز',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _buildStatItem(
                icon: Icons.star_rounded,
                iconColor: AppColors.star,
                value: '${_store.rating}',
                label: '${_store.reviewCount} تقييم',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.primary,
                value: '${_store.productCount}',
                label: 'منتج',
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          // Description
          Text(
            _store.description,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 20),
          // Products section header
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'منتجات المتجر',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_products.length} منتج',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  SliverGrid _buildProductsGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _ProductCard(
            product: _products[index],
            index: index,
          );
        },
        childCount: _products.length,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  final int index;

  const _ProductCard({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/product',
          arguments: product.id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: product.mainImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.shimmerBase,
                        child: const Center(
                          child: Icon(
                            Icons.card_giftcard_rounded,
                            color: AppColors.textHint,
                            size: 32,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.shimmerBase,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textHint,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Discount badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.discount,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${product.discountPercent}%-',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Favorite icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: product.isFavorite
                            ? AppColors.discount
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: AppColors.star),
                        const SizedBox(width: 3),
                        Text(
                          '${product.rating}',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${product.reviewCount})',
                          style: GoogleFonts.tajawal(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price
                    if (product.hasDiscount)
                      Text(
                        AppUtils.formatPrice(product.price),
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: AppColors.textHint,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textHint,
                        ),
                      ),
                    Text(
                      AppUtils.formatPrice(product.effectivePrice),
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 100 * index),
        ).slideY(begin: 0.1);
  }
}
