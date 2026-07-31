import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
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
  void dispose() {
    _recipientController.dispose();
    super.dispose();
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
          centerTitle: true,
          title: Text(
            'مساعد الهدايا الذكي',
            style: GoogleFonts.tajawal(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
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
                            'دعنا نساعدك في اختيار الهدية المثالية',
                            style: GoogleFonts.tajawal(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'أجب عن الأسئلة التالية وسنقترح لك أفضل الخيارات',
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
              const SizedBox(height: 24),

              // المناسبة
              _fieldLabel('المناسبة'),
              const SizedBox(height: 8),
              _buildDropdown<String>(
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
                  _genderOption('ذكر', Icons.male),
                  const SizedBox(width: 12),
                  _genderOption('أنثى', Icons.female),
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

              // Submit
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
              if (_showSuggestions) _buildSuggestionsList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
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

  Widget _buildDropdown<T>({
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

  Widget _genderOption(String label, IconData icon) {
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

  Widget _buildSuggestionsList() {
    final suggestions = _getMockSuggestions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline,
                color: AppColors.accent, size: 20),
            const SizedBox(width: 6),
            Text(
              'الهدايا المقترحة',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
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
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(
                          'أضف للسلة',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          'عرض التفاصيل',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
