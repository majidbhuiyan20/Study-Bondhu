import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n.dart' show AppLocalizationsX,AppLocalizationsBangla;
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/widgets/app_card.dart';

/// Spec #31 — manual backup. V1 ships offline-only; we expose:
///   - **Export**: dump every table to a single JSON file in the documents
///     directory and surface the path so it can be copied / shared.
///   - **Restore**: paste the full path to a JSON file (file picker plugin
///     would be the proper V2 upgrade).
class BackupView extends ConsumerStatefulWidget {
  const BackupView({super.key});

  @override
  ConsumerState<BackupView> createState() => _State();
}

class _State extends ConsumerState<BackupView> {
  bool _busy = false;
  String? _lastExportPath;
  String? _lastMessage;
  bool _lastSuccess = true;

  Future<void> _doExport() async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _lastMessage = null;
    });
    try {
      final file =
          await ref.read(backupServiceProvider).exportToFile();
      if (!mounted) return;
      setState(() {
        _lastExportPath = file.path;
        _lastMessage = l10n.isBangla
            ? 'ব্যাকআপ তৈরি হয়েছে'
            : 'Backup created';
        _lastSuccess = true;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastMessage = l10n.isBangla
            ? 'ব্যাকআপ ব্যর্থ: $e'
            : 'Backup failed: $e';
        _lastSuccess = false;
        _busy = false;
      });
    }
  }

  Future<void> _showRestoreDialog() async {
    final l10n = context.l10n;
    final pathCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.isBangla
              ? 'রিস্টোর করতে ফাইলের পাথ দিন'
              : 'Enter backup file path'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.isBangla
                    ? 'সতর্কতা: বর্তমান ডেটা মুছে যাবে এবং ব্যাকআপের ডেটা দিয়ে প্রতিস্থাপিত হবে।'
                    : 'Warning: existing data will be wiped and replaced with the backup contents.',
                style: TextStyle(
                    color: ThemeColors.textSecondary(context), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pathCtrl,
                decoration: const InputDecoration(
                  hintText: '/path/to/backup.json',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.isBangla ? 'বাতিল' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, pathCtrl.text.trim()),
              child: Text(l10n.isBangla ? 'রিস্টোর' : 'Restore'),
            ),
          ],
        );
      },
    );
    if (result == null || result.isEmpty) return;
    await _doRestore(result);
  }

  Future<void> _doRestore(String path) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _lastMessage = null;
    });
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw l10n.isBangla ? 'ফাইল পাওয়া যায়নি' : 'File not found';
      }
      await ref.read(backupServiceProvider).restoreFromFile(file);
      if (!mounted) return;
      setState(() {
        _lastMessage = l10n.isBangla
            ? 'রিস্টোর সম্পন্ন — অ্যাপ পুনরায় চালু করুন'
            : 'Restore complete — please reopen the app';
        _lastSuccess = true;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastMessage = l10n.isBangla
            ? 'রিস্টোর ব্যর্থ: $e'
            : 'Restore failed: $e';
        _lastSuccess = false;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;
    return Scaffold(
      appBar: AppBar(title: Text(isBn ? 'ব্যাকআপ' : 'Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.cloud_off_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn
                            ? 'ডেটা শুধু এই ডিভাইসে থাকে'
                            : 'Data stays on this device',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBn
                            ? 'StudyBondhu সম্পূর্ণ অফলাইন। ব্যাকআপ নিজে তৈরি ও শেয়ার করুন।'
                            : 'StudyBondhu is fully offline. Create and share backups yourself.',
                        style: TextStyle(
                            color: ThemeColors.textSecondary(context),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            onTap: _busy ? null : _doExport,
            child: Row(
              children: [
                const Icon(Icons.file_download_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          isBn
                              ? 'JSON ফাইলে এক্সপোর্ট'
                              : 'Export to JSON file',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      Text(
                          isBn
                              ? 'ডিভাইসে ফাইল তৈরি হবে'
                              : 'Save a backup file locally',
                          style: TextStyle(
                              color: ThemeColors.textSecondary(context),
                              fontSize: 12)),
                    ],
                  ),
                ),
                if (_busy)
                  const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: _busy ? null : _showRestoreDialog,
            child: Row(
              children: [
                const Icon(Icons.file_upload_rounded,
                    color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          isBn
                              ? 'JSON থেকে রিস্টোর'
                              : 'Restore from JSON',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      Text(
                          isBn
                              ? 'বর্তমান ডেটা মুছে ব্যাকআপ দিয়ে প্রতিস্থাপন'
                              : 'Wipe current data and replace with backup',
                          style: TextStyle(
                              color: ThemeColors.textSecondary(context),
                              fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          if (_lastMessage != null) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  Icon(
                    _lastSuccess ? Icons.check_circle : Icons.error_outline,
                    color: _lastSuccess ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_lastMessage!)),
                  if (_lastExportPath != null)
                    IconButton(
                      tooltip: 'Copy path',
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(
                            ClipboardData(text: _lastExportPath!));
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(isBn
                                ? 'পাথ কপি হয়েছে'
                                : 'Path copied'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}