import 'package:flutter/cupertino.dart';
import 'package:sawitify/core/network/response/track_response.dart';

import '../../../data/model/playlist_model.dart';
import '../../../data/model/track_model.dart';

PlaylistResponse parsePlaylist(
    Map<String, dynamic> json,
    ) {
  String title = '';
  String description = '';
  String thumbnail = '';

  final tracks = <TrackModel>[];

  /// HEADER
  try {

    final header =
    json["header"];

    if (header != null) {

      if (header[
      "musicResponsiveHeaderRenderer"] !=
          null) {

        final renderer =
        header[
        "musicResponsiveHeaderRenderer"];

        title =
        renderer["title"]
        ["runs"][0]["text"];

        final thumbs =
        renderer["thumbnail"]
        ["musicThumbnailRenderer"]
        ["thumbnail"]["thumbnails"] as List;

        thumbnail =
        thumbs.last["url"];
      }

      else if (header[
      "musicDetailHeaderRenderer"] !=
          null) {

        final renderer =
        header[
        "musicDetailHeaderRenderer"];

        title =
        renderer["title"]
        ["runs"][0]["text"];

        final thumbs =
        renderer["thumbnail"]
        ["croppedSquareThumbnailRenderer"]
        ["thumbnail"]["thumbnails"] as List;

        thumbnail =
        thumbs.last["url"];
      }
    }
  } catch (e) {
    debugPrint(
      "HEADER ERROR: $e",
    );
  }

  /// TRACKS
  try {

    final sections =
    json["contents"]
    ["twoColumnBrowseResultsRenderer"]
    ["secondaryContents"]
    ["sectionListRenderer"]
    ["contents"] as List;

    List<dynamic> items = [];

    for (final section in sections) {

      if (section[
      "musicPlaylistShelfRenderer"] !=
          null) {

        items =
        section[
        "musicPlaylistShelfRenderer"]
        ["contents"];

        break;
      }

      if (section[
      "musicShelfRenderer"] !=
          null) {

        items =
        section[
        "musicShelfRenderer"]
        ["contents"];

        break;
      }
    }

    for (final item in items) {

      final track =
      parseTrack(item);

      if (track != null) {
        tracks.add(track);
      }
    }

  } catch (e) {
    debugPrint(
      "Track Error: $e",
    );
  }

  return PlaylistResponse(
    title: title,
    description: description,
    thumbnail: thumbnail,
    tracks: tracks,
  );
}