import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/track_model.dart';

class MusicStorage {

  static const String trackKey =
      'last_track';

  //----------------------------------
  // Save Track
  //----------------------------------
  static Future<void> saveTrack(
      TrackModel track,
      ) async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      trackKey,
      jsonEncode(
        {
          "title": track.title,
          "artist": track.artist,
          "videoId": track.videoId,
          "thumbnail": track.thumbnail,
          "duration": track.duration,
        },
      ),
    );
  }

  //----------------------------------
  // Get Track
  //----------------------------------
  static Future<TrackModel?> getTrack() async {

    final prefs =
    await SharedPreferences.getInstance();

    final data =
    prefs.getString(
      trackKey,
    );

    if (data == null) {
      return null;
    }

    final json =
    jsonDecode(data);

    return TrackModel(
      title: json["title"] ?? "",
      artist: json["artist"] ?? "",
      videoId: json["videoId"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      duration: json["duration"] ?? "",
    );
  }

  //----------------------------------
  // Clear
  //----------------------------------
  static Future<void> clear() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      trackKey,
    );
  }
}