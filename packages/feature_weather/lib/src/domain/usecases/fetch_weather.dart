import 'package:app_shared/app_shared.dart';
import '../entities/weather.dart';
import '../repositories/weather_repository.dart';

class FetchWeatherUseCase {
  FetchWeatherUseCase(this._repository);

  final WeatherRepository _repository;

  Future<Result<Weather, Failure>> call({
    required double latitude,
    required double longitude,
  }) {
    return _repository.fetchByCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
