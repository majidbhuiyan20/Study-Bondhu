# 31 — Backup (V2+)

V1 ships as **completely offline**. Backup is a future feature.

## Roadmap

```
Local Database
      ↓
Backup
      ↓
Cloud Storage
```

## Possible features

- Manual backup to Google Drive / iCloud.
- Auto backup on a schedule (weekly).
- Restore from a backup file.
- Export to JSON.
- Import from JSON.
- Multi-device sync (requires account).

## Privacy stance

Cloud backup is **opt-in** and **explicit**. The user must:

1. Enable cloud backup in Settings.
2. Sign in to their cloud provider.
3. Confirm the first backup.

Without all three, data stays on the device.

## Implementation notes (V2)

- Export: serialize all tables to JSON via `sqflite` cursor.
- Cloud: use platform-native APIs (Google Drive REST, iCloud via
  CloudKit).
- Sync: track `updated_at` per row, sync deltas.

See `36_privacy.md` for the data-handling principles.