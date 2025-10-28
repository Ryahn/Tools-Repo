/// Game model representing a game entry in the system
class Game {
  final int id;
  final String gameName;
  final String author;
  final String? gameNameJap;
  final String? gameNameRomaji;
  final String reason;
  final String ruling;
  final String approved;
  final bool isAuthorBanned;
  final String? steamLink;
  final String? dlsiteLink;
  final String? dlsiteCode;
  final String? itchLink;
  final String? patreonLink;
  final String? subscribestarLink;
  final String? jastLink;
  final String? exhentaiLink;
  final String? egahentaiLink;
  final String? nhentaiLink;
  final String? mangagamerLink;
  final String? othersLink;
  final String? vndbLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Game({
    required this.id,
    required this.gameName,
    required this.author,
    this.gameNameJap,
    this.gameNameRomaji,
    required this.reason,
    required this.ruling,
    required this.approved,
    required this.isAuthorBanned,
    this.steamLink,
    this.dlsiteLink,
    this.dlsiteCode,
    this.itchLink,
    this.patreonLink,
    this.subscribestarLink,
    this.jastLink,
    this.exhentaiLink,
    this.egahentaiLink,
    this.nhentaiLink,
    this.mangagamerLink,
    this.othersLink,
    this.vndbLink,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Game instance from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as int,
      gameName: json['game_name'] as String,
      author: json['author'] as String,
      gameNameJap: _parseString(json['game_name_jap']),
      gameNameRomaji: _parseString(json['game_name_romaji']),
      reason: _parseStringNonNull(json['reason']),
      ruling: _parseStringNonNull(json['ruling']),
      approved: _parseStringNonNull(json['approved']),
      isAuthorBanned: json['is_author_banned'] as bool,
      steamLink: _parseString(json['steam_link']),
      dlsiteLink: _parseString(json['dlsite_link']),
      dlsiteCode: _parseString(json['dlsite_code']),
      itchLink: _parseString(json['itch_link']),
      patreonLink: _parseString(json['patreon_link']),
      subscribestarLink: _parseString(json['subscribestar_link']),
      jastLink: _parseString(json['jast_link']),
      exhentaiLink: _parseString(json['exhentai_link']),
      egahentaiLink: _parseString(json['egahentai_link']),
      nhentaiLink: _parseString(json['nhentai_link']),
      mangagamerLink: _parseString(json['mangagamer_link']),
      othersLink: _parseString(json['others_link']),
      vndbLink: _parseString(json['vndb_link']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  /// Helper to safely parse nullable strings from JSON
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Helper to safely parse non-nullable strings from JSON
  static String _parseStringNonNull(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Helper to safely parse DateTime from JSON
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return null;
  }

  /// Convert a Game instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_name': gameName,
      'author': author,
      'game_name_jap': gameNameJap,
      'game_name_romaji': gameNameRomaji,
      'reason': reason,
      'ruling': ruling,
      'approved': approved,
      'is_author_banned': isAuthorBanned,
      'steam_link': steamLink,
      'dlsite_link': dlsiteLink,
      'dlsite_code': dlsiteCode,
      'itch_link': itchLink,
      'patreon_link': patreonLink,
      'subscribestar_link': subscribestarLink,
      'jast_link': jastLink,
      'exhentai_link': exhentaiLink,
      'egahentai_link': egahentaiLink,
      'nhentai_link': nhentaiLink,
      'mangagamer_link': mangagamerLink,
      'others_link': othersLink,
      'vndb_link': vndbLink,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if the game is approved
  bool get isApproved => approved == 'approved';

  /// Check if the game is banned
  bool get isBanned => approved == 'banned';

  /// Check if the game is pending
  bool get isPending => approved == 'pending';

  /// Get the status color for UI
  String get statusColor {
    switch (approved) {
      case 'approved':
        return 'success';
      case 'banned':
        return 'danger';
      case 'pending':
        return 'warning';
      default:
        return 'secondary';
    }
  }
}

/// Model for paginated games list response
class GamesPaginatedResponse {
  final List<Game> games;
  final String? nextCursor;
  final bool hasMore;

  GamesPaginatedResponse({
    required this.games,
    this.nextCursor,
    required this.hasMore,
  });

  factory GamesPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return GamesPaginatedResponse(
      games: (json['data'] as List<dynamic>)
          .map((item) => Game.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor']?.toString(),
      hasMore: json['has_more'] as bool,
    );
  }
}
