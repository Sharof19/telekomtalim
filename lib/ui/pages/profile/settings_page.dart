import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/auth/logout_use_case.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/ui/pages/profile/widgets/settings_tiles.dart';
import 'package:uztelecom/ui/providers/app/app_providers.dart';

ThemeModeProvider? _maybeThemeProvider(BuildContext context) {
  try {
    return Provider.of<ThemeModeProvider>(context);
  } catch (error, stackTrace) {
    AppLogger.warning(
      'Theme provider is not available in settings context.',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? AppColors.darkBackground
        : AppColors.profileBackgroundLight;
    final foreground = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        foregroundColor: foreground,
        title: Text(
          tr(context, TrKey.settings),
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
  late final LogoutUseCase _logout;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _logout = context.read<LogoutUseCase>();
  }

  Future<void> _handleLogout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    await _logout();

    if (!mounted) return;
    await AppNavigator.resetToSplash(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = _maybeThemeProvider(context);
    final isDark =
        themeProvider?.isDark ??
        Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final divider = isDark ? AppColors.darkBorder : const Color(0xFFF0F0F0);
    final tileIconColor = isDark
        ? const Color(0xFF7DA8FF)
        : const Color(0xFF2563EB);
    final switchActive = isDark
        ? const Color(0xFF3B82F6)
        : AppColors.accentAmber;
    const switchTrackLight = Color(0xFFFDE9C2);
    const switchTrackDark = Color(0xFF2A3B52);
    final switchTrack = isDark ? switchTrackDark : switchTrackLight;
    final groupShadowBase = isDark ? AppColors.transparent : AppColors.black;

    final children = <Widget>[
      SettingsGroupCard(
        backgroundColor: cardColor,
        shadowColor: groupShadowBase,
        children: [
          SettingsTile(
            icon: Iconsax.user,
            label: tr(context, TrKey.profilMalumotlari),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () async {
              await AppNavigator.pushProfileInfo(context);
            },
          ),
          SettingsTile(
            icon: Iconsax.book,
            label: tr(context, TrKey.myCourses),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () {
              AppNavigator.pushMyCourses(context);
            },
          ),
          SettingsTile(
            icon: Iconsax.award,
            label: tr(context, TrKey.sertifikatlarim),
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
      SettingsSectionLabel(
        title: tr(context, TrKey.settings),
        color: textPrimary,
      ),
      const SizedBox(height: 10),
      SettingsGroupCard(
        backgroundColor: cardColor,
        shadowColor: groupShadowBase,
        children: [
          SettingsTile(
            icon: Iconsax.language_square,
            label: tr(context, TrKey.ilovaTili),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () {
              AppNavigator.pushLanguage(context);
            },
          ),
          SettingsSwitchTile(
            icon: Iconsax.moon,
            label: tr(context, TrKey.qorongiRejim),
            value: isDark,
            onChanged: (value) {
              themeProvider?.setDarkMode(value);
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
      SettingsGroupCard(
        backgroundColor: cardColor,
        shadowColor: groupShadowBase,
        children: [
          SettingsTile(
            icon: Iconsax.support,
            label: tr(context, TrKey.yordamVaQollabQuvvatlash),
            textColor: textPrimary,
            dividerColor: divider,
            iconColor: tileIconColor,
            onTap: () {
              AppNavigator.pushSupport(context);
            },
          ),
          SettingsTile(
            icon: Iconsax.logout,
            label: tr(context, TrKey.chiqish),
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
