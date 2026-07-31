import '../../domain/entities/occasion_reminder_entity.dart';

class OccasionReminderModel extends OccasionReminderEntity {
  const OccasionReminderModel({
    required super.id,
    required super.name,
    required super.date,
    required super.relation,
    super.advanceNoticeDays,
    super.notes,
  });

  factory OccasionReminderModel.fromJson(Map<String, dynamic> json) {
    return OccasionReminderModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      relation: json['relation'] ?? '',
      advanceNoticeDays: json['advance_notice_days'] ?? 7,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'relation': relation,
      'advance_notice_days': advanceNoticeDays,
      'notes': notes,
    };
  }
}
