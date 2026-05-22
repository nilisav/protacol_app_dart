class HabitHistoryEntry {
  final DateTime date;
  final String status; // 'completed' 'not_completed'

  HabitHistoryEntry({required this.date, required this.status});

  factory HabitHistoryEntry.fromJson(Map<String, dynamic> json) {
    return HabitHistoryEntry(
      date: DateTime.parse((json['date'] as Map)['Time'] as String),
      status: json['status'] as String,
    );
  }
}

class Habit {
  final int id;
  final String title;
  final String? description;
  final List<HabitHistoryEntry> history;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.history,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    final idValue = json['ID'] ?? json['id'] ?? 0;
    final id = idValue is int ? idValue : int.parse(idValue.toString());

    return Habit(
      id: id,
      title: json['Title'] as String? ?? json['title'] as String? ?? '',
      description:
          json['Description'] as String? ?? json['description'] as String?,
      history:
          (json['History'] as List<dynamic>?)
              ?.map(
                (e) => HabitHistoryEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  String? statusForDate(DateTime date) {
    final formatted = _formatDate(date);
    for (final entry in history) {
      if (_formatDate(entry.date) == formatted) {
        return entry.status;
      }
    }
    return null;
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
