class PlayerModel {
  final String videoId;
  final String streamUrl;
  final String mimeType;
  final int bitrate;
  final String durationMs;

  const PlayerModel({
    required this.videoId,
    required this.streamUrl,
    required this.mimeType,
    required this.bitrate,
    required this.durationMs,
  });

  factory PlayerModel.fromAudioJson(
      Map<String, dynamic> json,
      ) {

    final streaming =
    json["streamingData"];

    if (streaming == null) {

      final reason =
      json["playabilityStatus"]
      ?["reason"];

      throw Exception(
        reason ??
            "No streaming data",
      );

    }

    final adaptive =
    (streaming["adaptiveFormats"]
    as List?)

        ?.cast<Map<String,dynamic>>();

    if (
    adaptive == null ||
        adaptive.isEmpty
    ) {

      throw Exception(
        "No adaptive formats",
      );

    }

    final audio =
    adaptive.firstWhere(

          (e) =>

          e["mimeType"]
              .toString()
              .startsWith(
            "audio/mp4",
          ),

      orElse: () =>

          adaptive.firstWhere(

                (e) =>

                e["mimeType"]
                    .toString()
                    .startsWith(
                  "audio/",
                ),

          ),

    );

    final url =
    audio["url"];

    if (url == null) {

      throw Exception(
        "Encrypted stream",
      );

    }

    return PlayerModel(

      videoId:

      json["videoDetails"]
      ?["videoId"]

          ?? '',

      streamUrl:

      url,

      mimeType:

      audio["mimeType"],

      bitrate:

      audio["bitrate"] ?? 0,

      durationMs:

      audio["approxDurationMs"]

          ?? '0',

    );

  }
}
