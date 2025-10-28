// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetaResponseImpl _$$MetaResponseImplFromJson(Map<String, dynamic> json) =>
    _$MetaResponseImpl(
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );

Map<String, dynamic> _$$MetaResponseImplToJson(_$MetaResponseImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'total_pages': instance.totalPages,
    };
