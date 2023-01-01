import 'package:aqueduct/aqueduct.dart';

void main() async {
  var cluster = AqueductPool<CalcAqueduct>(5, () => CalcAqueduct());
  await cluster.start();
  for (int i = 0; i < 99; i++) {
    cluster.task((p0) async {
      return p0.runCalculation(i);
    }).then((value) => print("$i * $i = $value"));
  }

  var handshake = HandshakeAqueduct();
  handshake.launch();
}

class CalcAqueduct extends Aqueduct {
  @override
  void isolateRun() async {
    await for (var event in events) {
      if (event is int) {
        await Future.delayed(Duration(seconds: 1));
        send(event * event);
      }
    }
  }

  @override
  void mainRun() {}

  @MainIsolate()
  Future<int> runCalculation(int input) async {
    var resultFuture = next;
    send(input);
    return await resultFuture;
  }
}

class HandshakeAqueduct extends Aqueduct {
  @override
  void mainRun() async {
    var message = await next;
    print("Main: $message");
    send("Hello space!");
    var lastMessage = await last;
    print("Exit: $lastMessage");
  }

  @override
  void isolateRun() async {
    send("Hello earth!");
    var answer = await next;
    print("Isolate: $answer");
    exit("Goodbye from Space!");
  }
}
