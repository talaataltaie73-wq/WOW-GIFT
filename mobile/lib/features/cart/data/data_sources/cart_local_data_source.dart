import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';

class CartLocalDataSource {
  final SharedPreferences _prefs;

  static const String _cartKey = 'cart_data';

  CartLocalDataSource(this._prefs);

  Future<void> saveCart(Map<String, dynamic> cartJson) async {
    try {
      final jsonString = json.encode(cartJson);
      await _prefs.setString(_cartKey, jsonString);
    } catch (e) {
      throw const CacheException('فشل حفظ السلة');
    }
  }

  Map<String, dynamic>? getCart() {
    try {
      final jsonString = _prefs.getString(_cartKey);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCart() async {
    try {
      await _prefs.remove(_cartKey);
    } catch (e) {
      throw const CacheException('فشل مسح السلة');
    }
  }
}
