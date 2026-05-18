import 'package:uuid/uuid.dart';

class UuidGen {
  const UuidGen._();

  static const _uuid = Uuid();

  static String v4() => _uuid.v4();
}
