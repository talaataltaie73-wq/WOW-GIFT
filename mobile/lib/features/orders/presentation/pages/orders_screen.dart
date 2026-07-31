import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/order_entity.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // ── Mock Orders (inline) ─────────────────────────────────────────────

  static final List<OrderEntity> _orders = [
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
      deliveryAddress: 'بغداد، الأعظمية، شارع عمر بن عبد العزيز',
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
      deliveryAddress: 'بغداد، الجادرية، قرب جامعة بغداد',
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(
            'الطلبات',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: _orders.isEmpty ? _buildEmptyState(context) : _buildOrdersList(context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد طلبات',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم تقم بأي طلب بعد، ابدأ بتصفح الهدايا المميزة',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    final statusColor = AppUtils.getStatusColor(order.status);
    final statusLabel = AppUtils.getStatusLabel(order.status);

    return GestureDetector(
      onTap: () => _showOrderDetail(context, order),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: order number + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.orderNumber,
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            // Recipient
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  order.recipientName,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            // Gift box name
            if (order.giftBoxName != null && order.giftBoxName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.giftBoxName!,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Footer: date + total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('yyyy/MM/dd', 'ar').format(order.createdAt),
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  AppUtils.formatPrice(order.totalAmount),
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context, OrderEntity order) {
    final statusColor = AppUtils.getStatusColor(order.status);
    final statusLabel = AppUtils.getStatusLabel(order.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تفاصيل الطلب',
                            style: GoogleFonts.tajawal(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    // Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Order number & status
                          _buildDetailSection(
                            context,
                            icon: Icons.receipt_outlined,
                            title: 'معلومات الطلب',
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  'رقم الطلب',
                                  order.orderNumber,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الحالة',
                                      style: GoogleFonts.tajawal(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'تاريخ الطلب',
                                  DateFormat('yyyy/MM/dd - HH:mm', 'ar')
                                      .format(order.createdAt),
                                ),
                                if (order.deliveryDate != null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'موعد التوصيل',
                                    DateFormat('yyyy/MM/dd - HH:mm', 'ar')
                                        .format(order.deliveryDate!),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Recipient info
                          _buildDetailSection(
                            context,
                            icon: Icons.person_outline_rounded,
                            title: 'بيانات المستلم',
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  'الاسم',
                                  order.recipientName,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'الهاتف',
                                  order.recipientPhone,
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'العنوان',
                                  order.deliveryAddress,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Gift box
                          if (order.giftBoxName != null &&
                              order.giftBoxName!.isNotEmpty) ...[
                            _buildDetailSection(
                              context,
                              icon: Icons.card_giftcard_rounded,
                              title: 'صندوق الهدية',
                              iconColor: AppColors.accent,
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                    'الصندوق',
                                    order.giftBoxName!,
                                  ),
                                  if (order.personalMessage != null &&
                                      order.personalMessage!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildDetailRow(
                                      'الرسالة',
                                      order.personalMessage!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Items
                          _buildDetailSection(
                            context,
                            icon: Icons.shopping_bag_outlined,
                            title: 'المنتجات (${order.items.length})',
                            child: Column(
                              children: order.items.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          color: AppColors.textHint,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: GoogleFonts.tajawal(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'الكمية: ${item.quantity}',
                                              style: GoogleFonts.tajawal(
                                                fontSize: 12,
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        AppUtils.formatPrice(
                                            item.price * item.quantity),
                                        style: GoogleFonts.tajawal(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Total
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الإجمالي',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  AppUtils.formatPrice(order.totalAmount),
                                  style: GoogleFonts.tajawal(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
