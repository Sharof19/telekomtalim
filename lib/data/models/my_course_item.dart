import 'package:uztelecom/data/models/course_model_parser.dart';

part 'course/my_course_item_factory.dart';
part 'course/my_course_item_copy_with.dart';

class MyCourseItem {
  final int id;
  final String? status;
  final String? photo;
  final String? mainVideo;
  final String? filePath;
  final String? launchUrl;
  final String? fullQuery;
  final String? duration;
  final String? trainerName;
  final int? listenerCount;
  final double? progressPercent;
  final int? completedActivities;
  final int? totalActivities;
  final String? titleUz;
  final String? titleRu;
  final String? descriptionUz;
  final String? descriptionRu;
  final String? languageUz;
  final String? languageRu;
  final String? audienceUz;
  final String? audienceRu;

  const MyCourseItem({
    required this.id,
    this.status,
    this.photo,
    this.mainVideo,
    this.filePath,
    this.launchUrl,
    this.fullQuery,
    this.duration,
    this.trainerName,
    this.listenerCount,
    this.progressPercent,
    this.completedActivities,
    this.totalActivities,
    this.titleUz,
    this.titleRu,
    this.descriptionUz,
    this.descriptionRu,
    this.languageUz,
    this.languageRu,
    this.audienceUz,
    this.audienceRu,
  });

  String? get title => titleFallback;
  String? get description => descriptionFallback;
  String? get language => languageFallback;
  String? get audience => audienceFallback;

  String? get titleFallback =>
      CourseModelParser.firstNonEmpty(titleUz, titleRu);
  String? get descriptionFallback =>
      CourseModelParser.firstNonEmpty(descriptionUz, descriptionRu);
  String? get languageFallback =>
      CourseModelParser.firstNonEmpty(languageUz, languageRu);
  String? get audienceFallback =>
      CourseModelParser.firstNonEmpty(audienceUz, audienceRu);

  String? titleFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, titleUz, titleRu);
  String? descriptionFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, descriptionUz, descriptionRu);
  String? languageFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, languageUz, languageRu);
  String? audienceFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, audienceUz, audienceRu);

  factory MyCourseItem.fromJson(Map<String, dynamic> json) =>
      _myCourseItemFromJson(json);

  MyCourseItem copyWith({
    int? id,
    String? status,
    String? photo,
    String? mainVideo,
    String? filePath,
    String? launchUrl,
    String? fullQuery,
    String? duration,
    String? trainerName,
    int? listenerCount,
    double? progressPercent,
    int? completedActivities,
    int? totalActivities,
    String? titleUz,
    String? titleRu,
    String? descriptionUz,
    String? descriptionRu,
    String? languageUz,
    String? languageRu,
    String? audienceUz,
    String? audienceRu,
  }) => _myCourseItemCopyWith(
    id: id,
    status: status,
    photo: photo,
    mainVideo: mainVideo,
    filePath: filePath,
    launchUrl: launchUrl,
    fullQuery: fullQuery,
    duration: duration,
    trainerName: trainerName,
    listenerCount: listenerCount,
    progressPercent: progressPercent,
    completedActivities: completedActivities,
    totalActivities: totalActivities,
    titleUz: titleUz,
    titleRu: titleRu,
    descriptionUz: descriptionUz,
    descriptionRu: descriptionRu,
    languageUz: languageUz,
    languageRu: languageRu,
    audienceUz: audienceUz,
    audienceRu: audienceRu,
  );
}
