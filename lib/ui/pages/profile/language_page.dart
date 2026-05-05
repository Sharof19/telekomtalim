import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/core/utils/app_logger.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/providers/app/app_providers.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late String _selectedCode;

  LocaleProvider? _maybeLocaleProvider(BuildContext context) {
    try {
      return Provider.of<LocaleProvider>(context, listen: false);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Locale provider is not available in language context.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final provider = _maybeLocaleProvider(context);
    _selectedCode =
        provider?.locale.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? AppColors.languageCardDark : AppColors.white;
    final borderColor = isDark
        ? AppColors.cardBorderDark
        : AppColors.cardBorderLight;
    final selectedBorder = scheme.primary;
    final titleColor = scheme.onSurface;

    final items = [
      _LangItem(code: 'uz', titleKey: TrKey.ozbekcha, flag: '🇺🇿'),
      _LangItem(code: 'ru', titleKey: TrKey.russkiy, flag: '🇷🇺'),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: titleColor,
        title: Text(
          tr(context, TrKey.dasturTiliniTanlang),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                final selected = _selectedCode == item.code;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCode = item.code);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? selectedBorder : borderColor,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.languageFlagDark
                                : AppColors.languageFlagLight,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item.flag,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            tr(context, item.titleKey),
                            style: TextStyle(
                              color: selected ? scheme.primary : titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle, color: scheme.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20 + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final provider = _maybeLocaleProvider(context);
                  await provider?.setLocale(Locale(_selectedCode));
                  if (!mounted) return;
                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  tr(context, TrKey.saveAction),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangItem {
  final String code;
  final TrKey titleKey;
  final String flag;

  const _LangItem({
    required this.code,
    required this.titleKey,
    required this.flag,
  });
}
