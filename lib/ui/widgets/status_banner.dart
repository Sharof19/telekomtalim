import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:uztelecom/ui/l10n/tr.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class StatusBanner {
  static Future<void> show(
    BuildContext context, {
    required bool success,
    required String title,
    String? message,
    String? actionLabel,
    VoidCallback? onAction,
  }) async {
    final color = success ? AppColors.success : AppColors.error;
    final resolvedMessage = _friendlyMessage(context, message);
    final buttonLabel =
        actionLabel ??
        (success
            ? tr(context, uz: 'Davom etish', ru: 'Продолжить')
            : tr(context, uz: 'Yopish', ru: 'Закрыть'));

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final width = MediaQuery.of(ctx).size.width * 0.82;
        final maxWidth = math.min(width, 360.0);
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              width: maxWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 130,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipPath(
                            clipper: _BannerClipper(),
                            child: Container(color: color, height: 130),
                          ),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              success
                                  ? Icons.check_rounded
                                  : Icons.error_outline_rounded,
                              color: color,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                      child: Column(
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          if (resolvedMessage != null &&
                              resolvedMessage.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              resolvedMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF5F6472),
                                height: 1.4,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                onAction?.call();
                              },
                              child: Text(buttonLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String? _friendlyMessage(BuildContext context, String? message) {
  if (message == null || message.isEmpty) return message;
  final lower = message.toLowerCase();
  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection failed')) {
    return tr(
      context,
      uz: 'Internetga ulanish yo‘q. Iltimos, aloqani tekshiring.',
      ru: 'Нет подключения к интернету. Проверьте соединение.',
    );
  }
  return message;
}

class _BannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 28);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 18,
      size.width,
      size.height - 28,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
