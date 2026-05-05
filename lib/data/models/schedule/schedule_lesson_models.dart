class ScheduleCell {
  final bool hasLesson;
  final LessonInfo? lesson;

  const ScheduleCell({required this.hasLesson, this.lesson});

  factory ScheduleCell.fromJson(Map<String, dynamic> json) {
    return ScheduleCell(
      hasLesson: json['has_lesson'] == true,
      lesson: json['lesson'] is Map<String, dynamic>
          ? LessonInfo.fromJson(json['lesson'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LessonInfo {
  final int id;
  final String? group;
  final String? theme;
  final int? listeners;
  final String? educationType;
  final bool isOnline;
  final BbbObject bbbObject;

  const LessonInfo({
    required this.id,
    this.group,
    this.theme,
    this.listeners,
    this.educationType,
    required this.isOnline,
    required this.bbbObject,
  });

  factory LessonInfo.fromJson(Map<String, dynamic> json) {
    return LessonInfo(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      group: json['group']?.toString(),
      theme: json['theme']?.toString(),
      listeners: (json['listeners'] is num)
          ? (json['listeners'] as num).toInt()
          : null,
      educationType: json['education_type']?.toString(),
      isOnline: json['is_online'] == true,
      bbbObject: BbbObject.fromJson(
        json['bbb_object'] is Map<String, dynamic>
            ? json['bbb_object'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }
}

class BbbObject {
  final bool hasBbbCreate;
  final String? meetingId;

  const BbbObject({required this.hasBbbCreate, this.meetingId});

  factory BbbObject.fromJson(Map<String, dynamic> json) {
    return BbbObject(
      hasBbbCreate: json['has_bbb_create'] == true,
      meetingId: json['meeting_id']?.toString(),
    );
  }
}
