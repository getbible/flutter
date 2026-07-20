import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/app_state.dart';
import '../domain/models/annotations.dart';
import '../domain/models/bible.dart';
import '../domain/models/cache.dart';
import '../domain/models/passage.dart';
import '../domain/models/search.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = <int, GlobalKey>{};
  int? _boundaryDirection;
  DateTime? _boundaryAt;
  int? _editingNote;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = context.watch<AppState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: _ReaderDrawer(state: state),
      endDrawer: _StudyDrawer(
        state: state,
        onOpenPassage: _openPassage,
      ),
      appBar: _ReaderAppBar(
        state: state,
        onMenu: () => _scaffoldKey.currentState?.openDrawer(),
        onStudy: () => _scaffoldKey.currentState?.openEndDrawer(),
        onSearch: () => _showSearch(context, state),
      ),
      body: SafeArea(child: _body(context, state)),
    );
  }

  Widget _body(BuildContext context, AppState state) {
    if (state.loading && state.current == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.current == null) {
      return _ErrorState(state: state);
    }
    final BibleChapter chapter = state.current!;
    final TextDirection direction = chapter.isRtl
        ? TextDirection.rtl
        : TextDirection.ltr;
    return Directionality(
      textDirection: direction,
      child: Column(
        children: <Widget>[
          _ChapterHeading(state: state),
          if (state.freshness != CacheFreshness.fresh)
            CacheStatusNotice(freshness: state.freshness!),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (DragEndDetails details) {
                final double velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() < 350) return;
                unawaited(_turn(state, velocity > 0 ? -1 : 1));
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notice) =>
                    _onScrollNotification(notice, state),
                child: _ReaderBody(
                  state: state,
                  controller: _scrollController,
                  verseKeys: _verseKeys,
                  editingNote: _editingNote,
                  onEditNote: (int? verse) =>
                      setState(() => _editingNote = verse),
                  onOpenVerseMenu: _showVerseMenu,
                ),
              ),
            ),
          ),
          _MobileChapterNavigation(state: state, onTurn: _turn),
        ],
      ),
    );
  }

  bool _onScrollNotification(ScrollNotification notice, AppState state) {
    if (notice is! OverscrollNotification || notice.overscroll == 0) {
      return false;
    }
    final int direction = notice.overscroll > 0 ? 1 : -1;
    final DateTime now = DateTime.now();
    final bool repeated = _boundaryDirection == direction &&
        _boundaryAt != null &&
        now.difference(_boundaryAt!) <= const Duration(milliseconds: 2200);
    _boundaryDirection = direction;
    _boundaryAt = now;
    if (repeated) {
      _boundaryDirection = null;
      _boundaryAt = null;
      unawaited(_turn(state, direction));
    }
    return false;
  }

  Future<void> _turn(AppState state, int direction) async {
    if ((direction < 0 && !state.canGoPrevious) ||
        (direction > 0 && !state.canGoNext)) {
      return;
    }
    await state.turnChapter(direction);
    if (!mounted) return;
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  Future<void> _openPassage(Passage passage) async {
    final AppState state = context.read<AppState>();
    await Navigator.of(context).maybePop();
    if (!mounted) return;
    await state.loadPassage(passage);
    if (!mounted) return;
    await _scrollToVerse(passage.verse);
  }

  Future<void> _scrollToVerse(int? verse) async {
    if (verse == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    final BuildContext? target = _verseKeys[verse]?.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        alignment: 0.2,
        duration: const Duration(milliseconds: 260),
      );
    }
  }

  Future<void> _showVerseMenu(
    BuildContext anchorContext,
    Verse verse,
    String reference,
  ) async {
    final AppState state = context.read<AppState>();
    final RenderBox button = anchorContext.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Rect target = topLeft & button.size;
    final String? choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(target, Offset.zero & overlay.size),
      semanticLabel: 'Choose marking for $reference',
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: '__note__',
          child: Text(
            state.notes.any((VerseNote note) => note.verse == verse.verse)
                ? 'Edit note'
                : 'Add note',
          ),
        ),
        if (state.markings.any(
          (Marking marking) =>
              marking.verse == verse.verse && marking.isWholeVerse,
        ))
          const PopupMenuItem<String>(
            value: '__none__',
            child: Text('Remove verse marking'),
          ),
        const PopupMenuDivider(),
        for (final MarkingGroup group in state.groups)
          PopupMenuItem<String>(
            value: group.id,
            child: _GroupChoice(group: group),
          ),
      ],
    );
    if (choice == null || !mounted) return;
    if (choice == '__note__') {
      setState(() => _editingNote = verse.verse);
    } else if (choice == '__none__') {
      await state.removeWholeVerseMarking(verse.verse);
    } else {
      await state.markWholeVerse(verse, reference, choice);
    }
  }

  Future<void> _showSearch(BuildContext context, AppState state) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => _SearchDialog(
        state: state,
        onOpen: (SearchVerse result) async {
          Navigator.of(context).pop();
          await state.loadPassage(
            Passage(
              translation: state.passage.translation,
              book: result.book,
              chapter: result.chapter,
              verse: result.verse,
            ),
          );
          await _scrollToVerse(result.verse);
        },
      ),
    );
  }
}

