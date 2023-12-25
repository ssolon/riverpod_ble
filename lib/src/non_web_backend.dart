import "package:flutter/foundation.dart";

import 'ble.dart';
import "ble_win_ble.dart";
import "ble_flutter_blue_plus.dart";
import "ble_linux.dart";

Ble setupBackend(bool exitWhenRequested) =>
    //defaultTargetPlatform == TargetPlatform.windows
    // ? BleWinBle() as Ble
    // : FlutterBluePlusBle();

    /* This switch statement doesn't work even with the cast as above */
    /* Well it works but needs that one, redundant, cast */

    switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS =>
        FlutterBluePlusBle() as Ble,
      TargetPlatform.linux => LinuxBle(exitWhenRequested),
      TargetPlatform.windows => BleWinBle(),
      _ => throw Exception("Unsupported platform=$defaultTargetPlatform"),
    };
