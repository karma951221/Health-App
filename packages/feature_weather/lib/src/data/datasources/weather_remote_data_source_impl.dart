import 'package:dio/dio.dart';
import '../models/open_meteo_response_model.dart';
import 'weather_remote_data_source.dart';

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  WeatherRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _base = 'https://api.open-meteo.com/v1/forecast';

  @override
  Future<OpenMeteoResponseModel> fetchRaw({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _base,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current_weather': true,
        'daily': 'temperature_2m_max,temperature_2m_min',
        'forecast_days': 1,
        'timezone': 'auto',
      },
    );
    return OpenMeteoResponseModel.fromJson(response.data!);
  }
}
