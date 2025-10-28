import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/socket_type.dart';
part 'response_model.freezed.dart';
part 'response_model.g.dart';


@freezed
class ResponseModel with _$ResponseModel {
  const ResponseModel._();

  const factory ResponseModel({
    required SocketType type,
    required String? data,
  }) = _ResponseModel;

  factory ResponseModel.fromJson(dynamic json) => _$ResponseModelFromJson(json);

  static ResponseModel fromWebSocketJson(Map<String, dynamic> json) {
    if (json.containsKey('output')) {
      return ResponseModel(type: SocketType.response, data: json['output']);
    } else if (json.containsKey('error')) {
      return ResponseModel(type: SocketType.error, data: json['error']);
    } else if (json.containsKey('data')) {
      return ResponseModel(type: SocketType.pause, data: json['data']);
    } else {
      throw FormatException("Unknown WebSocket response format: $json");
    }
  }
}
