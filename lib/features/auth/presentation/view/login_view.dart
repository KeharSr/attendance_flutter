import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/auth/presentation/view/auth_components.dart';
import 'package:attendance_flutter/features/auth/presentation/view/register_view.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        final message = next.successMessage!;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => DashboardView(message: message),
          ),
        );
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });

    final loginState = ref.watch(authViewModelProvider);
    final isPasswordVisible = loginState.willPasswordShow;
    return Scaffold(
      backgroundColor: authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AttendanceBrandHeader(
                    eyebrow: 'Your workday, organized',
                    title: 'Good to see you.',
                    subtitle: 'Sign in to clock in, view your hours, and stay connected with your team.',
                  ),
                  const SizedBox(height: 18),
                  _AttendanceTip(
                    icon: Icons.schedule_rounded,
                    title: 'Ready for today?',
                    subtitle: 'Keep your attendance up to date in one place.',
                  ),
                  const SizedBox(height: 18),
                  _AuthCard(
                    title: 'Sign in to your account',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthFieldLabel(label: 'Phone number'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 98XXXXXXXX',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const AuthFieldLabel(label: 'Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: isPasswordVisible
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () {
                                ref
                                    .read(authViewModelProvider.notifier)
                                    .togglePasswordVisibility();
                              },
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: () {
                              ref
                                  .read(authViewModelProvider.notifier)
                                  .loginUser(
                                    phone: _phoneController.text,
                                    password: _passwordController.text,
                                  );
                            },
                            icon: loginState.isLoading
                                ? AppLoadingIndicator()
                                : const Icon(Icons.login_rounded, size: 20),
                            label: const Text('Sign in'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterView(),
                          ),
                        );
                      },
                      child: const Text('New to Workforce? Create an account'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const _SupportText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08102A43),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: authNavy, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _AttendanceTip extends StatelessWidget {
  const _AttendanceTip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2EA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF218653),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: authNavy, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: const Color(0xFF718096)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupportText extends StatelessWidget {
  const _SupportText();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Need help? Contact your administrator',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: const Color(0xFF8290A3)),
      ),
    );
  }
}
