import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/features/auth/domain/entity/auth_entity.dart';
import 'package:attendance_flutter/features/auth/presentation/view/auth_components.dart';
import 'package:attendance_flutter/features/auth/presentation/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        AppSnackBar.success(context, next.successMessage!);
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final willPasswordShow = authState.willPasswordShow;
    return Scaffold(
      backgroundColor: authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AttendanceBrandHeader(
                      eyebrow: 'Set up your profile',
                      title: 'Join your team.',
                      subtitle: 'Create your account to start tracking attendance and making every workday count.',
                    ),
                    const SizedBox(height: 18),
                    const _RegisterProgress(),
                    const SizedBox(height: 18),
                    _RegisterCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your work profile',
                            style: TextStyle(
                              color: authNavy,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Use the details your team can identify you with.',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const AuthFieldLabel(label: 'Full name'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _fullNameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Alex Morgan',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
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
                            validator: (value) {
                              final phone = value?.trim() ?? '';
                              if (phone.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (phone.length < 7) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          const AuthFieldLabel(label: 'Password'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !willPasswordShow,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'At least 6 characters',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip: willPasswordShow
                                    ? 'Hide password'
                                    : 'Show password',
                                onPressed: () {
                                  ref
                                      .read(authViewModelProvider.notifier)
                                      .togglePasswordVisibility();
                                },
                                icon: Icon(
                                  willPasswordShow
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please create a password';
                              }
                              if (value.length < 6) {
                                return 'Use at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        ref
                                            .read(
                                              authViewModelProvider.notifier,
                                            )
                                            .createUser(
                                              AuthEntity(
                                                id: null,
                                                name: _fullNameController.text,
                                                phone: _phoneController.text,
                                                password:
                                                    _passwordController.text,
                                                role: null,
                                              ),
                                            );
                                      }
                                    },
                              icon: authState.isLoading
                                  ? const AppLoadingIndicator(
                                      size: 20,
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                      backgroundColor: Color(0x55FFFFFF),
                                      label: 'Creating profile',
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                              label: Text(
                                authState.isLoading
                                    ? 'Creating profile...'
                                    : 'Create profile',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const LoginView(),
                            ),
                          );
                        },
                        child: const Text('Already part of the team? Sign in'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _PrivacyText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({required this.child});

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
      child: child,
    );
  }
}

class _RegisterProgress extends StatelessWidget {
  const _RegisterProgress();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: const BoxDecoration(
            color: authBlue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: authBlue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Profile setup',
          style: TextStyle(
            color: authBlue,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PrivacyText extends StatelessWidget {
  const _PrivacyText();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your attendance data stays secure with your organization.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: const Color(0xFF8290A3)),
      ),
    );
  }
}
