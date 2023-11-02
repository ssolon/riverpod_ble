import "package:flutter/foundation.dart";

import 'ble.dart';
import "ble_win_ble.dart";
import "ble_flutter_blue_plus.dart";

Ble setupBackend() => defaultTargetPlatform == TargetPlatform.windows
    ? BleWinBle() as Ble
    : FlutterBluePlusBle();
 
 /* This switch statement doesn't work even with the cast as above
 switch (defaultTargetPlatform) {
          TargetPlatform.windows => BleWinBle(),
          TargetPlatform.android ||
          TargetPlatform.iOS ||
          TargetPlatform.macOS => FlutterBluePlusBle(),
          _ => throw Exception("Unsupported platform=$defaultTargetPlatform"),
        }; 
*/