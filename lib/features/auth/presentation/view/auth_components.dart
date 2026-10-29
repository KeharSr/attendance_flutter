import 'package:flutter/material.dart';

const authNavy = Color(0xFF102A43);
const authBlue = Color(0xFF1769E0);
const authBackground = Color(0xFFF4F7FB);

class AttendanceBrandHeader extends StatelessWidget {
  const AttendanceBrandHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: authBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'WORKFORCE',
                style: TextStyle(
                  color: authNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            eyebrow,
            style: const TextStyle(
              color: authBlue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: authNavy,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: authNavy, fontWeight: FontWeight.w700),
    );
  }
}
