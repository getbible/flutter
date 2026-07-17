import '../../core/json.dart';
import 'passage.dart';

final class MarkingGroup {
  const MarkingGroup({
    required this.id,
    required this.name,
    required this.color,
    this.sortOrder = 0,
    this.isStarter = false,
    required this.updatedAt,
  });

  factory MarkingGroup.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'marking group');
    final String color = optionalString(
      json,
      'color',
      optionalString(json, 'value'),
    );
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(color)) {
      throw const FormatException('A marking group contains an invalid color.');
    }
    return MarkingGroup(
      id: requireString(json, 'id'),
      name: requireString(json, 'name'),
      color: color.toUpperCase(),
      sortOrder: optionalInt(json, 'sortOrder'),
      isStarter: optionalBool(json, 'isStarter'),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        optionalInt(json, 'updatedAt', DateTime.now().millisecondsSinceEpoch),
        isUtc: true,
      ),
    );
  }

  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final bool isStarter;
  final DateTime updatedAt;

  MarkingGroup copyWith({
    String? id,
    String? name,
    String? color,
    int? sortOrder,
    DateTime? updatedAt,
  }) => MarkingGroup(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    isStarter: isStarter,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  JsonMap toJson({bool websiteCompatible = false}) => <String, Object?>{
    'id': id,
    'name': name,
    if (websiteCompatible) 'value': color.toLowerCase() else 'color': color,
    if (!websiteCompatible) ...<String, Object?>{
      'version': 1,
      'sortOrder': sortOrder,
      'isStarter': isStarter,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    },
  };
}

final class Marking {
  const Marking({
    required this.id,
    required this.passage,
    required this.verse,
    required this.start,
    required this.end,
    required this.quote,
    required this.reference,
    required this.groupId,
    required this.createdAt,
  });

  factory Marking.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'marking');
    final Object? startValue = json['start'];
    final Object? endValue = json['end'];
    final int? start = startValue == null ? null : requireInt(json, 'start');
    final int? end = endValue == null ? null : requireInt(json, 'end');
    if ((start == null) != (end == null) ||
        (start != null && (start < 0 || end! <= start))) {
      throw const FormatException('A marking contains an invalid text range.');
    }
    return Marking(
      id: requireString(json, 'id'),
      passage: Passage.fromJson(json['passage']),
      verse: requireInt(json, 'verse'),
      start: start,
      end: end,
      quote: requireString(json, 'quote'),
      reference: optionalString(json, 'reference'),
      groupId: requireString(
        json,
        json.containsKey('groupId') ? 'groupId' : 'colorId',
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        requireInt(json, 'createdAt'),
        isUtc: true,
      ),
    );
  }

  final String id;
  final Passage passage;
  final int verse;
  final int? start;
  final int? end;
  final String quote;
  final String reference;
  final String groupId;
  final DateTime createdAt;

  bool get isWholeVerse => start == null && end == null;
  String get identity => isWholeVerse
      ? '${passage.canonicalKey}|$verse|all|$groupId'
      : '${passage.key}|$verse|$start|$end|$quote|$groupId';

  bool matchesPassage(Passage other) => isWholeVerse
      ? passage.canonicalKey == other.canonicalKey
      : passage.key == other.key;

  Marking copyWith({
    String? id,
    int? start,
    int? end,
    String? quote,
    String? groupId,
  }) => Marking(
    id: id ?? this.id,
    passage: passage,
    verse: verse,
    start: start ?? this.start,
    end: end ?? this.end,
    quote: quote ?? this.quote,
    reference: reference,
    groupId: groupId ?? this.groupId,
    createdAt: createdAt,
  );

  JsonMap toJson({bool websiteCompatible = false}) => <String, Object?>{
    if (!websiteCompatible) 'version': 1,
    'id': id,
    'passage': passage.toJson(),
    'verse': verse,
    'start': start,
    'end': end,
    'quote': quote,
    'reference': reference,
    websiteCompatible ? 'colorId' : 'groupId': groupId,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
}

final class VerseNote {
  const VerseNote({
    required this.id,
    required this.passage,
    required this.verse,
    required this.reference,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerseNote.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'verse note');
    return VerseNote(
      id: requireString(json, 'id'),
      passage: Passage.fromJson(json['passage']),
      verse: requireInt(json, 'verse'),
      reference: requireString(json, 'reference'),
      text: requireString(json, 'text'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        requireInt(json, 'createdAt'),
        isUtc: true,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        requireInt(json, 'updatedAt'),
        isUtc: true,
      ),
    );
  }

  final String id;
  final Passage passage;
  final int verse;
  final String reference;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get canonicalKey => '${passage.canonicalKey}/$verse';

  bool matchesPassage(Passage other) =>
      passage.canonicalKey == other.canonicalKey;

  VerseNote copyWith({String? id}) => VerseNote(
    id: id ?? this.id,
    passage: passage,
    verse: verse,
    reference: reference,
    text: text,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  JsonMap toJson() => <String, Object?>{
    'version': 1,
    'id': id,
    'passage': passage.toJson(),
    'verse': verse,
    'reference': reference,
    'text': text,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };
}

int compareMarkings(Marking left, Marking right) =>
    left.passage.book.compareTo(right.passage.book) != 0
    ? left.passage.book.compareTo(right.passage.book)
    : left.passage.chapter.compareTo(right.passage.chapter) != 0
    ? left.passage.chapter.compareTo(right.passage.chapter)
    : left.verse.compareTo(right.verse) != 0
    ? left.verse.compareTo(right.verse)
    : (left.start ?? -1).compareTo(right.start ?? -1);

int compareNotes(VerseNote left, VerseNote right) =>
    left.passage.book.compareTo(right.passage.book) != 0
    ? left.passage.book.compareTo(right.passage.book)
    : left.passage.chapter.compareTo(right.passage.chapter) != 0
    ? left.passage.chapter.compareTo(right.passage.chapter)
    : left.verse.compareTo(right.verse);
