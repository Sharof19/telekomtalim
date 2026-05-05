import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/providers/profile/profile_provider.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  static const String _avatarPrefsKey = 'profile_avatar_path';

  final ImagePicker _imagePicker = ImagePicker();
  String? _avatarPath;
  bool _isPickingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_avatarPrefsKey);
    if (savedPath == null || savedPath.isEmpty) return;
    if (!await File(savedPath).exists()) {
      await prefs.remove(_avatarPrefsKey);
      return;
    }
    if (!mounted) return;
    setState(() => _avatarPath = savedPath);
  }

  Future<void> _pickAvatarFromGallery() async {
    if (_isPickingAvatar) return;
    try {
      setState(() => _isPickingAvatar = true);
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked == null) return;

      final docsDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${docsDir.path}/profile_avatar');
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final newPath =
          '${avatarDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await picked.saveTo(newPath);

      final prefs = await SharedPreferences.getInstance();
      final oldPath = _avatarPath;
      await prefs.setString(_avatarPrefsKey, newPath);

      if (!mounted) return;
      setState(() => _avatarPath = newPath);

      if (oldPath != null &&
          oldPath.isNotEmpty &&
          oldPath != newPath &&
          await File(oldPath).exists()) {
        await File(oldPath).delete();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.profilRasmiYangilandi))),
      );
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.galereyaniOchibBolmadi))),
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to pick or save profile avatar.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr(context, TrKey.rasmTanlashdaXatolikYuzBerdi)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingAvatar = false);
      }
    }
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.characters.take(1).toString().toUpperCase();
    }
    final first = parts.first.characters.take(1).toString();
    final second = parts[1].characters.take(1).toString();
    return '$first$second'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkText
        : AppColors.profileTextLight;
    final textSecondary = isDark
        ? AppColors.profileTextMutedDark
        : AppColors.lightMuted;
    final cardBg = isDark ? AppColors.profileCardDark : AppColors.white;
    final cardBorder = isDark
        ? AppColors.cardBorderDark
        : AppColors.cardBorderLight;
    final avatarBg = isDark
        ? AppColors.profileAvatarDark
        : AppColors.profileAvatarLight;
    final avatarText = isDark
        ? AppColors.profileAvatarTextDark
        : AppColors.brandBlue;
    final buttonBg = isDark
        ? AppColors.profileButtonBgDark
        : AppColors.profileButtonBgLight;
    final buttonBorder = isDark
        ? AppColors.profileButtonBorderDark
        : AppColors.profileButtonBorderLight;
    final buttonText = isDark
        ? AppColors.profileButtonTextDark
        : AppColors.examAnswerExpectedText;

    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final info = provider.profile;
        final hasError = provider.error != null || info == null;
        final fullName = info?.fullName.trim().isNotEmpty ?? false
            ? info!.fullName.trim()
            : tr(context, TrKey.foydalanuvchi);
        final email = info?.email?.trim();
        final secondaryText = hasError
            ? tr(context, TrKey.profilMalumotlariYuklanmadi)
            : (email != null && email.isNotEmpty
                  ? email
                  : tr(context, TrKey.emailKiritilmagan));

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 112,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [
                                AppColors.profileHeaderGradientDarkStart,
                                AppColors.profileHeaderGradientDarkEnd,
                              ]
                            : const [
                                AppColors.brandBlue,
                                AppColors.profileHeaderGradientDarkEnd,
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    bottom: -34,
                    child: GestureDetector(
                      onTap: _pickAvatarFromGallery,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: avatarBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark
                                ? AppColors.profileAvatarBorderDark
                                : AppColors.profileAvatarBorderLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _isPickingAvatar
                            ? Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      avatarText,
                                    ),
                                  ),
                                ),
                              )
                            : (_avatarPath != null &&
                                  File(_avatarPath!).existsSync())
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(21),
                                child: Image.file(
                                  File(_avatarPath!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  _initials(fullName),
                                  style: TextStyle(
                                    color: avatarText,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: -22,
                    child: OutlinedButton.icon(
                      onPressed: _pickAvatarFromGallery,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: buttonBg,
                        side: BorderSide(color: buttonBorder),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: buttonText,
                      ),
                      label: Text(
                        tr(context, TrKey.editAction),
                        style: TextStyle(
                          color: buttonText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 48, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 28,
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      secondaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
