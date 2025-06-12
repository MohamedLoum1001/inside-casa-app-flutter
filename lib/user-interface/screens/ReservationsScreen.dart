import 'package:flutter/material.dart';
import 'package:inside_casa_app/user-interface/widgets/ReservationCard.dart';
import '../models/reservation.dart';
// import '../widgets/reservation_card.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  // Liste mockée de réservations
  List<Reservation> reservations = [
    Reservation(
      id: '1',
      title: 'Découverte de la Médina',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 15)),
      participants: 3,
    ),
    Reservation(
      id: '2',
      title: 'Dîner au restaurant local',
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 19)),
      participants: 2,
    ),
  ];

  void _editReservation(Reservation reservation) {
    // Ici tu pourrais naviguer vers l'écran de modification
    // Par exemple Navigator.push(context, ...);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modifier la réservation "${reservation.title}"')),
    );
  }

  void _cancelReservation(String id) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Voulez-vous vraiment annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      setState(() {
        reservations.removeWhere((r) => r.id == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation annulée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: reservations.isEmpty
          ? const Center(
              child: Text(
                'Aucune réservation trouvée.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return ReservationCard(
                  reservation: reservation,
                  onEdit: () => _editReservation(reservation),
                  onCancel: () => _cancelReservation(reservation.id),
                );
              },
            ),
    );
  }
}
