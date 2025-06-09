import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  static SharedPreferences? _prefs;
  static bool _initialized = false;

  static Future<void> init() async {
    if (!_initialized) {
      print('Initializing LocalData...');
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      print('LocalData initialized. All keys: ${_prefs?.getKeys()}');
    }
  }

  static Future<void> setData({required String key, required dynamic value}) async {
    if (!_initialized) await init();
    
    print('Setting data - Key: $key, Value: $value');
    bool? success;
    
    if (value is String) {
      success = await _prefs?.setString(key, value);
    } else if (value is double) {
      success = await _prefs?.setDouble(key, value);
    } else if (value is int) {
      success = await _prefs?.setInt(key, value);
    } else if (value is bool) {
      success = await _prefs?.setBool(key, value);
    } else if (value is List<String>) {
      success = await _prefs?.setStringList(key, value);
    }
    
    print('Data set result: $success');
    print('Current value for $key: ${_prefs?.get(key)}');
  }

  static Future<dynamic> getData({required String key}) async {
    if (!_initialized) await init();
    final value = _prefs?.get(key);
    print('Getting data - Key: $key, Value: $value');
    return value;
  }

  static Future<void> clearData() async {
    if (!_initialized) await init();
    print('Clearing all data');
    await _prefs?.clear();
    print('Data cleared. All keys: ${_prefs?.getKeys()}');
  }
}