import 'dart:developer';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const _tag = 'BleConnector';

class BleConnector {
  /// Stops the scanner, then connects to [device].
  /// Returns the connected device or null on failure.
  static Future<BluetoothDevice?> connect(
    BluetoothDevice device, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    log('Connecting to ${device.remoteId}…', name: _tag);
    try {
      await device.connect(license: License.free, timeout: timeout, autoConnect: false);
      log('Connected to ${device.remoteId}', name: _tag);
      return device;
    } on FlutterBluePlusException catch (e) {
      log('Connection failed: ${e.description}', name: _tag);
      return null;
    } catch (e) {
      log('Connection error: $e', name: _tag);
      return null;
    }
  }

  /// Gracefully disconnects [device], swallowing errors.
  static Future<void> disconnect(BluetoothDevice device) async {
    try {
      await device.disconnect();
      log('Disconnected from ${device.remoteId}', name: _tag);
    } catch (e) {
      log('Disconnect error: $e', name: _tag);
    }
  }
}
