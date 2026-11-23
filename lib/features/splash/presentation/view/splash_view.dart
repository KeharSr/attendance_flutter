import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendance_flutter/core/common/app_theme.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFF8FAFC),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    final logoProgress = Curves.easeOutCubic.transform(
                      (value / .7).clamp(0.0, 1.0),
                    );
                    final textProgress = Curves.easeOutCubic.transform(
                      ((value - .2) / .8).clamp(0.0, 1.0),
                    );
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: logoProgress,
                          child: Transform.translate(
                            offset: Offset(0, 16 * (1 - logoProgress)),
                            child: Transform.scale(
                              scale: .9 + .1 * logoProgress,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: const Color(0xFFE4EDF2),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0D126B8E),
                                      blurRadius: 28,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    width: 88,
                                    height: 88,
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
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Opacity(
                          opacity: textProgress,
                          child: Transform.translate(
                            offset: Offset(0, 8 * (1 - textProgress)),
                            child: const Column(
                              children: [
                                Text(
                                  'GBN Store',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -.7,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Your workday, in one place.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            value: reducedMotion ? .75 : null,
                            strokeWidth: 2,
                            strokeCap: StrokeCap.round,
                            color: AppColors.accent,
                            backgroundColor: const Color(0xFFE4EDF2),
                            semanticsLabel: 'Loading GBN Store HRMS',
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'GBN Store HRMS',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: .5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
