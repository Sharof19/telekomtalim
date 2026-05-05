import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? AppColors.shimmerDarkBase
        : AppColors.shimmerLightBase;
    final highlight = isDark
        ? AppColors.shimmerDarkHighlight
        : AppColors.shimmerLightHighlight;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final width = bounds.width == 0 ? 1.0 : bounds.width;
            final dx = width * 2 * _controller.value - width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlidingGradientTransform(dx),
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(slidePercent, 0, 0);
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBorder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(
                  4,
                  (_) => SizedBox(
                    width: cardWidth,
                    child: const _DashboardStatSkeleton(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const _WeeklyTimeSkeleton(),
          const SizedBox(height: 12),
          const _CurrentCoursesSkeleton(),
        ],
      ),
    );
  }
}

class _DashboardStatSkeleton extends StatelessWidget {
  const _DashboardStatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.cardBorderDark
              : AppColors.cardBorderLight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: ShimmerBox(height: 14, radius: 8)),
              SizedBox(width: 8),
              ShimmerBox(width: 34, height: 34, radius: 10),
            ],
          ),
          Spacer(),
          ShimmerBox(width: 64, height: 24, radius: 8),
        ],
      ),
    );
  }
}

class _WeeklyTimeSkeleton extends StatelessWidget {
  const _WeeklyTimeSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 120, height: 18, radius: 8),
          SizedBox(height: 18),
          ShimmerBox(height: 140, radius: 12),
        ],
      ),
    );
  }
}

class _CurrentCoursesSkeleton extends StatelessWidget {
  const _CurrentCoursesSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBox(width: 110, height: 18, radius: 8),
          SizedBox(height: 12),
          _CourseCardSkeleton(),
          SizedBox(height: 12),
          _CourseCardSkeleton(),
        ],
      ),
    );
  }
}

class _CourseCardSkeleton extends StatelessWidget {
  const _CourseCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.homeInnerCardDark
            : AppColors.homeInnerCardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 144, height: 108, radius: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 170, height: 18, radius: 8),
                  SizedBox(height: 10),
                  ShimmerBox(height: 8, radius: 8),
                  SizedBox(height: 8),
                  ShimmerBox(width: 120, height: 14, radius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListCardsSkeleton extends StatelessWidget {
  final int itemCount;
  final double imageWidth;
  final double itemHeight;

  const ListCardsSkeleton({
    super.key,
    this.itemCount = 4,
    this.imageWidth = 120,
    this.itemHeight = 110,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppShimmer(
      child: ListView.separated(
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, _) {
          return Container(
            height: itemHeight,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.cardBorderDark
                    : AppColors.cardBorderLight,
              ),
            ),
            child: Row(
              children: [
                if (imageWidth > 0)
                  ShimmerBox(width: imageWidth, height: itemHeight, radius: 16),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 160, height: 18, radius: 8),
                        SizedBox(height: 10),
                        ShimmerBox(width: 110, height: 14, radius: 8),
                        SizedBox(height: 14),
                        ShimmerBox(height: 8, radius: 8),
                        SizedBox(height: 8),
                        ShimmerBox(width: 96, height: 14, radius: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
