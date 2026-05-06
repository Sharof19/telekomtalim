import 'package:flutter_test/flutter_test.dart';
import 'package:uztelecom/data/models/course_item.dart';
import 'package:uztelecom/data/models/my_course_item.dart';

void main() {
  test('parses listener my training course response shape', () {
    final item = MyCourseItem.fromJson({
      'id': 22,
      'name_uz': 'Elektr xavfsizligi',
      'name_ru': 'Электробезопасность',
      'main_video': '/media/edu_course/main_videos/tb1-done_b8Boh6c.mp4',
      'photo': '/media/edu_course/photos/photo_2026-04-30_01-42-48.jpg',
      'languages_display': ["O'zbek"],
      'duration_display': '01:00:00',
      'edu_resources': {
        'id': 17,
        'file_path': 'edu_resources/lrs/unpacked/17/scormdriver/indexAPI.html',
        'index_html_path':
            'media/edu_resources/lrs/unpacked/17/scormcontent/index.html',
      },
      'trainers': [
        {'id': 16327, 'full_name': 'Farmonov Farrux Xasan o‘g‘li'},
      ],
      'audience_name': 'Yangi qabul qilinganlar',
      'audience_display': {
        'id': 3,
        'name_uz': 'Yangi qabul qilinganlar',
        'name_ru': 'Yangi qabul qilinganlar',
      },
      'listener_count': 13000,
      'progress_percent': 0,
      'completed_activities': 0,
      'total_activities': 0,
    });

    expect(item.id, 22);
    expect(item.titleUz, 'Elektr xavfsizligi');
    expect(
      item.photo,
      '/media/edu_course/photos/photo_2026-04-30_01-42-48.jpg',
    );
    expect(
      item.mainVideo,
      '/media/edu_course/main_videos/tb1-done_b8Boh6c.mp4',
    );
    expect(
      item.filePath,
      'edu_resources/lrs/unpacked/17/scormdriver/indexAPI.html',
    );
    expect(item.languageUz, "O'zbek");
    expect(item.audienceUz, 'Yangi qabul qilinganlar');
    expect(item.trainerName, 'Farmonov Farrux Xasan o‘g‘li');
    expect(item.listenerCount, 13000);
    expect(item.progressPercent, 0);
    expect(item.completedActivities, 0);
    expect(item.totalActivities, 0);
  });

  test('parses main video from nested media object', () {
    final item = CourseItem.fromJson({
      'id': 7,
      'name_uz': 'Kurs',
      'main_video': {'url': '/media/edu_course/main_videos/intro.mp4'},
      'edu_resources': {
        'id': 17,
        'file_path': 'edu_resources/lrs/unpacked/17/scormdriver/indexAPI.html',
      },
    });

    expect(item.mainVideo, '/media/edu_course/main_videos/intro.mp4');
  });

  test('keeps root main video when edu resource is flattened', () {
    final item = MyCourseItem.fromJson({
      'id': 22,
      'name_uz': 'Elektr xavfsizligi',
      'main_video': '/media/edu_course/main_videos/tb1-done.mp4',
      'edu_resources': {
        'id': 17,
        'main_video': null,
        'file_path': 'edu_resources/lrs/unpacked/17/scormdriver/indexAPI.html',
      },
    });

    expect(item.mainVideo, '/media/edu_course/main_videos/tb1-done.mp4');
  });
}
