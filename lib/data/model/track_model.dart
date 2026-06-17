class TrackModel {
  final String title;
  final String artist;
  final String videoId;
  final String thumbnail;
  final String duration;


  TrackModel({
    required this.title,
    required this.artist,
    required this.videoId,
    required this.thumbnail,
    required this.duration,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      videoId: json['videoId'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'videoId': videoId,
      'thumbnail': thumbnail,
      'duration': duration,
    };
  }
}