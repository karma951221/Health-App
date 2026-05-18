import 'package:app_shared/src/env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Env.appName is populated from .env (or defaultValue)', () {
    expect(Env.appName, isNotEmpty);
  });
}
