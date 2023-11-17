<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->


## Features

A [Riverpod](https://riverpod.dev/) interface to access Bluetooth LE devices
that supports multiple platforms.

Flutter supports multiple platforms but there isn't a package with a single 
API that supports all of them.
This is an attempt fill that gap.

Note that this is somewhat of an experiment in creating a package to support
Bluetooth LE and, as of this writing, **should not be considered a finished, stable,
full featured, product**.

It's also my first major implementation using Riverpod so I'm not sure that
best practices are being followed.

This package builds on existing packages that provide platform specific implementations.

Currently the following platforms are supported:
* Android, IOS, MacOs using [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)
* Windows using [win_ble](https://pub.dev/packages/win_ble) 
* Web using [flutter_web_bluetooth](https://pub.dev/packages/flutter_web_bluetooth)

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
