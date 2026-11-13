import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(appSharedPrefsProvider);
    final auth = ref.watch(authViewModelProvider);
    ref.listen(authViewModelProvider, (previous, next) {
      if (previous?.isLoggingOut == true &&
          !next.isLoggingOut &&
          next.errorMessage != null) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });
    final savedName = prefs.getUserName()?.trim() ?? '';
    final name = savedName.isEmpty ? 'Employee' : savedName;
    final phone = prefs.getUserPhone()?.trim();
    final id = prefs.getUserId()?.trim();
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.accentLight,
                        child: Text(
                          name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'GBN Store',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  const Text(
                    'Personal information',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  _ProfileDetail(
                    icon: Icons.person_outline,
                    label: 'Full name',
                    value: name,
                  ),
                  const SizedBox(height: 22),
                  _ProfileDetail(
                    icon: Icons.phone_outlined,
                    label: 'Phone number',
                    value: phone == null || phone.isEmpty
                        ? 'Not provided'
                        : phone,
                  ),
                  const SizedBox(height: 22),
                  _ProfileDetail(
                    icon: Icons.badge_outlined,
                    label: 'Employee ID',
                    value: id == null || id.isEmpty ? 'Not provided' : id,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'To update your details or account access, contact your HR administrator.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: Text(
                        auth.isLoggingOut ? 'Signing out...' : 'Sign out',
                      ),
                      onPressed: auth.isLoggingOut || auth.isLoading
                          ? null
                          : () => ref
                                .read(authViewModelProvider.notifier)
                                .logoutUser(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'GBN Store HRMS',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 21, color: AppColors.accent),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
