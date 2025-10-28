import 'package:json_annotation/json_annotation.dart';

part 'promotion.g.dart';

@JsonSerializable()
class Promotion {
  final int id;

  @JsonKey(name: 'devName')
  final String devName;

  @JsonKey(name: 'gameName')
  final String gameName;

  @JsonKey(name: 'threadId')
  final int threadId;

  final String reason;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const Promotion({
    required this.id,
    required this.devName,
    required this.gameName,
    required this.threadId,
    required this.reason,
    this.createdAt,
    this.updatedAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int,
      devName: _parseStringNonNull(json['devName']),
      gameName: _parseStringNonNull(json['gameName']),
      threadId: json['threadId'] as int,
      reason: _parseStringNonNull(json['reason']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => _$PromotionToJson(this);

  /// Parse a nullable string
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return value.toString();
  }

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

@JsonSerializable()
class PromotionPaginatedResponse {
  final List<Promotion> data;

  @JsonKey(name: 'next_cursor')
  final String? nextCursor;

  @JsonKey(name: 'has_more')
  final bool hasMore;

  const PromotionPaginatedResponse({
    required this.data,
    this.nextCursor,
    required this.hasMore,
  });

  factory PromotionPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PromotionPaginatedResponse(
      data: (json['data'] as List)
          .map((item) => Promotion.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: Promotion._parseString(json['next_cursor']),
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$PromotionPaginatedResponseToJson(this);
}
