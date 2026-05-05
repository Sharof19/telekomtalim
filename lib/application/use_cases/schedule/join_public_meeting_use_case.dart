import 'package:uztelecom/data/repositories/bbb_repository.dart';

class JoinPublicMeetingUseCase {
  const JoinPublicMeetingUseCase({required BbbRepository bbbRepository})
    : _bbbRepository = bbbRepository;

  final BbbRepository _bbbRepository;

  Future<String?> call(String meetingId) {
    return _bbbRepository.joinPublicMeeting(meetingId);
  }
}
