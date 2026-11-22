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
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final headerHeight = (constraints.maxHeight * .35).clamp(
              230.0,
              310.0,
            );
            final panelHeight = (constraints.maxHeight - headerHeight).clamp(
              0.0,
              double.infinity,
            );
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 485),
                  child: Column(
                    children: [
                      SizedBox(
                        height: headerHeight,
                        child: const _BrandHeader(),
                      ),
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(minHeight: panelHeight),
                        padding: EdgeInsets.fromLTRB(
                          constraints.maxWidth < 400 ? 24 : 32,
                          28,
                          constraints.maxWidth < 400 ? 24 : 32,
                          20 + MediaQuery.paddingOf(context).bottom,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                (panelHeight -
                                        48 -
                                        MediaQuery.paddingOf(context).bottom)
                                    .clamp(0.0, double.infinity),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Form(
                                key: _formKey,
                                child: AutofillGroup(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _FieldLabel('Phone number'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _phoneController,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: _ink,
                                        ),
                                        validator: (value) =>
                                            value == null ||
                                                value.trim().isEmpty
                                            ? 'Enter your phone number'
                                            : null,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.telephoneNumber,
                                        ],
                                        decoration: _fieldDecoration(
                                          'Enter your phone number',
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const _FieldLabel('Password'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordController,
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
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) {
                                          if (!state.isLoading) _signIn();
                                        },
                                        decoration:
                                            _fieldDecoration(
                                              'Enter your password',
                                            ).copyWith(
                                              suffixIcon: TextButton(
                                                onPressed: () => ref
                                                    .read(
                                                      authViewModelProvider
                                                          .notifier,
                                                    )
                                                    .togglePasswordVisibility(),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: const Color(
                                                    0xFF467D91,
                                                  ),
                                                  minimumSize: const Size(
                                                    64,
                                                    48,
                                                  ),
                                                  textStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                child: Text(
                                                  state.willPasswordShow
                                                      ? 'Hide'
                                                      : 'Show',
                                                ),
                                              ),
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: state.isLoading
                                              ? null
                                              : _forgotPassword,
                                          style: TextButton.styleFrom(
                                            foregroundColor: _teal,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 12,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          child: const Text('Forgot password?'),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: FilledButton(
                                          onPressed: state.isLoading
                                              ? null
                                              : _signIn,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: _teal,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            textStyle: const TextStyle(
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
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 48),
                                child: Text(
                                  'No account? Contact your workspace administrator.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 12,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
      borderRadius: BorderRadius.circular(14),
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
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 76,
            height: 76,
            child: OverflowBox(
              maxWidth: 122,
              maxHeight: 122,
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 122,
                height: 122,
                semanticLabel: 'GBN Store logo',
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome back',
          style: TextStyle(
            color: _ink,
            fontSize: 26,
            height: 1.25,
            fontWeight: FontWeight.w600,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to GBN Store',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
      ],
    ),
  );
}
