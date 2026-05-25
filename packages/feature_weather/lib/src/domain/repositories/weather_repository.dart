import 'package:app_shared/app_shared.dart';
import '../entities/weather.dart';

abstract interface class WeatherRepository {
  Future<Result<Weather, Failure>> fetchByCoordinates({
    required double latitude,
    required double longitude,
  });
}
