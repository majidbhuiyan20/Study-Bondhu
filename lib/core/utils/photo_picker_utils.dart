import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../l10n.dart' show AppLocalizationsBangla, AppLocalizationsX;

/// Utility for picking, saving, and managing profile photos.
class PhotoPickerUtils {
  PhotoPickerUtils._();

  static final ImagePicker _picker = ImagePicker();

  /// Prompts the user to pick an image from Camera or Gallery (or remove existing).
  /// Saves the image locally into app documents directory and returns the persistent path.
  /// Returns `null` if user cancelled.
  /// Returns `''` (empty string) if user chose to remove photo.
  static Future<String?> showPhotoOptionsSheet(
    BuildContext context, {
    bool hasExistingPhoto = false,
  }) async {
    final l10n = context.l10n;
    final isBn = l10n.isBangla;

    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(isBn ? 'গ্যালারি থেকে বেছে নিন' : 'Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(isBn ? 'ছবি তুলুন' : 'Take a Photo'),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              if (hasExistingPhoto)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    isBn ? 'ছবি মুছে ফেলুন' : 'Remove Photo',
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () => Navigator.pop(ctx, 'remove'),
                ),
            ],
          ),
        ),
      ),
    );

    if (action == null) return null;
    if (action == 'remove') return '';

    final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final xfile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (xfile == null) return null;

    // Save image permanently to app documents/profile_photos directory
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(docDir.path, 'profile_photos'));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
      final ext = p.extension(xfile.path).isNotEmpty ? p.extension(xfile.path) : '.jpg';
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$ext';
      final savedFile = await File(xfile.path).copy(p.join(photosDir.path, fileName));
      return savedFile.path;
    } catch (_) {
      return xfile.path;
    }
  }
}
