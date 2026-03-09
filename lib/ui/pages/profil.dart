import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uztelecom/domain/services/profile_service.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/settings_pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  final bool embedded;

  const ProfilePage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Container(
      color: isDark ? const Color(0xFF0B1724) : const Color(0xFFF7F7F7),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileHeader(),
              SizedBox(height: 18),
              const SettingsSections(
                scrollable: false,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );

    return embedded ? content : Scaffold(body: content);
  }
}

class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader();

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  static const String _avatarPrefsKey = 'profile_avatar_path';
  final ProfileService _service = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  late Future<ProfileInfo> _future;
  String? _avatarPath;
  bool _isPickingAvatar = false;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchProfile();
    _loadAvatar();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
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
        SnackBar(
          content: Text(
            tr(
              context,
              uz: 'Profil rasmi yangilandi.',
              ru: 'Фото профиля обновлено.',
            ),
          ),
        ),
      );
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              uz: 'Galereyani ochib bo‘lmadi.',
              ru: 'Не удалось открыть галерею.',
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              context,
              uz: 'Rasm tanlashda xatolik yuz berdi.',
              ru: 'Произошла ошибка при выборе изображения.',
            ),
          ),
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
      final first = parts.first;
      return first.characters.take(1).toString().toUpperCase();
    }
    final first = parts.first.characters.take(1).toString();
    final second = parts[1].characters.take(1).toString();
    return '$first$second'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? const Color(0xFFE4E9F0)
        : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? const Color(0xFFAFC0D4)
        : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0F1E2F) : Colors.white;
    final cardBorder = isDark
        ? const Color(0xFF1F3248)
        : const Color(0xFFE3E8F0);
    final avatarBg = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFF2F5FA);
    final avatarText = isDark
        ? const Color(0xFF8FB3FF)
        : const Color(0xFF2F5EE8);
    final buttonBg = isDark ? const Color(0xFF122438) : const Color(0xFFF8FAFF);
    final buttonBorder = isDark
        ? const Color(0xFF2A3E57)
        : const Color(0xFFD7E1F3);
    final buttonText = isDark
        ? const Color(0xFFD8E4FF)
        : const Color(0xFF1E3A8A);

    return FutureBuilder<ProfileInfo>(
      future: _future,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final hasError = snapshot.hasError || info == null;
        final fullName = info?.fullName.trim().isNotEmpty ?? false
            ? info!.fullName.trim()
            : tr(context, uz: 'Foydalanuvchi', ru: 'Пользователь');
        final email = info?.email?.trim();
        final secondaryText = hasError
            ? tr(
                context,
                uz: "Profil ma'lumotlari yuklanmadi.",
                ru: 'Не удалось загрузить профиль.',
              )
            : (email != null && email.isNotEmpty
                  ? email
                  : tr(
                      context,
                      uz: 'Email kiritilmagan',
                      ru: 'Email не указан',
                    ));

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
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
                            ? const [Color(0xFF1E40AF), Color(0xFF4F46E5)]
                            : const [Color(0xFF3B82F6), Color(0xFF4F46E5)],
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
                                ? const Color(0xFF2C4058)
                                : const Color(0xFFE5EAF2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
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
                        tr(context, uz: "Tahrirlash", ru: 'Изменить'),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;

  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFE4E9F0) : Colors.black87;
    final textSecondary = isDark ? const Color(0xFFB5C0CF) : Colors.black45;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          action,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}

class _BadgesRow extends StatelessWidget {
  const _BadgesRow();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: const [
          _BadgeItem(title: "So'z jangchisi", icon: Icons.shield_outlined),
          _BadgeItem(title: 'Vunderkind', icon: Icons.school_outlined),
          _BadgeItem(title: 'Marafonchi', icon: Icons.emoji_events_outlined),
          _BadgeItem(title: "Tezkor o'quvchi", icon: Icons.flash_on_outlined),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _BadgeItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = isDark ? const Color(0xFF1E2A3A) : const Color(0xFFE6E6E6);
    final iconColor = isDark ? const Color(0xFFB5C0CF) : Colors.grey.shade700;
    final labelColor = isDark ? const Color(0xFFB5C0CF) : Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1B2736) : const Color(0xFFF1F2F0);
    final iconBg = isDark ? const Color(0xFF24354A) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE4E9F0) : Colors.black87;
    final textSecondary = isDark ? const Color(0xFFB5C0CF) : Colors.black54;
    final borderColor = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFFE0A85A);
    final chipText = isDark ? const Color(0xFFBFD6FF) : Colors.black54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: const Icon(Icons.access_time, color: Color(0xFFE15A5A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(context, uz: 'Sarflangan', ru: 'Потрачено'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr(context, uz: '22 daqiqa', ru: '22 минуты'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Text(
                  tr(context, uz: 'Haftalik', ru: 'Еженедельно'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: chipText,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16, color: chipText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          tr(
            context,
            uz: 'Arizalar hozircha mavjud emas.',
            ru: 'Заявок пока нет.',
          ),
        ),
      ),
    );
  }
}
