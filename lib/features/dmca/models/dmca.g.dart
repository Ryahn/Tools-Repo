// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dmca.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dmca _$DmcaFromJson(Map<String, dynamic> json) => Dmca(
  id: (json['id'] as num).toInt(),
  uniqueId: json['uniqueId'] as String?,
  gameName: json['gameName'] as String,
  gameUrl: json['gameUrl'] as String,
  devName: json['devName'] as String,
  severity: json['severity'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DmcaToJson(Dmca instance) => <String, dynamic>{
  'id': instance.id,
  'uniqueId': instance.uniqueId,
  'gameName': instance.gameName,
  'gameUrl': instance.gameUrl,
  'devName': instance.devName,
  'severity': instance.severity,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

DmcaPaginatedResponse _$DmcaPaginatedResponseFromJson(
  Map<String, dynamic> json,
) => DmcaPaginatedResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => Dmca.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
  hasMore: json['has_more'] as bool,
);

Map<String, dynamic> _$DmcaPaginatedResponseToJson(
  DmcaPaginatedResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'next_cursor': instance.nextCursor,
  'has_more': instance.hasMore,
};
