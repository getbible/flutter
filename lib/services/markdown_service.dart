import '../domain/models/bible.dart';

String chapterMarkdown(BibleChapter chapter, Translation translation) {
  final StringBuffer output = StringBuffer('# ${chapter.bookName} ${chapter.chapter}\n\n');
  for (final Verse verse in chapter.verses) {
    output.writeln('${verse.verse}. ${verse.text}');
  }
  output
    ..writeln('\n**${translation.translation}**')
    ..writeln('\n> ${translation.distributionLicense}');
  return output.toString();
}
