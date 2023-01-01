/// Support for creating long-lived isolate based workers.
library aqueduct;

export 'src/aqueduct.dart';
export 'src/args.dart';
export 'src/cluster.dart';
export 'src/entrypoint.dart';
export 'src/extension.dart';

/// Marks something as being only available in the scope of the main isolate.
class MainIsolate {
  const MainIsolate();
}

/// Marks something as being only available in the scope of the spawned isolate.
class SpawnedIsolate {
  const SpawnedIsolate();
}
