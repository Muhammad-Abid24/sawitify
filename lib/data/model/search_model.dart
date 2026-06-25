enum SearchItemType { suggestion, song, artist, album, playlist, unknown }

class SearchResponse {
  final List<String> suggestions;
  final List<SearchItem> items;

  const SearchResponse({required this.suggestions, required this.items});
}

class SearchItem {
  final String id;

  final String title;

  final String artist;

  final String subtitle;

  final String thumbnail;

  final SearchItemType type;

  const SearchItem({
    required this.id,
    required this.artist,
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    required this.type,
  });
}
