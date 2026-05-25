import 'package:app_shared/app_shared.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsUseCases {
  final SettingsRepository repository;

  SettingsUseCases(this.repository);

  Future<Result<AppSettings, Failure>> getSettings() =>
      repository.getSettings();

  Future<Result<void, Failure>> setDarkMode(bool isDarkMode) =>
      repository.setDarkMode(isDarkMode);

  Stream<AppSettings> watchSettings() => repository.watchSettings();
}
