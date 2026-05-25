import 'package:json_annotation/json_annotation.dart';

part 'open_meteo_response_model.g.dart';

@JsonSerializable(createToJson: false)
class OpenMeteoResponseModel {
  const OpenMeteoResponseModel({
    required this.currentWeather,
    this.daily,
  });

  @JsonKey(name: 'current_weather')
  final CurrentWeatherModel currentWeather;

  @JsonKey(name: 'daily')
  final DailyModel? daily;

  factory OpenMeteoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$OpenMeteoResponseModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CurrentWeatherModel {
  const CurrentWeatherModel({
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
  });

  final double temperature;

  @JsonKey(name: 'weathercode')
  final int weatherCode;

  @JsonKey(name: 'is_day')
  final int isDay;

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class DailyModel {
  const DailyModel({
    this.tempMax,
    this.tempMin,
  });

  @JsonKey(name: 'temperature_2m_max')
  final List<double>? tempMax;

  @JsonKey(name: 'temperature_2m_min')
  final List<double>? tempMin;

  factory DailyModel.fromJson(Map<String, dynamic> json) =>
      _$DailyModelFromJson(json);
}
