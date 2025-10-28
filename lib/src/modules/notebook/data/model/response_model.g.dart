// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResponseModelImpl _$$ResponseModelImplFromJson(Map<String, dynamic> json) =>
    _$ResponseModelImpl(
      type: $enumDecode(_$SocketTypeEnumMap, json['type']),
      data: json['data'] as String?,
    );

Map<String, dynamic> _$$ResponseModelImplToJson(_$ResponseModelImpl instance) =>
    <String, dynamic>{
      'type': _$SocketTypeEnumMap[instance.type]!,
      'data': instance.data,
    };

const _$SocketTypeEnumMap = {
  SocketType.response: 'response',
  SocketType.error: 'error',
  SocketType.pause: 'pause',
};
