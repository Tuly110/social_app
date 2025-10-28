import 'package:injectable/injectable.dart';

@module
abstract class WebSocketModule {
  @Named('webSocketUrl')
  String get webSocketUrl => "ws://66.45.239.69:5992";
}
