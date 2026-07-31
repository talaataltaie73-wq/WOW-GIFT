import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../cubit/phone_verification_cubit.dart';
import '../cubit/phone_verification_state.dart';
import '../widgets/checkout_progress_indicator.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  String _selectedChannel = 'sms';
  String? _phoneError;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    final verifiedPhone = sl.phoneVerificationCubit.getVerifiedPhone();
    if (verifiedPhone != null && verifiedPhone.startsWith('+964')) {
      _phoneController.text = verifiedPhone.substring(4);
      _validatePhone(verifiedPhone.substring(4));
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    setState(() {
      if (digits.isEmpty) {
        _phoneError = null;
        _isValid = false;
      } else if (!RegExp(r'^7[0-9]{9}$').hasMatch(digits)) {
        _phoneError = 'يرجى إدخال رقم جوال عراقي صحيح (يبدأ بـ 7)';
        _isValid = false;
      } else {
        _phoneError = null;
        _isValid = true;
      }
    });
  }

  String _formatE164() {
    final digits = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    return '+964$digits';
  }

  void _submit() {
    if (!_isValid) return;
    sl.phoneVerificationCubit.requestOtp(
      phone: _formatE164(),
      channel: _selectedChannel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneVerificationCubit, PhoneVerificationState>(
      bloc: sl.phoneVerificationCubit,
      listener: (context, state) {
        if (state is OtpRequested) {
          Navigator.of(context).pushNamed('/otp-verification');
        } else if (state is RateLimited) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'يرجى الانتظار ${state.retryAfterSeconds} ثانية قبل المحاولة مرة أخرى',
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else if (state is PhoneVerificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Wow Gift',
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textOnPrimary,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              const CheckoutProgressIndicator(activeStep: 2),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'تأكيد رقم الجوال الخاص بك',
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نحتاج رقم جوالك ليتواصل معك مندوب التوصيل عند الوصول',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildPhoneField(context),
                      if (_phoneError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _phoneError!,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'طريقة استلام رمز التحقق',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      _buildChannelSelector(context),
                      const SizedBox(height: 32),
                      _buildSendButton(context),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              _buildTrustNote(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      style: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        hintText: '5XX XXX XXXX',
        hintStyle: GoogleFonts.tajawal(
          fontSize: 16,
          color: AppColors.textHint,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 1,
                height: 28,
                color: AppColors.border,
                margin: const EdgeInsetsDirectional.only(end: 10),
              ),
              Text(
                '+964',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      onChanged: _validatePhone,
    );
  }

  Widget _buildChannelSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ChannelPill(
            label: 'رسالة نصية (SMS)',
            icon: Icons.sms_rounded,
            isSelected: _selectedChannel == 'sms',
            selectedColor: AppColors.accent,
            onTap: () {
              setState(() => _selectedChannel = 'sms');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ChannelPill(
            label: 'واتساب',
            iconWidget: const Icon(
              Icons.chat_rounded,
              color: Color(0xFF25D366),
              size: 22,
            ),
            isSelected: _selectedChannel == 'whatsapp',
            selectedColor: AppColors.accent,
            onTap: () {
              setState(() => _selectedChannel = 'whatsapp');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return BlocBuilder<PhoneVerificationCubit, PhoneVerificationState>(
      bloc: sl.phoneVerificationCubit,
      builder: (context, state) {
        final isLoading = state is PhoneVerificationLoading;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isValid && !isLoading ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
              disabledForegroundColor:
                  AppColors.textOnPrimary.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : Text(
                    'إرسال رمز التحقق',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTrustNote(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 16,
            color: AppColors.textHint.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Text(
            'نحافظ على بياناتك آمنة ولا نشاركها مع أي جهة',
            style: GoogleFonts.tajawal(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ChannelPill({
    required this.label,
    this.icon,
    this.iconWidget,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
          color: isSelected
              ? selectedColor.withValues(alpha: 0.05)
              : AppColors.background,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? selectedColor : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            if (iconWidget != null)
              iconWidget!
            else if (icon != null)
              Icon(
                icon,
                size: 22,
                color: isSelected ? selectedColor : AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
