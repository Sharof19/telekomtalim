import 'package:uztelecom/data/models/course_model_parser.dart';

part 'course/course_item_factory.dart';

class CourseItem {
  final int id;
  final String? status;
  final String? photo;
  final String? mainVideo;
  final String? file;
  final String? filePath;
  final String? launchUrl;
  final String? fullQuery;
  final String? duration;
  final int? hours;
  final int? days;
  final String? trainerName;
  final int? listenerCount;
  final String? trainingType;
  final String? specType;
  final String? comment;
  final String? sector;
  final String? sectorSpec;
  final String? execPlace;
  final String? titleUz;
  final String? titleRu;
  final String? descriptionUz;
  final String? descriptionRu;
  final String? courseNameUz;
  final String? courseNameRu;
  final String? languageUz;
  final String? languageRu;
  final String? audienceUz;
  final String? audienceRu;

  CourseItem({
    required this.id,
    this.status,
    this.photo,
    this.mainVideo,
    this.file,
    this.filePath,
    this.launchUrl,
    this.fullQuery,
    this.duration,
    this.hours,
    this.days,
    this.trainerName,
    this.listenerCount,
    this.trainingType,
    this.specType,
    this.comment,
    this.sector,
    this.sectorSpec,
    this.execPlace,
    this.titleUz,
    this.titleRu,
    this.descriptionUz,
    this.descriptionRu,
    this.courseNameUz,
    this.courseNameRu,
    this.languageUz,
    this.languageRu,
    this.audienceUz,
    this.audienceRu,
  });

  String? get title => titleFallback;
  String? get description => descriptionFallback;
  String? get courseName => courseNameFallback;
  String? get language => languageFallback;
  String? get audience => audienceFallback;

  String? get titleFallback =>
      CourseModelParser.firstNonEmpty(titleUz, titleRu);
  String? get descriptionFallback =>
      CourseModelParser.firstNonEmpty(descriptionUz, descriptionRu);
  String? get courseNameFallback => CourseModelParser.firstNonEmpty(
    courseNameUz,
    courseNameRu,
    titleUz,
    titleRu,
  );
  String? get languageFallback =>
      CourseModelParser.firstNonEmpty(languageUz, languageRu);
  String? get audienceFallback =>
      CourseModelParser.firstNonEmpty(audienceUz, audienceRu);

  String? titleFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, titleUz, titleRu);
  String? descriptionFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, descriptionUz, descriptionRu);
  String? courseNameFor(String localeCode) => CourseModelParser.forLocale(
    localeCode,
    courseNameUz ?? titleUz,
    courseNameRu ?? titleRu,
  );
  String? languageFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, languageUz, languageRu);
  String? audienceFor(String localeCode) =>
      CourseModelParser.forLocale(localeCode, audienceUz, audienceRu);

  factory CourseItem.fromJson(Map<String, dynamic> json) =>
      _courseItemFromJson(json);
}
