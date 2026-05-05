import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -120,
          child: _BackdropCircle(
            size: 260,
            color: AppColors.brandBlue.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -100,
          child: _BackdropCircle(
            size: 220,
            color: AppColors.brandBlue.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

class _BackdropCircle extends StatelessWidget {
  const _BackdropCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
