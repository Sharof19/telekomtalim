import 'package:uztelecom/core/routing/args/course_route_args.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/data/models/my_course_item.dart';

CourseInfoInitialData courseInfoInitialDataFromCourseItem(CourseItem item) {
  return CourseInfoInitialData(
    id: item.id,
    status: item.status,
    photo: item.photo,
    mainVideo: item.mainVideo,
    file: item.file,
    filePath: item.filePath,
    launchUrl: item.launchUrl,
    fullQuery: item.fullQuery,
    duration: item.duration,
    hours: item.hours,
    days: item.days,
    trainerName: item.trainerName,
    listenerCount: item.listenerCount,
    titleUz: item.titleUz,
    titleRu: item.titleRu,
    descriptionUz: item.descriptionUz,
    descriptionRu: item.descriptionRu,
    courseNameUz: item.courseNameUz,
    courseNameRu: item.courseNameRu,
    languageUz: item.languageUz,
    languageRu: item.languageRu,
    audienceUz: item.audienceUz,
    audienceRu: item.audienceRu,
  );
}

CourseInfoInitialData courseInfoInitialDataFromMyCourseItem(MyCourseItem item) {
  return CourseInfoInitialData(
    id: item.id,
    status: item.status,
    photo: item.photo,
    mainVideo: item.mainVideo,
    filePath: item.filePath,
    launchUrl: item.launchUrl,
    fullQuery: item.fullQuery,
    duration: item.duration,
    trainerName: item.trainerName,
    listenerCount: item.listenerCount,
    titleUz: item.titleUz,
    titleRu: item.titleRu,
    descriptionUz: item.descriptionUz,
    descriptionRu: item.descriptionRu,
    courseNameUz: item.titleUz,
    courseNameRu: item.titleRu,
    languageUz: item.languageUz,
    languageRu: item.languageRu,
    audienceUz: item.audienceUz,
    audienceRu: item.audienceRu,
  );
}
