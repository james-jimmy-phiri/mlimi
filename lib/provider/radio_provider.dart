import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/models/radio_models.dart';
import 'package:mlimi/services/radio_service.dart';
import 'package:path_provider/path_provider.dart';

class RadioProvider extends ChangeNotifier {
  final RadioService _service = RadioService();
  final GetStorage _storage = GetStorage();

  RadioPlayerStatus _status = RadioPlayerStatus.idle;
  RadioPlayerStatus get status => _status;

  bool _isLive = true;
  bool get isLive => _isLive;

  double _volume = 0.75;
  double get volume => _volume;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  bool _isMiniPlayerVisible = false;
  bool get isMiniPlayerVisible => _isMiniPlayerVisible;

  bool _isDataSaverEnabled = false;
  bool get isDataSaverEnabled => _isDataSaverEnabled;

  String _audioQuality = 'standard';
  String get audioQuality => _audioQuality;

  // Contact details provided by user
  final String _hotlineNumber = '+265 983 87 44 33';
  String get hotlineNumber => _hotlineNumber;

  final String _tollFreeHotline = '321';
  String get tollFreeHotline => _tollFreeHotline;

  final String _whatsappNumber = '+265 987 96 93 11';
  String get whatsappNumber => _whatsappNumber;

  final String _facebookPageUrl = 'https://www.facebook.com/MlimiRadio/';
  String get facebookPageUrl => _facebookPageUrl;

  // Live recording states
  bool _isRecording = false;
  bool get isRecording => _isRecording;

  Duration _recordingDuration = Duration.zero;
  Duration get recordingDuration => _recordingDuration;

  Timer? _recordTimer;

  // Real stream capture internals
  http.Client? _httpClient;
  StreamSubscription<List<int>>? _streamSub;
  IOSink? _fileSink;
  String? _tempFilePath;

  // Selected schedule day: 0 = Mon, 1 = Tue, 2 = Wed, 3 = Thu, 4 = Fri, 5 = Sat, 6 = Sun
  int _selectedDayIndex = 2; // Default to Wednesday
  int get selectedDayIndex => _selectedDayIndex;

  RadioProgramme? _currentProgramme;
  RadioProgramme? get currentProgramme => _currentProgramme;

  RadioRecording? _currentRecording;
  RadioRecording? get currentRecording => _currentRecording;

  Set<String> _favouriteProgrammeIds = {};
  Set<String> get favouriteProgrammeIds => _favouriteProgrammeIds;

  Set<String> _favouriteRecordingIds = {};
  Set<String> get favouriteRecordingIds => _favouriteRecordingIds;

  Map<String, List<RadioProgramme>> _weeklySchedule = {};
  Map<String, List<RadioProgramme>> get weeklySchedule => _weeklySchedule;

  List<RadioProgramme> _allProgrammes = [];
  List<RadioProgramme> get allProgrammes => _allProgrammes;

  List<RadioRecording> _allRecordings = [];
  List<RadioRecording> get allRecordings => _allRecordings;

  StreamSubscription? _statusSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  RadioProvider() {
    _init();
  }

