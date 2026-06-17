import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/network/api_client.dart';
import '../../data/model/track_model.dart';
import '../../data/repository/player_repository.dart';
import 'music_storage.dart';

class MusicPlayerService extends ChangeNotifier {
  bool _autoNextInProgress = false;

  static final instance =
  MusicPlayerService._();

  MusicPlayerService._() {

    _initAudioSession();

    player.positionStream.listen(
          (position) async {

        final duration =
            player.duration;

        if (duration == null) {
          return;
        }

        if (_autoNextInProgress) {
          return;
        }

        //----------------------------------
        // Jangan auto next kalau pause
        //----------------------------------
        if (!player.playing) {
          return;
        }

        //----------------------------------
        // Trigger 1 detik sebelum selesai
        //----------------------------------
        if (position >=
            duration - const Duration(seconds: 1)) {

          _autoNextInProgress = true;

          debugPrint(
            'AUTO NEXT BY POSITION',
          );

          try {

            if (_loopMode ==
                LoopMode.one) {

              await player.seek(
                Duration.zero,
              );

              await player.play();

              return;
            }

            final nextTrack =
            await skipToNext();

            if (nextTrack == null) {

              debugPrint(
                'END OF PLAYLIST',
              );

              return;
            }

            await playTrack(
              nextTrack,
            );

          } catch (e) {

            debugPrint(
              'AUTO NEXT ERROR = $e',
            );

          } finally {

            _autoNextInProgress = false;
          }
        }
      },
    );
  }

  final AudioPlayer player =
  AudioPlayer();

  final PlayerRepository _playerRepository =
  PlayerRepository(
    ApiClient(),
  );

  TrackModel? _currentTrack;

  List<TrackModel> _playlist = [];

  int _currentIndex = 0;

  bool _shuffleEnabled = false;

  LoopMode _loopMode = LoopMode.off;

  bool get shuffleEnabled => _shuffleEnabled;

  LoopMode get loopMode => _loopMode;

  bool get hasSource =>
      player.audioSource != null;

  //----------------------------------
  // Getters
  //----------------------------------

  TrackModel? get currentTrack =>
      _currentTrack;

  List<TrackModel> get playlist =>
      _playlist;

  int get currentIndex =>
      _currentIndex;

  bool get canSkipNext =>
      _currentIndex <
          _playlist.length - 1;

  bool get canSkipPrevious =>
      _currentIndex > 0;

  //----------------------------------
  // Current Track
  //----------------------------------

  void setCurrentTrack(
      TrackModel track, {
        List<TrackModel>? playlist,
        int? index,
      }) {

    _currentTrack = track;

    MusicStorage.saveTrack(
      track,
    );

    if (playlist != null) {
      _playlist = playlist;
    }

    if (index != null) {
      _currentIndex = index;
    }

    debugPrint(
      'TRACK = ${track.title}',
    );

    debugPrint(
      'INDEX = $_currentIndex',
    );

    debugPrint(
      'PLAYLIST LENGTH = ${_playlist.length}',
    );

    notifyListeners();
  }

  //----------------------------------
// Restore Last Track + AudioSource
//----------------------------------

  Future<void> restorePlayer() async {

    final track =
    await MusicStorage.getTrack();

    if (track == null) {

      debugPrint(
        '❌ No saved track',
      );

      return;
    }

    try {

      debugPrint(
        '🔄 Restoring player...',
      );

      final repository =
      PlayerRepository(
        ApiClient(),
      );

      final playerData =
      await repository.getPlayer(
        track.videoId,
      );

      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(
            playerData.streamUrl,
          ),
        ),
      );

      _currentTrack = track;

      notifyListeners();

