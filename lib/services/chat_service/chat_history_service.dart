import 'dart:convert';

import 'package:hive/hive.dart';

class ChatHistoryService {
  static const String _boxName = 'chatHistory';

  static Future<void> ensureInitialized() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get _box => Hive.box(_boxName);

  static List<Map<String, dynamic>> getRooms() {
    if (!Hive.isBoxOpen(_boxName)) {
      return const [];
    }
    final List<Map<String, dynamic>> rooms = [];
    for (final dynamic value in _box.values) {
      if (value is Map) {
        rooms.add(_deepCopy(Map<String, dynamic>.from(value)));
      }
    }
    rooms.sort((a, b) {
      final aTime = DateTime.tryParse(a['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return rooms;
  }

  static Map<String, dynamic>? getRoom(String roomId) {
    if (!Hive.isBoxOpen(_boxName)) {
      return null;
    }
    final dynamic raw = _box.get(roomId);
    if (raw is Map) {
      return _deepCopy(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static Future<String> createRoom({required String title}) async {
    await ensureInitialized();
    final String roomId = DateTime.now().microsecondsSinceEpoch.toString();
    final String timestamp = DateTime.now().toIso8601String();
    final Map<String, dynamic> room = {
      'id': roomId,
      'title': title,
      'createdAt': timestamp,
      'updatedAt': timestamp,
      'lastMessage': '',
      'messages': <Map<String, dynamic>>[],
    };
    await _box.put(roomId, room);
    return roomId;
  }

  static Future<void> saveMessages(
      String roomId, List<Map<String, dynamic>> messages) async {
    await ensureInitialized();
    final Map<String, dynamic> room = getRoom(roomId) ??
        {
          'id': roomId,
          'title': 'Obrolan',
          'createdAt': DateTime.now().toIso8601String(),
        };
    final List<Map<String, dynamic>> sanitized = messages.map((msg) {
      final dynamic safe = jsonDecode(jsonEncode(msg));
      if (safe is Map) {
        return Map<String, dynamic>.from(safe);
      }
      return <String, dynamic>{};
    }).toList();

    final String timestamp = DateTime.now().toIso8601String();
    room['messages'] = sanitized;
    room['updatedAt'] = timestamp;
    room['lastMessage'] =
        sanitized.isNotEmpty ? sanitized.last['text']?.toString() ?? '' : '';

    await _box.put(roomId, room);
  }

  static Future<void> renameRoom(String roomId, String title) async {
    await ensureInitialized();
    final Map<String, dynamic>? room = getRoom(roomId);
    if (room == null) return;
    room['title'] = title;
    await _box.put(roomId, room);
  }

  static Future<void> deleteRoom(String roomId) async {
    if (!Hive.isBoxOpen(_boxName)) return;
    await _box.delete(roomId);
  }

  static Map<String, dynamic> _deepCopy(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
  }
}
