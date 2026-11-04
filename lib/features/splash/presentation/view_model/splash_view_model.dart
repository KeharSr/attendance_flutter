import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashViewModelProvider = NotifierProvider<SplashViewModel, bool>(
  SplashViewModel.new,
);

class SplashViewModel extends Notifier<bool> {
  @override
  bool build() {
    final timer = Timer(const Duration(milliseconds: 2400), () => state = true);
    ref.onDispose(timer.cancel);
    return false;
  }
}
