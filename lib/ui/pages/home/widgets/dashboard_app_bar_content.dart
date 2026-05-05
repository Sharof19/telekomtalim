import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/ui/pages/home/widgets/dashboard_welcome_card.dart';

class DashboardAppBarContent extends StatelessWidget {
  final String fallbackName;

  const DashboardAppBarContent({super.key, required this.fallbackName});

  @override
  Widget build(BuildContext context) {
    final localName = fallbackName.trim();
    final name = localName.isNotEmpty
        ? localName
        : tr(context, TrKey.foydalanuvchi);
    return DashboardWelcomeCard(name: name);
  }
}
