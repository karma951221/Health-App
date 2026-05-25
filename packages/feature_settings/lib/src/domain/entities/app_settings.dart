import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

part 'app_settings.g.dart';

@freezed
@JsonSerializable()
class AppSettings with _$AppSettings {
  const AppSettings({this.isDarkMode = false});

  final bool isDarkMode;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
