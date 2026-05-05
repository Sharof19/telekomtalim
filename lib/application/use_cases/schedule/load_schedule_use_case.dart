import 'package:uztelecom/data/models/schedule_models.dart';
import 'package:uztelecom/data/repositories/schedule_repository.dart';

class LoadScheduleUseCase {
  const LoadScheduleUseCase({required ScheduleRepository scheduleRepository})
    : _scheduleRepository = scheduleRepository;

  final ScheduleRepository _scheduleRepository;

  Future<ScheduleData> call({
    required String startDate,
    required String endDate,
  }) {
    return _scheduleRepository.fetchSchedule(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
