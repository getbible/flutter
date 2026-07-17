typedef JsonMap = Map<String, Object?>;

JsonMap requireJsonMap(Object? value, String label) {
  if (value is! Map) {
    throw FormatException('$label must be a JSON object.');
  }
  return value.map<String, Object?>(
    (Object? key, Object? item) => MapEntry(key.toString(), item),
  );
}

List<Object?> requireJsonList(Object? value, String label) {
  if (value is! List) {
    throw FormatException('$label must be a JSON array.');
  }
  return value.cast<Object?>();
}

String requireString(JsonMap json, String key, {String? label}) {
  final Object? value = json[key];
  if (value is! String) {
    throw FormatException('${label ?? key} must be a string.');
  }
  return value;
}

String optionalString(JsonMap json, String key, [String fallback = '']) {
  final Object? value = json[key];
  return value is String ? value : fallback;
}

int requireInt(JsonMap json, String key, {String? label}) {
  final Object? value = json[key];
  if (value is int) return value;
  if (value is num && value.isFinite && value == value.roundToDouble()) {
    return value.toInt();
  }
  throw FormatException('${label ?? key} must be an integer.');
}

int optionalInt(JsonMap json, String key, [int fallback = 0]) {
  final Object? value = json[key];
  if (value is int) return value;
  if (value is num && value.isFinite) return value.toInt();
  return fallback;
}

double optionalDouble(JsonMap json, String key, [double fallback = 0]) {
  final Object? value = json[key];
  return value is num && value.isFinite ? value.toDouble() : fallback;
}

bool optionalBool(JsonMap json, String key, [bool fallback = false]) {
  final Object? value = json[key];
  return value is bool ? value : fallback;
}

Map<String, String> stringMap(Object? value) {
  if (value is! Map) return const <String, String>{};
  return value.map<String, String>(
    (Object? key, Object? item) => MapEntry(key.toString(), item.toString()),
  );
}

List<T> sortedNumericValues<T>(
  Object? value,
  T Function(Object? value) parser,
) {
  final JsonMap map = requireJsonMap(value, 'numbered API record');
  final List<MapEntry<String, Object?>> entries = map.entries.toList()
    ..sort(
      (MapEntry<String, Object?> left, MapEntry<String, Object?> right) =>
          (int.tryParse(left.key) ?? 0).compareTo(int.tryParse(right.key) ?? 0),
    );
  return entries
      .map((MapEntry<String, Object?> item) => parser(item.value))
      .toList();
}
