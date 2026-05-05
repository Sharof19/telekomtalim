class CourseInfoInitialData {
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

  const CourseInfoInitialData({
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
}

class CourseInfoRouteArgs {
  final int courseId;
  final CourseInfoInitialData? initialData;
  final bool useMyCoursesDetailApi;

  const CourseInfoRouteArgs({
    required this.courseId,
    this.initialData,
    this.useMyCoursesDetailApi = false,
  });
}