      debugPrint(
        '✅ Restored: ${track.title}',
      );

    } catch (e) {

      debugPrint(
        '❌ Restore failed = $e',
      );
    }
  }

  //----------------------------------
  // Restore Last Track
  //----------------------------------

  Future<void> restoreLastTrack() async {
    await restorePlayer();
  }

  Future<void> playRestoredTrack() async {

    try {

      if (player.audioSource == null) {

        await restorePlayer();
      }

      await player.play();

    } catch (e) {

      debugPrint(
        'PLAY RESTORE ERROR = $e',
      );
    }
  }

  //----------------------------------
  // Set Playlist
  //----------------------------------

  void setPlaylist(
      List<TrackModel> playlist, [
        int startIndex = 0,
      ]) {

    _playlist = playlist;

    _currentIndex =
        startIndex;

    notifyListeners();
  }

  //----------------------------------
  // Next
  //----------------------------------

  Future<TrackModel?> skipToNext() async {

    if (_playlist.isEmpty) {
      return null;
    }

    //----------------------------------
    // Repeat One
    //----------------------------------

    // if (_loopMode == LoopMode.one) {
    //
    //   return _currentTrack;
    // }

    //----------------------------------
    // Shuffle
    //----------------------------------

    if (_shuffleEnabled &&
        _playlist.length > 1) {

      int randomIndex = _currentIndex;

      while (randomIndex == _currentIndex) {

        randomIndex =
            DateTime.now()
                .millisecondsSinceEpoch %
                _playlist.length;
      }

      _currentIndex =
          randomIndex;

    } else {

      //----------------------------------
      // Normal Next
      //----------------------------------

      if (_currentIndex >=
          _playlist.length - 1) {

        //----------------------------------
        // Repeat All
        //----------------------------------

        if (_loopMode ==
            LoopMode.all) {

          _currentIndex = 0;

        } else {

          return null;
        }

      } else {

        _currentIndex++;
      }
    }

    _currentTrack =
    _playlist[_currentIndex];

    await MusicStorage.saveTrack(
      _currentTrack!,
    );

    notifyListeners();

    return _currentTrack;
  }

  //----------------------------------
  // Previous
  //----------------------------------

  Future<TrackModel?> skipToPrevious() async {

    if (_playlist.isEmpty) {
      return null;
    }

    //----------------------------------
    // Repeat One
    //----------------------------------

    // if (_loopMode == LoopMode.one) {
    //
    //   return _currentTrack;
    // }

    //----------------------------------
    // Shuffle
    //----------------------------------

    if (_shuffleEnabled &&
        _playlist.length > 1) {

      int randomIndex = _currentIndex;

      while (randomIndex == _currentIndex) {

        randomIndex =
            DateTime.now()
                .microsecondsSinceEpoch %
                _playlist.length;
      }

      _currentIndex =
          randomIndex;

    } else {

      //----------------------------------
      // Normal Previous
      //----------------------------------

      if (_currentIndex <= 0) {

        //----------------------------------
        // Repeat All
        //----------------------------------

        if (_loopMode ==
            LoopMode.all) {

          _currentIndex =
              _playlist.length - 1;

        } else {

          return null;
        }

      } else {

        _currentIndex--;
      }
    }

    _currentTrack =
    _playlist[_currentIndex];

    await MusicStorage.saveTrack(
      _currentTrack!,
    );

    notifyListeners();

    return _currentTrack;
  }

  //----------------------------------
  // Clear
  //----------------------------------

  void clearCurrentTrack() {

    _currentTrack = null;

    _playlist = [];

    _currentIndex = 0;

    MusicStorage.clear();

    notifyListeners();
  }

  //----------------------------------
  // Dispose
  //----------------------------------

  Future<void> disposePlayer() async {

    debugPrint(
      '❌ DISPOSE PLAYER CALLED',
    );

    await player.dispose();
  }

  void toggleShuffle() {

    _shuffleEnabled = !_shuffleEnabled;

    notifyListeners();

    debugPrint(
      'SHUFFLE = $_shuffleEnabled',
    );
  }

  Future<void> toggleLoopMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;

      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;

      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }

    if (_loopMode == LoopMode.one) {

      await player.seek(
        Duration.zero,
      );

      await player.setLoopMode(
        LoopMode.one,
      );

    } else {

      await player.setLoopMode(
        LoopMode.off,
      );
    }

    notifyListeners();
  }

  Future<void> playTrack(
      TrackModel track,
      ) async {

    debugPrint('STEP 1');

    final playerData =
    await _playerRepository.getPlayer(
      track.videoId,
    );

    debugPrint('STEP 2');

    await player.stop();

    debugPrint('STEP 3');

    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(
          playerData.streamUrl,
        ),
      ),
      preload: true,
    );

    debugPrint('STEP 4');

    await player.load();

    debugPrint(
      'TRACK DURATION=${track.duration}',
    );

    debugPrint(
      'PLAYER DURATION=${player.duration}',
    );

    debugPrint('STEP 5');

    _currentTrack = track;

    notifyListeners();

    debugPrint('STEP 6');

    player.play();

    debugPrint('STEP 7');
  }

  Future<void> _initAudioSession() async {

    final session =
    await AudioSession.instance;

    await session.configure(
      const AudioSessionConfiguration.music(),
    );

    await session.setActive(true);

    debugPrint(
      '✅ AudioSession initialized',
    );
  }
}