import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class LocalSettingsDataSource {
  static const String _darkModeKey = 'isDarkMode';

  final SharedPreferences prefs;

  LocalSettingsDataSource(this.prefs);

  SettingsModel getSettings() {
    final isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    return SettingsModel(isDarkMode: isDarkMode);
  }

  Future<void> saveDarkMode(bool isDarkMode) {
    return prefs.setBool(_darkModeKey, isDarkMode);
  }

  Stream<SettingsModel> watchDarkMode() async* {
    yield getSettings();
  }
}
