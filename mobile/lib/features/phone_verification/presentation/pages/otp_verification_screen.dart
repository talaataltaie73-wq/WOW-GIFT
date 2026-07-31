import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../cubit/phone_verification_cubit.dart';
import '../cubit/phone_verification_state.dart';
import '../widgets/checkout_progress_indicator.dart';
import '../widgets/otp_input_boxes.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpKey = GlobalKey<OtpInputBoxesState>();
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _hasError = false;
  String? _errorMessage;
  String? _devCode;
  bool _isVerifying = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    final cubit = sl.phoneVerificationCubit;
    final otpRequest = cubit.lastOtpRequest;
    if (otpRequest != null) {
      _startResendTimer(otpRequest.resendAfterSeconds);
      if (kDevMode && otpRequest.devCode != null) {
        _devCode = otpRequest.devCode;
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = seconds;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
      });
    });
  }

  String _formatCountdown(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  String _maskPhone(String phone) {
    if (phone.length < 8) return phone;
    final prefix = phone.substring(0, 4);
    final suffix = phone.substring(phone.length - 4);
    final masked = '*' * (phone.length - 8);
    return '$prefix ${'$masked'.replaceAll('', ' ').trim()} $suffix';
  }

  void _onOtpCompleted(String code) {
    if (_isVerifying) return;
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isVerifying = true;
    });
    sl.phoneVerificationCubit.verifyOtp(code);
  }

  void _resendOtp() {
    if (_resendCountdown > 0) return;
    sl.phoneVerificationCubit.resendOtp();
  }

  void _switchToWhatsApp() {
    if (_resendCountdown > 0) return;
    sl.phoneVerificationCubit.resendOtp(channel: 'whatsapp');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneVerificationCubit, PhoneVerificationState>(
      bloc: sl.phoneVerificationCubit,
      listener: (context, state) {
        if (state is PhoneVerified) {
          if (!_hasNavigated) {
            _hasNavigated = true;
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/checkout',
              (route) => route.settings.name == '/home' || route.isFirst,
            );
          }
        } else if (state is PhoneVerificationError) {
          setState(() {
            _hasError = true;
            _errorMessage = state.message;
            _isVerifying = false;
          });
          _otpKey.currentState?.shakeAndClear();
        } else if (state is OtpExpired) {
          setState(() {
            _hasError = true;
            _errorMessage = 'انتهت صلاحية الرمز. يرجى طلب رمز جديد';
            _isVerifying = false;
          });
          _otpKey.currentState?.shakeAndClear();
        } else if (state is RateLimited) {
          setState(() {
            _hasError = false;
            _errorMessage = null;
            _isVerifying = false;
          });
          _startResendTimer(state.retryAfterSeconds);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'يرجى الانتظار ${state.retryAfterSeconds} ثانية',
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
        } else if (state is OtpRequested) {
          _startResendTimer(state.otpRequest.resendAfterSeconds);
          setState(() {
            _hasError = false;
            _errorMessage = null;
          });
          if (kDevMode && state.otpRequest.devCode != null) {
            setState(() {
              _devCode = state.otpRequest.devCode;
            });
          }
          _otpKey.currentState?.clearAll();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إرسال رمز جديد',
                style: GoogleFonts.tajawal(),
              ),
              backgroundColor: AppColors.success,
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
                        'أدخل رمز التحقق',
                        style: GoogleFonts.tajawal(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أرسلنا رمز تحقق مكون من 6 أرقام إلى رقم الهاتف',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      _buildPhoneDisplay(context),
                      const SizedBox(height: 28),
                      OtpInputBoxes(
                        key: _otpKey,
                        onCompleted: _onOtpCompleted,
                        hasError: _hasError,
                        prefillCode: _devCode,
                      ),
                      if (_hasError && _errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (kDevMode && _devCode != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'رمز التطوير: $_devCode',
                            style: GoogleFonts.tajawal(
                              fontSize: 11,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildResendSection(context),
                      const SizedBox(height: 24),
                      _buildConfirmButton(context),
                      const SizedBox(height: 16),
                      _buildWhatsAppSwitch(context),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneDisplay(BuildContext context) {
    final phone = sl.phoneVerificationCubit.currentPhone;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            _maskPhone(phone),
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'تغيير',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendSection(BuildContext context) {
    final canResend = _resendCountdown <= 0;
    return Column(
      children: [
        if (!canResend)
          Text(
            'يمكنك إعادة إرسال الرمز خلال ${_formatCountdown(_resendCountdown)}',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: canResend ? _resendOtp : null,
          child: Text(
            'إعادة إرسال الرمز',
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: canResend ? AppColors.accent : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return BlocBuilder<PhoneVerificationCubit, PhoneVerificationState>(
      bloc: sl.phoneVerificationCubit,
      builder: (context, state) {
        final isLoading = state is OtpVerifying || state is OtpResending;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    final code = _otpKey.currentState?.currentCode ?? '';
                    if (code.length == 6) {
                      _onOtpCompleted(code);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.4),
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
                    'تأكيد ومتابعة',
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

  Widget _buildWhatsAppSwitch(BuildContext context) {
    final currentChannel = sl.phoneVerificationCubit.currentChannel;
    if (currentChannel == 'whatsapp') return const SizedBox.shrink();

    return GestureDetector(
      onTap: _switchToWhatsApp,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_rounded,
            size: 18,
            color: AppColors.accent.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 6),
          Text(
            'التوصيل عبر واتساب بدلاً من الرسائل النصية',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
