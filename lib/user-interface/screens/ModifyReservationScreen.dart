import 'package:flutter/material.dart';
import '../models/Reservation.dart';

class ModifyReservationScreen extends StatefulWidget {
  final Reservation reservation;
  final void Function(String id, Reservation updated) onUpdate;

  const ModifyReservationScreen({
    required this.reservation,
    required this.onUpdate,
    super.key,
  });

  @override
  State<ModifyReservationScreen> createState() => _ModifyReservationScreenState();
}

class _ModifyReservationScreenState extends State<ModifyReservationScreen> {
  DateTime? newDate;
  TimeOfDay? newTime;
  int participants = 1;

  @override
  void initState() {
    super.initState();
    newDate = widget.reservation.dateTime;
    newTime = TimeOfDay.fromDateTime(widget.reservation.dateTime);
    participants = widget.reservation.participants;
  }

  void _submit() {
    if (newDate == null || newTime == null) return;

    final updated = Reservation(
      id: widget.reservation.id,
      title: widget.reservation.title, 
      dateTime: DateTime(
        newDate!.year,
        newDate!.month,
        newDate!.day,
        newTime!.hour,
        newTime!.minute,
      ),
      participants: participants,
    );

    widget.onUpdate(widget.reservation.id, updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier Réservation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: Text("Date: ${newDate?.toLocal().toString().split(' ')[0]}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: newDate!,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => newDate = picked);
              },
            ),
            ListTile(
              title: Text("Heure: ${newTime?.format(context)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: newTime!,
                );
                if (picked != null) setState(() => newTime = picked);
              },
            ),
            Row(
              children: [
                const Text('Participants :'),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: participants,
                  onChanged: (value) => setState(() => participants = value!),
                  items: List.generate(10, (i) => i + 1)
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                      .toList(),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text("Sauvegarder"),
            )
          ],
        ),
      ),
    );
  }
}
