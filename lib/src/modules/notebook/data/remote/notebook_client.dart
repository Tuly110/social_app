import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';

import '../model/response_model.dart';

@injectable
class Client {
  final WebSocketChannel _channel;

  Client(@Named('webSocketUrl') String url)
      : _channel = WebSocketChannel.connect(Uri.parse(url)) {
    print("🔵 WebSocket connecting to $url");


    _channel.stream.listen(
      (event) {
        print("🟢 Received: $event");
      },
      onError: (error) {
        print("🔴 WebSocket Error: $error");
      },
      onDone: () {
        print("🟡 WebSocket connection closed.");
      },
    );
  }
  void connect(){
  }

  Stream<ResponseModel> response() {
    return _channel.stream.map((event) {
      print("📥 Received raw: $event");
      final json = jsonDecode(event);
      print("📥 Parsed JSON: $json");
      return ResponseModel.fromWebSocketJson(json);
    });
  }

  void request(String code) {
    final request = jsonEncode({"code": code});
    print("📤 Sending request: $request");
    _channel.sink.add(request);
  }

  void dispose() {
    _channel.sink.close(status.goingAway);
  }
}
