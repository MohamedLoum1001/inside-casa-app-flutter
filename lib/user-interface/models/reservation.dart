class Reservation {
  final String id;
  final String title;          // Ajouté ici
  final DateTime dateTime;
  final int participants;

  Reservation({
    required this.id,
    required this.title,       // Ajouté ici
    required this.dateTime,
    required this.participants,
  });

  Reservation copyWith({
    String? id,
    String? title,             // Ajouté ici
    DateTime? dateTime,
    int? participants,
  }) {
    return Reservation(
      id: id ?? this.id,
      title: title ?? this.title,    // Ajouté ici
      dateTime: dateTime ?? this.dateTime,
      participants: participants ?? this.participants,
    );
  }

  @override
  String toString() {
    return 'Reservation(id: $id, title: $title, dateTime: $dateTime, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reservation &&
        other.id == id &&
        other.title == title &&             // Ajouté ici
        other.dateTime == dateTime &&
        other.participants == participants;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ dateTime.hashCode ^ participants.hashCode;
}
