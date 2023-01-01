import 'dart:isolate';

import 'package:aqueduct_isolates/aqueduct_isolates.dart';

/// Flexible handler for creating long-lived isolate based workers.
///
/// All fields of the implementing type should be immutable and must be
/// passable via [SendPort.send]. All field values will be shared with spawned
/// isolate instance although mutations won't be reflected in the main instance.
///
/// Both isolate instances run in the "same" object, meaning [events], [next],
/// [context], ..., will have different values depending on which isolate tries
/// to access the data. Further clarification for api surfaces can be provided
/// using the meta annotations [MainIsolate] and [SpawnedIsolate].
abstract class Aqueduct {
  dynamic contextRaw;

  /// Run method for the main isolate.
  @MainIsolate()
  void mainRun();

  /// Run method for the spawned isolate.
  @SpawnedIsolate()
  void isolateRun();

  /// Spawns an isolate and initializes it for bidirectional communication.
  @MainIsolate()
  Future launch() async {
    var dataReceiver = ReceivePort("dataSrc");
    var events = dataReceiver.asBroadcastStream();
    var callbackReceiver = ReceivePort("callback");
    var callbacks = callbackReceiver.asBroadcastStream();
    var initialCallbackFuture = callbacks.first;
    callbacks.skip(1).first.then((_) {
      dataReceiver.close();
      callbackReceiver.close();
    });
    var isolate = await Isolate.spawn(
        aqueductEntrypoint,
        AqueductInitArgs(
            dataReceiver.sendPort, callbackReceiver.sendPort, this));
    AqueductCallback callback = await initialCallbackFuture;
    var dataPort = callback.dataPort;
    isolate.addOnExitListener(callbackReceiver.sendPort);
    var context =
        AqueductContext(isolate, events, dataPort, null, dataReceiver);
    contextRaw = context;
    mainRun();
  }

  /// Creates an aqueduct implementation using functions.
  static Aqueduct create(
          {required Function(Aqueduct) main,
          required Function(Aqueduct) isolate}) =>
      AqueductImpl(main, isolate);
}

class AqueductImpl extends Aqueduct {
  final Function(Aqueduct) main;
  final Function(Aqueduct) isolate;

  AqueductImpl(this.main, this.isolate);

  @override
  void isolateRun() {
    isolate(this);
  }

  @override
  void mainRun() {
    main(this);
  }
}
