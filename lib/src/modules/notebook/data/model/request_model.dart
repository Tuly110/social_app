import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_model.freezed.dart';
part 'request_model.g.dart';


@freezed
class RequestModel with _$RequestModel {
  const RequestModel._();

  const factory RequestModel({
    required String code,
  }) = _RequestModel;

  factory RequestModel.fromJson(dynamic json) => _$RequestModelFromJson(json);
}