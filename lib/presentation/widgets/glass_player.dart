import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme/app_theme.dart';
import '../states/music_player_service.dart';
import 'auto_marque.dart';

class GlassPlayerCard extends StatefulWidget {
  const GlassPlayerCard({super.key, required this.title, required this.artist});

  final String title;
  final String artist;

  @override
  State<GlassPlayerCard> createState() => _GlassPlayerCardState();
}

class _GlassPlayerCardState extends State<GlassPlayerCard> {
  final MusicPlayerService _playerService = MusicPlayerService.instance;

  bool _isLoadingNext = false;
  bool _isLoadingPrev = false;

  @override
  void dispose() {
    debugPrint('❌ GLASS PLAYER DISPOSE');
    //FlutterVolumeController.removeListener();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _togglePlayPause() async {
    final player = _playerService.player;

    //----------------------------------
    // Lagu selesai
    //----------------------------------
    if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);

      await player.play();

      return;
    }

    //----------------------------------
    // Normal
    //----------------------------------
    if (player.playing) {
      debugPrint('⏸ PAUSE FROM PLAYER PAGE');

      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> _skipToPrevious() async {
    if (_isLoadingPrev) return;

    final prevTrack = await _playerService.skipToPrevious();
    if (prevTrack == null) {
      // Tidak ada lagu sebelumnya
      debugPrint('⚠️ No previous track');
      return;
    }

    setState(() {
      _isLoadingPrev = true;
    });

    try {
      // Load dan play lagu sebelumnya
      await _playerService.playTrack(prevTrack);

      _playerService.player.play();

      debugPrint('✅ Playing previous: ${prevTrack.title}');
    } catch (e) {
      debugPrint('❌ Error playing previous: $e');
      // Revert jika error
      await _playerService.skipToNext();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPrev = false;
        });
      }
    }
  }

  Future<void> _skipToNext() async {
    if (_isLoadingNext) return;

    final nextTrack = await _playerService.skipToNext();

    if (nextTrack == null) {
      debugPrint('⚠️ No next track');

      return;
    }

    setState(() {
      _isLoadingNext = true;
    });

    try {
      debugPrint('NEXT START');

      await _playerService.playTrack(nextTrack);

      debugPrint('NEXT PLAYTRACK DONE');
    } catch (e) {
      debugPrint('NEXT ERROR = $e');
    } finally {
      debugPrint('NEXT FINALLY');

      if (mounted) {
        setState(() {
          _isLoadingNext = false;
        });

        debugPrint('_isLoadingNext = false');
      }
    }
  }

  Future<void> _toggleShuffle() async {
    _playerService.toggleShuffle();

    setState(() {});
  }

  Future<void> _toggleRepeat() async {
    _playerService.toggleLoopMode();

    setState(() {});
  }

  Future<void> _volumeUp() async {
    final before = await FlutterVolumeController.getVolume();

    debugPrint('BEFORE = $before');

    await FlutterVolumeController.setVolume(
      ((before ?? 0) + 0.1).clamp(0.0, 1.0),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final after = await FlutterVolumeController.getVolume();

    debugPrint('AFTER = $after');
  }

  Future<void> _volumeDown() async {
    final current = await FlutterVolumeController.getVolume() ?? 0.0;

    final newVolume = (current - 0.1).clamp(0.0, 1.0);

    debugPrint('VOLUME DOWN: $current -> $newVolume');

    await FlutterVolumeController.setVolume(newVolume);
    debugPrint(
      'CURRENT SYSTEM VOLUME = ${await FlutterVolumeController.getVolume()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _playerService,
      builder: (context, _) {
        final currentTrack = _playerService.currentTrack;

        // Gunakan currentTrack jika ada, fallback ke widget data
        final displayTitle = currentTrack?.title ?? widget.title;
        final displayArtist = currentTrack?.artist ?? widget.artist;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: .12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .18),
                  width: 1.2,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //----------------------------------
                      // Title
                      //----------------------------------
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                autoMarquee(
                                  text: displayTitle,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.height < 700
                                        ? 18
                                        : 21,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  height: 30,
                                ),
                                autoMarquee(
                                  text: displayArtist,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .85),
                                    fontSize:
                                        MediaQuery.of(context).size.height < 700
                                        ? 13
                                        : 16,
                                  ),
                                  height: 25,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Show more options
                              debugPrint('More options tapped');
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      //----------------------------------
                      // Controls (iPad Style)
                      //----------------------------------
                      Flexible(
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final shortestSide = MediaQuery.of(
                                context,
                              ).size.shortestSide;

                              // Calculate ideal size for center control
                              final maxHeightBasedSize = maxHeight * 0.75;
                              final shortestSideBasedSize = shortestSide * 0.55;

                              final idealControlSize = maxHeightBasedSize.clamp(
                                160.0, // Increased minimum for better tap targets
                                shortestSideBasedSize,
                              );

                              // Calculate available width for center control
                              // Total width = shuffle (56) + controlSize + repeat (56) + padding (32)
                              final minRequiredWidth =
                                  56 + idealControlSize + 56 + 32;

                              // Check if we have enough width for horizontal layout
                              final useHorizontalLayout =
                                  constraints.maxWidth >= minRequiredWidth;

                              // Determine actual control size
                              final controlSize = useHorizontalLayout
                                  ? idealControlSize
                                  : idealControlSize.clamp(
                                      0.0,
                                      constraints.maxWidth - 32,
                                    );

                              final ringSize = controlSize * 0.90;

                              final center = controlSize / 2;

                              final iconSize = ringSize * 0.13;

                              final orbitRadius = ringSize * 0.30;

                              final playButtonSize = ringSize * 0.30;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  //----------------------------------
                                  // TOP ROW: Shuffle + Center + Repeat (if enough width)
                                  //----------------------------------
                                  if (useHorizontalLayout)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        //----------------------------------
                                        // SHUFFLE
                                        //----------------------------------
                                        SizedBox(
                                          width: 50,
                                          child: IconButton(
                                            onPressed: _toggleShuffle,
                                            icon: Icon(
                                              Icons.shuffle,
                                              color:
                                                  _playerService.shuffleEnabled
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),

                                        //----------------------------------
                                        // CENTER CONTROL (always shown)
                                        //----------------------------------
                                        SizedBox(
                                          width: controlSize,
                                          height: controlSize,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              //----------------------------------
                                              // GREEN RING
                                              //----------------------------------
                                              Container(
                                                width: ringSize,
                                                height: ringSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.primary,
                                                    width: 3,
                                                  ),
                                                ),
                                              ),

                                              //----------------------------------
                                              // VOLUME UP
                                              //----------------------------------
                                              Positioned(
                                                left: center - 32,
                                                top: center - orbitRadius - 32,
                                                child: Container(
                                                  width: 64,
                                                  height: 64,
                                                  alignment: Alignment.center,
                                                  child: IconButton(
                                                    onPressed: _volumeUp,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 56,
                                                          minHeight: 56,
                                                        ),
                                                    icon: Icon(
                                                      CupertinoIcons
                                                          .speaker_2_fill,
                                                      color: Colors.white,
                                                      size: iconSize * 1.1,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              //----------------------------------
                                              // VOLUME DOWN
                                              //----------------------------------
                                              Positioned(
                                                left: center - 32,
                                                top: center + orbitRadius - 32,
                                                child: Container(
                                                  width: 64,
                                                  height: 64,
                                                  alignment: Alignment.center,
                                                  child: IconButton(
                                                    onPressed: _volumeDown,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 56,
                                                          minHeight: 56,
                                                        ),
                                                    icon: Icon(
                                                      CupertinoIcons
                                                          .speaker_1_fill,
                                                      color: Colors.white,
                                                      size: iconSize * 1.1,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              //----------------------------------
                                              // PREVIOUS
                                              //----------------------------------
                                              Positioned(
                                                left: center - orbitRadius - 40,
                                                top: center - 40,
                                                child: Container(
                                                  width: 80,
                                                  height: 80,
                                                  alignment: Alignment.center,
                                                  child: IconButton(
                                                    onPressed: _isLoadingPrev
                                                        ? null
                                                        : _skipToPrevious,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 64,
                                                          minHeight: 64,
                                                        ),
                                                    icon: _isLoadingPrev
                                                        ? const SizedBox(
                                                            width: 32,
                                                            height: 32,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          )
                                                        : Icon(
                                                            Icons.skip_previous,
                                                            color: Colors.white,
                                                            size:
                                                                ringSize * 0.15,
                                                          ),
                                                  ),
                                                ),
                                              ),

                                              //----------------------------------
                                              // NEXT
                                              //----------------------------------
                                              Positioned(
                                                left: center + orbitRadius - 40,
                                                top: center - 40,
                                                child: Container(
                                                  width: 80,
                                                  height: 80,
                                                  alignment: Alignment.center,
                                                  child: IconButton(
                                                    onPressed: _isLoadingNext
                                                        ? null
                                                        : _skipToNext,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(
                                                          minWidth: 64,
                                                          minHeight: 64,
                                                        ),
                                                    icon: _isLoadingNext
                                                        ? const SizedBox(
                                                            width: 32,
                                                            height: 32,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                          )
                                                        : Icon(
                                                            Icons.skip_next,
                                                            color: Colors.white,
                                                            size:
                                                                ringSize * 0.15,
                                                          ),
                                                  ),
                                                ),
                                              ),

                                              //----------------------------------
                                              // PLAY
                                              //----------------------------------
                                              StreamBuilder<PlayerState>(
                                                stream: _playerService
                                                    .player
                                                    .playerStateStream,
                                                builder: (context, snapshot) {
                                                  final state = snapshot.data;

                                                  final isPlaying =
                                                      state?.playing ?? false;

                                                  final completed =
                                                      state?.processingState ==
                                                      ProcessingState.completed;

                                                  return GestureDetector(
                                                    onTap: _togglePlayPause,
                                                    child: Container(
                                                      width: playButtonSize,
                                                      height: playButtonSize,
                                                      decoration:
                                                          const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                      child: Icon(
                                                        (isPlaying &&
                                                                !completed)
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                        size:
                                                            playButtonSize *
                                                            0.55,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        //----------------------------------
                                        // REPEAT (for horizontal layout)
                                        //----------------------------------
                                        SizedBox(
                                          width: 50,
                                          child: IconButton(
                                            onPressed: _toggleRepeat,
                                            icon: Icon(
                                              _playerService.loopMode ==
                                                      LoopMode.one
                                                  ? Icons.repeat_one
                                                  : Icons.repeat,
                                              color:
                                                  _playerService.loopMode !=
                                                      LoopMode.off
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  //----------------------------------
                                  // CENTER CONTROL (for vertical layout)
                                  //----------------------------------
                                  if (!useHorizontalLayout)
                                    SizedBox(
                                      width: controlSize,
                                      height: controlSize,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          //----------------------------------
                                          // GREEN RING
                                          //----------------------------------
                                          Container(
                                            width: ringSize,
                                            height: ringSize,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.primary,
                                                width: 3,
                                              ),
                                            ),
                                          ),

                                          //----------------------------------
                                          // VOLUME UP
                                          //----------------------------------
                                          Positioned(
                                            left: center - 32,
                                            top: center - orbitRadius - 32,
                                            child: Container(
                                              width: 64,
                                              height: 64,
                                              alignment: Alignment.center,
                                              child: IconButton(
                                                onPressed: _volumeUp,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 56,
                                                      minHeight: 56,
                                                    ),
                                                icon: Icon(
                                                  CupertinoIcons.speaker_2_fill,
                                                  color: Colors.white,
                                                  size: iconSize * 1.1,
                                                ),
                                              ),
                                            ),
                                          ),

                                          //----------------------------------
                                          // VOLUME DOWN
                                          //----------------------------------
                                          Positioned(
                                            left: center - 32,
                                            top: center + orbitRadius - 32,
                                            child: Container(
                                              width: 64,
                                              height: 64,
                                              alignment: Alignment.center,
                                              child: IconButton(
                                                onPressed: _volumeDown,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 56,
                                                      minHeight: 56,
                                                    ),
                                                icon: Icon(
                                                  CupertinoIcons.speaker_1_fill,
                                                  color: Colors.white,
                                                  size: iconSize * 1.1,
                                                ),
                                              ),
                                            ),
                                          ),

                                          //----------------------------------
                                          // PREVIOUS
                                          //----------------------------------
                                          Positioned(
                                            left: center - orbitRadius - 40,
                                            top: center - 40,
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              alignment: Alignment.center,
                                              child: IconButton(
                                                onPressed: _isLoadingPrev
                                                    ? null
                                                    : _skipToPrevious,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 64,
                                                      minHeight: 64,
                                                    ),
                                                icon: _isLoadingPrev
                                                    ? const SizedBox(
                                                        width: 32,
                                                        height: 32,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                    : Icon(
                                                        Icons.skip_previous,
                                                        color: Colors.white,
                                                        size: ringSize * 0.15,
                                                      ),
                                              ),
                                            ),
                                          ),

                                          //----------------------------------
                                          // NEXT
                                          //----------------------------------
                                          Positioned(
                                            left: center + orbitRadius - 40,
                                            top: center - 40,
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              alignment: Alignment.center,
                                              child: IconButton(
                                                onPressed: _isLoadingNext
                                                    ? null
                                                    : _skipToNext,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 64,
                                                      minHeight: 64,
                                                    ),
                                                icon: _isLoadingNext
                                                    ? const SizedBox(
                                                        width: 32,
                                                        height: 32,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      )
                                                    : Icon(
                                                        Icons.skip_next,
                                                        color: Colors.white,
                                                        size: ringSize * 0.15,
                                                      ),
                                              ),
                                            ),
                                          ),

                                          //----------------------------------
                                          // PLAY
                                          //----------------------------------
                                          StreamBuilder<PlayerState>(
                                            stream: _playerService
                                                .player
                                                .playerStateStream,
                                            builder: (context, snapshot) {
                                              final state = snapshot.data;

                                              final isPlaying =
                                                  state?.playing ?? false;

                                              final completed =
                                                  state?.processingState ==
                                                  ProcessingState.completed;

                                              return GestureDetector(
                                                onTap: _togglePlayPause,
                                                child: Container(
                                                  width: playButtonSize,
                                                  height: playButtonSize,
                                                  decoration:
                                                      const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                  child: Icon(
                                                    (isPlaying && !completed)
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    size: playButtonSize * 0.55,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

                                  //----------------------------------
                                  // BOTTOM ROW: Shuffle + Repeat (for vertical layout)
                                  //----------------------------------
                                  if (!useHorizontalLayout)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        //----------------------------------
                                        // SHUFFLE
                                        //----------------------------------
                                        SizedBox(
                                          width: 50,
                                          child: IconButton(
                                            onPressed: _toggleShuffle,
                                            icon: Icon(
                                              Icons.shuffle,
                                              color:
                                                  _playerService.shuffleEnabled
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 32),

                                        //----------------------------------
                                        // REPEAT
                                        //----------------------------------
                                        SizedBox(
                                          width: 50,
                                          child: IconButton(
                                            onPressed: _toggleRepeat,
                                            icon: Icon(
                                              _playerService.loopMode ==
                                                      LoopMode.one
                                                  ? Icons.repeat_one
                                                  : Icons.repeat,
                                              color:
                                                  _playerService.loopMode !=
                                                      LoopMode.off
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
