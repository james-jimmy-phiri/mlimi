import 'package:flutter/material.dart';

enum RadioPlayerStatus {
  idle,
  connecting,
  buffering,
  playing,
  paused,
  error,
}

enum ProgrammeStatus {
  completed,
  live,
  upcoming,
}

class RadioProgramme {
  final String id;
  final String title;
  final String subtitle;
  final String presenter;
  final String startTime;
  final String endTime;
  final String duration;
  final String dayOfWeek; // e.g. "Wednesday"
  final String date; // e.g. "2024-10-23"
  final String language; // e.g. "Chichewa" or "English"
  final String category;
  final String project; // e.g. "Trade", "Care", "Trust", "Total Landcare", "Agcom", "Ministry of Agriculture", "General"
  final String topic;
  final String sponsor; // e.g. "Tobacco Commission", "FHL", "Farmers Hope", "--"
  final String format; // e.g. "Live", "Comp", "Live/Comp"
  final Color cardColor;
  final Color accentColor;
  final ProgrammeStatus status;
  final bool hasRecording;
  final bool isTollFree;
  final bool isOfflineAvailable;
  final String? audioUrl;
  final String? artworkUrl;

  const RadioProgramme({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.presenter,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.dayOfWeek,
    required this.date,
    required this.language,
    required this.category,
    this.project = "General",
    required this.topic,
    this.sponsor = "--",
    this.format = "Live",
    required this.cardColor,
    required this.accentColor,
    this.status = ProgrammeStatus.upcoming,
    this.hasRecording = false,
    this.isTollFree = false,
    this.isOfflineAvailable = false,
    this.audioUrl,
    this.artworkUrl,
  });

  bool get isLive => status == ProgrammeStatus.live;

  factory RadioProgramme.fromJson(Map<String, dynamic> json, {String day = "Wednesday", String date = "2024-10-23"}) {
    final formatStr = json['format']?.toString() ?? 'Live';
    final sponsorStr = json['sponsor']?.toString() ?? '--';
    final projectStr = json['project']?.toString() ?? 'General';
    final categoryStr = json['category']?.toString() ?? 'Agriculture';
    final titleStr = json['title']?.toString() ?? 'Mlimi Broadcast';

    Color cardC;
    Color accentC;

    if (projectStr.toLowerCase().contains('trade')) {
      cardC = const Color(0xFF0D9488); // Teal
      accentC = const Color(0xFF99F6E4);
    } else if (projectStr.toLowerCase().contains('care')) {
      cardC = const Color(0xFFE11D48); // Rose
      accentC = const Color(0xFFFECDD3);
    } else if (projectStr.toLowerCase().contains('total landcare')) {
      cardC = const Color(0xFF16A34A); // Green
      accentC = const Color(0xFFBBF7D0);
    } else if (projectStr.toLowerCase().contains('agcom')) {
      cardC = const Color(0xFFD97706); // Amber
      accentC = const Color(0xFFFDE68A);
    } else if (projectStr.toLowerCase().contains('ministry')) {
      cardC = const Color(0xFF4F46E5); // Indigo
      accentC = const Color(0xFFC7D2FE);
    } else {
      cardC = const Color(0xFF059669); // Emerald
      accentC = const Color(0xFFA7F3D0);
    }

    return RadioProgramme(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: titleStr,
      subtitle: sponsorStr != '--' ? "$sponsorStr • $categoryStr" : categoryStr,
      presenter: json['presenter']?.toString() ?? 'Mlimi Team',
      startTime: json['time']?.toString() ?? '06:00',
      endTime: json['endTime']?.toString() ?? '07:00',
      duration: json['duration']?.toString() ?? '1h',
      dayOfWeek: day,
      date: date,
      language: "Chichewa / English",
      category: categoryStr,
      project: projectStr,
      topic: json['topic']?.toString() ?? titleStr,
      sponsor: sponsorStr,
      format: formatStr,
      cardColor: cardC,
      accentColor: accentC,
      status: formatStr.toLowerCase().contains('live') ? ProgrammeStatus.live : ProgrammeStatus.upcoming,
      hasRecording: true,
      isTollFree: formatStr.toLowerCase().contains('live'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'presenter': presenter,
      'time': startTime,
      'endTime': endTime,
      'duration': duration,
      'dayOfWeek': dayOfWeek,
      'date': date,
      'language': language,
      'category': category,
      'project': project,
      'topic': topic,
      'sponsor': sponsor,
      'format': format,
    };
  }

  RadioProgramme copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? presenter,
    String? startTime,
    String? endTime,
    String? duration,
    String? dayOfWeek,
    String? date,
    String? language,
    String? category,
    String? project,
    String? topic,
    String? sponsor,
    String? format,
    Color? cardColor,
    Color? accentColor,
    ProgrammeStatus? status,
    bool? hasRecording,
    bool? isTollFree,
    bool? isOfflineAvailable,
    String? audioUrl,
    String? artworkUrl,
  }) {
    return RadioProgramme(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      presenter: presenter ?? this.presenter,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      date: date ?? this.date,
      language: language ?? this.language,
      category: category ?? this.category,
      project: project ?? this.project,
      topic: topic ?? this.topic,
      sponsor: sponsor ?? this.sponsor,
      format: format ?? this.format,
      cardColor: cardColor ?? this.cardColor,
      accentColor: accentColor ?? this.accentColor,
      status: status ?? this.status,
      hasRecording: hasRecording ?? this.hasRecording,
      isTollFree: isTollFree ?? this.isTollFree,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
      audioUrl: audioUrl ?? this.audioUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
    );
  }
}

