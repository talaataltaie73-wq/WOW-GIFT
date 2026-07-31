import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/gift_box_entity.dart';

class GiftBoxesScreen extends StatelessWidget {
  const GiftBoxesScreen({super.key});

  static const List<GiftBoxEntity> _mockBoxes = [
    GiftBoxEntity(
      id: '1',
      name: 'صندوق الأناقة',
      description: 'صندوق أنيق بتصميم فاخر مناسب لجميع المناسبات الخاصة',
      price: 25000,
      image: '',
      color: 'ذهبي',
      size: 'وسط',
      maxItems: 5,
    ),
    GiftBoxEntity(
      id: '2',
      name: 'صندوق الرومانسية',
      description: 'صندوق رومانسي باللون الأحمر مثالي لهدايا الحب والذكرى السنوية',
      price: 35000,
      image: '',
      color: 'أحمر',
      size: 'كبير',
      maxItems: 7,
    ),
    GiftBoxEntity(
      id: '3',
      name: 'صندوق الفرح',
      description: 'صندوق وردي مبهج لأعياد الميلاد والتهاني',
      price: 30000,
      image: '',
      color: 'وردي',
      size: 'وسط',
      maxItems: 5,
    ),
    GiftBoxEntity(
      id: '4',
      name: 'صندوق VIP',
      description: 'صندوق فاخر أسود بلمسات ذهبية للهدايا الاستثنائية',
      price: 75000,
      image: '',
      color: 'أسود',
      size: 'كبير',
      maxItems: 10,
    ),
    GiftBoxEntity(
      id: '5',
      name: 'صندوق الطفل',
      description: 'صندوق لطيف بألوان زاهية مخصص لهدايا الأطفال',
      price: 20000,
      image: '',
      color: 'أزرق',
      size: 'صغير',
      maxItems: 4,
    ),
    GiftBoxEntity(
      id: '6',
      name: 'صندوق المحبة',
      description: 'صندوق أخضر أنيق يعبر عن المحبة والتقدير',
      price: 28000,
      image: '',
      color: 'أخضر',
      size: 'صغير',
      maxItems: 4,
    ),
  ];

  Color _getBoxColor(String colorName) {
    switch (colorName) {
      case 'ذهبي':
        return const Color(0xFFD4AF37);
      case 'أحمر':
        return const Color(0xFFDC2626);
      case 'وردي':
        return const Color(0xFFF472B6);
      case 'أسود':
        return const Color(0xFF1F2937);
      case 'أزرق':
        return const Color(0xFF3B82F6);
      case 'أخضر':
        return const Color(0xFF16A34A);
      default:
        return AppColors.primary;
    }
  }

  void _showSelectionSheet(BuildContext context, GiftBoxEntity box) {
    final boxColor = _getBoxColor(box.color);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.background,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: boxColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        size: 32,
                        color: boxColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            box.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppUtils.formatPrice(box.price),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  box.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.palette_outlined,
                      label: box.color,
                      color: boxColor,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.straighten_outlined,
                      label: box.size,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.inventory_2_outlined,
                      label: 'حتى ${box.maxItems} منتجات',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushNamed(
                        '/products',
                        arguments: {'giftBox': box},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'اختيار هذا الصندوق',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(
            'صناديق الهدايا',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'اختر صندوق الهدية المناسب',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemCount: _mockBoxes.length,
                itemBuilder: (context, index) {
                  final box = _mockBoxes[index];
                  return _GiftBoxCard(
                    box: box,
                    boxColor: _getBoxColor(box.color),
                    onTap: () => _showSelectionSheet(context, box),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftBoxCard extends StatelessWidget {
  final GiftBoxEntity box;
  final Color boxColor;
  final VoidCallback onTap;

  const _GiftBoxCard({
    required this.box,
    required this.boxColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: boxColor.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 48,
                  color: boxColor,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      box.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      box.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Color chip and size
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: boxColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            box.color,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: boxColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            box.size,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      AppUtils.formatPrice(box.price),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
