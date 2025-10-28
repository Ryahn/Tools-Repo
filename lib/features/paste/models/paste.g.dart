// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paste.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Paste _$PasteFromJson(Map<String, dynamic> json) => Paste(
  slug: json['slug'] as String,
  content: json['content'] as String,
  language: json['language'] as String,
  private: json['private'] as bool,
  userId: (json['userId'] as num?)?.toInt(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PasteToJson(Paste instance) => <String, dynamic>{
  'slug': instance.slug,
  'content': instance.content,
  'language': instance.language,
  'private': instance.private,
  'userId': instance.userId,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