class RadioRecording {
  final String id;
  final String programmeId;
  final String title;
  final String presenter;
  final String airDate;
  final String durationText;
  final Duration duration;
  final String audioUrl;
  final String? localPath;
  final String category;
  final String project; // "Trade", "Care", "Trust", "Total Landcare", "Agcom", "Ministry of Agriculture", "My Live Recordings"
  final String description;
  final String? artworkUrl;
  final bool isDownloaded;
  final bool isFavourite;
  final bool isLiveRecording;
  final double downloadProgress;
  final DateTime? recordedAt;

  const RadioRecording({
    required this.id,
    required this.programmeId,
    required this.title,
    required this.presenter,
    required this.airDate,
    required this.durationText,
    required this.duration,
    required this.audioUrl,
    this.localPath,
    required this.category,
    this.project = "General",
    required this.description,
    this.artworkUrl,
    this.isDownloaded = false,
    this.isFavourite = false,
    this.isLiveRecording = false,
    this.downloadProgress = 0.0,
    this.recordedAt,
  });

  factory RadioRecording.fromJson(Map<String, dynamic> json) {
    return RadioRecording(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      programmeId: json['programmeId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      presenter: json['presenter']?.toString() ?? '',
      airDate: json['airDate']?.toString() ?? '',
      durationText: json['durationText']?.toString() ?? '00:00',
      duration: Duration(seconds: json['durationSeconds'] ?? 0),
      audioUrl: json['audioUrl']?.toString() ?? '',
      localPath: json['localPath']?.toString(),
      category: json['category']?.toString() ?? 'Agriculture',
      project: json['project']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      artworkUrl: json['artworkUrl']?.toString(),
      isDownloaded: json['isDownloaded'] ?? false,
      isFavourite: json['isFavourite'] ?? false,
      isLiveRecording: json['isLiveRecording'] ?? false,
      downloadProgress: (json['downloadProgress'] ?? 0.0).toDouble(),
      recordedAt: json['recordedAt'] != null ? DateTime.tryParse(json['recordedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programmeId': programmeId,
      'title': title,
      'presenter': presenter,
      'airDate': airDate,
      'durationText': durationText,
      'durationSeconds': duration.inSeconds,
      'audioUrl': audioUrl,
      'localPath': localPath,
      'category': category,
      'project': project,
      'description': description,
      'artworkUrl': artworkUrl,
      'isDownloaded': isDownloaded,
      'isFavourite': isFavourite,
      'isLiveRecording': isLiveRecording,
      'downloadProgress': downloadProgress,
      'recordedAt': recordedAt?.toIso8601String(),
    };
  }

  RadioRecording copyWith({
    String? id,
    String? programmeId,
    String? title,
    String? presenter,
    String? airDate,
    String? durationText,
    Duration? duration,
    String? audioUrl,
    String? localPath,
    String? category,
    String? project,
    String? description,
    String? artworkUrl,
    bool? isDownloaded,
    bool? isFavourite,
    bool? isLiveRecording,
    double? downloadProgress,
    DateTime? recordedAt,
  }) {
    return RadioRecording(
      id: id ?? this.id,
      programmeId: programmeId ?? this.programmeId,
      title: title ?? this.title,
      presenter: presenter ?? this.presenter,
      airDate: airDate ?? this.airDate,
      durationText: durationText ?? this.durationText,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      category: category ?? this.category,
      project: project ?? this.project,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavourite: isFavourite ?? this.isFavourite,
      isLiveRecording: isLiveRecording ?? this.isLiveRecording,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
