import 'dart:isolate';

import 'package:aqueduct_isolates/aqueduct_isolates.dart';

/// Entrypoint for the isolates spawned by [Aqueduct.launch].
@pragma("vm:entry-point")
void aqueductEntrypoint(AqueductInitArgs args) {
  var receiver = ReceivePort("dataDst");
  var events = receiver.asBroadcastStream();
  args.callback.send(AqueductCallback(receiver.sendPort));
  var context =
      AqueductContext(null, events, args.data, args.callback, receiver);
  args.aqueduct.contextRaw = context;
  args.aqueduct.isolateRun();
}
