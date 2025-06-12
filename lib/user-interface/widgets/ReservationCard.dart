import 'package:flutter/material.dart';
import '../models/reservation.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatted = "${reservation.dateTime.day.toString().padLeft(2, '0')}/"
        "${reservation.dateTime.month.toString().padLeft(2, '0')}/"
        "${reservation.dateTime.year} à "
        "${reservation.dateTime.hour.toString().padLeft(2, '0')}h"
        "${reservation.dateTime.minute.toString().padLeft(2, '0')}";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          reservation.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "$dateFormatted\nParticipants : ${reservation.participants}",
          style: const TextStyle(height: 1.4),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'cancel') {
              onCancel();
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'cancel', child: Text('Annuler')),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
