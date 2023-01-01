import 'dart:async';
import 'dart:collection';

import 'package:aqueduct/aqueduct.dart';

/// A pool consisting of a total of [count] individual [Aqueduct] isolates
/// which are constructed using [supplier].
class AqueductPool<T extends Aqueduct> {
  /// Specifies the amount of pooled isolates.
  final int count;

  /// Specifies the supplier function used to create the [T] isolate instances.
  final T Function() supplier;

  AqueductPool(this.count, this.supplier);

  final List<T> _instances = [];
  final Queue<T> _idle = Queue();
  final Queue<Future Function(T)> _tasks = Queue();

  /// Fills the pool with the specified amount fo isolates and launches them.
  Future start() async {
    for (int i = 0; i < count; i++) {
      var aqueduct = supplier();
      await aqueduct.launch();
      _instances.add(aqueduct);
      _idle.add(aqueduct);
    }
    _poll();
  }

  /// Submits a task with the return value [R] and the function [func].
  /// Returns the return value of the task after it has been completed.
  Future<R> task<R>(FutureOr<R> Function(T) func) async {
    var completer = Completer<R>();
    _tasks.add((p) async {
      var result = await func(p);
      completer.complete(result);
      _poll();
    });
    _poll();
    return completer.future;
  }

  void _poll() {
    if (_tasks.isNotEmpty && _idle.isNotEmpty) {
      var batch = _tasks.removeFirst();
      var instance = _idle.removeLast();
      batch(instance).then((_) => _idle.add(instance));
    }
  }
}
