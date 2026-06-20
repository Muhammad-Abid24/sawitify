import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sawitify/presentation/pages/now_player_page.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/model/track_model.dart';
import '../../data/model/playlist_model.dart';
import '../../data/repository/player_repository.dart';
import '../../data/repository/playlist_repository.dart';
import '../widgets/auto_marque.dart';
import '../widgets/mini_player.dart';
import '../widgets/toolbar.dart';
import '../widgets/youtube_thumbnail.dart';

class PlaylistPage extends StatefulWidget {
  final String browseId;
  final String title;
  final String subTitle;
  final String thumbnail;

  const PlaylistPage({
    super.key,
    required this.browseId,
    required this.title,
    required this.subTitle,
    required this.thumbnail,
  });

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool isLoading = true;

  String? errorMessage;

  PlaylistResponse? playlist;

  late final PlayerRepository playerRepository;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    playerRepository = PlayerRepository(ApiClient());
    loadPlaylist();
  }

  Future<void> loadPlaylist() async {
    try {
      final repository = PlaylistRepository(ApiClient().dioBrowse);

      final response = await repository.getPlaylistDetail(widget.browseId);

      debugPrint('PLAYLIST TITLE = ${response.title}');

      debugPrint('TRACK COUNT = ${response.tracks.length}');

      if (!mounted) return;

      setState(() {
        playlist = response;
        isLoading = false;
      });

      // Preload stream URLs untuk semua lagu di playlist
      if (response.tracks.isNotEmpty) {
        final videoIds = response.tracks.map((track) => track.videoId).toList();
        debugPrint('🔄 Starting preload for ${videoIds.length} tracks...');
      }
    } catch (e) {
      debugPrint('PLAYLIST ERROR: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background1,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background1,
        body: Center(child: Text(errorMessage!)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background1,

      appBar: Toolbar(
        bgColor: AppColors.primary,
        txtTitle: "Daftar Putar",
        titleColor: Colors.white,
        icons: Icons.arrow_back,
        iconsColor: Colors.white,
      ),

      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 160),
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              ...playlist!.tracks.map((track) => _buildTrack(track)),
            ],
          ),

          const Positioned(left: 0, right: 0, bottom: 95, child: MiniPlayer()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.thumbnail,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.subTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTrack(TrackModel track) {
    return InkWell(
      onTap: () async {
        try {
          final playerData = await playerRepository.getPlayer(track.videoId);

          debugPrint('STREAM URL = ${playerData.streamUrl}');

          //----------------------------------
          // Cari posisi lagu di playlist
          //----------------------------------
          final trackIndex = playlist!.tracks.indexWhere(
            (e) => e.videoId == track.videoId,
          );

          debugPrint('TRACK INDEX = $trackIndex');

          //----------------------------------
          // Simpan ke NewMusicPlayerService
          //----------------------------------
          // NewMusicService.instance
          //     .setCurrentTrack(
          //   track,
          //   playlist: playlist!.tracks,
          //   index: trackIndex,
          // );

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NowPlayingScreen(
                imageUrl: track.thumbnail,
                title: track.title,
                artist: track.artist,
                duration: track.duration,
                videoId: track.videoId,
                fromMiniPlayer: false,
              ),
            ),
          );

          // showModalBottomSheet(
          //   context: context,
          //   isScrollControlled: true,
          //   backgroundColor: Colors.transparent,
          //   enableDrag: true,
          //   builder: (_) {
          //     return PlayerPage();
          //   },
          //);
        } catch (e) {
          debugPrint('PLAYER ERROR = $e');

          if (!mounted) return;

          String errorMessage = 'Gagal memutar lagu';

          if (e.toString().contains('age-restricted')) {
            errorMessage = 'Lagu ini dibatasi oleh usia.';
          } else if (e.toString().contains('region-locked')) {
            errorMessage = 'Lagu tidak tersedia di wilayah Anda.';
          } else if (e.toString().contains('playable')) {
            errorMessage = 'Lagu tidak dapat diputar.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //----------------------------------
            // THUMBNAIL
            //----------------------------------
            YoutubeThumbnail(
              videoId: track.videoId,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(8),
            ),

            const SizedBox(width: 16),

            //----------------------------------
            // TITLE + ARTIST
            //----------------------------------
            Expanded(
              child: SizedBox(
                height: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    autoMarquee(
                      text: track.title,
                      height: 22,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    autoMarquee(
                      text: track.artist,
                      height: 18,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            //----------------------------------
            // DURATION
            //----------------------------------
            SizedBox(
              width: 45,
              child: Text(
                track.duration,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

            const SizedBox(width: 8),

            //----------------------------------
            // MENU
            //----------------------------------
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white70,
                size: 22,
              ),
              onPressed: () {
                debugPrint('MENU: ${track.title}');

                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.background2,
                  builder: (_) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Putar',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),

                          ListTile(
                            leading: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Tambahkan ke Favorit',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),

                          ListTile(
                            leading: const Icon(
                              Icons.playlist_add,
                              color: Colors.white,
                            ),
                            title: const Text(
                              'Tambahkan ke Playlist',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
