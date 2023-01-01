import 'dart:async';

import 'package:aqueduct_isolates/aqueduct_isolates.dart';
import 'package:test/test.dart';

// Declare global variable for use in test
Completer completer = Completer();

void main() {
  test('Test an basic function aqueduct usage', () async {
    var aqueduct = Aqueduct.create(main: (Aqueduct instance) async {
      var response = await instance.last;
      completer.complete(response);
    }, isolate: (Aqueduct instance) async {
      int msg = await instance.next;
      instance.exit(msg * 2);
    });
    await aqueduct.launch();
    aqueduct.send(9);
    var result = await completer.future;
    expect(result, 9 * 2);
  });
}
