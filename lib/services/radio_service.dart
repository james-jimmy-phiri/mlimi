import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mlimi/models/radio_models.dart';

class RadioService {
  static final RadioService _instance = RadioService._internal();
  factory RadioService() => _instance;
  RadioService._internal();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  static const String liveStreamUrl = 'https://play.streamafrica.net/mlimi';

  bool _isLive = true;
  bool get isLive => _isLive;

  RadioPlayerStatus _status = RadioPlayerStatus.idle;
  RadioPlayerStatus get status => _status;

  final StreamController<RadioPlayerStatus> _statusController =
      StreamController<RadioPlayerStatus>.broadcast();
  Stream<RadioPlayerStatus> get statusStream => _statusController.stream;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get volumeStream => _player.volumeStream;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.idle) {
          _updateStatus(RadioPlayerStatus.idle);
        } else if (state.processingState == ProcessingState.loading) {
          _updateStatus(RadioPlayerStatus.connecting);
        } else if (state.processingState == ProcessingState.buffering) {
          _updateStatus(RadioPlayerStatus.buffering);
        } else if (state.processingState == ProcessingState.ready) {
          if (state.playing) {
            _updateStatus(RadioPlayerStatus.playing);
          } else {
            _updateStatus(RadioPlayerStatus.paused);
          }
        } else if (state.processingState == ProcessingState.completed) {
          _updateStatus(RadioPlayerStatus.paused);
        }
      });

      _player.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace st) {
          debugPrint('RadioService playback error: $e');
          _updateStatus(RadioPlayerStatus.error);
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('RadioService initialization error: $e');
    }
  }

  void _updateStatus(RadioPlayerStatus newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }

  Future<void> playLive() async {
    try {
      await init();
      _isLive = true;
      _updateStatus(RadioPlayerStatus.connecting);
      await _player.stop();
      await _player.setUrl(liveStreamUrl);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing live stream: $e');
      _updateStatus(RadioPlayerStatus.error);
    }
  }

  Future<void> playRecording(String url, {bool isLocal = false}) async {
    try {
      await init();
      _isLive = false;
      _updateStatus(RadioPlayerStatus.connecting);
      await _player.stop();
      if (isLocal) {
        await _player.setFilePath(url);
      } else {
        await _player.setUrl(url);
      }
      await _player.play();
    } catch (e) {
      debugPrint('Error playing recording: $e');
      _updateStatus(RadioPlayerStatus.error);
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Error resuming playback: $e');
      _updateStatus(RadioPlayerStatus.error);
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Error pausing: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _updateStatus(RadioPlayerStatus.idle);
    } catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);
    } catch (e) {
      debugPrint('Error setting speed: $e');
    }
  }

  void dispose() {
    _statusController.close();
    _player.dispose();
  }
}
