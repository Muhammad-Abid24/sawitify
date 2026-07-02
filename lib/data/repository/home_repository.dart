import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:Sawitify/core/network/request/request_base.dart';

import '../../core/network/response/home_response.dart';
import '../../core/network/service_config.dart';
import '../model/album_model.dart';

class HomeRepository {
  final Dio dio;

  HomeRepository(this.dio);

  Future<HomeResponse> getHome() async {
    final response = await dio.post(
      '/browse',
      queryParameters: {'alt': 'json', 'key': ServiceConfig.apiKey},
      data: {...RequestBase.requestBase, 'browseId': 'FEmusic_home'},
    );

    debugPrint(
      response.data.toString().contains("continuationItemRenderer").toString(),
    );

    debugPrint(
      const JsonEncoder.withIndent(
        '  ',
      ).convert(response.data).substring(0, 5000),
    );

    final json = Map<String, dynamic>.from(response.data);

    return _parseHome(json);
  }

  HomeResponse _parseHome(Map<String, dynamic> json) {
    final shelves = <Shelf>[];

    try {
      final tabs =
          json["contents"]["singleColumnBrowseResultsRenderer"]["tabs"] as List;

      for (final tab in tabs) {
        final tabRenderer = tab["tabRenderer"];

        debugPrint("Tab title : ${tabRenderer["title"]}");

        final content = tabRenderer["content"];

        if (content == null) continue;

        final sectionList = content["sectionListRenderer"];

        if (sectionList == null) continue;

        final contents =
            tabRenderer["content"]["sectionListRenderer"]["contents"] as List;

        debugPrint("Total contents: ${contents.length}");

        for (final item in contents) {
          debugPrint("Renderer: ${item.keys.first}");
        }

        for (final item in contents) {
          debugPrint("Renderer: ${item.keys.first}");

          final shelf = _parseDynamicShelf(item);

          if (shelf != null && shelf.items.isNotEmpty) {
            shelves.add(shelf);
          }
        }
      }
    } catch (e) {
      debugPrint("Parse Home Error: $e");
    }

    return HomeResponse(shelves: shelves);
  }

  Shelf? _parseDynamicShelf(Map<String, dynamic> item) {
    try {
      if (item.containsKey("musicCarouselShelfRenderer")) {
        return _parseCarouselShelf(item["musicCarouselShelfRenderer"]);
      }

      if (item.containsKey("musicImmersiveCarouselShelfRenderer")) {
        return _parseImmersiveShelf(
          item["musicImmersiveCarouselShelfRenderer"],
        );
      }

      return null;
    } catch (e) {
      debugPrint("Parse Shelf Error: $e");

      return null;
    }
  }

  Shelf _parseCarouselShelf(Map<String, dynamic> shelf) {
    String title = "Untitled";

    try {
      title =
          shelf["header"]["musicCarouselShelfBasicHeaderRenderer"]["title"]["runs"][0]["text"];
    } catch (_) {}

    final items = <Album>[];

    final contents = shelf["contents"] as List? ?? [];

    for (final item in contents) {
      final album = _safeParseAlbum(item);

      if (album != null) {
        items.add(album);
      }
    }

    return Shelf(title: title, items: items);
  }

  Shelf _parseImmersiveShelf(Map<String, dynamic> shelf) {
    String title = "Featured";

    try {
      title =
          shelf["headerRenderer"]["musicCarouselShelfBasicHeaderRenderer"]["title"]["runs"][0]["text"];
    } catch (_) {}

    final items = <Album>[];

    final contents = shelf["contents"] as List? ?? [];

    for (final item in contents) {
      final album = _safeParseAlbum(item);

      if (album != null) {
        items.add(album);
      }
    }

    return Shelf(title: title, items: items);
  }

  Album? _safeParseAlbum(Map<String, dynamic> json) {
    try {
      final renderer = json["musicTwoRowItemRenderer"];

      if (renderer == null) {
        return null;
      }

      final title = renderer["title"]["runs"][0]["text"] ?? "";

      String subtitle = "";

      try {
        final runs = renderer["subtitle"]["runs"] as List;

        subtitle = runs.map((e) => e["text"]?.toString() ?? "").join();
      } catch (_) {}

      String browseId = "";

      try {
        browseId = renderer["navigationEndpoint"]["browseEndpoint"]["browseId"];
      } catch (_) {}

      String thumbnail = "";

      try {
        final thumbs =
            renderer["thumbnailRenderer"]?["musicThumbnailRenderer"]?["thumbnail"]?["thumbnails"]
                as List? ??
            [];

        if (thumbs.isNotEmpty) {
          thumbnail = thumbs.last["url"];
        }
      } catch (_) {}

      return Album(
        title: title,
        subtitle: subtitle,
        browseId: browseId,
        thumbnail: thumbnail,
      );
    } catch (e) {
      debugPrint("Parse Album Error: $e");

      return null;
    }
  }

  HomeResponse parseContinuation(Map<String, dynamic> json) {
    final shelves = <Shelf>[];

    try {
      final contents =
          json["continuationContents"]["sectionListContinuation"]["contents"]
              as List;

      debugPrint("Continuation contents: ${contents.length}");

      for (final item in contents) {
        debugPrint("Continuation Renderer: ${item.keys.first}");

        final shelf = _parseDynamicShelf(item);

        if (shelf != null && shelf.items.isNotEmpty) {
          shelves.add(shelf);
        }
      }
    } catch (e) {
      debugPrint("Parse Continuation Error: $e");
    }

    return HomeResponse(shelves: shelves);
  }

  Future<HomeResponse> load1(String continuation) async {
    final response = await dio.post(
      '/browse',
      queryParameters: {
        'continuation': continuation,
        'alt': 'json',
        'key': ServiceConfig.apiKey,
      },
      data: RequestBase.requestBase,
    );

    final json = Map<String, dynamic>.from(response.data);

    return parseContinuation(json);
  }

  Future<HomeResponse> load2(String continuation) async {
    final response = await dio.post(
      '/browse',
      queryParameters: {
        'continuation': continuation,
        'alt': 'json',
        'key': ServiceConfig.apiKey,
      },
      data: RequestBase.requestBase,
    );

    final json = Map<String, dynamic>.from(response.data);

    return parseContinuation(json);
  }
}
