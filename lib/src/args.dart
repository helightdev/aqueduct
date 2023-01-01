import 'dart:isolate';

import 'package:aqueduct/aqueduct.dart';

/// Shared context abstraction for both the main and spawned isolates.
class AqueductContext {
  /// Reference to the spawned isolate. Only present in the main isolate.
  @MainIsolate()
  final Isolate? isolate;

  /// Reference to the incoming event stream. Present in both isolates.
  final Stream<dynamic> events;

  /// Reference to the outgoing event stream. Present in both isolates.
  final SendPort dataPort;

  /// Reference to the outgoing callback port. Only present in the spawned isolate.
  @SpawnedIsolate()
  final SendPort? callbackPort;

  /// Reference to the receiving event port. Present in both isolates.
  final ReceivePort receiver;

  const AqueductContext(this.isolate, this.events, this.dataPort,
      this.callbackPort, this.receiver);
}

/// Initial callback message of spawned isolate to the main isolate.
class AqueductCallback {
  /// Reference to the outgoing event port.
  final SendPort dataPort;

  const AqueductCallback(this.dataPort);
}

/// Initial message which is sent to the spawned isolate.
class AqueductInitArgs {
  final SendPort data;
  final SendPort callback;
  final Aqueduct aqueduct;

  const AqueductInitArgs(this.data, this.callback, this.aqueduct);
}
