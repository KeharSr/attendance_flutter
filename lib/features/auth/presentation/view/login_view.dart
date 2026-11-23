import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';
import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _teal = AppColors.accent;
const _ink = Color(0xFF182230);
const _muted = Color(0xFF667085);

class LoginView extends ConsumerStatefulWidget {
  const LoginView({this.message, super.key});
  final String? message;

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authViewModelProvider.notifier).loadBiometricStatus();
      }
    });
    if (widget.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AppSnackBar.success(context, widget.message!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (!mounted) return;
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });
    final state = ref.watch(authViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - 56).clamp(
                  0.0,
                  double.infinity,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BrandHeader(),
                      const SizedBox(height: 32),
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sign in to your employee workspace.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE4E7EC)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x07163449),
                              blurRadius: 20,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _FieldLabel('Phone number'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneController,
                                  enabled: !state.isLoading,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _ink,
                                  ),
                                  validator: (value) =>
                                      value == null || value.trim().isEmpty
                                      ? 'Enter your phone number'
                                      : null,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  decoration:
                                      _fieldDecoration(
                                        'Enter your phone number',
                                      ).copyWith(
                                        prefixIcon: const Icon(
                                          LucideIcons.phone,
                                          size: 18,
                                          color: _muted,
                                        ),
                                      ),
                                ),
                                const SizedBox(height: 18),
                                const _FieldLabel('Password'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  enabled: !state.isLoading,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: _ink,
                                  ),
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Enter your password'
                                      : null,
                                  obscureText: !state.willPasswordShow,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    if (!state.isLoading) _signIn();
                                  },
                                  decoration:
                                      _fieldDecoration(
                                        'Enter your password',
                                      ).copyWith(
                                        prefixIcon: const Icon(
                                          LucideIcons.lockKeyhole,
                                          size: 18,
                                          color: _muted,
                                        ),
                                        suffixIcon: IconButton(
                                          tooltip: state.willPasswordShow
                                              ? 'Hide password'
                                              : 'Show password',
                                          onPressed: state.isLoading
                                              ? null
                                              : () => ref
                                                    .read(
                                                      authViewModelProvider
                                                          .notifier,
                                                    )
                                                    .togglePasswordVisibility(),
                                          icon: Icon(
                                            state.willPasswordShow
                                                ? LucideIcons.eyeOff
                                                : LucideIcons.eye,
                                            size: 18,
                                          ),
                                          color: _muted,
                                        ),
                                      ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : _forgotPassword,
                                    style: TextButton.styleFrom(
                                      foregroundColor: _teal,
                                      textStyle: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    child: const Text('Forgot password?'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 48,
                                          ),
                                          child: FilledButton(
                                            onPressed: state.isLoading
                                                ? null
                                                : _signIn,
                                            style: FilledButton.styleFrom(
                                              backgroundColor: _teal,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                    horizontal: 16,
                                                  ),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              textStyle: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            child: state.isLoading
                                                ? const AppLoadingIndicator(
                                                    size: 20,
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                    label: 'Signing in',
                                                  )
                                                : const Text('Sign in'),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 48,
                                        child: Tooltip(
                                          message:
                                              state.biometricEnabled &&
                                                  state.biometricAvailable
                                              ? 'Sign in with biometrics'
                                              : 'Enable biometric sign-in in Profile after signing in',
                                          child: OutlinedButton(
                                            onPressed:
                                                state.isLoading ||
                                                    !state.biometricEnabled ||
                                                    !state.biometricAvailable
                                                ? null
                                                : () => ref
                                                      .read(
                                                        authViewModelProvider
                                                            .notifier,
                                                      )
                                                      .loginWithBiometrics(),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(48, 48),
                                              backgroundColor: const Color(
                                                0xFFEDF7FA,
                                              ),
                                              foregroundColor: _teal,
                                              side: BorderSide(
                                                color: _teal.withValues(
                                                  alpha: .3,
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Icon(
                                              LucideIcons.fingerprint,
                                              size: 26,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No account? Contact your workspace administrator.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _forgotPassword() {
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot password?'),
        content: const Text(
          'Contact your workspace administrator to reset your password and regain access to your employee account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref
        .read(authViewModelProvider.notifier)
        .loginUser(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  InputDecoration _fieldDecoration(String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
    );
    return InputDecoration(
      hintText: hint,
      errorMaxLines: 2,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: _muted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: _teal, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: _ink,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 48,
          height: 48,
          child: OverflowBox(
            maxWidth: 66,
            maxHeight: 66,
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 66,
              height: 66,
              semanticLabel: 'GBN Store logo',
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GBN Store',
              style: TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Employee workspace',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );
}
