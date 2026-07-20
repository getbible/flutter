import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/app_state.dart';
import '../domain/models/bible.dart';
import '../domain/models/cache.dart';
import '../domain/models/passage.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Semantics(
          label: 'getBible.live — The words of eternal life',
          image: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(238),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Image.asset(
                'assets/branding/getbible_wordmark.png',
                height: 30,
                fit: BoxFit.contain,
                alignment: AlignmentDirectional.centerStart,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(tooltip: 'Reading settings', icon: const Icon(Icons.text_fields), onPressed: () => _settings(context, state)),
        ],
      ),
      body: SafeArea(child: _body(context, state)),
    );
  }

  Widget _body(BuildContext context, AppState state) {
    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.error != null && state.current == null) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        const Icon(Icons.cloud_off, size: 48), const SizedBox(height: 16), Text(state.error!, textAlign: TextAlign.center),
        const SizedBox(height: 16), FilledButton(onPressed: () => state.loadPassage(state.passage), child: const Text('Retry')),
      ])));
    }
    final BibleChapter chapter = state.current!;
    final TextDirection direction = chapter.direction.toLowerCase() == 'rtl' ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(textDirection: direction, child: Column(children: <Widget>[
      _Navigation(state: state),
      if (state.freshness != CacheFreshness.fresh)
        CacheStatusNotice(freshness: state.freshness!),
      Expanded(child: state.preferences.layout == ReaderLayout.lines
        ? ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), itemCount: chapter.verses.length, itemBuilder: (BuildContext context, int index) => _VerseLine(verse: chapter.verses[index], size: state.preferences.textSize))
        : SingleChildScrollView(padding: const EdgeInsets.all(20), child: SelectableText(chapter.verses.map((Verse v) => '${v.verse} ${v.text}').join('  '), style: TextStyle(fontSize: state.preferences.textSize, height: 1.55))),
      ),
    ]));
  }

  void _settings(BuildContext context, AppState state) => showModalBottomSheet<void>(context: context, builder: (BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    SegmentedButton<AppearanceMode>(segments: AppearanceMode.values.map((AppearanceMode value) => ButtonSegment(value: value, label: Text(value.name))).toList(), selected: <AppearanceMode>{state.preferences.appearanceMode}, onSelectionChanged: (Set<AppearanceMode> value) => state.setAppearance(value.first)),
    const SizedBox(height: 16),
    SegmentedButton<ReaderLayout>(segments: const <ButtonSegment<ReaderLayout>>[ButtonSegment(value: ReaderLayout.lines, label: Text('Lines')), ButtonSegment(value: ReaderLayout.paragraph, label: Text('Paragraph'))], selected: <ReaderLayout>{state.preferences.layout}, onSelectionChanged: (Set<ReaderLayout> value) => state.setLayout(value.first)),
  ]))));
}

/// A compact, non-interactive status notice for Scripture served from cache.
///
/// [MaterialBanner] is reserved for messages with at least one action. Cache
/// freshness is informational, so this responsive notice avoids presenting a
/// fake dismiss action and remains usable with narrow windows and large text.
class CacheStatusNotice extends StatelessWidget {
  const CacheStatusNotice({required this.freshness, super.key})
    : assert(freshness != CacheFreshness.fresh);

  final CacheFreshness freshness;

  @override
  Widget build(BuildContext context) {
    final bool verified = freshness == CacheFreshness.cachedVerified;
    final String message = verified
        ? 'Verified cached Scripture'
        : 'Offline cached Scripture — verification unavailable';
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: verified ? colors.primary : colors.error,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.state});
  final AppState state;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(8), child: Row(children: <Widget>[
    Expanded(child: DropdownButtonFormField<String>(initialValue: state.passage.translation, decoration: const InputDecoration(labelText: 'Translation'), items: state.translations.map((Translation t) => DropdownMenuItem(value: t.abbreviation, child: Text(t.abbreviation.toUpperCase()))).toList(), onChanged: (String? value) { if (value != null) state.loadPassage(Passage(translation: value, book: state.passage.book, chapter: state.passage.chapter)); })),
    const SizedBox(width: 8),
    Expanded(flex: 2, child: DropdownButtonFormField<int>(initialValue: state.passage.book, decoration: const InputDecoration(labelText: 'Book'), items: state.books.map((BibleBook b) => DropdownMenuItem(value: b.number, child: Text(b.name))).toList(), onChanged: (int? value) { if (value != null) state.loadPassage(Passage(translation: state.passage.translation, book: value, chapter: 1)); })),
    const SizedBox(width: 8),
    SizedBox(width: 92, child: TextFormField(initialValue: '${state.passage.chapter}', decoration: const InputDecoration(labelText: 'Chapter'), keyboardType: TextInputType.number, onFieldSubmitted: (String value) { final int? chapter = int.tryParse(value); if (chapter != null && chapter > 0) state.loadPassage(Passage(translation: state.passage.translation, book: state.passage.book, chapter: chapter)); })),
  ]));
}

class _VerseLine extends StatelessWidget {
  const _VerseLine({required this.verse, required this.size});
  final Verse verse; final double size;
  @override Widget build(BuildContext context) => Semantics(label: 'Verse ${verse.verse}: ${verse.text}', child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: SelectableText.rich(TextSpan(children: <InlineSpan>[
    TextSpan(text: '${verse.verse} ', style: TextStyle(fontSize: size * .65, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
    TextSpan(text: verse.text, style: TextStyle(fontSize: size, height: 1.5)),
  ]))));
}
