import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';

class DashboardErrorCard extends StatelessWidget {
  const DashboardErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(tr(context, TrKey.retryAction)),
            ),
          ],
        ),
      ),
    );
  }
}
