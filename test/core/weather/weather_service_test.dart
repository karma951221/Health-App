import 'package:daylog/core/weather/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const sampleBody = '''
{
  "latitude": 37.5,
  "longitude": 127.0,
  "current_weather": {"temperature": 12.3, "weathercode": 3, "is_day": 1},
  "daily": {
    "temperature_2m_max": [18.0],
    "temperature_2m_min": [7.0]
  }
}
''';

  group('MorningWeather.fromOpenMeteoJson', () {
    test('현재 날씨와 당일 최고/최저를 파싱한다', () {
      final weather = MorningWeather.fromOpenMeteoJson(
        {
          'current_weather': {
            'temperature': 12.3,
            'weathercode': 3,
            'is_day': 1,
          },
          'daily': {
            'temperature_2m_max': [18.0],
            'temperature_2m_min': [7.0],
          },
        },
      );

      expect(weather.temperature, 12.3);
      expect(weather.weatherCode, 3);
      expect(weather.isDay, isTrue);
      expect(weather.tempMax, 18.0);
      expect(weather.tempMin, 7.0);
      expect(weather.description, '흐림');
    });

    test('daily가 없어도 최고/최저는 null로 파싱한다', () {
      final weather = MorningWeather.fromOpenMeteoJson({
        'current_weather': {
          'temperature': 5.0,
          'weathercode': 0,
          'is_day': 0,
        },
      });

      expect(weather.tempMax, isNull);
      expect(weather.tempMin, isNull);
      expect(weather.isDay, isFalse);
      expect(weather.description, '맑음');
    });

    test('current_weather가 없으면 FormatException', () {
      expect(
        () => MorningWeather.fromOpenMeteoJson({'daily': {}}),
        throwsFormatException,
      );
    });
  });

  group('WeatherService.fetchByCoordinates', () {
    test('200 응답을 MorningWeather로 변환한다', () async {
      final service = WeatherService(
        client: MockClient((request) async {
          expect(request.url.queryParameters['latitude'], '37.5');
          expect(request.url.queryParameters['current_weather'], 'true');
          return http.Response(sampleBody, 200);
        }),
      );

      final weather = await service.fetchByCoordinates(
        latitude: 37.5,
        longitude: 127.0,
      );

      expect(weather.temperature, 12.3);
      expect(weather.tempMax, 18.0);
    });

    test('비-200 응답이면 예외를 던진다', () async {
      final service = WeatherService(
        client: MockClient((request) async => http.Response('error', 500)),
      );

      expect(
        () => service.fetchByCoordinates(latitude: 0, longitude: 0),
        throwsA(isA<http.ClientException>()),
      );
    });
  });
}
