class PlayerRequest {
  final String videoId;

  const PlayerRequest({
    required this.videoId,
  });

  Map<String, dynamic> toJson() {
    return {
      "context": {
        "client": {
          "clientName": "ANDROID_VR",
          "clientVersion": "1.56.21",
          "deviceModel": "Quest 3",
          "osVersion": "12",
          "osName": "Android",
          "androidSdkVersion": 32,
          "hl": "en",
          "timeZone": "UTC",
          "utcOffsetMinutes": 0,
        }
      },
      "videoId": videoId,
      "playbackContext": {
        "contentPlaybackContext": {
          "html5Preference": "HTML5_PREF_WANTS",
          "signatureTimestamp": "20614",
        }
      },
      // "racyCheckOk": true,
      // "contentCheckOk": true,
      // "params": "CgAQ3D3D==",
    };
  }

}
