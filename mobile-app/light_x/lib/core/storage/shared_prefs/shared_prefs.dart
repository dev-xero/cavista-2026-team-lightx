import 'package:shared_preferences/shared_preferences.dart';

part 'src/shared_pref_keys.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._();
  late final SharedPreferences _prefs;
  bool isInitialized = false;

  SharedPrefs._();

  static SharedPrefs get instance => _instance;
  static SharedPreferences get prefs => instance._prefs;

  static Future<void> initialize() async => await instance._initialize();

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    isInitialized = true;
  }

  Object? get(SharedPrefKeys key) {
    return _prefs.get(key.name);
  }

  static Future<bool> set<T>(SharedPrefKeys key, T value) {
    if (value is String) {
      return prefs.setString(key.name, value as String);
    } else if (value is int) {
      return prefs.setInt(key.name, value as int);
    } else if (value is bool) {
      return prefs.setBool(key.name, value as bool);
    } else if (value is double) {
      return prefs.setDouble(key.name, value as double);
    } else if (value is List<String>) {
      return prefs.setStringList(key.name, value as List<String>);
    } else {
      throw ArgumentError('Unsupported type: $T');
    }
  }

  static Future<bool> remove(SharedPrefKeys key) {
    return prefs.remove(key.name);
  }

  // function to clear all
  void clear() {
    _prefs.clear();
  }
}
