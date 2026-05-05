part of 'package:uztelecom/data/models/course_item.dart';

CourseItem _courseItemFromJson(Map<String, dynamic> json) {
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

  return CourseItem(
    id: (source['id'] is num) ? (source['id'] as num).toInt() : 0,
    status: source['status_display']?.toString(),
    photo: source['photo']?.toString(),
    mainVideo: source['main_video']?.toString(),
    file: source['file']?.toString(),
    filePath: source['file_path']?.toString(),
    launchUrl:
        CourseModelParser.pickLaunchUrl(json) ??
        CourseModelParser.pickLaunchUrl(source),
    fullQuery:
        CourseModelParser.pickFullQuery(json) ??
        CourseModelParser.pickFullQuery(source),
    duration:
        source['duration_display']?.toString() ??
        source['duration']?.toString(),
    hours: (source['hours'] is num) ? (source['hours'] as num).toInt() : null,
    days: (source['days'] is num)
        ? (source['days'] as num).toInt()
        : (source['days_count'] is num)
        ? (source['days_count'] as num).toInt()
        : null,
    trainerName:
        CourseModelParser.pickTrainerName(json) ??
        CourseModelParser.pickTrainerName(source),
    listenerCount:
        CourseModelParser.pickInt(json['listener_count']) ??
        CourseModelParser.pickInt(source['listener_count']),
    trainingType: null,
    specType: null,
    comment: null,
    sector: null,
    sectorSpec: null,
    execPlace: null,
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
    courseNameUz: CourseModelParser.pickLocalizedValue(source, 'name', 'uz'),
    courseNameRu: CourseModelParser.pickLocalizedValue(source, 'name', 'ru'),
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
