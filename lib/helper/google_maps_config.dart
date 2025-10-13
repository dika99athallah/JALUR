import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_utils/src/platform/platform.dart';

class GoogleMapsConfig {
  static String get _legacyMapsKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? '';

  static String get servicesApiKey {
    final candidates = <String?>[
      dotenv.env['GOOGLE_MAPS_SERVICES_KEY'],
      dotenv.env['GOOGLE_WEATHER_API_KEY'],
      dotenv.env['WEATHER_API_KEY'],
      _legacyMapsKey,
    ];

    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }

  static String get androidSdkApiKey {
    final candidates = <String?>[
      dotenv.env['GOOGLE_MAPS_ANDROID_SDK_KEY'],
      dotenv.env['GOOGLE_MAPS_ANDROID_KEY'],
      _legacyMapsKey,
    ];

    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }

  static String get iosSdkApiKey {
    final candidates = <String?>[
      dotenv.env['GOOGLE_MAPS_IOS_SDK_KEY'],
      dotenv.env['GOOGLE_MAPS_IOS_KEY'],
      _legacyMapsKey,
    ];

    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }

  static String get sdkApiKey {
    if (GetPlatform.isAndroid) {
      final key = androidSdkApiKey;
      if (key.isNotEmpty) {
        return key;
      }
    } else if (GetPlatform.isIOS || GetPlatform.isMacOS) {
      final key = iosSdkApiKey;
      if (key.isNotEmpty) {
        return key;
      }
    }

    final fallback = dotenv.env['GOOGLE_MAPS_SDK_KEY']?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    return servicesApiKey;
  }

  static String get androidPackageName =>
      dotenv.env['GOOGLE_ANDROID_PACKAGE'] ?? '';

  static String get androidCertificateSha1 =>
      dotenv.env['GOOGLE_ANDROID_CERT_SHA1'] ?? '';

  static String get iosBundleIdentifier =>
      dotenv.env['GOOGLE_IOS_BUNDLE_ID'] ?? '';

  static bool get hasServicesKey => servicesApiKey.isNotEmpty;

  static bool get hasSdkKey => sdkApiKey.isNotEmpty;

  static bool isValid() => hasServicesKey;

  /// Backwards compatibility for older code paths expecting [apiKey].
  static String get apiKey => servicesApiKey;
}
