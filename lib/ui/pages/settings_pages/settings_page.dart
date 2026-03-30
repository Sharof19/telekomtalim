import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uztelecom/domain/provider/provider.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeModeProvider>();
    final isDark = themeProvider.isDark;
    final background = isDark
        ? const Color(0xFF0B1724)
        : const Color(0xFFF7F7F7);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        foregroundColor: isDark ? const Color(0xFFE4E9F0) : Colors.black87,
        title: Text(
          tr(context, uz: 'Sozlamalar', ru: 'Настройки'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: const SettingsSections(),
    );
  }
}

class SettingsSections extends StatefulWidget {
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  const SettingsSections({
    super.key,
    this.scrollable = true,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
  });

  @override
  State<SettingsSections> createState() => _SettingsSectionsState();
}

class _SettingsSectionsState extends State<SettingsSections> {
  final AuthRepository _loginService = AuthRepository();
  bool _loggingOut = false;

  @override
  void dispose() {
    _loginService.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await _loginService.logout();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    await AppNavigator.resetToSplash(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeModeProvider>();
    final isDark = themeProvider.isDark;
    final cardColor = isDark ? const Color(0xFF162333) : Colors.white;
    final textPrimary = isDark ? const Color(0xFFE4E9F0) : Colors.black87;
    final divider = isDark ? const Color(0xFF1E2C3C) : const Color(0xFFF0F0F0);
    final tileIconColor = isDark
        ? const Color(0xFF7DA8FF)
        : const Color(0xFF2563EB);
    final switchActive = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFFF59E0B);
    final switchTrack = isDark
        ? const Color(0xFF2A3B52)
        : const Color(0xFFFDE9C2);

    final children = <Widget>[
      _GroupCard(
        backgroundColor: cardColor,
        shadowColor: isDark ? Colors.transparent : null,
        children: [
          _SettingsTile(
            icon: Iconsax.user,
            label: tr(context, uz: "Profil ma'lumotlari", ru: 'Данные профиля'),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () async {
              await AppNavigator.pushProfileInfo(context);
            },
          ),
          _SettingsTile(
            icon: Iconsax.book,
            label: tr(context, uz: 'Kurslarim', ru: 'Мои курсы'),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () {
              AppNavigator.pushMyCourses(context);
            },
          ),
          _SettingsTile(
            icon: Iconsax.award,
            label: tr(context, uz: 'Sertifikatlarim', ru: 'Мои сертификаты'),
            showDivider: false,
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () {
              AppNavigator.pushCertificates(context);
            },
          ),
        ],
      ),
      const SizedBox(height: 18),
      _SectionLabel(
        title: tr(context, uz: 'Sozlamalar', ru: 'Настройки'),
        color: textPrimary,
      ),
      const SizedBox(height: 10),
      _GroupCard(
        backgroundColor: cardColor,
        shadowColor: isDark ? Colors.transparent : null,
        children: [
          _SettingsTile(
            icon: Iconsax.language_square,
            label: tr(context, uz: 'Ilova tili', ru: 'Язык приложения'),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () {
              AppNavigator.pushLanguage(context);
            },
          ),
          _SettingsSwitchTile(
            icon: Iconsax.moon,
            label: tr(context, uz: "Qorong'i rejim", ru: 'Темный режим'),
            value: isDark,
            onChanged: (value) {
              themeProvider.setDarkMode(value);
            },
            showDivider: false,
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            activeColor: switchActive,
            activeTrackColor: switchTrack,
          ),
        ],
      ),
      const SizedBox(height: 18),
      _GroupCard(
        backgroundColor: cardColor,
        shadowColor: isDark ? Colors.transparent : null,
        children: [
          _SettingsTile(
            icon: Iconsax.support,
            label: tr(
              context,
              uz: "Yordam va qo'llab-quvvatlash",
              ru: 'Поддержка',
            ),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () {
              AppNavigator.pushSupport(context);
            },
          ),
          _SettingsTile(
            icon: Iconsax.logout,
            label: tr(context, uz: 'Chiqish', ru: 'Выйти'),
            showDivider: false,
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: _handleLogout,
          ),
        ],
      ),
    ];

    if (widget.scrollable) {
      return ListView(padding: widget.padding, children: children);
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionLabel({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? shadowColor;

  const _GroupCard({
    required this.children,
    this.backgroundColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? Colors.black).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showDivider;
  final Color textColor;
  final Color dividerColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.showDivider = true,
    required this.textColor,
    required this.dividerColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chevronColor = textColor.withValues(alpha: 0.5);
    return Column(
      children: [
        ListTile(
          leading: _IconBadge(icon: icon, iconColor: iconColor),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textColor,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: chevronColor),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          tileColor: Colors.transparent,
          selectedTileColor: Colors.transparent,
          enableFeedback: false,
          onTap: onTap,
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: dividerColor),
      ],
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;
  final Color textColor;
  final Color dividerColor;
  final Color iconColor;
  final Color activeColor;
  final Color activeTrackColor;

  const _SettingsSwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
    required this.textColor,
    required this.dividerColor,
    required this.iconColor,
    required this.activeColor,
    required this.activeTrackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: _IconBadge(icon: icon, iconColor: iconColor),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textColor,
            ),
          ),
          trailing: Switch(
            value: value,
            activeThumbColor: activeColor,
            activeTrackColor: activeTrackColor,
            onChanged: onChanged,
          ),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          tileColor: Colors.transparent,
          selectedTileColor: Colors.transparent,
          enableFeedback: false,
        ),
        if (showDivider) Divider(height: 1, thickness: 1, color: dividerColor),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _IconBadge({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: iconColor);
  }
}
