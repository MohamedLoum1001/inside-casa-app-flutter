import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/screens/ModifyReservationScreen.dart';
import '../models/Reservation.dart';

class ReservationListScreen extends StatelessWidget {
  final List<Reservation> reservations;
  final void Function(String id) onDelete;
  final void Function(String id, Reservation updated) onEdit;

  const ReservationListScreen({
    super.key,
    required this.reservations,
    required this.onDelete,
    required this.onEdit,
  });

  void _confirmCancel(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Annuler la réservation ?"),
        content: const Text("Voulez-vous vraiment annuler cette réservation ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Non")),
          ElevatedButton(
            onPressed: () {
              onDelete(id);
              Navigator.pop(context);
            },
            child: const Text("Oui, annuler"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Réservations')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
      body: reservations.isEmpty
          ? const Center(child: Text("Aucune réservation"))
          : ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (ctx, i) {
                final r = reservations[i];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(
                        "Le ${r.dateTime.day}/${r.dateTime.month} à ${r.dateTime.hour}h${r.dateTime.minute.toString().padLeft(2, '0')}"),
                    subtitle: Text("${r.participants} participant(s)"),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text("Modifier")),
                        const PopupMenuItem(value: 'delete', child: Text("Annuler")),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmCancel(context, r.id);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ModifyReservationScreen(
                                reservation: r,
                                onUpdate: onEdit,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