class _ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ReaderAppBar({
    required this.state,
    required this.onMenu,
    required this.onStudy,
    required this.onSearch,
  });

  final AppState state;
  final VoidCallback onMenu;
  final VoidCallback onStudy;
  final VoidCallback onSearch;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 720;
    return AppBar(
      toolbarHeight: 62,
      leading: IconButton(
        tooltip: 'Reader navigation and settings',
        onPressed: onMenu,
        icon: const Icon(Icons.menu),
      ),
      titleSpacing: 4,
      title: Row(
        children: <Widget>[
          Image.asset(
            'assets/branding/getbible_app_icon.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'getBible.Life',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          if (!compact) ...<Widget>[
            const SizedBox(width: 18),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onSearch,
                child: IgnorePointer(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        if (compact)
          IconButton(
            tooltip: 'Search this translation',
            onPressed: onSearch,
            icon: const Icon(Icons.search),
          ),
        IconButton(
          tooltip: 'Previous chapter',
          onPressed: state.canGoPrevious
              ? () => unawaited(state.turnChapter(-1))
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next chapter',
          onPressed:
              state.canGoNext ? () => unawaited(state.turnChapter(1)) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 10),
          child: OutlinedButton(onPressed: onStudy, child: const Text('Study')),
        ),
      ],
    );
  }
}

