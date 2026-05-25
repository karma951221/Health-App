import 'package:feature_weather/feature_weather.dart';
import 'package:feature_weather/src/data/models/open_meteo_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _SuccessDataSource implements WeatherRemoteDataSource {
  _SuccessDataSource(this._model);
  final OpenMeteoResponseModel _model;

  @override
  Future<OpenMeteoResponseModel> fetchRaw({
    required double latitude,
    required double longitude,
  }) async =>
      _model;
}

class _ErrorDataSource implements WeatherRemoteDataSource {
  _ErrorDataSource(this._error);
  final Exception _error;

  @override
  Future<OpenMeteoResponseModel> fetchRaw({
    required double latitude,
    required double longitude,
  }) async =>
      throw _error;
}

void main() {
  final sampleModel = OpenMeteoResponseModel(
    currentWeather: const CurrentWeatherModel(
      temperature: 12.3,
      weatherCode: 3,
      isDay: 1,
    ),
    daily: DailyModel(tempMax: [18.0], tempMin: [7.0]),
  );

  group('WeatherRepositoryImpl', () {
    test('datasource 성공 시 Weather를 반환한다', () async {
      final repo = WeatherRepositoryImpl(_SuccessDataSource(sampleModel));

      final result = await repo.fetchByCoordinates(
        latitude: 37.5,
        longitude: 127.0,
      );

      expect(result.isOk, isTrue);
      result.when(
        success: (weather) {
          expect(weather.temperature, 12.3);
          expect(weather.tempMax, 18.0);
          expect(weather.isDay, isTrue);
        },
        failure: (_) => fail('성공이어야 합니다'),
      );
    });

    test('datasource 예외 시 Failure를 반환한다', () async {
      final repo = WeatherRepositoryImpl(
        _ErrorDataSource(Exception('네트워크 오류')),
      );

      final result = await repo.fetchByCoordinates(
        latitude: 37.5,
        longitude: 127.0,
      );

      expect(result.isErr, isTrue);
      result.when(
        success: (_) => fail('실패이어야 합니다'),
        failure: (failure) => expect(failure.message, '날씨를 불러오지 못했어요.'),
      );
    });
  });
}
