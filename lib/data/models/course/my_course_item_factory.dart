part of 'package:uztelecom/data/models/my_course_item.dart';

MyCourseItem _myCourseItemFromJson(Map<String, dynamic> json) {
  final source = CourseModelParser.flattenEduResources(json);
  final language = CourseModelParser.pickDisplayMap(source, const [
    'language_display',
  ]);
  final languageDisplay = CourseModelParser.pickFirstDisplayText(
    source,
    'languages_display',
  );
  final audiences = source['audiences'] as List<dynamic>? ?? [];
  final audience = audiences.isNotEmpty
      ? Map<String, dynamic>.from(audiences.first as Map)
      : CourseModelParser.pickDisplayMap(source, const [
          'audience_display',
          'audience',
        ]);
  final audienceName = source['audience_name']?.toString();

  return MyCourseItem(
    id: (source['id'] is num) ? (source['id'] as num).toInt() : 0,
    status: source['status_display']?.toString(),
    photo: CourseModelParser.pickMediaPath(source, const ['photo']),
    mainVideo:
        CourseModelParser.pickMediaPath(json, const [
          'main_video',
          'mainVideo',
        ]) ??
        CourseModelParser.pickMediaPath(source, const [
          'main_video',
          'mainVideo',
        ]),
    filePath: CourseModelParser.pickMediaPath(source, const [
      'file_path',
      'filePath',
    ]),
    launchUrl:
        CourseModelParser.pickLaunchUrl(json) ??
        CourseModelParser.pickLaunchUrl(source),
    fullQuery:
        CourseModelParser.pickFullQuery(json) ??
        CourseModelParser.pickFullQuery(source),
    duration:
        source['duration_display']?.toString() ??
        source['duration']?.toString(),
    trainerName:
        CourseModelParser.pickTrainerName(json) ??
        CourseModelParser.pickTrainerName(source),
    listenerCount:
        CourseModelParser.pickInt(json['listener_count']) ??
        CourseModelParser.pickInt(source['listener_count']),
    progressPercent:
        CourseModelParser.pickDouble(json['progress_percent']) ??
        CourseModelParser.pickDouble(source['progress_percent']) ??
        CourseModelParser.pickDouble(json['progress']),
    completedActivities:
        CourseModelParser.pickInt(json['completed_activities']) ??
        CourseModelParser.pickInt(source['completed_activities']) ??
        CourseModelParser.pickInt(json['completed_modules']) ??
        CourseModelParser.pickInt(json['completed_lessons']) ??
        CourseModelParser.pickInt(source['completed_modules']) ??
        CourseModelParser.pickInt(source['completed_lessons']),
    totalActivities:
        CourseModelParser.pickInt(json['total_activities']) ??
        CourseModelParser.pickInt(source['total_activities']) ??
        CourseModelParser.pickInt(json['total_modules']) ??
        CourseModelParser.pickInt(json['total_lessons']) ??
        CourseModelParser.pickInt(source['total_modules']) ??
        CourseModelParser.pickInt(source['total_lessons']),
    titleUz: CourseModelParser.pickLocalizedValue(source, 'name', 'uz'),
    titleRu: CourseModelParser.pickLocalizedValue(source, 'name', 'ru'),
    descriptionUz: CourseModelParser.pickLocalizedValue(
      source,
      'description',
      'uz',
    ),
    descriptionRu: CourseModelParser.pickLocalizedValue(
      source,
      'description',
      'ru',
    ),
    languageUz:
        CourseModelParser.pickLocalizedValue(language, 'name', 'uz') ??
        languageDisplay,
    languageRu:
        CourseModelParser.pickLocalizedValue(language, 'name', 'ru') ??
        languageDisplay,
    audienceUz:
        CourseModelParser.pickLocalizedValue(audience, 'name', 'uz') ??
        audienceName,
    audienceRu:
        CourseModelParser.pickLocalizedValue(audience, 'name', 'ru') ??
        audienceName,
  );
}
