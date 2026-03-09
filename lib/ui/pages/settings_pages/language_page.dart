import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/domain/provider/provider.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = context.read<LocaleProvider>().locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF0F1E2C) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1F3144) : const Color(0xFFE4E7EE);
    final selectedBorder = scheme.primary;
    final titleColor = scheme.onBackground;
    final muted = scheme.onBackground.withOpacity(0.6);

    final items = [
      _LangItem(code: 'uz', labelUz: "O'zbekcha", labelRu: "Узбекский", flag: '🇺🇿'),
      _LangItem(code: 'ru', labelUz: "Русский", labelRu: "Русский", flag: '🇷🇺'),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: titleColor,
        title: Text(
          tr(context, uz: 'Dastur tilini tanlang', ru: 'Выберите язык приложения'),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                ? const Color(0xFF17283A)
                                : const Color(0xFFF2F4F8),
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
                            tr(context, uz: item.labelUz, ru: item.labelRu),
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
                  await context
                      .read<LocaleProvider>()
                      .setLocale(Locale(_selectedCode));
                  if (mounted) Navigator.of(context).pop();
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
                  tr(context, uz: 'Saqlash', ru: 'Сохранить'),
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
  final String labelUz;
  final String labelRu;
  final String flag;

  const _LangItem({
    required this.code,
    required this.labelUz,
    required this.labelRu,
    required this.flag,
  });
}
