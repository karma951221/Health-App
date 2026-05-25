import 'package:app_shared/app_shared.dart';
import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<Result<AppSettings, Failure>> getSettings();
  Future<Result<void, Failure>> setDarkMode(bool isDarkMode);
  Stream<AppSettings> watchSettings();
}
