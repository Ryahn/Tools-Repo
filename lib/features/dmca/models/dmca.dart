import 'package:json_annotation/json_annotation.dart';

part 'dmca.g.dart';

@JsonSerializable()
class Dmca {
  final int id;
  final String? uniqueId;
  
  @JsonKey(name: 'gameName')
  final String gameName;
  
  @JsonKey(name: 'gameUrl')
  final String gameUrl;
  
  @JsonKey(name: 'devName')
  final String devName;
  
  final String severity;
  
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const Dmca({
    required this.id,
    this.uniqueId,
    required this.gameName,
    required this.gameUrl,
    required this.devName,
    required this.severity,
    this.createdAt,
    this.updatedAt,
  });

  factory Dmca.fromJson(Map<String, dynamic> json) {
    return Dmca(
      id: json['id'] as int,
      uniqueId: _parseString(json['uniqueId']),
      gameName: _parseStringNonNull(json['gameName']),
      gameUrl: _parseStringNonNull(json['gameUrl']),
      devName: _parseStringNonNull(json['devName']),
      severity: _parseStringNonNull(json['severity']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => _$DmcaToJson(this);

  /// Parse a nullable string that might be int or null from backend
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
class DmcaPaginatedResponse {
  final List<Dmca> data;
  
  @JsonKey(name: 'next_cursor')
  final String? nextCursor;
  
  @JsonKey(name: 'has_more')
  final bool hasMore;

  const DmcaPaginatedResponse({
    required this.data,
    this.nextCursor,
    required this.hasMore,
  });

  factory DmcaPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return DmcaPaginatedResponse(
      data: (json['data'] as List)
          .map((item) => Dmca.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: Dmca._parseString(json['next_cursor']),
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$DmcaPaginatedResponseToJson(this);
}

