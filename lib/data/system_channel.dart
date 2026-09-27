import 'package:flutter/services.dart';

/// Small Android-only helpers implemented in MainActivity.kt.
class SystemChannel {
  const SystemChannel();

  static const _channel = MethodChannel('qari/system');

  /// Free bytes on the volume containing [path], or null if unknown.
  Future<int?> freeBytes(String path) async {
    try {
      return await _channel.invokeMethod<int>('freeBytes', {'path': path});
    } catch (_) {
      return null;
    }
  }

  Future<void> openTtsSettings() async {
    try {
      await _channel.invokeMethod<void>('openTtsSettings');
    } catch (_) {}
  }
}
