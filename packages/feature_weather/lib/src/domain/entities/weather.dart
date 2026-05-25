import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';

@freezed
class Weather with _$Weather {
  const Weather({
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
    this.tempMax,
    this.tempMin,
  });

  final double temperature;
  final int weatherCode;
  final bool isDay;
  final double? tempMax;
  final double? tempMin;

  String get description => _descriptionKo(weatherCode);
}

String _descriptionKo(int code) {
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
