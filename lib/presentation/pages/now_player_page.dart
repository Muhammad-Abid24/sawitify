import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/model/track_model.dart';
import '../../data/repository/player_repository.dart';
import '../states/music_player_service.dart';
import '../widgets/glass_player.dart';
import '../widgets/youtube_thumbnail.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.artist,
    required this.duration,
    required this.videoId,
    required this.fromMiniPlayer,
  });

  final String imageUrl;
  final String title;
  final String artist;
  final String duration;
  final String videoId;
  final bool fromMiniPlayer;

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}


class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _rotationController;
  late final PlayerRepository playerRepository;

  VoidCallback? _musicListener;

  double _dragOffset = 0;

  bool isLoading = true;

  // Track data yang bisa berubah saat prev/next
  String _currentImageUrl = '';
  String _currentTitle = '';
  String _currentArtist = '';
  String _currentDuration = '';
  String _currentVideoId = '';

  bool _forceNextTriggered = false;


  // Helper untuk parse duration string (misal "3:45") ke Duration
  Duration _parseDuration(
      String duration,
      ) {
    final parts =
    duration.replaceAll('.', ':')
        .split(':');

    if (parts.length == 2) {
      return Duration(
        minutes: int.parse(parts[0]),
        seconds: int.parse(parts[1]),
      );
    }

    if (parts.length == 3) {
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
    }

    return Duration.zero;
  }

  // Helper untuk format Duration ke string (misal 3:45)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    playerRepository = PlayerRepository(
      ApiClient(),
    );

    _currentImageUrl = widget.imageUrl;
    _currentTitle = widget.title;
    _currentArtist = widget.artist;
    _currentDuration = widget.duration;
    _currentVideoId = widget.videoId;

    //----------------------------------
    // Listen track change
    //----------------------------------
    _musicListener = () {

      final track =
          MusicPlayerService
              .instance
              .currentTrack;

      if (track == null) {
        return;
      }

      if (track.videoId ==
          _currentVideoId) {
        return;
      }

      debugPrint(
        '🔄 TRACK CHANGED = ${track.title}',
      );

      if (!mounted) {
        return;
      }

      setState(() {

        _currentTitle =
            track.title;

        _currentArtist =
            track.artist;

        _currentImageUrl =
            track.thumbnail;

        _currentDuration =
            track.duration;

        _currentVideoId =
            track.videoId;
      });
    };

    MusicPlayerService
        .instance
        .addListener(
      _musicListener!,
    );

    if (!widget.fromMiniPlayer) {
      _loadAndPlay();
    } else {
      isLoading = false;
    }
  }

  void _updateTrackData(
      TrackModel track,
      ) {

    if (!mounted) {
      return;
    }

    setState(() {

      _currentTitle =
          track.title;

      _currentArtist =
          track.artist;

      _currentImageUrl =
          track.thumbnail;

      _currentDuration =
          track.duration;

      _currentVideoId =
          track.videoId;
    });

    debugPrint(
      '✅ UI updated with: ${track.title}',
    );
  }

  Future<void> _loadAndPlay() async {
    try {

      final playerData =
      await playerRepository.getPlayer(
        _currentVideoId,
      );

      final player =
          MusicPlayerService.instance.player;

      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(
            playerData.streamUrl,
          ),
        ),
      );

      await player.load();

      debugPrint(
        'REAL DURATION = ${player.duration}',
      );

      MusicPlayerService.instance.setCurrentTrack(
        TrackModel(
          title: _currentTitle,
          artist: _currentArtist,
          videoId: _currentVideoId,
          thumbnail: _currentImageUrl,
          duration: _currentDuration,
        ),
        playlist: MusicPlayerService.instance.playlist.isNotEmpty
            ? MusicPlayerService.instance.playlist
            : null,
      );

      // Set loading to false immediately after audio source is set
      // The player will start playing and UI will show current position
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      await player.play();

    } catch (e) {

      debugPrint(
        'PLAYER ERROR = $e',
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Show user-friendly error message
        String errorMessage = 'Gagal memutar lagu';
        if (e.toString().contains('age-restricted')) {
          errorMessage = 'Lagu ini dibatasi oleh usia. Silakan pilih lagu lain.';
        } else if (e.toString().contains('region-locked')) {
          errorMessage = 'Lagu ini tidak tersedia di wilayah Anda.';
        } else if (e.toString().contains('playable')) {
          errorMessage = 'Lagu ini tidak dapat diputar.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade400,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _seek(Duration position) {
    MusicPlayerService.instance.player.seek(position);
  }

  @override
  void dispose() {

    debugPrint(
      '❌ NOW PLAYING DISPOSE',
    );

    if (_musicListener != null) {

      MusicPlayerService
          .instance
          .removeListener(
        _musicListener!,
      );
    }

    _rotationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MusicPlayerService.instance,
      builder: (context, _) {

        if (isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final size = MediaQuery.of(context).size;

        final screenHeight = size.height;
        final screenWidth = size.width;

        final albumSize = screenHeight * 0.26;

        final bottomBarHeight = screenHeight * 0.06;


        return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Opacity(
                opacity: (1 - (_dragOffset / 400))
                    .clamp(0.5, 1.0),

                child: Stack(
                  children: [
                    //----------------------------------
                    // Background Album
                    //----------------------------------
                    Positioned.fill(
                      child: YoutubeThumbnail(
                        videoId: _currentVideoId,
                        fit: BoxFit.cover,
                      ),
                    ),

                    //----------------------------------
                    // Heavy Blur
                    //----------------------------------
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 1.5,
                          sigmaY: 1.5,
                        ),
                        child: Container(
                          color: Colors.black.withValues(alpha: .15),
                        ),
                      ),
                    ),

                    //----------------------------------
                    // Gradient Overlay
                    //----------------------------------
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: .15),
                              Colors.black.withValues(alpha: .30),
                              Colors.black.withValues(alpha: .45),
                            ],
                          ),
                        ),
                      ),
                    ),

                    //----------------------------------
                    // Content
                    //----------------------------------


                    SafeArea(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,

                          onVerticalDragUpdate: (details) {

                            if (details.delta.dy > 0) {

                              setState(() {
                                _dragOffset =
                                    (_dragOffset + details.delta.dy)
                                        .clamp(0.0, 150.0);
                              });
                            }
                          },

                          onVerticalDragEnd: (details) {

                            if (_dragOffset > 120) {

                              Navigator.pop(context);

                            } else {

                              setState(() {
                                _dragOffset = 0;
                              });
                            }
                          },

                          child: ClipRect(
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 150,
                              ),

                              transform: Matrix4.translationValues(
                                0,
                                _dragOffset,
                                0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: _dragOffset > 20 ? 30 : 50,
                                      height: _dragOffset > 20 ? 30 : 5,
                                      decoration: _dragOffset > 20
                                          ? null
                                          : BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: _dragOffset > 20
                                          ? Icon(
                                        Icons.keyboard_arrow_down,
                                        color: AppColors.primary,
                                        size: 30,
                                      )
                                          : null,
                                    ),

                                    const SizedBox(height: 20),

                                    //----------------------------------
                                    // Album Art
                                    //----------------------------------
                                    SizedBox(
                                      width: albumSize,
                                      height: albumSize,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [

                                          //----------------------------------
                                          // VINYL
                                          //----------------------------------
                                          RotationTransition(
                                            turns: _rotationController,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [

                                                Container(
                                                  width: albumSize,
                                                  height: albumSize,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.background1,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.background1.withValues(alpha: .35),
                                                        blurRadius: 25,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                //----------------------------------
                                                // GROOVES
                                                //----------------------------------
                                                ...List.generate(
                                                  5,
                                                      (index) => Container(
                                                    width: albumSize * (0.88 - (index * 0.13)),
                                                    height: albumSize * (0.88 - (index * 0.13)),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: AppColors.primary.withValues(alpha: .18),
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                //----------------------------------
                                                // ALBUM LABEL
                                                //----------------------------------
                                                Container(
                                                  width: albumSize * 0.55,
                                                  height: albumSize * 0.55,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: AppColors.background1,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: YoutubeThumbnail(
                                                      videoId: _currentVideoId,
                                                      fit: BoxFit.cover,
                                                      isCircular: true,
                                                    ),
                                                  ),
                                                ),

                                                //----------------------------------
                                                // CENTER HOLE
                                                //----------------------------------
                                                Container(
                                                  width: albumSize * 0.05,
                                                  height: albumSize * 0.05,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.015,
                                    ),


                                    //----------------------------------
                                    // Glass Player Card
                                    //----------------------------------
                                    Flexible(
                                      child: GlassPlayerCard(
                                        title: _currentTitle,
                                        artist: _currentArtist,
                                      ),
                                    ),

                                    SizedBox(
                                      height: screenHeight * 0.015,
                                    ),

                                    //----------------------------------
                                    // Progress Slider (Real-time)
                                    //----------------------------------
                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      opacity: _dragOffset > 30 ? 0 : 1,
                                      child: StreamBuilder<Duration>(
                                        stream: MusicPlayerService
                                            .instance
                                            .player
                                            .positionStream,
                                        builder: (context, snapshot) {

                                          final position =
                                              snapshot.data ?? Duration.zero;

                                          debugPrint(
                                            '_currentDuration = $_currentDuration',
                                          );

                                          final duration =
                                          _parseDuration(
                                            _currentDuration,
                                          );

                                          if (
                                          !_forceNextTriggered &&
                                              duration.inMilliseconds > 0 &&
                                              position.inMilliseconds >= duration.inMilliseconds
                                          ) {

                                            _forceNextTriggered = true;

                                            debugPrint('🔥 FORCE NEXT FROM PLAYER PAGE');

                                            WidgetsBinding.instance.addPostFrameCallback((_) async {

                                              try {

                                                final nextTrack =
                                                await MusicPlayerService.instance.skipToNext();

                                                if (nextTrack != null) {

                                                  await MusicPlayerService.instance.playTrack(
                                                    nextTrack,
                                                  );
                                                }

                                              } finally {

                                                await Future.delayed(
                                                  const Duration(seconds: 2),
                                                );

                                                if (mounted) {
                                                  _forceNextTriggered = false;
                                                }
                                              }
                                            });
                                          }

                                          final safePosition =
                                          position > duration
                                              ? duration
                                              : position;

                                          double sliderValue = 0;

                                          if (duration.inMilliseconds > 0) {
                                            sliderValue =
                                                safePosition.inMilliseconds /
                                                    duration.inMilliseconds;

                                            sliderValue =
                                                sliderValue.clamp(
                                                  0.0,
                                                  1.0,
                                                );
                                          }

                                          debugPrint(
                                              'POSITION=${position.inMilliseconds}'
                                          );

                                          debugPrint(
                                              'DURATION=${duration.inMilliseconds}'
                                          );

                                          debugPrint(
                                              'SLIDER=$sliderValue'
                                          );

                                          debugPrint(
                                              'SAFE=${safePosition.inMilliseconds}'
                                          );

                                          return Column(
                                            children: [

                                              //----------------------------------
                                              // Slider
                                              //----------------------------------
                                              SliderTheme(
                                                data: SliderTheme.of(context)
                                                    .copyWith(
                                                  trackHeight: 6,
                                                  thumbShape:
                                                  const RoundSliderThumbShape(
                                                    enabledThumbRadius: 1,
                                                  ),
                                                  activeTrackColor:
                                                  AppColors.primary,
                                                  inactiveTrackColor:
                                                  Colors.white.withOpacity(
                                                    0.3,
                                                  ),
                                                ),
                                                child: Slider(
                                                  key: ValueKey(
                                                    sliderValue,
                                                  ),
                                                  value: sliderValue,
                                                  min: 0,
                                                  max: 1,
                                                  onChanged: (value) {

                                                    final seekPosition =
                                                    Duration(
                                                      milliseconds:
                                                      (value *
                                                          duration
                                                              .inMilliseconds)
                                                          .toInt(),
                                                    );

                                                    _seek(
                                                      seekPosition,
                                                    );
                                                  },
                                                ),
                                              ),

                                              //----------------------------------
                                              // Time
                                              //----------------------------------
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [

                                                    Text(
                                                      _formatDuration(
                                                        safePosition,
                                                      ),
                                                      style:
                                                      const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),

                                                    Text(
                                                      _currentDuration,
                                                      style:
                                                      const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    //----------------------------------
                                    // Bottom Bar
                                    //----------------------------------

                                    AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      opacity: _dragOffset > 30
                                          ? 0
                                          : 1,
                                      child: Container(
                                        height: bottomBarHeight,
                                      margin: EdgeInsets.only(
                                        bottom: screenHeight * 0.015,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: .08),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: .15),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: const [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.share,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.queue_music,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                                  ],
                                ),
                              ),
                            ),

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            )
        );
  }
  );
}
}
