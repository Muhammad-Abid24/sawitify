import 'package:sawitify/core/network/api_client.dart';
import 'package:sawitify/core/network/service_config.dart';

import '../model/search_model.dart';

class SearchRepository {
  SearchRepository(this.api);

  final ApiClient api;

  Future<SearchResponse> search(String keyword) async {
    final Map<String, dynamic> json =
        await api.apiSearch.search("json", ServiceConfig.apiKey!, {
              "context": {
                "client": {
                  "clientName": "WEB_REMIX",
                  "clientVersion": "1.20260603.06.00",
                  "hl": "id",
                  "gl": "ID",
                },
                "user": {"enableSafetyMode": false},
              },
              "input": keyword,
            })
            as Map<String, dynamic>;

    final List<String> suggestions = [];
    final List<SearchItem> items = [];

    final List contents = json["contents"] as List? ?? [];

    for (final section in contents) {
      final renderer =
          section["searchSuggestionsSectionRenderer"] as Map<String, dynamic>?;

      if (renderer == null) continue;

      final List rows = renderer["contents"] as List? ?? [];

      for (final row in rows) {
        //
        // =========================
        // SEARCH SUGGESTION
        // =========================
        //

        if (row["searchSuggestionRenderer"] != null) {
          final suggestion =
              row["searchSuggestionRenderer"] as Map<String, dynamic>;

          final List runs = suggestion["suggestion"]?["runs"] as List? ?? [];

          final text = runs.map((e) => e["text"]?.toString() ?? "").join();

          if (text.isNotEmpty) {
            suggestions.add(text);
          }

          continue;
        }

        //
        // =========================
        // SEARCH RESULT
        // =========================
        //

        if (row["musicResponsiveListItemRenderer"] == null) {
          continue;
        }

        final item =
            row["musicResponsiveListItemRenderer"] as Map<String, dynamic>;

        final List flexColumns = item["flexColumns"] as List? ?? [];

        if (flexColumns.isEmpty) {
          continue;
        }

        //
        // title
        //

        final title =
            flexColumns
                .first["musicResponsiveListItemFlexColumnRenderer"]?["text"]?["runs"]?[0]?["text"]
                ?.toString() ??
            "";

        //
        // subtitle
        //

        String subtitle = "";
        String artist = "";

        if (flexColumns.length > 1) {
          final List subtitleRuns =
              flexColumns[1]["musicResponsiveListItemFlexColumnRenderer"]?["text"]?["runs"]
                  as List? ??
              [];

          subtitle = subtitleRuns
              .map((e) => e["text"]?.toString() ?? "")
              .join();

          if (subtitleRuns.length >= 3) {
            artist = subtitleRuns[2]["text"]?.toString() ?? "";
          }
        }

        //
        // thumbnail
        //

        String thumbnail = "";

        final List thumbnails =
            item["thumbnail"]?["musicThumbnailRenderer"]?["thumbnail"]?["thumbnails"]
                as List? ??
            [];

        if (thumbnails.isNotEmpty) {
          thumbnail = thumbnails.last["url"]?.toString() ?? "";
        }

        //
        // id
        //

        String id = "";

        final nav = item["navigationEndpoint"] as Map<String, dynamic>? ?? {};

        if (nav["watchEndpoint"] != null) {
          id = nav["watchEndpoint"]["videoId"]?.toString() ?? "";
        }

        if (id.isEmpty && nav["browseEndpoint"] != null) {
          id = nav["browseEndpoint"]["browseId"]?.toString() ?? "";
        }

        //
        // type
        //

        final lower = subtitle.toLowerCase();

        SearchItemType type = SearchItemType.unknown;

        if (lower.contains("song") || lower.contains("lagu")) {
          type = SearchItemType.song;
        } else if (lower.contains("artist") ||
            lower.contains("artis") ||
            lower.contains("audiens")) {
          type = SearchItemType.artist;
        } else if (lower.contains("album")) {
          type = SearchItemType.album;
        } else if (lower.contains("playlist")) {
          type = SearchItemType.playlist;
        }

        items.add(
          SearchItem(
            id: id,
            artist: artist,
            title: title,
            subtitle: subtitle,
            thumbnail: thumbnail,
            type: type,
          ),
        );
      }
    }

    return SearchResponse(suggestions: suggestions, items: items);
  }
}
