# 27 — Local Files / Resources

Attach references to local files (PDFs, images, notes) from a subject.

## Model

```dart
class LocalResource {
  final int? id;
  final int subjectId;
  final String title;
  final String path;            // absolute path on device
  final String? mimeType;
  final DateTime createdAt;
}
```

## Use cases

- "Lecture 01.pdf" from Downloads
- Personal photo of a whiteboard
- Audio recording of a class

## Implementation

- Use `file_picker` to import (does **not** copy the file, just stores
  the path).
- Tap → opens via `open_filex`.

## Privacy

The app never reads or uploads the contents. Only the file path is stored.

## Files

```
lib/features/resources/
├── models/local_resource.dart
├── repositories/resources_repository.dart
├── view_models/resources_view_model.dart
└── views/resources_view.dart
```

## Offline-first alignment

Since StudyBondhu is offline-first, this is the natural way to bring in
existing study material without any server.