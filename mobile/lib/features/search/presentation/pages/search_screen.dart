import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/product_entity.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;

  List<ProductEntity> _results = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  static const List<String> _popularSearches = [
    'عطر',
    'ورد',
    'شوكولاتة',
    'ساعة',
    'هدية',
  ];

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
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchController.text);
    });
  }

  void _performSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final lower = q.toLowerCase();
      final filtered = _mockProducts.where((p) {
        return p.name.toLowerCase().contains(lower) ||
            p.description.toLowerCase().contains(lower) ||
            p.categoryName.toLowerCase().contains(lower) ||
            p.storeName.toLowerCase().contains(lower);
      }).toList();

      setState(() {
        _results = filtered;
        _hasSearched = true;
        _isSearching = false;
      });
    });
  }

  void _addToRecent(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _recentSearches.remove(q);
      _recentSearches.insert(0, q);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
  }

  void _searchFromChip(String text) {
    _searchController.text = text;
    _addToRecent(text);
    _performSearch(text);
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          titleSpacing: 0,
          title: Container(
            height: 42,
            margin: const EdgeInsets.only(left: 16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              textInputAction: TextInputAction.search,
              onSubmitted: (v) {
                _addToRecent(v);
                _performSearch(v);
              },
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن هدية مميزة...',
                hintStyle: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _results = [];
                            _hasSearched = false;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textHint,
                          size: 18,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: _isSearching
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _hasSearched
                ? _buildSearchResults()
                : _buildIdleContent(),
      ),
    );
  }

  // ── Idle content: recent + popular ──

  Widget _buildIdleContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عمليات البحث الأخيرة',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _recentSearches.clear());
                  },
                  child: Text(
                    'مسح الكل',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...(_recentSearches.map((search) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.history,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  title: Text(
                    search,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() => _recentSearches.remove(search));
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                  ),
                  onTap: () => _searchFromChip(search),
                ))),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
          ],

          // Popular searches
          Text(
            'عمليات البحث الشائعة',
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((search) {
              return ActionChip(
                label: Text(
                  search,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                backgroundColor: AppColors.primary.withOpacity(0.08),
                side: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                avatar: const Icon(
                  Icons.trending_up,
                  size: 16,
                  color: AppColors.primary,
                ),
                onPressed: () => _searchFromChip(search),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Suggestion section
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: AppColors.textHint.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'ابحث عن الهدية المثالية',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'يمكنك البحث بالاسم أو الفئة أو المتجر',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search results grid ──

  Widget _buildSearchResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textHint.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب كلمات بحث مختلفة',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${_results.length} نتيجة',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final product = _results[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/product', arguments: product.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textHint,
                      size: 32,
                    ),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.discount,
                        borderRadius: BorderRadius.circular(6),
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
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: product.isFavorite
                          ? AppColors.error
                          : AppColors.textHint,
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                    const SizedBox(height: 2),
                    Text(
                      product.storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    // Price
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${_formatPrice(product.effectivePrice)} د.ع',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${_formatPrice(product.price)} د.ع',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          final starValue = i + 1;
                          if (product.rating >= starValue) {
                            return const Icon(Icons.star,
                                size: 12, color: AppColors.star);
                          } else if (product.rating >= starValue - 0.5) {
                            return const Icon(Icons.star_half,
                                size: 12, color: AppColors.star);
                          } else {
                            return const Icon(Icons.star_border,
                                size: 12, color: AppColors.star);
                          }
                        }),
                        const SizedBox(width: 3),
                        Text(
                          '(${product.reviewCount})',
                          style: GoogleFonts.tajawal(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