class _ChapterHeading extends StatelessWidget {
  const _ChapterHeading({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final BibleChapter chapter = state.current!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: <Widget>[
          Text(chapter.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Text(
            chapter.abbreviation.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const Spacer(),
          Semantics(
            label: state.freshness == CacheFreshness.cachedUnverified
                ? 'Saved offline Scripture'
                : 'Verified Scripture',
            child: Text(
              state.freshness == CacheFreshness.cachedUnverified
                  ? 'SAVED'
                  : 'VERIFIED',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderBody extends StatelessWidget {
  const _ReaderBody({
    required this.state,
    required this.controller,
    required this.verseKeys,
    required this.editingNote,
    required this.onEditNote,
    required this.onOpenVerseMenu,
  });

  final AppState state;
  final ScrollController controller;
  final Map<int, GlobalKey> verseKeys;
  final int? editingNote;
  final ValueChanged<int?> onEditNote;
  final Future<void> Function(BuildContext, Verse, String) onOpenVerseMenu;

  @override
  Widget build(BuildContext context) {
    final BibleChapter chapter = state.current!;
    final double maximumWidth = state.preferences.readingWidth ==
            ReadingWidth.constrained
        ? 920
        : double.infinity;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maximumWidth),
        child: ListView.builder(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          itemCount: chapter.verses.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == chapter.verses.length) {
              return _ChapterFooter(state: state);
            }
            final Verse verse = chapter.verses[index];
            final GlobalKey key = verseKeys.putIfAbsent(
              verse.verse,
              GlobalKey.new,
            );
            final String reference =
                '${chapter.bookName} ${chapter.chapter}:${verse.verse}';
            final VerseNote? note = state.notes
                .where((VerseNote item) => item.verse == verse.verse)
                .firstOrNull;
            return _VerseLine(
              key: key,
              state: state,
              verse: verse,
              reference: reference,
              note: note,
              editing: editingNote == verse.verse,
              onEditNote: onEditNote,
              onOpenMenu: onOpenVerseMenu,
            );
          },
        ),
      ),
    );
  }
}

class _VerseLine extends StatelessWidget {
  const _VerseLine({
    super.key,
    required this.state,
    required this.verse,
    required this.reference,
    required this.note,
    required this.editing,
    required this.onEditNote,
    required this.onOpenMenu,
  });

  final AppState state;
  final Verse verse;
  final String reference;
  final VerseNote? note;
  final bool editing;
  final ValueChanged<int?> onEditNote;
  final Future<void> Function(BuildContext, Verse, String) onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final Marking? whole = state.markings
        .where((Marking item) => item.verse == verse.verse && item.isWholeVerse)
        .firstOrNull;
    final MarkingGroup? wholeGroup = whole == null
        ? null
        : state.groups
            .where((MarkingGroup item) => item.id == whole.groupId)
            .firstOrNull;
    final Color? wholeColor = wholeGroup == null
        ? null
        : _hexColor(wholeGroup.color).withAlpha(45);
    return Semantics(
      label: '$reference. ${verse.text}',
      child: ColoredBox(
        color: wholeColor ?? Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Builder(
                    builder: (BuildContext anchorContext) => InkWell(
                      onTap: () => onOpenMenu(anchorContext, verse, reference),
                      borderRadius: BorderRadius.circular(20),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 44, minHeight: 44),
                        child: Center(
                          child: Text(
                            '${verse.verse}',
                            style: TextStyle(
                              fontSize: state.preferences.textSize * 0.58,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _SelectableMarkedVerse(state: state, verse: verse, reference: reference)),
                ],
              ),
              if (editing)
                _InlineNoteEditor(
                  state: state,
                  verse: verse.verse,
                  reference: reference,
                  note: note,
                  onClose: () => onEditNote(null),
                )
              else if (note != null)
                _SavedNote(
                  note: note!,
                  onTap: () => onEditNote(verse.verse),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectableMarkedVerse extends StatelessWidget {
  const _SelectableMarkedVerse({required this.state, required this.verse, required this.reference});

  final AppState state;
  final Verse verse;
  final String reference;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      _markedText(context),
      contextMenuBuilder:
          (BuildContext context, EditableTextState editableTextState) {
        final TextSelection selection =
            editableTextState.textEditingValue.selection;
        final bool valid = selection.isValid &&
            !selection.isCollapsed &&
            selection.start >= 0 &&
            selection.end <= verse.text.length;
        final List<ContextMenuButtonItem> buttons = <ContextMenuButtonItem>[
          ...editableTextState.contextMenuButtonItems,
          if (valid && state.activeGroup != null)
            ContextMenuButtonItem(
              label: 'Mark: ${state.activeGroup!.name}',
              onPressed: () {
                editableTextState.hideToolbar();
                unawaited(state.markSelectedText(
                  verse,
                  selection.start,
                  selection.end,
                  reference,
                  state.activeGroup!.id,
                ));
              },
            ),
          if (valid &&
              state.selectionHasMarking(
                verse.verse,
                selection.start,
                selection.end,
              ))
            ContextMenuButtonItem(
              label: 'Remove highlighting',
              onPressed: () {
                editableTextState.hideToolbar();
                unawaited(state.removeSelectionMarkings(
                  verse.verse,
                  selection.start,
                  selection.end,
                ));
              },
            ),
        ];
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: buttons,
        );
      },
    );
  }

  TextSpan _markedText(BuildContext context) {
    final List<Marking> ranged = state.markings
        .where((Marking item) =>
            item.verse == verse.verse &&
            !item.isWholeVerse &&
            item.start! >= 0 &&
            item.end! <= verse.text.length)
        .toList()
      ..sort((Marking left, Marking right) => left.start!.compareTo(right.start!));
    final Set<int> boundaries = <int>{0, verse.text.length};
    for (final Marking marking in ranged) {
      boundaries.add(marking.start!);
      boundaries.add(marking.end!);
    }
    final List<int> offsets = boundaries.toList()..sort();
    final List<InlineSpan> spans = <InlineSpan>[];
    for (int index = 0; index < offsets.length - 1; index++) {
      final int start = offsets[index];
      final int end = offsets[index + 1];
      final Marking? marking = ranged.reversed
          .where((Marking item) => item.start! <= start && item.end! >= end)
          .firstOrNull;
      final MarkingGroup? group = marking == null
          ? null
          : state.groups
              .where((MarkingGroup item) => item.id == marking.groupId)
              .firstOrNull;
      spans.add(TextSpan(
        text: verse.text.substring(start, end),
        style: TextStyle(
          backgroundColor: group == null ? null : _hexColor(group.color),
        ),
      ));
    }
    return TextSpan(
      style: TextStyle(
        fontFamily: _fontFamily(state.preferences.readerFont),
        fontSize: state.preferences.textSize,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      children: spans,
    );
  }
}

class _InlineNoteEditor extends StatefulWidget {
  const _InlineNoteEditor({
    required this.state,
    required this.verse,
    required this.reference,
    required this.note,
    required this.onClose,
  });

  final AppState state;
  final int verse;
  final String reference;
  final VerseNote? note;
  final VoidCallback onClose;

  @override
  State<_InlineNoteEditor> createState() => _InlineNoteEditorState();
}

class _InlineNoteEditorState extends State<_InlineNoteEditor> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.note?.text ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(44, 8, 0, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(widget.reference, style: const TextStyle(fontWeight: FontWeight.w600))),
                IconButton(
                  tooltip: 'Close note editor',
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(hintText: 'Write your note…'),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (widget.note != null)
                  IconButton(
                    tooltip: 'Delete note',
                    onPressed: () async {
                      await widget.state.deleteVerseNote(widget.verse);
                      widget.onClose();
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    await widget.state.saveVerseNote(
      widget.verse,
      widget.reference,
      _controller.text,
    );
    widget.onClose();
  }
}

class _SavedNote extends StatelessWidget {
  const _SavedNote({required this.note, required this.onTap});

  final VerseNote note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(44, 4, 0, 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('NOTE', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 3),
                Text(note.text, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      );
}

class _StudyDrawer extends StatefulWidget {
  const _StudyDrawer({required this.state, required this.onOpenPassage});

  final AppState state;
  final ValueChanged<Passage> onOpenPassage;

  @override
  State<_StudyDrawer> createState() => _StudyDrawerState();
}

class _StudyDrawerState extends State<_StudyDrawer> {
  int _tab = 0;
  String? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final AppState state = widget.state;
    return Drawer(
      width: MediaQuery.sizeOf(context).width.clamp(300, 430).toDouble(),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Study tools', style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: IconButton(
                tooltip: 'Close Study tools',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 0, label: Text('Markings')),
                ButtonSegment<int>(value: 1, label: Text('Notes')),
              ],
              selected: <int>{_tab},
              onSelectionChanged: (Set<int> value) =>
                  setState(() => _tab = value.first),
            ),
            const Divider(),
            Expanded(
              child: _tab == 0 ? _markings(state) : _notes(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _markings(AppState state) {
    if (_selectedGroup != null) {
      final MarkingGroup? group = state.groups
          .where((MarkingGroup item) => item.id == _selectedGroup)
          .firstOrNull;
      final List<Marking> items = state.savedMarkings
          .where((Marking item) => item.groupId == _selectedGroup)
          .toList()
        ..sort(compareMarkings);
      return Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.arrow_back),
            title: Text(group?.name ?? 'Markings'),
            onTap: () => setState(() => _selectedGroup = null),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No markings in this group yet.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Marking marking = items[index];
                      return ListTile(
                        title: Text(marking.reference),
                        subtitle: Text(marking.quote, maxLines: 2, overflow: TextOverflow.ellipsis),
                        onTap: () => widget.onOpenPassage(Passage(
                          translation: state.passage.translation,
                          book: marking.passage.book,
                          chapter: marking.passage.chapter,
                          verse: marking.verse,
                        )),
                      );
                    },
                  ),
          ),
        ],
      );
    }
    return ListView.builder(
      itemCount: state.groups.length,
      itemBuilder: (BuildContext context, int index) {
        final MarkingGroup group = state.groups[index];
        final int count = state.savedMarkings.where((Marking item) => item.groupId == group.id).length;
        return ListTile(
          leading: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(color: _hexColor(group.color), shape: BoxShape.circle),
          ),
          title: Text(group.name),
          subtitle: Text('$count markings'),
          selected: state.preferences.activeMarkingGroupId == group.id,
          onTap: () {
            unawaited(state.selectActiveGroup(group.id));
            setState(() => _selectedGroup = group.id);
          },
        );
      },
    );
  }

  Widget _notes(AppState state) {
    final List<VerseNote> notes = <VerseNote>[...state.savedNotes]..sort(compareNotes);
    if (notes.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No verse notes yet. Select a verse and choose Add note to create one.'),
      ));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) {
        final VerseNote note = notes[index];
        return ListTile(
          title: Text(note.reference),
          subtitle: Text(note.text, maxLines: 3, overflow: TextOverflow.ellipsis),
          onTap: () => widget.onOpenPassage(Passage(
            translation: state.passage.translation,
            book: note.passage.book,
            chapter: note.passage.chapter,
            verse: note.verse,
          )),
        );
      },
    );
  }
}

