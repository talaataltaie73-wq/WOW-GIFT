import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/occasion_reminder_entity.dart';

class OccasionsScreen extends StatefulWidget {
  const OccasionsScreen({super.key});

  @override
  State<OccasionsScreen> createState() => _OccasionsScreenState();
}

class _OccasionsScreenState extends State<OccasionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Reminders tab state ──
  List<OccasionReminderEntity> _reminders = [];
  bool _remindersLoading = true;
  int _nextId = 5;

  // ── AI Assistant tab state ──
  String _selectedOccasion = 'عيد ميلاد';
  final TextEditingController _recipientController = TextEditingController();
  String _selectedGender = 'ذكر';
  double _selectedAge = 25;
  RangeValues _budgetRange = const RangeValues(50000, 200000);
  final Set<String> _selectedInterests = {};
  bool _showSuggestions = false;
  bool _suggestionsLoading = false;

  static const List<String> _occasionTypes = [
    'عيد ميلاد',
    'زواج',
    'خطوبة',
    'تخرج',
    'مولود جديد',
    'عيد الأم',
    'عيد الأب',
    'عيد الحب',
    'النجاح',
    'أخرى',
  ];

  static const List<String> _relationOptions = [
    'أم',
    'أب',
    'زوج/ة',
    'أخ/أخت',
    'صديق/ة',
    'زميل',
    'أخرى',
  ];

  static const List<int> _noticeDaysOptions = [1, 3, 7, 14, 30];

  static const List<String> _interestOptions = [
    'رياضة',
    'قراءة',
    'طبخ',
    'سفر',
    'تكنولوجيا',
    'موضة',
    'فن',
    'موسيقى',
    'ألعاب',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMockReminders();
  }

  void _loadMockReminders() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _reminders = [
          OccasionReminderEntity(
            id: '1',
            name: 'عيد ميلاد أمي',
            date: DateTime.now().add(const Duration(days: 12)),
            relation: 'أم',
            advanceNoticeDays: 7,
            notes: 'تحب العطور والورود',
          ),
          OccasionReminderEntity(
            id: '2',
            name: 'ذكرى زواج أبي وأمي',
            date: DateTime.now().add(const Duration(days: 30)),
            relation: 'أب',
            advanceNoticeDays: 14,
            notes: 'يفضل الساعات الكلاسيكية',
          ),
          OccasionReminderEntity(
            id: '3',
            name: 'تخرج صديقي أحمد',
            date: DateTime.now().add(const Duration(days: 5)),
            relation: 'صديق',
            advanceNoticeDays: 3,
            notes: 'يحب التكنولوجيا والألعاب',
          ),
          OccasionReminderEntity(
            id: '4',
            name: 'عيد ميلاد زوجتي',
            date: DateTime.now().add(const Duration(days: 45)),
            relation: 'زوج/ة',
            advanceNoticeDays: 14,
            notes: 'تحب المجوهرات والشوكولاتة الفاخرة',
          ),
        ];
        _remindersLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  // ── Helpers ──

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  Color _daysColor(int days) {
    if (days <= 3) return AppColors.error;
    if (days <= 7) return AppColors.warning;
    return AppColors.success;
  }

  IconData _relationIcon(String relation) {
    switch (relation) {
      case 'أم':
        return Icons.favorite;
      case 'أب':
        return Icons.person;
      case 'زوج/ة':
        return Icons.favorite_border;
      case 'أخ/أخت':
        return Icons.people;
      case 'صديق/ة':
      case 'صديق':
        return Icons.group;
      case 'زميل':
        return Icons.work;
      default:
        return Icons.card_giftcard;
    }
  }

  // ── Build ──

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
          centerTitle: true,
          title: Text(
            'المناسبات',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'التذكيرات'),
              Tab(text: 'مساعد الهدايا'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRemindersTab(),
            _buildAiAssistantTab(),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: _showAddReminderSheet,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1 – Reminders
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRemindersTab() {
    if (_remindersLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 72,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد تذكيرات',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف تذكيراً لمناسبة قادمة',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    final sorted = List<OccasionReminderEntity>.from(_reminders)
      ..sort((a, b) => a.date.compareTo(b.date));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reminder = sorted[index];
        final days = _daysUntil(reminder.date);
        return Dismissible(
          key: Key(reminder.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          confirmDismiss: (_) async {
            return await _confirmDelete(context, reminder.name);
          },
          onDismissed: (_) {
            setState(() {
              _reminders.removeWhere((r) => r.id == reminder.id);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم حذف "${reminder.name}"',
                  style: GoogleFonts.tajawal(),
                ),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          child: GestureDetector(
            onLongPress: () async {
              final confirmed = await _confirmDelete(context, reminder.name);
              if (confirmed == true) {
                setState(() {
                  _reminders.removeWhere((r) => r.id == reminder.id);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _relationIcon(reminder.relation),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.name,
                          style: GoogleFonts.tajawal(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(reminder.date),
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.person_outline,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.relation,
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (reminder.notes != null &&
                            reminder.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            reminder.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Days badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _daysColor(days).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          days < 0 ? 'انتهى' : '$days',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _daysColor(days),
                          ),
                        ),
                        if (days >= 0)
                          Text(
                            'يوم',
                            style: GoogleFonts.tajawal(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _daysColor(days),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف التذكير',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'هل تريد حذف "$name"؟',
            style: GoogleFonts.tajawal(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'حذف',
                style: GoogleFonts.tajawal(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add Reminder Bottom Sheet ──

  void _showAddReminderSheet() {
    String name = '';
    DateTime? selectedDate;
    String relation = _relationOptions.first;
    int noticeDays = 7;
    String notes = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle
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
                      const SizedBox(height: 16),
                      Text(
                        'إضافة تذكير جديد',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // اسم المناسبة
                      _sheetLabel('اسم المناسبة'),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (v) => name = v,
                        style: GoogleFonts.tajawal(fontSize: 14),
                        decoration: _inputDecoration('مثال: عيد ميلاد أمي'),
                      ),
                      const SizedBox(height: 16),
                      // التاريخ
                      _sheetLabel('التاريخ'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate:
                                DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now()
                                .add(const Duration(days: 365 * 2)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    surface: AppColors.background,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedDate != null
                                    ? _formatDate(selectedDate!)
                                    : 'اختر التاريخ',
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: selectedDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // العلاقة
                      _sheetLabel('العلاقة'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: relation,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.primary),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            items: _relationOptions
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setSheetState(() => relation = v);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // التنبيه قبل
                      _sheetLabel('التنبيه قبل'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: noticeDays,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppColors.primary),
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            items: _noticeDaysOptions
                                .map((d) => DropdownMenuItem(
                                      value: d,
                                      child: Text('$d يوم'),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setSheetState(() => noticeDays = v);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ملاحظات
                      _sheetLabel('ملاحظات'),
                      const SizedBox(height: 8),
                      TextField(
                        onChanged: (v) => notes = v,
                        maxLines: 2,
                        style: GoogleFonts.tajawal(fontSize: 14),
                        decoration:
                            _inputDecoration('ملاحظات إضافية (اختياري)'),
                      ),
                      const SizedBox(height: 24),
                      // Submit
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (name.trim().isEmpty || selectedDate == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'يرجى إدخال اسم المناسبة والتاريخ',
                                    style: GoogleFonts.tajawal(),
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }
                            final newReminder = OccasionReminderEntity(
                              id: '${_nextId++}',
                              name: name.trim(),
                              date: selectedDate!,
                              relation: relation,
                              advanceNoticeDays: noticeDays,
                              notes:
                                  notes.trim().isEmpty ? null : notes.trim(),
                            );
                            setState(() {
                              _reminders.add(newReminder);
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تمت إضافة التذكير بنجاح',
                                  style: GoogleFonts.tajawal(),
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'إضافة التذكير',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(
        fontSize: 13,
        color: AppColors.textHint,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2 – AI Gift Assistant
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAiAssistantTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مساعد الهدايا الذكي',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'أخبرنا عن المناسبة وسنقترح لك أفضل الهدايا',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // المناسبة
          _fieldLabel('المناسبة'),
          const SizedBox(height: 8),
          _dropdownField<String>(
            value: _selectedOccasion,
            items: _occasionTypes,
            onChanged: (v) => setState(() => _selectedOccasion = v!),
          ),
          const SizedBox(height: 16),

          // المستلم
          _fieldLabel('المستلم'),
          const SizedBox(height: 8),
          TextField(
            controller: _recipientController,
            style: GoogleFonts.tajawal(fontSize: 14),
            decoration: _inputDecoration('مثال: أمي، صديقي أحمد'),
          ),
          const SizedBox(height: 16),

          // الجنس
          _fieldLabel('الجنس'),
          const SizedBox(height: 8),
          Row(
            children: [
              _genderRadio('ذكر', Icons.male),
              const SizedBox(width: 12),
              _genderRadio('أنثى', Icons.female),
            ],
          ),
          const SizedBox(height: 16),

          // العمر
          _fieldLabel('العمر: ${_selectedAge.toInt()} سنة'),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.15),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: GoogleFonts.tajawal(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            child: Slider(
              value: _selectedAge,
              min: 1,
              max: 80,
              divisions: 79,
              label: '${_selectedAge.toInt()} سنة',
              onChanged: (v) => setState(() => _selectedAge = v),
            ),
          ),
          const SizedBox(height: 16),

          // الميزانية
          _fieldLabel(
            'الميزانية: ${_formatPrice(_budgetRange.start)} - ${_formatPrice(_budgetRange.end)} د.ع',
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.accent.withOpacity(0.15),
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withOpacity(0.1),
              valueIndicatorColor: AppColors.accent,
              valueIndicatorTextStyle: GoogleFonts.tajawal(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            child: RangeSlider(
              values: _budgetRange,
              min: 10000,
              max: 500000,
              divisions: 49,
              labels: RangeLabels(
                '${_formatPrice(_budgetRange.start)} د.ع',
                '${_formatPrice(_budgetRange.end)} د.ع',
              ),
              onChanged: (v) => setState(() => _budgetRange = v),
            ),
          ),
          const SizedBox(height: 16),

          // الاهتمامات
          _fieldLabel('الاهتمامات'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestOptions.map((interest) {
              final selected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(
                  interest,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: selected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _suggestionsLoading ? null : _generateSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _suggestionsLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 20),
              label: Text(
                _suggestionsLoading ? 'جاري التحليل...' : 'اقترح هدايا',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Suggestions
          if (_showSuggestions) _buildSuggestionCards(),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _dropdownField<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _genderRadio(String label, IconData icon) {
    final selected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateSuggestions() {
    setState(() {
      _suggestionsLoading = true;
      _showSuggestions = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _suggestionsLoading = false;
        _showSuggestions = true;
      });
    });
  }

  Widget _buildSuggestionCards() {
    final suggestions = _getMockSuggestions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الهدايا المقترحة',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((s) => _suggestionCard(s)),
      ],
    );
  }

  List<Map<String, String>> _getMockSuggestions() {
    return [
      {
        'name': 'عطر فرنسي فاخر',
        'price': '85,000 د.ع',
        'reason':
            'مناسب لـ$_selectedOccasion - عطر أنيق يعكس الذوق الرفيع ويناسب ${_selectedGender == 'ذكر' ? 'الرجال' : 'النساء'}',
        'icon': 'perfume',
      },
      {
        'name': 'طقم شوكولاتة بلجيكية',
        'price': '35,000 د.ع',
        'reason':
            'هدية كلاسيكية محبوبة لجميع الأعمار، مثالية لمناسبة $_selectedOccasion',
        'icon': 'chocolate',
      },
      {
        'name': 'ساعة يد أنيقة',
        'price': '120,000 د.ع',
        'reason':
            'هدية عملية وأنيقة تناسب عمر ${_selectedAge.toInt()} سنة وتبقى ذكرى جميلة',
        'icon': 'watch',
      },
      {
        'name': 'باقة ورد مع بطاقة تهنئة',
        'price': '45,000 د.ع',
        'reason':
            'تعبير رائع عن المشاعر، مع إمكانية إضافة رسالة شخصية مميزة',
        'icon': 'flower',
      },
    ];
  }

  Widget _suggestionCard(Map<String, String> suggestion) {
    IconData icon;
    switch (suggestion['icon']) {
      case 'perfume':
        icon = Icons.spa;
        break;
      case 'chocolate':
        icon = Icons.cake;
        break;
      case 'watch':
        icon = Icons.watch;
        break;
      case 'flower':
        icon = Icons.local_florist;
        break;
      default:
        icon = Icons.card_giftcard;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        suggestion['name']!,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      suggestion['price']!,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion['reason']!,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      'عرض المنتج',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
