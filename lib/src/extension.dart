import 'dart:isolate';

import 'package:aqueduct_isolates/aqueduct_isolates.dart';

extension AqueductExtension on Aqueduct {
  /// Gets the context for the current isolate.
  AqueductContext get context => contextRaw;

  /// Gets the ingoing event stream for this isolate.
  Stream<dynamic> get events => context.events;

  /// Gets the outgoing event stream for this isolate.
  SendPort get dataPort => context.dataPort;

  /// Creates a future that completes with the next received event.
  Future<dynamic> get next => events.first;

  /// Creates a future that completes with the last event received,
  /// i.E. the event passed to [exit].
  Future<dynamic> get last => events.last;

  /// Exits this isolate and returns [value] as its last event.
  @SpawnedIsolate()
  void exit(Object value) {
    context.receiver.close();
    Isolate.exit(context.dataPort, value);
  }

  /// Sends an event to the other isolate.
  void send(Object value) => dataPort.send(value);
}
