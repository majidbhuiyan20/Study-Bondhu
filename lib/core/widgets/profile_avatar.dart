import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Reusable profile avatar displaying the user's photo (if valid file path exists)
/// or falling back to initials with stylized background.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.avatarPath,
    this.radius = 28,
    this.showEditBadge = false,
    this.onTap,
    this.borderColor,
    this.borderWidth = 2,
    this.backgroundColor,
  });

  final String name;
  final String? avatarPath;
  final double radius;
  final bool showEditBadge;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  bool get _hasValidFile {
    if (avatarPath == null || avatarPath!.trim().isEmpty) return false;
    try {
      final file = File(avatarPath!);
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final bColor = borderColor ?? Colors.white.withValues(alpha: 0.7);

    Widget avatarWidget = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.primaryLight,
        border: Border.all(color: bColor, width: borderWidth),
        image: _hasValidFile
            ? DecorationImage(
                image: FileImage(File(avatarPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: _hasValidFile
          ? null
          : Text(
              _initial,
              style: TextStyle(
                color: backgroundColor != null ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.75,
              ),
            ),
    );

    if (showEditBadge) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(radius * 0.12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: radius * 0.45,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
