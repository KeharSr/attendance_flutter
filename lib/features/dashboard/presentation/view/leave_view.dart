import 'package:flutter/material.dart';

class LeaveView extends StatelessWidget {
  const LeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleDashboardPage(
      icon: Icons.event_available_rounded,
      color: Color(0xFF14804A),
      title: 'Leave management',
      subtitle: 'Apply for leave and keep track of your remaining balance.',
      buttonLabel: 'Apply for leave',
      balance: '12 days',
      balanceLabel: 'Available leave',
    );
  }
}

class _SimpleDashboardPage extends StatelessWidget {
  const _SimpleDashboardPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.balance,
    required this.balanceLabel,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String balance;
  final String balanceLabel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF14804A),
                child: Icon(Icons.event_available_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xE6FFFFFF),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6EBF2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balanceLabel,
                      style: const TextStyle(color: Color(0xFF667085)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      balance,
                      style: const TextStyle(
                        color: Color(0xFF102A43),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.beach_access_rounded, color: color, size: 36),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded),
          label: Text(buttonLabel),
        ),
        const SizedBox(height: 26),
        const Text(
          'Recent leave',
          style: TextStyle(
            color: Color(0xFF102A43),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.check_circle_rounded, color: Color(0xFF14804A)),
          title: Text(
            'Dashain holiday',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text('Approved · 3 days'),
        ),
      ],
    );
  }
}
