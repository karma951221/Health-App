import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'APP_NAME', defaultValue: 'daylog')
  static const String appName = _Env.appName;
}
