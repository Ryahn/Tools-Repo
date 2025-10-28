class DashboardStats {
  final GamesStats games;
  final ReportsStats reports;
  final UploadersStats uploaders;
  final DmcaStats dmca;
  final PromotionsStats promotions;

  DashboardStats({
    required this.games,
    required this.reports,
    required this.uploaders,
    required this.dmca,
    required this.promotions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      games: GamesStats.fromJson(json['games'] as Map<String, dynamic>),
      reports: ReportsStats.fromJson(json['reports'] as Map<String, dynamic>),
      uploaders: UploadersStats.fromJson(
        json['uploaders'] as Map<String, dynamic>,
      ),
      dmca: DmcaStats.fromJson(json['dmca'] as Map<String, dynamic>),
      promotions: PromotionsStats.fromJson(
        json['promotions'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'games': games.toJson(),
      'reports': reports.toJson(),
      'uploaders': uploaders.toJson(),
      'dmca': dmca.toJson(),
      'promotions': promotions.toJson(),
    };
  }
}

class GamesStats {
  final int banned;
  final int pending;
  final int approved;

  GamesStats({
    required this.banned,
    required this.pending,
    required this.approved,
  });

  int get total => banned + pending + approved;

  factory GamesStats.fromJson(Map<String, dynamic> json) {
    return GamesStats(
      banned: json['banned'] as int,
      pending: json['pending'] as int,
      approved: json['approved'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'banned': banned, 'pending': pending, 'approved': approved};
  }
}

class ReportsStats {
  final int total;

  ReportsStats({required this.total});

  factory ReportsStats.fromJson(Map<String, dynamic> json) {
    return ReportsStats(total: json['total'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'total': total};
  }
}

class UploadersStats {
  final int total;
  final int full;
  final int junior;

  UploadersStats({
    required this.total,
    required this.full,
    required this.junior,
  });

  factory UploadersStats.fromJson(Map<String, dynamic> json) {
    return UploadersStats(
      total: json['total'] as int,
      full: json['full'] as int,
      junior: json['junior'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'full': full, 'junior': junior};
  }
}

class DmcaStats {
  final int total;

  DmcaStats({required this.total});

  factory DmcaStats.fromJson(Map<String, dynamic> json) {
    return DmcaStats(total: json['total'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'total': total};
  }
}

class PromotionsStats {
  final int total;

  PromotionsStats({required this.total});

  factory PromotionsStats.fromJson(Map<String, dynamic> json) {
    return PromotionsStats(total: json['total'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'total': total};
  }
}
