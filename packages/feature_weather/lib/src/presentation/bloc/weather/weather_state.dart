import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/weather.dart';

part 'weather_state.freezed.dart';

enum WeatherStatus { initial, loading, success, failure }

@freezed
class WeatherState with _$WeatherState {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.errorMessage,
  });

  final WeatherStatus status;
  final Weather? weather;
  final String? errorMessage;
}
