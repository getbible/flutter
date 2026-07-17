import '../domain/models/annotations.dart';

String _groupId(String name) => name
    .toLowerCase()
    .replaceAll(RegExp("['’]"), '')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-+$'), '');

List<MarkingGroup> starterMarkingGroups() {
  const List<(String, String)> values = <(String, String)>[
    ('Adultery', '#F9A8B8'),
    ('Authority of the Bible', '#93C5FD'),
    ('Baptism', '#7DD3FC'),
    ('Biblical Love', '#F9A8D4'),
    ('Blessings and Curses', '#FDE68A'),
    ('Christian Clothing', '#D8B4FE'),
    ('Christian Offices', '#A5B4FC'),
    ('Communion', '#FCA5A5'),
    ('Conditional Security', '#FDBA74'),
    ('Dating', '#F0ABFC'),
    ('Dietary Guidance', '#BEF264'),
    ('Discipline', '#FCD34D'),
    ('Education', '#67E8F9'),
    ('Effective Prayer', '#C4B5FD'),
    ('Family Planning', '#FDA4AF'),
    ('First Day', '#FED7AA'),
    ('Flattery', '#FECDD3'),
    ('Free Will', '#99F6E4'),
    ("God's Judgment", '#FB7185'),
    ('Grace', '#BBF7D0'),
    ('Home Church', '#86EFAC'),
    ('Immutability', '#BFDBFE'),
    ("Jesus Christ's Deity", '#C7D2FE'),
    ("Jesus Christ's Humanity", '#FECACA'),
    ('Leadership', '#A7F3D0'),
    ('Longevity', '#D9F99D'),
    ("Man's Role", '#BAE6FD'),
    ('Marriage', '#F5B7D2'),
    ("Music's Influence", '#E9D5FF'),
    ('No Fellowship', '#FDC4A8'),
    ('No One is Good', '#FDA4A4'),
    ('Non-Resistance', '#A7F3E8'),
    ('Not Under the Law', '#DDD6FE'),
    ("Obey God's Commandments", '#FDE047'),
    ('Obey Government Laws', '#CBD5E1'),
    ('Omnipotent', '#818CF8'),
    ('Omnipresent', '#60A5FA'),
    ('Omniscient', '#A78BFA'),
    ('Orderly Home', '#B7E4C7'),
    ('Ordinances', '#67D6E8'),
    ('Prince of this World', '#C4A7A7'),
    ('Providence', '#8DD3C7'),
    ('Renewing of the Mind', '#A5F3FC'),
    ('Repentance', '#FBBF8A'),
    ('Saved by Faith', '#86EFAC'),
    ('Sodomy', '#F59E9E'),
    ('Spirit of Prophecy', '#D8B4FE'),
    ('Spiritual Gifts', '#C084FC'),
    ('Spiritual Judgment', '#F0C36E'),
    ('Spiritual Rebirth', '#6EE7B7'),
    ('Temptation', '#FCA5A5'),
    ('What is Life', '#5EEAD4'),
    ('Wine', '#E8A0BF'),
    ('Wisdom Cause', '#FEF08A'),
    ('Wisdom Fruit', '#BEF264'),
    ('Wisdom Origin', '#FCD34D'),
    ('Wisdom Value', '#FBBF24'),
    ("Woman's Role", '#FBCFE8'),
    ('Word of God', '#7DD3FC'),
    ('Worldly Wisdom', '#D6D3D1'),
  ];
  final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return <MarkingGroup>[
    for (int index = 0; index < values.length; index++)
      MarkingGroup(
        id: _groupId(values[index].$1),
        name: values[index].$1,
        color: values[index].$2,
        sortOrder: index,
        isStarter: true,
        updatedAt: epoch,
      ),
  ];
}
