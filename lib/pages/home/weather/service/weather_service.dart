import 'dart:convert';

import 'package:JIR/helper/google_maps_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://weather.googleapis.com/v1';

  final http.Client _client;

  String get _apiKey {
    final candidates = <(String source, String?)>[
      if (GetPlatform.isAndroid)
        (
          'GOOGLE_WEATHER_ANDROID_KEY',
          dotenv.env['GOOGLE_WEATHER_ANDROID_KEY']
        ),
      if (GetPlatform.isIOS || GetPlatform.isMacOS)
        ('GOOGLE_WEATHER_IOS_KEY', dotenv.env['GOOGLE_WEATHER_IOS_KEY']),
      ('GOOGLE_WEATHER_API_KEY', dotenv.env['GOOGLE_WEATHER_API_KEY']),
      ('WEATHER_API_KEY', dotenv.env['WEATHER_API_KEY']),
      ('GOOGLE_MAPS_SERVICES_KEY', dotenv.env['GOOGLE_MAPS_SERVICES_KEY']),
      ('GOOGLE_MAPS_API_KEY', dotenv.env['GOOGLE_MAPS_API_KEY']),
      (
        'GoogleMapsConfig.servicesApiKey',
        GoogleMapsConfig.servicesApiKey,
      ),
    ];

    for (final entry in candidates) {
      final key = entry.$2?.trim();
      if (key != null && key.isNotEmpty) {
        if (kDebugMode) {
          final suffix = key.length >= 4 ? key.substring(key.length - 4) : key;
          debugPrint(
            '[WeatherService] Using API key from ${entry.$1} (suffix $suffix)',
          );
        }
        return key;
      }
    }

    throw StateError(
      'Google Weather API key is missing. Set GOOGLE_MAPS_SERVICES_KEY atau '
      'GOOGLE_WEATHER_ANDROID_KEY / GOOGLE_WEATHER_IOS_KEY (atau '
      'GOOGLE_WEATHER_API_KEY) di berkas .env.',
    );
  }

  Future<WeatherCurrent> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse('$_baseUrl/currentConditions:lookup').replace(
      queryParameters: <String, String>{
        'key': _apiKey,
        'location.latitude': lat.toString(),
        'location.longitude': lon.toString(),
        'unitsSystem': 'METRIC',
        'languageCode': 'en',
      },
    );

    final response = await _client.get(uri, headers: _buildHeaders());
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch current conditions: ${_formatError(response)}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherCurrent.fromJson(data);
  }

  Future<List<WeatherHour>> fetchHourlyForecast({
    required double lat,
    required double lon,
    int hours = 6,
  }) async {
    final cappedHours = hours.clamp(1, 240);
    final uri = Uri.parse('$_baseUrl/forecast/hours:lookup').replace(
      queryParameters: <String, String>{
        'key': _apiKey,
        'location.latitude': lat.toString(),
        'location.longitude': lon.toString(),
        'hours': '$cappedHours',
        'unitsSystem': 'METRIC',
        'languageCode': 'en',
        'pageSize': '$cappedHours',
      },
    );

    final response = await _client.get(uri, headers: _buildHeaders());
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch hourly forecast: ${_formatError(response)}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = (data['forecastHours'] as List<dynamic>? ?? <dynamic>[]);
    return rawList
        .map((item) => WeatherHour.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<WeatherHour>> fetchHourlyHistory({
    required double lat,
    required double lon,
    int hours = 6,
  }) async {
    final cappedHours = hours.clamp(1, 24);
    final uri = Uri.parse('$_baseUrl/history/hours:lookup').replace(
      queryParameters: <String, String>{
        'key': _apiKey,
        'location.latitude': lat.toString(),
        'location.longitude': lon.toString(),
        'hours': '$cappedHours',
        'unitsSystem': 'METRIC',
        'languageCode': 'en',
        'pageSize': '$cappedHours',
      },
    );

    final response = await _client.get(uri, headers: _buildHeaders());
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch hourly history: ${_formatError(response)}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawList = (data['historyHours'] as List<dynamic>? ?? <dynamic>[]);
    final result = rawList
        .map((item) => WeatherHour.fromJson(item as Map<String, dynamic>))
        .toList();
    result.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchHourlyWindow({
    int before = 2,
    int after = 2,
    required double lat,
    required double lon,
  }) async {
    final futures = <Future<dynamic>>[];

    if (before > 0) {
      futures.add(
        fetchHourlyHistory(lat: lat, lon: lon, hours: before),
      );
    } else {
      futures.add(Future<List<WeatherHour>>.value(const <WeatherHour>[]));
    }

    futures.add(fetchCurrent(lat: lat, lon: lon));

    if (after > 0) {
      futures.add(
        fetchHourlyForecast(lat: lat, lon: lon, hours: after),
      );
    } else {
      futures.add(Future<List<WeatherHour>>.value(const <WeatherHour>[]));
    }

    final results = await Future.wait(futures);
    final history = results[0] as List<WeatherHour>;
    final current = results[1] as WeatherCurrent;
    final forecast = results[2] as List<WeatherHour>;

    final combined = <WeatherHour>[
      ...history,
      current.asHour(),
      ...forecast,
    ];

    final deduped = <int, WeatherHour>{};
    for (final hour in combined) {
      deduped[_hourKey(hour.dateTime)] = hour;
    }

    final sorted = deduped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sorted.map((entry) => entry.value.toMap()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchHistory({
    int hours = 24,
    required double lat,
    required double lon,
  }) async {
    final history = await fetchHourlyHistory(
      lat: lat,
      lon: lon,
      hours: hours,
    );
    return history.map((hour) => hour.toMap()).toList();
  }
}

int _hourKey(DateTime dt) {
  final rounded = DateTime(dt.year, dt.month, dt.day, dt.hour);
  return rounded.millisecondsSinceEpoch ~/ 1000;
}

Map<String, String> _buildHeaders() {
  final headers = <String, String>{
    'Accept': 'application/json',
  };

  if (GetPlatform.isIOS || GetPlatform.isMacOS) {
    final bundle = GoogleMapsConfig.iosBundleIdentifier.trim();
    if (bundle.isNotEmpty) {
      headers['X-Ios-Bundle-Identifier'] = bundle;
    }
  }

  if (GetPlatform.isAndroid) {
    final packageName = GoogleMapsConfig.androidPackageName.trim();
    final certSha1 = GoogleMapsConfig.androidCertificateSha1.trim();
    if (packageName.isNotEmpty) {
      headers['X-Android-Package'] = packageName;
    }
    if (certSha1.isNotEmpty) {
      headers['X-Android-Cert'] = certSha1;
    }
  }

  if (kDebugMode) {
    debugPrint('[WeatherService] Request headers: $headers');
  }

  return headers;
}

String _formatError(http.Response response) {
  final status = response.statusCode;
  final bodyText = response.body;

  try {
    final dynamic decoded = jsonDecode(bodyText);
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'] as String?;
        final details = error['details'];
        String? reason;
        if (details is List) {
          for (final item in details) {
            if (item is Map<String, dynamic>) {
              final itemReason = item['reason'] as String?;
              if (itemReason != null && itemReason.isNotEmpty) {
                reason = itemReason;
                break;
              }
            }
          }
        }

        final buffer = StringBuffer('$status');
        if (message != null && message.isNotEmpty) {
          buffer.write(' $message');
        }

        final hint = _hintForReason(reason);
        if (hint != null) {
          buffer.write(' ($hint)');
        }

        return buffer.toString();
      }
    }
  } catch (_) {
    // Ignore JSON parse errors and fall back to raw body.
  }

  return '$status $bodyText';
}

String? _hintForReason(String? reason) {
  switch (reason) {
    case 'API_KEY_IOS_APP_BLOCKED':
      return 'Ensure GOOGLE_IOS_BUNDLE_ID matches the iOS restrictions for the Google Weather API key or supply a platform-specific key via GOOGLE_WEATHER_IOS_KEY.';
    case 'API_KEY_ANDROID_APP_BLOCKED':
      return 'Ensure GOOGLE_ANDROID_PACKAGE and GOOGLE_ANDROID_CERT_SHA1 match the Android restrictions for the Google Weather API key or set GOOGLE_WEATHER_ANDROID_KEY to a key with the correct allowance.';
    default:
      return null;
  }
}

class WeatherHour {
  WeatherHour({
    required this.dateTime,
    required this.temperatureCelsius,
    required this.description,
    required this.conditionType,
    required this.iconBaseUri,
  });

  factory WeatherHour.fromJson(Map<String, dynamic> json) {
    final interval = json['interval'] as Map<String, dynamic>?;
    final startTime =
        interval != null ? interval['startTime'] as String? : null;
    final weatherCondition =
        json['weatherCondition'] as Map<String, dynamic>? ?? const {};
    final description =
        weatherCondition['description'] as Map<String, dynamic>?;
    final temperature = json['temperature'] as Map<String, dynamic>?;

    return WeatherHour(
      dateTime: _parseDateTime(startTime ?? json['currentTime'] as String?),
      temperatureCelsius:
          (temperature?['degrees'] as num?)?.toDouble() ?? double.nan,
      description: description?['text'] as String? ?? '',
      conditionType: weatherCondition['type'] as String? ?? '',
      iconBaseUri: weatherCondition['iconBaseUri'] as String? ?? '',
    );
  }

  final DateTime dateTime;
  final double temperatureCelsius;
  final String description;
  final String conditionType;
  final String iconBaseUri;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
        'temp': temperatureCelsius.isNaN ? 0.0 : temperatureCelsius,
        'description': description,
        'conditionType': conditionType,
        'icon': iconBaseUri,
      };
}

class WeatherCurrent extends WeatherHour {
  WeatherCurrent({
    required super.dateTime,
    required super.temperatureCelsius,
    required super.description,
    required super.conditionType,
    required super.iconBaseUri,
  });

  factory WeatherCurrent.fromJson(Map<String, dynamic> json) {
    final weatherCondition =
        json['weatherCondition'] as Map<String, dynamic>? ?? const {};
    final description =
        weatherCondition['description'] as Map<String, dynamic>?;
    final temperature = json['temperature'] as Map<String, dynamic>?;

    return WeatherCurrent(
      dateTime: _parseDateTime(json['currentTime'] as String?),
      temperatureCelsius:
          (temperature?['degrees'] as num?)?.toDouble() ?? double.nan,
      description: description?['text'] as String? ?? '',
      conditionType: weatherCondition['type'] as String? ?? '',
      iconBaseUri: weatherCondition['iconBaseUri'] as String? ?? '',
    );
  }

  WeatherHour asHour() => WeatherHour(
        dateTime: dateTime,
        temperatureCelsius: temperatureCelsius,
        description: description,
        conditionType: conditionType,
        iconBaseUri: iconBaseUri,
      );
}

DateTime _parseDateTime(String? raw) {
  if (raw == null || raw.isEmpty) {
    return DateTime.now();
  }
  try {
    return DateTime.parse(raw).toLocal();
  } catch (_) {
    return DateTime.now();
  }
}
