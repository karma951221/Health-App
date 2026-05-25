import 'package:bloc/bloc.dart';
import '../../../domain/usecases/fetch_weather.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._fetchWeather) : super(const WeatherState());

  final FetchWeatherUseCase _fetchWeather;

  Future<void> fetch({
    required double latitude,
    required double longitude,
  }) async {
    emit(const WeatherState(status: WeatherStatus.loading));

    final result = await _fetchWeather(
      latitude: latitude,
      longitude: longitude,
    );

    result.when(
      success: (weather) => emit(
        WeatherState(status: WeatherStatus.success, weather: weather),
      ),
      failure: (failure) => emit(
        WeatherState(
          status: WeatherStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
