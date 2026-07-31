import 'package:equatable/equatable.dart';

class OccasionReminderEntity extends Equatable {
  final String id;
  final String name;
  final DateTime date;
  final String relation;
  final int advanceNoticeDays;
  final String? notes;

  const OccasionReminderEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.relation,
    this.advanceNoticeDays = 7,
    this.notes,
  });

  @override
  List<Object?> get props => [id, name, date, relation];
}