class _SearchDialog extends StatefulWidget {
  const _SearchDialog({required this.state, required this.onOpen});

  final AppState state;
  final ValueChanged<SearchVerse> onOpen;

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _query = TextEditingController();
  SearchWordMode _words = SearchWordMode.all;
  SearchMatchMode _match = SearchMatchMode.exact;
  SearchScope _scope = const SearchScope.all();
  bool _caseSensitive = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            AppBar(
              leading: IconButton(
                tooltip: 'Close search',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
              title: Text('Search ${widget.state.current?.abbreviation.toUpperCase() ?? ''}'),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _query,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search the Bible',
                      suffixIcon: IconButton(
                        tooltip: 'Search',
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      DropdownButton<SearchWordMode>(
                        value: _words,
                        items: const <DropdownMenuItem<SearchWordMode>>[
                          DropdownMenuItem(value: SearchWordMode.all, child: Text('All words')),
                          DropdownMenuItem(value: SearchWordMode.any, child: Text('Any word')),
                          DropdownMenuItem(value: SearchWordMode.phrase, child: Text('Exact phrase')),
                        ],
                        onChanged: (SearchWordMode? value) => setState(() => _words = value ?? _words),
                      ),
                      DropdownButton<SearchMatchMode>(
                        value: _match,
                        items: const <DropdownMenuItem<SearchMatchMode>>[
                          DropdownMenuItem(value: SearchMatchMode.exact, child: Text('Exact word')),
                          DropdownMenuItem(value: SearchMatchMode.partial, child: Text('Partial word')),
                        ],
                        onChanged: (SearchMatchMode? value) => setState(() => _match = value ?? _match),
                      ),
                      DropdownButton<SearchScope>(
                        value: _scope,
                        items: <DropdownMenuItem<SearchScope>>[
                          const DropdownMenuItem(value: SearchScope.all(), child: Text('Whole Bible')),
                          const DropdownMenuItem(value: SearchScope.oldTestament(), child: Text('Old Testament')),
                          const DropdownMenuItem(value: SearchScope.newTestament(), child: Text('New Testament')),
                          for (final BibleBook book in widget.state.books)
                            DropdownMenuItem(value: SearchScope.book(book.number), child: Text(book.name)),
                        ],
                        onChanged: (SearchScope? value) => setState(() => _scope = value ?? _scope),
                      ),
                      FilterChip(
                        label: const Text('Case sensitive'),
                        selected: _caseSensitive,
                        onSelected: (bool value) => setState(() => _caseSensitive = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: widget.state,
                builder: (BuildContext context, Widget? child) {
                  if (widget.state.searchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (widget.state.searchError != null) {
                    return Center(child: Text(widget.state.searchError!));
                  }
                  if (widget.state.searchResults.isEmpty) {
                    return const Center(child: Text('Enter a search above.'));
                  }
                  return ListView.builder(
                    itemCount: widget.state.searchResults.length,
                    itemBuilder: (BuildContext context, int index) {
                      final SearchVerse result = widget.state.searchResults[index];
                      return ListTile(
                        title: Text(result.reference),
                        subtitle: Text(result.text),
                        onTap: () => widget.onOpen(result),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _search() {
    if (_query.text.trim().isEmpty) return;
    unawaited(widget.state.search(
      _query.text,
      SearchOptions(
        words: _words,
        match: _match,
        caseSensitive: _caseSensitive,
        scope: _scope,
        locale: widget.state.currentTranslation?.lang ?? 'und',
      ),
    ));
  }
}

class _ReaderDrawer extends StatelessWidget {
  const _ReaderDrawer({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) => Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text('Reader', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                initialValue: state.passage.translation,
                decoration: const InputDecoration(labelText: 'Translation'),
                items: state.translations
                    .map((Translation item) => DropdownMenuItem(value: item.abbreviation, child: Text(item.translation)))
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) unawaited(state.loadPassage(Passage(translation: value, book: state.passage.book, chapter: state.passage.chapter)));
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: state.passage.book,
                decoration: const InputDecoration(labelText: 'Book'),
                items: state.books.map((BibleBook item) => DropdownMenuItem(value: item.number, child: Text(item.name))).toList(),
                onChanged: (int? value) {
                  if (value != null) unawaited(state.loadPassage(Passage(translation: state.passage.translation, book: value, chapter: 1)));
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: state.passage.chapter,
                decoration: const InputDecoration(labelText: 'Chapter'),
                items: state.chapters.map((ChapterInfo item) => DropdownMenuItem(value: item.chapter, child: Text('${item.chapter}'))).toList(),
                onChanged: (int? value) {
                  if (value != null) unawaited(state.loadPassage(state.passage.copyWith(chapter: value, clearVerse: true)));
                },
              ),
              const Divider(height: 32),
              const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<AppearanceMode>(
                segments: AppearanceMode.values.map((AppearanceMode value) => ButtonSegment(value: value, label: Text(value.name))).toList(),
                selected: <AppearanceMode>{state.preferences.appearanceMode},
                onSelectionChanged: (Set<AppearanceMode> value) => unawaited(state.setAppearance(value.first)),
              ),
              const SizedBox(height: 16),
              const Text('Text size'),
              Slider(
                min: 16,
                max: 36,
                divisions: 20,
                value: state.preferences.textSize,
                label: '${state.preferences.textSize.round()}',
                onChanged: (double value) => unawaited(state.setTextSize(value)),
              ),
              SegmentedButton<ReaderLayout>(
                segments: const <ButtonSegment<ReaderLayout>>[
                  ButtonSegment(value: ReaderLayout.lines, label: Text('Lines')),
                  ButtonSegment(value: ReaderLayout.paragraph, label: Text('Paragraph')),
                ],
                selected: <ReaderLayout>{state.preferences.layout},
                onSelectionChanged: (Set<ReaderLayout> value) => unawaited(state.setLayout(value.first)),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: state.preferences.lightPalette,
                decoration: const InputDecoration(labelText: 'Light reading palette'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'white', child: Text('Pure white')),
                  DropdownMenuItem(value: 'paper', child: Text('Warm paper')),
                  DropdownMenuItem(value: 'ivory', child: Text('Soft ivory')),
                  DropdownMenuItem(value: 'mist', child: Text('Cool mist')),
                ],
                onChanged: (String? value) {
                  if (value != null) unawaited(state.setLightPalette(value));
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: state.preferences.darkPalette,
                decoration: const InputDecoration(labelText: 'Dark reading palette'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'black', child: Text('Pure black')),
                  DropdownMenuItem(value: 'brown', child: Text('Warm brown')),
                  DropdownMenuItem(value: 'charcoal', child: Text('Soft charcoal')),
                  DropdownMenuItem(value: 'navy', child: Text('Midnight blue')),
                ],
                onChanged: (String? value) {
                  if (value != null) unawaited(state.setDarkPalette(value));
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: state.preferences.readerFont,
                decoration: const InputDecoration(labelText: 'Reading font'),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'serif', child: Text('Classic serif')),
                  DropdownMenuItem(value: 'book', child: Text('Book serif')),
                  DropdownMenuItem(value: 'baskerville', child: Text('Baskerville')),
                  DropdownMenuItem(value: 'garamond', child: Text('Garamond')),
                  DropdownMenuItem(value: 'charter', child: Text('Charter')),
                  DropdownMenuItem(value: 'cambria', child: Text('Cambria')),
                  DropdownMenuItem(value: 'times', child: Text('Times New Roman')),
                  DropdownMenuItem(value: 'sans', child: Text('Clean sans')),
                  DropdownMenuItem(value: 'system', child: Text('System sans')),
                ],
                onChanged: (String? value) {
                  if (value != null) unawaited(state.setReaderFont(value));
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<ReadingWidth>(
                segments: const <ButtonSegment<ReadingWidth>>[
                  ButtonSegment(value: ReadingWidth.full, label: Text('Full width')),
                  ButtonSegment(value: ReadingWidth.constrained, label: Text('Page width')),
                ],
                selected: <ReadingWidth>{state.preferences.readingWidth},
                onSelectionChanged: (Set<ReadingWidth> value) => unawaited(state.setReadingWidth(value.first)),
              ),
            ],
          ),
        ),
      );
}

class _MobileChapterNavigation extends StatelessWidget {
  const _MobileChapterNavigation({required this.state, required this.onTurn});

  final AppState state;
  final Future<void> Function(AppState, int) onTurn;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width > 720) return const SizedBox.shrink();
    return Material(
      elevation: 3,
      child: Row(
        children: <Widget>[
          Expanded(child: TextButton(onPressed: state.canGoPrevious ? () => onTurn(state, -1) : null, child: const Text('Previous'))),
          Expanded(child: Text(state.current?.name ?? '', textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
          Expanded(child: TextButton(onPressed: state.canGoNext ? () => onTurn(state, 1) : null, child: const Text('Next'))),
        ],
      ),
    );
  }
}

class _ChapterFooter extends StatelessWidget {
  const _ChapterFooter({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Divider(),
            Text(state.currentTranslation?.translation ?? state.current?.translation ?? ''),
            if ((state.currentTranslation?.distributionLicense ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(state.currentTranslation!.distributionLicense, style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 16),
              Text(state.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => state.loadPassage(state.passage), child: const Text('Retry')),
            ],
          ),
        ),
      );
}

class _GroupChoice extends StatelessWidget {
  const _GroupChoice({required this.group});

  final MarkingGroup group;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Container(width: 18, height: 18, decoration: BoxDecoration(color: _hexColor(group.color), shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(group.name)),
        ],
      );
}

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              Container(width: 4, height: 22, decoration: BoxDecoration(color: verified ? colors.primary : colors.error, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Expanded(child: Text(message, style: Theme.of(context).textTheme.bodySmall)),
            ],
          ),
        ),
      ),
    );
  }
}

Color _hexColor(String value) {
  final String normalized = value.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

String? _fontFamily(String value) => switch (value) {
      'serif' => 'serif',
      'book' => 'Georgia',
      'baskerville' => 'Baskerville',
      'garamond' => 'Garamond',
      'charter' => 'Charter',
      'cambria' => 'Cambria',
      'times' => 'Times New Roman',
      'sans' => 'Arial',
      _ => null,
    };
