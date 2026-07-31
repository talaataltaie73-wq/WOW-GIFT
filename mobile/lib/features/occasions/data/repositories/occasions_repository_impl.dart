import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/occasion_reminder_entity.dart';
import '../../domain/repositories/occasions_repository.dart';
import '../data_sources/occasions_remote_data_source.dart';
import '../models/occasion_reminder_model.dart';

class OccasionsRepositoryImpl implements OccasionsRepository {
  final OccasionsRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  OccasionsRepositoryImpl(this._remoteDataSource, this._networkInfo);

  static final List<OccasionReminderEntity> _mockReminders = [
    OccasionReminderEntity(
      id: '1',
      name: 'عيد ميلاد أمي',
      date: DateTime.now().add(const Duration(days: 12)),
      relation: 'أم',
      advanceNoticeDays: 7,
      notes: 'تحب العطور والورود',
    ),
    OccasionReminderEntity(
      id: '2',
      name: 'ذكرى زواج أبي وأمي',
      date: DateTime.now().add(const Duration(days: 30)),
      relation: 'أب',
      advanceNoticeDays: 14,
      notes: 'يفضل الساعات الكلاسيكية',
    ),
    OccasionReminderEntity(
      id: '3',
      name: 'تخرج صديقي أحمد',
      date: DateTime.now().add(const Duration(days: 5)),
      relation: 'صديق',
      advanceNoticeDays: 3,
      notes: 'يحب التكنولوجيا والألعاب',
    ),
    OccasionReminderEntity(
      id: '4',
      name: 'عيد ميلاد زوجتي',
      date: DateTime.now().add(const Duration(days: 45)),
      relation: 'زوج/ة',
      advanceNoticeDays: 14,
      notes: 'تحب المجوهرات والشوكولاتة الفاخرة',
    ),
  ];

  @override
  Future<Either<Failure, List<OccasionReminderEntity>>> getReminders() async {
    if (!await _networkInfo.isConnected) {
      return Either.right(_mockReminders);
    }
    try {
      final reminders = await _remoteDataSource.getReminders();
      if (reminders.isEmpty) {
        return Either.right(_mockReminders);
      }
      return Either.right(reminders);
    } on ServerException {
      return Either.right(_mockReminders);
    }
  }

  @override
  Future<Either<Failure, OccasionReminderEntity>> addReminder(
    OccasionReminderEntity reminder,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(reminder);
    }
    try {
      final model = OccasionReminderModel(
        id: reminder.id,
        name: reminder.name,
        date: reminder.date,
        relation: reminder.relation,
        advanceNoticeDays: reminder.advanceNoticeDays,
        notes: reminder.notes,
      );
      final result = await _remoteDataSource.addReminder(model.toJson());
      return Either.right(result);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(String id) async {
    if (!await _networkInfo.isConnected) {
      return Either.right(null);
    }
    try {
      await _remoteDataSource.deleteReminder(id);
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message));
    }
  }
}
