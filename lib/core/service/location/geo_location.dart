import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocation {
  static Future<Position> getCurrentLocation() async {
    LocationPermission permission;

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are not enabled.');
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Handle denied permission
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission was denied.');
    }

    // Handle permanently denied permission
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    // Allow more time for iOS to acquire a fresh GPS fix.
    final timeLimit = Duration(
      seconds: defaultTargetPlatform == TargetPlatform.iOS ? 45 : 20,
    );
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeLimit,
        ),
      );
    } on TimeoutException {
      return Future.error(
        'Unable to get your current location in time. '
        'Move to an open area and try again. '
        'Check that Precise Location is enabled in app settings.',
      );
    }
  }
}
