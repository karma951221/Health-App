import 'package:app_shared/app_shared.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_settings_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalSettingsDataSource dataSource;

  SettingsRepositoryImpl(this.dataSource);

  @override
  Future<Result<AppSettings, Failure>> getSettings() async {
    try {
      final model = dataSource.getSettings();
      return Result.success(
        AppSettings(isDarkMode: model.isDarkMode),
      );
    } catch (e) {
      return Result.failure(
        Failure.unknown(message: 'Failed to get settings: $e'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> setDarkMode(bool isDarkMode) async {
    try {
      await dataSource.saveDarkMode(isDarkMode);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure.unknown(message: 'Failed to save settings: $e'),
      );
    }
  }

  @override
  Stream<AppSettings> watchSettings() {
    return dataSource.watchDarkMode().map(
          (model) => AppSettings(isDarkMode: model.isDarkMode),
        );
  }
}
