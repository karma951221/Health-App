import '../models/open_meteo_response_model.dart';

abstract interface class WeatherRemoteDataSource {
  Future<OpenMeteoResponseModel> fetchRaw({
    required double latitude,
    required double longitude,
  });
}
