// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Promotion _$PromotionFromJson(Map<String, dynamic> json) => Promotion(
  id: (json['id'] as num).toInt(),
  devName: json['devName'] as String,
  gameName: json['gameName'] as String,
  threadId: (json['threadId'] as num).toInt(),
  reason: json['reason'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PromotionToJson(Promotion instance) => <String, dynamic>{
  'id': instance.id,
  'devName': instance.devName,
  'gameName': instance.gameName,
  'threadId': instance.threadId,
  'reason': instance.reason,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

PromotionPaginatedResponse _$PromotionPaginatedResponseFromJson(
  Map<String, dynamic> json,
) => PromotionPaginatedResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => Promotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
  hasMore: json['has_more'] as bool,
);

Map<String, dynamic> _$PromotionPaginatedResponseToJson(
  PromotionPaginatedResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'next_cursor': instance.nextCursor,
  'has_more': instance.hasMore,
};
