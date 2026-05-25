import 'package:feature_weather/src/data/mappers/weather_mapper.dart';
import 'package:feature_weather/src/data/models/open_meteo_response_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherMapper.fromModel', () {
    test('현재 날씨와 당일 최고/최저를 매핑한다', () {
      final model = OpenMeteoResponseModel(
        currentWeather: const CurrentWeatherModel(
          temperature: 12.3,
          weatherCode: 3,
          isDay: 1,
        ),
        daily: DailyModel(
          tempMax: [18.0],
          tempMin: [7.0],
        ),
      );

      final weather = WeatherMapper.fromModel(model);

      expect(weather.temperature, 12.3);
      expect(weather.weatherCode, 3);
      expect(weather.isDay, isTrue);
      expect(weather.tempMax, 18.0);
      expect(weather.tempMin, 7.0);
      expect(weather.description, '흐림');
    });

    test('daily가 없으면 최고/최저는 null', () {
      final model = OpenMeteoResponseModel(
        currentWeather: const CurrentWeatherModel(
          temperature: 5.0,
          weatherCode: 0,
          isDay: 0,
        ),
      );

      final weather = WeatherMapper.fromModel(model);

      expect(weather.tempMax, isNull);
      expect(weather.tempMin, isNull);
      expect(weather.isDay, isFalse);
      expect(weather.description, '맑음');
    });
  });

  group('OpenMeteoResponseModel.fromJson', () {
    test('중첩 JSON을 올바르게 파싱한다', () {
      final json = {
        'current_weather': {
          'temperature': 12.3,
          'weathercode': 3,
          'is_day': 1,
        },
        'daily': {
          'temperature_2m_max': [18.0],
          'temperature_2m_min': [7.0],
        },
      };

      final model = OpenMeteoResponseModel.fromJson(json);

      expect(model.currentWeather.temperature, 12.3);
      expect(model.currentWeather.weatherCode, 3);
      expect(model.currentWeather.isDay, 1);
      expect(model.daily?.tempMax?.first, 18.0);
      expect(model.daily?.tempMin?.first, 7.0);
    });

    test('current_weather가 없으면 파싱 예외', () {
      expect(
        () => OpenMeteoResponseModel.fromJson({'daily': {}}),
        throwsA(anything),
      );
    });
  });
}
