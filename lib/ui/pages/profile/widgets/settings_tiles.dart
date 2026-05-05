import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class SettingsSectionLabel extends StatelessWidget {
  final String title;
  final Color color;

  const SettingsSectionLabel({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color),
    );
  }
}

class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? shadowColor;

  const SettingsGroupCard({
    super.key,
    required this.children,
    this.backgroundColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fallbackBackground = isDark ? AppColors.darkSurface : AppColors.white;
    final fallbackShadow = isDark ? AppColors.transparent : AppColors.black;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? fallbackBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (shadowColor ?? fallbackShadow).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showDivider;
  final Color textColor;
  final Color dividerColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
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
          leading: _SettingsIconBadge(icon: icon, iconColor: iconColor),
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

class SettingsSwitchTile extends StatelessWidget {
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

  const SettingsSwitchTile({
    super.key,
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
          leading: _SettingsIconBadge(icon: icon, iconColor: iconColor),
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

class _SettingsIconBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  const _SettingsIconBadge({required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: iconColor);
  }
}
