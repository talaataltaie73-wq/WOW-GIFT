import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/occasion_reminder_entity.dart';

abstract class OccasionsRepository {
  Future<Either<Failure, List<OccasionReminderEntity>>> getReminders();
  Future<Either<Failure, OccasionReminderEntity>> addReminder(OccasionReminderEntity reminder);
  Future<Either<Failure, void>> deleteReminder(String id);
}
