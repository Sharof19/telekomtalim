import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  static const String _phoneLabel = '+998 94 630 28 09';
  static const String _phoneDial = '+998946302809';
  static const String _telegramLabel = '@jasurbek_ogli';
  static const String _telegramHandle = 'jasurbek_ogli';

  Future<void> _openPhone(BuildContext context) async {
    bool launched = false;
    try {
      final uri = Uri.parse('tel:$_phoneDial');
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to open phone dialer.',
        error: error,
        stackTrace: stackTrace,
      );
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.qongiroqniOchibBolmadi))),
      );
    }
  }

  Future<void> _openTelegram(BuildContext context) async {
    final deepLink = Uri.parse('tg://resolve?domain=$_telegramHandle');
    final webLink = Uri.parse('https://t.me/$_telegramHandle');

    var opened = false;
    try {
      if (await canLaunchUrl(deepLink)) {
        opened = await launchUrl(
          deepLink,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to open Telegram deep link.',
        error: error,
        stackTrace: stackTrace,
      );
      opened = false;
    }
    if (opened) return;

    try {
      opened = await launchUrl(webLink, mode: LaunchMode.externalApplication);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to open Telegram web link.',
        error: error,
        stackTrace: stackTrace,
      );
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(context, TrKey.telegramniOchibBolmadi))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final titleColor = isDark ? AppColors.darkText : AppColors.lightText;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final cardBorder = isDark
        ? AppColors.cardBorderDark
        : AppColors.cardBorderLight;
    final subtitle = isDark ? const Color(0xFFAAB8C8) : AppColors.mutedGray;
    const accent = AppColors.accentBlueDeep;
    const accentSoft = Color(0x260B57A4);
    const actionText = AppColors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: titleColor,
        title: Text(
          tr(context, TrKey.qollabQuvvatlash),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
            _SupportTile(
              icon: Icons.call_rounded,
              title: tr(context, TrKey.telefonOrqali),
              value: _phoneLabel,
              actionLabel: tr(context, TrKey.qongiroqQilish),
              onTap: () => _openPhone(context),
              cardBg: cardBg,
              cardBorder: cardBorder,
              subtitle: subtitle,
              accent: accent,
              accentSoft: accentSoft,
              actionText: actionText,
            ),
            const SizedBox(height: 12),
            _SupportTile(
              icon: Icons.telegram,
              title: tr(context, TrKey.telegramOrqali),
              value: _telegramLabel,
              actionLabel: tr(context, TrKey.telegramgaOtish),
              onTap: () => _openTelegram(context),
              cardBg: cardBg,
              cardBorder: cardBorder,
              subtitle: subtitle,
              accent: accent,
              accentSoft: accentSoft,
              actionText: actionText,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String actionLabel;
  final VoidCallback onTap;
  final Color cardBg;
  final Color cardBorder;
  final Color subtitle;
  final Color accent;
  final Color accentSoft;
  final Color actionText;

  const _SupportTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.actionLabel,
    required this.onTap,
    required this.cardBg,
    required this.cardBorder,
    required this.subtitle,
    required this.accent,
    required this.accentSoft,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: subtitle,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(foregroundColor: actionText),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
