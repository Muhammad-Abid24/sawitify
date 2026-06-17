import 'package:flutter/cupertino.dart';

import '../../../data/model/track_model.dart';

TrackModel? parseTrack(
    Map<String, dynamic> item,
    ) {
  try {
    final renderer =
    item["musicResponsiveListItemRenderer"];

    final flexColumns =
    renderer["flexColumns"] as List;

    /// TITLE
    String title = '';

    try {
      title =
          flexColumns[0]
          ["musicResponsiveListItemFlexColumnRenderer"]
          ["text"]["runs"][0]["text"] ??
              '';
    } catch (_) {}

    /// ARTIST
    /// ARTIST
    String artist = '';

    try {

      if (flexColumns.length > 1) {

        final text =
        flexColumns[1]
        ["musicResponsiveListItemFlexColumnRenderer"]
        ?["text"];

        if (text != null) {

          if (text["runs"] is List) {

            artist =
                (text["runs"] as List)
                    .map(
                      (e) => e["text"] ?? '',
                )
                    .join();

            /// Hapus bullet separator
            artist = artist
                .replaceAll(' • ', '')
                .trim();
          }

          else if (text["simpleText"] != null) {

            artist =
                text["simpleText"]
                    .toString()
                    .trim();
          }
        }
      }

    } catch (_) {}

    /// VIDEO ID
    String videoId = '';

    try {
      videoId =
          renderer["playlistItemData"]
          ?["videoId"] ??
              '';
    } catch (_) {}

    if (videoId.isEmpty) {
      try {
        videoId =
            renderer["overlay"]
            ["musicItemThumbnailOverlayRenderer"]
            ["content"]
            ["musicPlayButtonRenderer"]
            ["playNavigationEndpoint"]
            ["watchEndpoint"]
            ["videoId"] ??
                '';
      } catch (_) {}
    }

    if (videoId.isEmpty) {
      try {
        videoId =
            renderer["navigationEndpoint"]
            ["watchEndpoint"]
            ["videoId"] ??
                '';
      } catch (_) {}
    }

    String thumbnail = '';

    try {
      final thumbs =
      renderer["thumbnail"]
      ["musicThumbnailRenderer"]
      ["thumbnail"]["thumbnails"] as List;

      thumbnail =
      thumbs.last["url"];
    } catch (_) {}

    String duration = '';

    try {
      final fixedColumns =
      renderer["fixedColumns"] as List;

      duration =
      fixedColumns[0]
      ["musicResponsiveListItemFixedColumnRenderer"]
      ["text"]["runs"][0]["text"];
    } catch (_) {}

    if (videoId.isEmpty) {
      return null;
    }

    return TrackModel(
      title: title,
      artist: artist,
      videoId: videoId,
      thumbnail: thumbnail,
      duration: duration,
    );
  } catch (e) {
    debugPrint(
      "Track Parse Error: $e",
    );

    return null;
  }
}