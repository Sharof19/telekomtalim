import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(tr(context, TrKey.arizalarHozirchaMavjudEmas))),
    );
  }
}
