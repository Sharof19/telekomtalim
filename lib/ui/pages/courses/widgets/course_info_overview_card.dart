import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_feature_card.dart';
import 'package:uztelecom/ui/pages/courses/widgets/course_learning_point.dart';

class CourseInfoOverviewCard extends StatelessWidget {
  const CourseInfoOverviewCard({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.dividerColor,
    required this.titleColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color dividerColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_objects,
                color: AppColors.courseInfoAccent,
              ),
              const SizedBox(width: 8),
              Text(
                'Nimani o‘rganasiz?',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const CourseLearningPoint(
            text: "Kurs mavzusini to'liq tushunish va qo'llay olish",
          ),
          const CourseLearningPoint(
            text: "Amaliy ko'nikmalar va tajriba olish",
          ),
          const CourseLearningPoint(
            text: "Real loyihalarda ishlash qobiliyati",
          ),
          const CourseLearningPoint(text: "Professional darajada bilim olish"),
          const CourseLearningPoint(
            text: "Kursni tugatgandan so'ng sertifikat olish",
          ),
          const SizedBox(height: 14),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: CourseFeatureCard(
                  icon: Icons.play_circle_fill,
                  title: 'Video darslar',
                  subtitle: 'HD sifatli video materiallar',
                  color: AppColors.courseFeatureVideo,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: CourseFeatureCard(
                  icon: Icons.verified_rounded,
                  title: 'Sertifikat',
                  subtitle: 'Kursni tugatgach darhol',
                  color: AppColors.courseFeatureCertificate,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: CourseFeatureCard(
                  icon: Icons.assignment_rounded,
                  title: 'Amaliy topshiriqlar',
                  subtitle: 'Real loyihalar bilan ishlash',
                  color: AppColors.courseFeatureTask,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
