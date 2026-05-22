class WorkspaceData {
  final List<Quote> quotes;
  final int daysSinceRegistration;
  final RealizedPotential realizedPotential;
  final String? mood;
  final int completedGoals;
  final SurveyInfo? surveyInfo;
  final List<Recommendation> aiRecommendations;
  final List<Achievement> achievements;
  final NewsData news;

  WorkspaceData({
    required this.quotes,
    required this.daysSinceRegistration,
    required this.realizedPotential,
    this.mood,
    required this.completedGoals,
    this.surveyInfo,
    required this.aiRecommendations,
    required this.achievements,
    required this.news,
  });

  factory WorkspaceData.fromJson(Map<String, dynamic> json) {
    return WorkspaceData(
      quotes: (json['quotes'] as List<dynamic>?)
              ?.map((q) => Quote.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      daysSinceRegistration: (json['days_since_registration'] as num?)?.toInt() ?? 0,
      realizedPotential:
          RealizedPotential.fromJson(json['realized_potential'] as Map<String, dynamic>? ?? {}),
      mood: json['mood'] as String?,
      completedGoals: (json['completed_goals'] as num?)?.toInt() ?? 0,
      surveyInfo: json['survey_info'] != null
          ? SurveyInfo.fromJson(json['survey_info'] as Map<String, dynamic>)
          : null,
      aiRecommendations: (json['ai_recommendations'] as List<dynamic>?)
              ?.map((r) => Recommendation.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((a) => Achievement.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      news: NewsData.fromJson(json['news'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class Quote {
  final int id;
  final String text;
  final String? author;
  final bool isActive;

  Quote({
    required this.id,
    required this.text,
    this.author,
    required this.isActive,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: (json['id'] as num?)?.toInt() ?? 0,
      text: json['text'] is Map ? (json['text'] as Map)['String'] as String? ?? '' : json['text'] as String? ?? '',
      author: json['author'] is Map ? (json['author'] as Map)['String'] as String? : json['author'] as String?,
      isActive: json['isactive'] is Map
          ? (json['isactive'] as Map)['Bool'] as bool? ?? false
          : json['isactive'] as bool? ?? false,
    );
  }
}

class RealizedPotential {
  final int today;
  final int yesterday;
  final int month;
  final int week;
  final Dynamics dynamics;

  RealizedPotential({
    required this.today,
    required this.yesterday,
    required this.month,
    required this.week,
    required this.dynamics,
  });

  factory RealizedPotential.fromJson(Map<String, dynamic> json) {
    return RealizedPotential(
      today: (json['today'] as num?)?.toInt() ?? 0,
      yesterday: (json['yesterday'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
      week: (json['week'] as num?)?.toInt() ?? 0,
      dynamics: Dynamics.fromJson(json['dynamics'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class Dynamics {
  final int average;
  final double growth;
  final List<DailyPoint> daily;

  Dynamics({
    required this.average,
    required this.growth,
    required this.daily,
  });

  factory Dynamics.fromJson(Map<String, dynamic> json) {
    return Dynamics(
      average: (json['average'] as num?)?.toInt() ?? 0,
      growth: (json['growth'] as num?)?.toDouble() ?? 0,
      daily: (json['daily'] as List<dynamic>?)
              ?.map((d) => DailyPoint.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DailyPoint {
  final DateTime date;
  final int potential;

  DailyPoint({required this.date, required this.potential});

  factory DailyPoint.fromJson(Map<String, dynamic> json) {
    return DailyPoint(
      date: DateTime.parse(json['date'] as String),
      potential: (json['potential'] as num?)?.toInt() ?? 0,
    );
  }
}

class SurveyInfo {
  final String status;

  SurveyInfo({required this.status});

  factory SurveyInfo.fromJson(Map<String, dynamic> json) {
    return SurveyInfo(status: json['status'] as String? ?? 'not_assigned');
  }
}

class Recommendation {
  final int id;
  final String type;
  final String text;
  final DateTime date;

  Recommendation({
    required this.id,
    required this.type,
    required this.text,
    required this.date,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'еженедельный',
      text: json['text'] as String? ?? '',
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
    );
  }
}

class Achievement {
  final String title;
  final int targetValue;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  Achievement({
    required this.title,
    required this.targetValue,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      title: json['title'] as String? ?? '',
      targetValue: (json['target_value'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse((json['created_at'] as Map)['Time'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse((json['updated_at'] as Map)['Time'] as String)
          : DateTime.now(),
    );
  }
}

class NewsData {
  final List<NewsItem> project;
  final List<NewsItem> research;

  NewsData({required this.project, required this.research});

  factory NewsData.fromJson(Map<String, dynamic> json) {
    return NewsData(
      project: (json['project'] as List<dynamic>?)
              ?.map((n) => NewsItem.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
      research: (json['research'] as List<dynamic>?)
              ?.map((n) => NewsItem.fromJson(n as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class NewsItem {
  final String title;
  final String previewText;
  final DateTime publicationDate;
  final String? tag;

  NewsItem({
    required this.title,
    required this.previewText,
    required this.publicationDate,
    this.tag,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] as String? ?? '',
      previewText: json['preview_text'] as String? ?? '',
      publicationDate: json['publication_date'] != null
          ? DateTime.parse((json['publication_date'] as Map)['Time'] as String)
          : DateTime.now(),
      tag: json['tag'] as String?,
    );
  }
}