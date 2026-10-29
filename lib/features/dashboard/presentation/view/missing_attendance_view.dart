import 'package:flutter/material.dart';

class MissingAttendanceView extends StatelessWidget {
  const MissingAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFD97706),
                foregroundColor: Colors.white,
                child: Icon(Icons.report_problem_outlined),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missing attendance',
                      style: TextStyle(
                        color: Color(0xFF102A43),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Report a missed check-in or check-out for correction.',
                      style: TextStyle(color: Color(0xFF667085), height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD97706),
          ),
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: const Text('Report missing attendance'),
        ),
        const SizedBox(height: 26),
        const Text(
          'Recent reports',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE6EBF2)),
          ),
          child: const ListTile(
            leading: Icon(
              Icons.pending_actions_rounded,
              color: Color(0xFFD97706),
            ),
            title: Text(
              'Check-out correction',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('21 October · Pending review'),
          ),
        ),
      ],
    );
  }
}
