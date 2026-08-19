# 18 — Notes

Keep it simple. **Not** a Notion clone.

## Hierarchy

```
Note
 ├── (optional) Subject
 └── (optional) Topic
```

## Features

- Plain text + checklist mode (`- [ ] item` syntax)
- Pin a note (sticky at top)
- Search by title or body
- Edit / delete

## UI

- List with title (max 1 line) and body preview (max 2 lines).
- Pin icon on the right.
- FAB → new note editor.

## Editor

- Single text field.
- Markdown-lite rendering on preview toggle:
  - `# Heading`
  - `- list item`
  - `- [ ] checklist`
  - `**bold**`, `*italic*`

## Files

```
lib/features/notes/
├── models/note.dart
├── repositories/notes_repository.dart
├── view_models/notes_view_model.dart
├── views/notes_view.dart
└── views/note_editor_view.dart
```

## Linked to

- Subject Details (Notes tab) — filtered by subject.
- Global Search (25).