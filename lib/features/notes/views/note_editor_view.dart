import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsCamelCase;
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/markdown_lite.dart';
import '../models/note.dart';
import '../view_models/notes_view_model.dart';

class NoteEditorView extends ConsumerStatefulWidget {
  const NoteEditorView({super.key, this.note, this.noteId});
  final Note? note;
  final int? noteId;

  @override
  ConsumerState<NoteEditorView> createState() => _State();
}

class _State extends ConsumerState<NoteEditorView> {
  late TextEditingController _title;
  late TextEditingController _body;
  bool _saving = false;
  bool _preview = false;
  bool _pinned = false;
  Note? _activeNote;

  @override
  void initState() {
    super.initState();
    _activeNote = widget.note;
    _title = TextEditingController(text: _activeNote?.title ?? '');
    _body = TextEditingController(text: _activeNote?.body ?? '');
    _pinned = _activeNote?.isPinned ?? false;

    if (_activeNote == null && widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final notes = ref.read(notesViewModelProvider).notes;
        Note? found;
        for (final n in notes) {
          if (n.id == widget.noteId) {
            found = n;
            break;
          }
        }
        if (found != null && mounted) {
          setState(() {
            _activeNote = found;
            _title.text = found!.title;
            _body.text = found.body;
            _pinned = found.isPinned;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    if (_activeNote == null) {
      final id = await ref.read(notesViewModelProvider.notifier).addNote(
            Note(
              title: _title.text.trim(),
              body: _body.text,
              isPinned: _pinned,
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (mounted) Navigator.pop(context, id);
    } else {
      await ref.read(notesViewModelProvider.notifier).updateNote(
            _activeNote!.copyWith(
              title: _title.text.trim(),
              body: _body.text,
              isPinned: _pinned,
              updatedAt: now,
            ),
          );
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _delete() async {
    if (_activeNote?.id == null) return;
    await ref
        .read(notesViewModelProvider.notifier)
        .deleteNote(_activeNote!.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? l10n.newNote : l10n.editNote),
        actions: [
          IconButton(
            tooltip: _preview ? 'Edit' : 'Preview',
            onPressed: () => setState(() => _preview = !_preview),
            icon: Icon(_preview
                ? Icons.edit_outlined
                : Icons.visibility_outlined),
          ),
          IconButton(
            tooltip: _pinned ? 'Unpin' : 'Pin',
            onPressed: () => setState(() => _pinned = !_pinned),
            icon: Icon(
              _pinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _pinned ? AppColors.primary : null,
            ),
          ),
          if (widget.note != null)
            IconButton(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: l10n.noteTitle,
                border: InputBorder.none,
                filled: false,
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: _preview
                  ? SingleChildScrollView(
                      child: MarkdownLite(source: _body.text),
                    )
                  : TextField(
                      controller: _body,
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: l10n.noteBodyHint,
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: widget.note == null ? l10n.newNote : l10n.editNote,
              onPressed: _saving ? null : _save,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
