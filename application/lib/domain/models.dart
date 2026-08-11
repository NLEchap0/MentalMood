// Pure domain models — no Flutter or Drift dependencies.
// These are the only data shapes the UI layer knows about.

enum MoodRange { last24h, last7d, last30d }

class MoodEntry {
  final int id;
  final int value;
  final int userId;
  final DateTime createdAt;
  final String? note;
  final List<String> tags;

  const MoodEntry({
    required this.id,
    required this.value,
    required this.userId,
    required this.createdAt,
    this.note,
    this.tags = const [],
  });

  bool get hasNote => note != null && note!.trim().isNotEmpty;

  MoodEntry copyWith({
    int? value,
    DateTime? createdAt,
    String? note,
    List<String>? tags,
  }) {
    return MoodEntry(
      id: id,
      value: value ?? this.value,
      userId: userId,
      createdAt: createdAt ?? this.createdAt,
      note: note,
      tags: tags ?? this.tags,
    );
  }
}

class MoodTag {
  final int id;
  final String label;
  final String emoji;

  const MoodTag({required this.id, required this.label, required this.emoji});
}

class Badge {
  final int id;
  final String code;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;

  const Badge({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
  });
}

class AppUser {
  final int id;
  final String username;
  final String name;
  final String surname;
  final DateTime birthDate;
  final String passwordHash;

  const AppUser({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.passwordHash,
  });

  String get fullName => '$name $surname';

  AppUser copyWith({String? name, String? surname, DateTime? birthDate}) {
    return AppUser(
      id: id,
      username: username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthDate: birthDate ?? this.birthDate,
      passwordHash: passwordHash,
    );
  }
}

class ChartPoint {
  final DateTime date;
  final double value;

  const ChartPoint({required this.date, required this.value});
}
