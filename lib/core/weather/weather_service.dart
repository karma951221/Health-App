import 'dart:convert';

import 'package:http/http.dart' as http;

/// 굿모닝 브리핑에 표시할 현재 날씨 요약.
///
/// open-meteo의 `current_weather` + 당일 `daily` 최고/최저를 담는다.
class MorningWeather {
  const MorningWeather({
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
    this.tempMax,
    this.tempMin,
  });

  /// 현재 기온(°C).
  final double temperature;

  /// WMO weather interpretation code.
  final int weatherCode;

  /// 주간 여부(open-meteo `is_day`).
  final bool isDay;

  /// 당일 최고 기온(°C). 없으면 null.
  final double? tempMax;

  /// 당일 최저 기온(°C). 없으면 null.
  final double? tempMin;

  /// 한국어 날씨 상태 설명.
  String get description => weatherDescriptionKo(weatherCode);

  /// open-meteo 응답 JSON을 파싱한다.
  ///
  /// 기대 형태:
  /// ```json
  /// {
  ///   "current_weather": {"temperature": 12.3, "weathercode": 3, "is_day": 1},
  ///   "daily": {"temperature_2m_max": [18.0], "temperature_2m_min": [7.0]}
  /// }
  /// ```
  factory MorningWeather.fromOpenMeteoJson(Map<String, dynamic> json) {
    final current = json['current_weather'] as Map<String, dynamic>?;
    if (current == null) {
      throw const FormatException('current_weather 누락');
    }

    final daily = json['daily'] as Map<String, dynamic>?;
    double? firstOf(String key) {
      final list = daily?[key];
      if (list is List && list.isNotEmpty) {
        return (list.first as num).toDouble();
      }
      return null;
    }

    return MorningWeather(
      temperature: (current['temperature'] as num).toDouble(),
      weatherCode: (current['weathercode'] as num).toInt(),
      isDay: (current['is_day'] as num?)?.toInt() == 1,
      tempMax: firstOf('temperature_2m_max'),
      tempMin: firstOf('temperature_2m_min'),
    );
  }
}

/// open-meteo 기반 날씨 조회. HTTP 클라이언트를 주입받아 테스트 가능하다.
class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'https://api.open-meteo.com/v1/forecast';

  /// 좌표 기준 현재 날씨 + 당일 최고/최저를 가져온다.
  Future<MorningWeather> fetchByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_base).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current_weather': 'true',
        'daily': 'temperature_2m_max,temperature_2m_min',
        'forecast_days': '1',
        'timezone': 'auto',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw http.ClientException(
        '날씨 요청 실패 (${response.statusCode})',
        uri,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return MorningWeather.fromOpenMeteoJson(body);
  }

  void dispose() => _client.close();
}

/// WMO weather code → 한국어 설명.
String weatherDescriptionKo(int code) {
  switch (code) {
    case 0:
      return '맑음';
    case 1:
      return '대체로 맑음';
    case 2:
      return '구름 조금';
    case 3:
      return '흐림';
    case 45:
    case 48:
      return '안개';
    case 51:
    case 53:
    case 55:
      return '이슬비';
    case 56:
    case 57:
      return '어는 이슬비';
    case 61:
    case 63:
    case 65:
      return '비';
    case 66:
    case 67:
      return '어는 비';
    case 71:
    case 73:
    case 75:
      return '눈';
    case 77:
      return '싸락눈';
    case 80:
    case 81:
    case 82:
      return '소나기';
    case 85:
    case 86:
      return '소낙눈';
    case 95:
      return '뇌우';
    case 96:
    case 99:
      return '뇌우·우박';
    default:
      return '알 수 없음';
  }
}
