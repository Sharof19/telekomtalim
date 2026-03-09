import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: scheme.onBackground,
        title: Text(
          tr(context, uz: 'Sertifikatlar', ru: 'Сертификаты'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Text(
          tr(
            context,
            uz: 'Sizda sertifikat mavjud emas.',
            ru: 'У вас нет сертификатов.',
          ),
          style: TextStyle(
            fontSize: 16,
            color: scheme.onBackground.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
