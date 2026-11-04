import 'package:attendance_flutter/core/common/app_loading_indicator.dart';
import 'package:attendance_flutter/core/common/app_snackbar.dart';
import 'package:attendance_flutter/core/dependency_injection/dependency_injection.dart';
import 'package:attendance_flutter/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _teal = Color(0xFF006B7A);
const _ink = Color(0xFF182230);
const _muted = Color(0xFF667085);

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (!mounted) return;
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => DashboardView(message: next.successMessage!),
          ),
        );
      } else if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppSnackBar.error(context, next.errorMessage!);
      }
    });
    final state = ref.watch(authViewModelProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 400;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 24,
                vertical: 22,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 44).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 485,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 24 : 42,
                      vertical: 42,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _BrandHeader(),
                            const SizedBox(height: 32),
                            const Center(
                              child: Text(
                                'Sign in',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 28,
                                  height: 1.25,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Center(
                              child: Text(
                                'Access your GBN Store employee account.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            const _FieldLabel('Phone number'),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(fontSize: 14, color: _ink),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
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
                            const SizedBox(height: 24),
                            const _FieldLabel('Password'),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(fontSize: 14, color: _ink),
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
                                    suffixIcon: TextButton(
                                      onPressed: () => ref
                                          .read(authViewModelProvider.notifier)
                                          .togglePasswordVisibility(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF467D91,
                                        ),
                                        minimumSize: const Size(64, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
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
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton(
                                onPressed: state.isLoading ? null : _signIn,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _teal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: const Color(0x33008399),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
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
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Sign in'),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 26),
                            const Divider(height: 1, color: Color(0xFFE5EEF2)),
                            const SizedBox(height: 27),
                            const Center(
                              child: Text(
                                'Need access? Contact your workspace administrator.',
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
                  ),
                ),
              ),
            );
          },
        ),
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
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
    );
    return InputDecoration(
      hintText: hint,
      errorMaxLines: 2,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: _muted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
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
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 48,
          height: 48,
          child: OverflowBox(
            maxWidth: 77,
            maxHeight: 77,
            child: Image.asset(
              'assets/images/gadgetbyte_logo.jpg',
              width: 77,
              height: 77,
              semanticLabel: 'Gadgetbyte logo',
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      const Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GBN Store',
              style: TextStyle(
                color: _ink,
                fontSize: 23,
                height: 1.25,
                fontWeight: FontWeight.w600,
                letterSpacing: -.8,
              ),
            ),
            SizedBox(height: 3),
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'HRMS',
                  style: TextStyle(
                    color: _teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Employee portal',
                  style: TextStyle(color: _muted, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
