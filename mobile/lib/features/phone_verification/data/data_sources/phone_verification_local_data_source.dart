import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';

class PhoneVerificationLocalDataSource {
  final SharedPreferences _prefs;

  PhoneVerificationLocalDataSource(this._prefs);

  bool isPhoneVerified() {
    return _prefs.getBool(AppConstants.phoneVerifiedKey) ?? false;
  }

  String? getVerifiedPhone() {
    return _prefs.getString(AppConstants.verifiedPhoneKey);
  }

  Future<void> saveVerificationStatus({
    required bool verified,
    required String phone,
    required DateTime verifiedAt,
  }) async {
    await _prefs.setBool(AppConstants.phoneVerifiedKey, verified);
    await _prefs.setString(AppConstants.verifiedPhoneKey, phone);
    await _prefs.setString(
      AppConstants.phoneVerifiedAtKey,
      verifiedAt.toIso8601String(),
    );
  }

  Future<void> clearVerificationStatus() async {
    await _prefs.remove(AppConstants.phoneVerifiedKey);
    await _prefs.remove(AppConstants.verifiedPhoneKey);
    await _prefs.remove(AppConstants.phoneVerifiedAtKey);
  }
}
