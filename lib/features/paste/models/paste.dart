import 'package:json_annotation/json_annotation.dart';

part 'paste.g.dart';

@JsonSerializable()
class Paste {
  final String slug;
  final String content;
  final String language;
  final bool private;

  @JsonKey(name: 'userId')
  final int? userId;

  @JsonKey(name: 'expiresAt')
  final DateTime? expiresAt;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const Paste({
    required this.slug,
    required this.content,
    required this.language,
    required this.private,
    this.userId,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Paste.fromJson(Map<String, dynamic> json) {
    return Paste(
      slug: _parseStringNonNull(json['slug']),
      content: _parseStringNonNull(json['content']),
      language: _parseStringNonNull(json['language']),
      private: json['private'] as bool? ?? false,
      userId: json['userId'] as int?,
      expiresAt: _parseDateTime(json['expiresAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => _$PasteToJson(this);

  /// Parse a non-nullable string that might be int from backend
  static String _parseStringNonNull(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

  /// Parse a DateTime that might be int timestamp or String ISO 8601
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    return null;
  }
}
