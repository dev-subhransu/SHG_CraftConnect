import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Configurable base URL
  static String? customBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }

    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback host to computer localhost
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (_) {
      // Platform check may fail on certain web/custom embeds
    }

    // iOS Simulator, macOS, Windows desktop
    return 'http://localhost:8000/api/v1';
  }

  // API Route paths
  static const String postsEndpoint = '/posts';
  static const String instantCheckoutEndpoint = '/orders/instant-checkout';
  static const String artisansEndpoint = '/artisans';
  static const String paymentsEndpoint = '/payments';
}
