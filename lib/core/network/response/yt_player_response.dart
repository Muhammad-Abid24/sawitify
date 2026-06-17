class YtPlayer {
  final String videoId;
  final String streamUrl;
  final String mimeType;
  final int bitrate;
  final String durationMs;

  const YtPlayer({
    required this.videoId,
    required this.streamUrl,
    required this.mimeType,
    required this.bitrate,
    required this.durationMs,
  });

  factory YtPlayer.fromJson(
      Map<String, dynamic> json,
      ) {

    final streamingData =
    json["streamingData"];

    final formats =
    streamingData["formats"] as List;

    final first =
        formats.first;

    return YtPlayer(
      videoId:
      json["videoDetails"]?["videoId"] ?? "",
      streamUrl:
      first["url"] ?? "",
      mimeType:
      first["mimeType"] ?? "",
      bitrate:
      first["bitrate"] ?? 0,
      durationMs:
      first["approxDurationMs"] ?? "0",
    );
  }
}