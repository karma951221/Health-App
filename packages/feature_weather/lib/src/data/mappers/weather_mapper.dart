import '../../domain/entities/weather.dart';
import '../models/open_meteo_response_model.dart';

extension WeatherMapper on Weather {
  static Weather fromModel(OpenMeteoResponseModel model) {
    return Weather(
      temperature: model.currentWeather.temperature,
      weatherCode: model.currentWeather.weatherCode,
      isDay: model.currentWeather.isDay == 1,
      tempMax: model.daily?.tempMax?.firstOrNull,
      tempMin: model.daily?.tempMin?.firstOrNull,
    );
  }
}
