import 'package:app_shared/app_shared.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';
import '../mappers/weather_mapper.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._dataSource);

  final WeatherRemoteDataSource _dataSource;

  @override
  Future<Result<Weather, Failure>> fetchByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final raw = await _dataSource.fetchRaw(
        latitude: latitude,
        longitude: longitude,
      );
      return Result.success(WeatherMapper.fromModel(raw));
    } catch (e) {
      return Result.failure(
        Failure.unknown(message: '날씨를 불러오지 못했어요.', cause: e),
      );
    }
  }
}
