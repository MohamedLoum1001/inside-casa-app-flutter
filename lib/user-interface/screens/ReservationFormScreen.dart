import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/Reservation.dart';

class ReservationFormScreen extends StatefulWidget {
  final void Function(Reservation) onSubmit;

  const ReservationFormScreen({required this.onSubmit, super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int participants = 1;

  void _submit() {
    if (selectedDate == null || selectedTime == null) return;

    final dt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    widget.onSubmit(Reservation(
      id: const Uuid().v4(),
      title: 'Réservation', 
      dateTime: dt,
      participants: participants,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Réservation')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: Text(selectedDate == null
                  ? 'Choisir une date'
                  : '${selectedDate!.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => selectedDate = picked);
              },
            ),
            ListTile(
              title: Text(selectedTime == null
                  ? 'Choisir une heure'
                  : selectedTime!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) setState(() => selectedTime = picked);
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Participants :'),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: participants,
                  onChanged: (value) {
                    if (value != null) setState(() => participants = value);
                  },
                  items: List.generate(10, (i) => i + 1)
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                      .toList(),
                )
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text("Confirmer"),
            )
          ],
        ),
      ),
    );
  }
}
