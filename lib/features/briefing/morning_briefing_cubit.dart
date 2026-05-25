import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/weather/weather_service.dart';

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
  final MorningWeather? weather;
  final String? message;
}

/// 알람 해제 직후 굿모닝 브리핑: 위치 권한 → 현재 위치 → 날씨 조회.
class MorningBriefingCubit extends Cubit<MorningBriefingState> {
  MorningBriefingCubit(this._weatherService)
      : super(const MorningBriefingState.loading());

  final WeatherService _weatherService;

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
      final weather = await _weatherService.fetchByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      emit(
        MorningBriefingState(
          status: BriefingStatus.success,
          weather: weather,
        ),
      );
    } catch (error) {
      emit(
        MorningBriefingState(
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

  @override
  Future<void> close() {
    _weatherService.dispose();
    return super.close();
  }
}
