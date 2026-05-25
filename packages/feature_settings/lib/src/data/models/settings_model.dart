import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
@JsonSerializable()
class SettingsModel with _$SettingsModel {
  const SettingsModel({
    this.isDarkMode = false,
  });

  final bool isDarkMode;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}
