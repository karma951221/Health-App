import 'package:feature_weather/feature_weather.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

export 'package:feature_weather/feature_weather.dart' show Weather;

enum BriefingStatus {
  loading,
  success,
  permissionDenied,
  permissionDeniedForever,
  locationDisabled,
  failure,
}

class MorningBriefingState {
  const MorningBriefingState({
    required this.status,
    this.weather,
    this.message,
  });

  const MorningBriefingState.loading()
      : status = BriefingStatus.loading,
        weather = null,
        message = null;

  final BriefingStatus status;
  final Weather? weather;
  final String? message;
}

/// 알람 해제 직후 굿모닝 브리핑: 위치 권한 → 현재 위치 → 날씨 조회.
class MorningBriefingCubit extends Cubit<MorningBriefingState> {
  MorningBriefingCubit(this._fetchWeather)
      : super(const MorningBriefingState.loading());

  final FetchWeatherUseCase _fetchWeather;

  Future<void> load() async {
    emit(const MorningBriefingState.loading());

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _emit(BriefingStatus.locationDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _emit(BriefingStatus.permissionDeniedForever);
        return;
      }
      if (permission == LocationPermission.denied) {
        _emit(BriefingStatus.permissionDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final result = await _fetchWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      result.when(
        success: (weather) => emit(
          MorningBriefingState(
            status: BriefingStatus.success,
            weather: weather,
          ),
        ),
        failure: (failure) => emit(
          MorningBriefingState(
            status: BriefingStatus.failure,
            message: failure.message,
          ),
        ),
      );
    } catch (_) {
      emit(
        const MorningBriefingState(
          status: BriefingStatus.failure,
          message: '날씨를 불러오지 못했어요.',
        ),
      );
    }
  }

  /// OS 앱 설정 화면 열기(영구 거부 시).
  Future<void> openSettings() => Geolocator.openAppSettings();

  void _emit(BriefingStatus status) {
    emit(MorningBriefingState(status: status));
  }
}