  void _init() {
    _loadPreferences();
    _loadScheduleFromJson();
    _loadRecordings();

    _statusSub = _service.statusStream.listen((newStatus) {
      _status = newStatus;
      if (newStatus == RadioPlayerStatus.playing ||
          newStatus == RadioPlayerStatus.buffering ||
          newStatus == RadioPlayerStatus.connecting ||
          newStatus == RadioPlayerStatus.paused) {
        _isMiniPlayerVisible = true;
      }
      notifyListeners();
    });

    _posSub = _service.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durSub = _service.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });

    _service.setVolume(_volume);
  }

  void _loadPreferences() {
    _isDataSaverEnabled = _storage.read('radio_data_saver') ?? false;
    _audioQuality = _storage.read('radio_audio_quality') ?? 'standard';
    final favProgs = _storage.read<List>('radio_fav_programmes');
    if (favProgs != null) {
      _favouriteProgrammeIds = favProgs.cast<String>().toSet();
    }
    final favRecs = _storage.read<List>('radio_fav_recordings');
    if (favRecs != null) {
      _favouriteRecordingIds = favRecs.cast<String>().toSet();
    }
  }

  Future<void> _loadScheduleFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/mlimi_radio_schedule.json');
      final data = json.decode(jsonString);
      final scheduleData = data['schedule'] as Map<String, dynamic>;

      final dayKeys = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      _weeklySchedule = {};

      for (var day in dayKeys) {
        if (scheduleData.containsKey(day)) {
          final list = (scheduleData[day] as List)
              .map((item) => RadioProgramme.fromJson(item, day: day))
              .toList();
          _weeklySchedule[day] = list;
        }
      }

      final currentDayKey = dayKeys[_selectedDayIndex];
      _allProgrammes = _weeklySchedule[currentDayKey] ?? [];

      if (_allProgrammes.isNotEmpty) {
        _currentProgramme = _allProgrammes.firstWhere(
          (p) => p.format.toLowerCase().contains('live'),
          orElse: () => _allProgrammes.first,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading radio schedule JSON: $e");
    }
  }

  List<RadioProgramme> get allWeeklyProgrammes {
    final all = <RadioProgramme>[];
    for (var list in _weeklySchedule.values) {
      all.addAll(list);
    }
    return all;
  }

  void _loadRecordings() {
    // Project-categorized agricultural recordings
    final List<RadioRecording> defaultRecordings = [
      RadioRecording(
        id: 'rec_trade_1',
        programmeId: 'prog_trade_1',
        title: "Tipindule ndi Mtedza: Groundnut Grading & Auction Market Prices",
        presenter: "TRADE Project Officer & Alinafe Phiri",
        airDate: "Today • 15:30 CAT",
        durationText: "42 mins",
        duration: const Duration(minutes: 42),
        audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        category: "Groundnuts",
        project: "Trade",
        description: "TRADE Programme analysis on groundnut value additions, sheller operations, and export market access in Malawi.",
        isFavourite: true,
      ),
      RadioRecording(
        id: 'rec_care_1',
        programmeId: 'prog_care_1',
        title: "Amayi Ticheze & Nutrition: Village Savings & Biofortified Crops",
        presenter: "Care Extension Team",
        airDate: "Yesterday • 10:10 CAT",
        durationText: "35 mins",
        duration: const Duration(minutes: 35),
        audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        category: "Nutrition & Women",
        project: "Care",
        description: "CARE project practical guide on women leadership in agricultural cooperatives, kitchen gardens, and Orange-Fleshed Sweet Potato production.",
        isDownloaded: true,
        downloadProgress: 1.0,
      ),
      RadioRecording(
        id: 'rec_trust_1',
        programmeId: 'prog_trust_1',
        title: "Farm Radio Trust: Digital Call Center Q&A on Fall Armyworm",
        presenter: "Dr. Nyirenda & Kondwani Banda",
        airDate: "Oct 21 • 08:00 CAT",
        durationText: "48 mins",
        duration: const Duration(minutes: 48),
        audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
        category: "Agronomy Advisory",
        project: "Trust",
        description: "Farm Radio Trust direct expert responses to questions submitted by farmers via hotline 321 and digital messaging platforms.",
        isFavourite: true,
      ),
      RadioRecording(
        id: 'rec_landcare_1',
        programmeId: 'prog_landcare_1',
        title: "Tipindule ndi Ulimi wa Ziphukira: Farmer Managed Natural Regeneration",
        presenter: "Total Landcare Specialist",
        airDate: "Oct 19 • 14:30 CAT",
        durationText: "28 mins",
        duration: const Duration(minutes: 28),
        audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
        category: "Conservation",
        project: "Total Landcare",
        description: "Techniques for restoring soil fertility and moisture retention through tree stump regeneration across central Malawi farms.",
      ),
      RadioRecording(
        id: 'rec_agcom_1',
        programmeId: 'prog_agcom_1',
        title: "Dziwani za AGCOM: Matching Grants for Producer Organizations",
        presenter: "AGCOM Agribusiness Officer",
        airDate: "Oct 18 • 14:30 CAT",
        durationText: "31 mins",
        duration: const Duration(minutes: 31),
        audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
        category: "Commercialisation",
        project: "Agcom",
        description: "Step-by-step application guidance for agricultural cooperatives to access AGCOM capital equipment and warehouse financing.",
      ),
      RadioRecording(
        id: 'rec_moa_1',
        programmeId: 'prog_moa_1',
        title: "Ministry of Agriculture: Rainfall Onset Forecast & Seed Selection",
        presenter: "Agric Communication Branch",
        airDate: "Oct 17 • 13:30 CAT",
        durationText: "38 mins",
        duration: const Duration(minutes: 38),
        audioUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3",
        category: "Extension Services",
        project: "Ministry of Agriculture",
        description: "Official National agricultural advisory from the Ministry of Agriculture on certified hybrid selection and basal dressing timelines.",
      ),
    ];

    final savedRecs = _storage.read<List>('radio_custom_recordings');
    List<RadioRecording> customList = [];
    if (savedRecs != null) {
      customList = savedRecs.map((e) => RadioRecording.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    // Initialize default favourites if not previously set
    if (_storage.read('radio_fav_recordings') == null) {
      for (var r in defaultRecordings) {
        if (r.isFavourite) {
          _favouriteRecordingIds.add(r.id);
        }
      }
      _storage.write('radio_fav_recordings', _favouriteRecordingIds.toList());
    }

    _allRecordings = [...customList, ...defaultRecordings].map((r) {
      return r.copyWith(isFavourite: _favouriteRecordingIds.contains(r.id));
    }).toList();
  }

  // ── Real Live Stream Recording Engine ─────────────────────────────────────
  // Records the Icecast HTTP stream bytes to a file on device storage.
  // Runs fully in parallel with the just_audio player — never interrupts it.

  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      // Prepare a temp file in the app documents directory
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _tempFilePath = '${dir.path}/mlimi_rec_$timestamp.tmp';
      final file = File(_tempFilePath!);
      _fileSink = file.openWrite();

      // Open a streaming HTTP GET to the live broadcast URL
      _httpClient = http.Client();
      final request = http.Request('GET', Uri.parse(RadioService.liveStreamUrl));
      request.headers['Icy-MetaData'] = '1';
      final response = await _httpClient!.send(request);

      if (response.statusCode != 200) {
        _httpClient?.close();
        _fileSink?.close();
        _tempFilePath = null;
        debugPrint('Stream recording: bad status ${response.statusCode}');
        return;
      }

      // Pipe stream bytes into the file
      _streamSub = response.stream.listen(
        (chunk) => _fileSink?.add(chunk),
        onError: (e) => debugPrint('Stream recording error: $e'),
        cancelOnError: false,
      );

      // Start duration timer
      _isRecording = true;
      _recordingDuration = Duration.zero;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });
      notifyListeners();
    } catch (e) {
      debugPrint('startRecording error: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  /// Stop recording. [title] is the user-chosen name. [project] is the category.
  /// Returns the saved [RadioRecording] with a real localPath playable as a file.
  Future<RadioRecording?> stopRecording({
    required String title,
    String project = "My Live Recordings",
  }) async {
    if (!_isRecording) return null;

    // Stop ingesting bytes
    _recordTimer?.cancel();
    await _streamSub?.cancel();
    _streamSub = null;
    await _fileSink?.flush();
    await _fileSink?.close();
    _fileSink = null;
    _httpClient?.close();
    _httpClient = null;

    _isRecording = false;

    final durationSeconds = _recordingDuration.inSeconds;
    final mins = (_recordingDuration.inSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_recordingDuration.inSeconds % 60).toString().padLeft(2, '0');
    final durationText = "$mins:$secs";

    // Move the temp file to a permanent named file
    String? savedPath;
    try {
      if (_tempFilePath != null) {
        final dir = await getApplicationDocumentsDirectory();
        // Sanitise title for filename
        final safeName = title
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(RegExp(r'\s+'), '_')
            .toLowerCase();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        savedPath = '${dir.path}/mlimi_${safeName}_$timestamp.mp3';
        await File(_tempFilePath!).rename(savedPath);
        _tempFilePath = null;
      }
    } catch (e) {
      debugPrint('Error renaming recording file: $e');
      savedPath = _tempFilePath; // fall back to temp path
      _tempFilePath = null;
    }

    // Build the recording entry — localPath is the real file on device
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} • ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} CAT';

    final newRecording = RadioRecording(
      id: 'rec_live_${now.millisecondsSinceEpoch}',
      programmeId: _currentProgramme?.id ?? 'live_stream',
      title: title,
      presenter: _currentProgramme?.presenter ?? 'Mlimi Live 98.4 FM',
      airDate: dateStr,
      durationText: durationText,
      duration: Duration(seconds: durationSeconds),
      audioUrl: savedPath ?? '',
      localPath: savedPath,
      category: _currentProgramme?.category ?? 'Live Broadcast',
      project: project,
      description:
          'Live recording captured from Mlimi Radio 98.4 / 98.6 FM on $dateStr.',
      isDownloaded: true,
      isLiveRecording: true,
      downloadProgress: 1.0,
      recordedAt: now,
    );

    _allRecordings.insert(0, newRecording);
    _saveCustomRecordings();
    _recordingDuration = Duration.zero;
    notifyListeners();
    return newRecording;
  }

  // Pick audio file from local storage to play in Player tab
  Future<void> pickAndPlayLocalAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          final cleanName = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
          final localRec = RadioRecording(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            programmeId: 'local_file',
            title: cleanName,
            presenter: "Device Storage Audio",
            airDate: "Imported Today",
            durationText: "Local File",
            duration: const Duration(minutes: 4),
            audioUrl: file.path!,
            localPath: file.path,
            category: "Local Music",
            project: "My Live Recordings",
            description: "Local audio file imported from device storage: ${file.name}",
            isDownloaded: true,
            isLiveRecording: true,
            downloadProgress: 1.0,
            recordedAt: DateTime.now(),
          );

          _allRecordings.insert(0, localRec);
          _saveCustomRecordings();
          await playRecording(localRec);
        }
      }
    } catch (e) {
      debugPrint("Error picking audio from local files: $e");
    }
  }

  void _saveCustomRecordings() {
    final customOnly = _allRecordings.where((r) => r.isLiveRecording).map((r) => r.toJson()).toList();
    _storage.write('radio_custom_recordings', customOnly);
  }

  void deleteRecording(String id) {
    _allRecordings.removeWhere((r) => r.id == id);
    _saveCustomRecordings();
    notifyListeners();
  }

  // Play Live Stream (Guaranteed to switch to live stream, stopping any recording playback)
  Future<void> playLive() async {
    _isLive = true;
    _currentRecording = null;
    notifyListeners();
    await _service.playLive();
  }

  // Toggle Live Radio strictly (Pauses if live is currently playing, otherwise starts Live Radio)
  Future<void> togglePlayLive() async {
    if (_isLive && _status == RadioPlayerStatus.playing) {
      await _service.pause();
    } else {
      await playLive();
    }
  }

  // Play Recorded Episode or Local Audio File
  Future<void> playRecording(RadioRecording recording) async {
    _isLive = false;
    _currentRecording = recording;
    notifyListeners();
    final isLocal = recording.localPath != null && recording.localPath!.isNotEmpty;
    await _service.playRecording(recording.localPath ?? recording.audioUrl, isLocal: isLocal);
  }

  // Toggle Play / Pause for currently active item
  Future<void> togglePlayPause() async {
    if (_status == RadioPlayerStatus.playing) {
      await _service.pause();
    } else if (_status == RadioPlayerStatus.paused) {
      await _service.play();
    } else {
      if (_isLive) {
        await playLive();
      } else if (_currentRecording != null) {
        await playRecording(_currentRecording!);
      } else {
        await playLive();
      }
    }
  }

  Future<void> pause() async {
    await _service.pause();
  }

  Future<void> stop() async {
    await _service.stop();
  }

  Future<void> seek(Duration position) async {
    _position = position;
    notifyListeners();
    await _service.seek(position);
  }

  Future<void> seekRelative(int seconds) async {
    final target = _position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _duration ? _duration : target);
    await seek(clamped);
  }

  Future<void> setVolume(double val) async {
    _volume = val.clamp(0.0, 1.0);
    notifyListeners();
    await _service.setVolume(_volume);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    notifyListeners();
    await _service.setSpeed(speed);
  }

  void selectDay(int index) {
    _selectedDayIndex = index;
    final dayKeys = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final selectedKey = dayKeys[index];
    _allProgrammes = _weeklySchedule[selectedKey] ?? [];
    notifyListeners();
  }

  void dismissMiniPlayer() {
    _isMiniPlayerVisible = false;
    notifyListeners();
  }

  void showMiniPlayer() {
    _isMiniPlayerVisible = true;
    notifyListeners();
  }

  void toggleFavouriteProgramme(String id) {
    if (_favouriteProgrammeIds.contains(id)) {
      _favouriteProgrammeIds.remove(id);
    } else {
      _favouriteProgrammeIds.add(id);
    }
    _storage.write('radio_fav_programmes', _favouriteProgrammeIds.toList());
    notifyListeners();
  }

  bool isProgrammeFavourite(String id) => _favouriteProgrammeIds.contains(id);

  void toggleFavouriteRecording(String id) {
    if (_favouriteRecordingIds.contains(id)) {
      _favouriteRecordingIds.remove(id);
    } else {
      _favouriteRecordingIds.add(id);
    }
    _storage.write('radio_fav_recordings', _favouriteRecordingIds.toList());

    final isFav = _favouriteRecordingIds.contains(id);
    final index = _allRecordings.indexWhere((r) => r.id == id);
    if (index != -1) {
      _allRecordings[index] = _allRecordings[index].copyWith(
        isFavourite: isFav,
      );
    }
    if (_currentRecording != null && _currentRecording!.id == id) {
      _currentRecording = _currentRecording!.copyWith(
        isFavourite: isFav,
      );
    }
    _saveCustomRecordings();
    notifyListeners();
  }

  bool isRecordingFavourite(String id) => _favouriteRecordingIds.contains(id);

  Future<void> downloadRecording(String id) async {
    final index = _allRecordings.indexWhere((r) => r.id == id);
    if (index == -1) return;

    for (double p = 0.2; p <= 1.0; p += 0.2) {
      await Future.delayed(const Duration(milliseconds: 300));
      _allRecordings[index] = _allRecordings[index].copyWith(
        downloadProgress: p,
        isDownloaded: p >= 1.0,
      );
      notifyListeners();
    }
  }

  void setDataSaver(bool enabled) {
    _isDataSaverEnabled = enabled;
    _storage.write('radio_data_saver', enabled);
    notifyListeners();
  }

  void setAudioQuality(String quality) {
    _audioQuality = quality;
    _storage.write('radio_audio_quality', quality);
    notifyListeners();
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _streamSub?.cancel();
    _fileSink?.close();
    _httpClient?.close();
    _statusSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _service.dispose();
    super.dispose();
  }
}
