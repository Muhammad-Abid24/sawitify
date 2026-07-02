import 'package:dio/dio.dart';
import 'package:Sawitify/core/network/service_config.dart';

import '../../core/network/request/request_base.dart';
import '../../core/network/response/playlist_response.dart';
import '../model/playlist_model.dart';

class PlaylistRepository {
  final Dio dio;

  PlaylistRepository(this.dio);

  Future<PlaylistResponse> getPlaylistDetail(String browseId) async {
    final request = await dio.post(
      '/browse',
      queryParameters: {'alt': 'json', 'key': ServiceConfig.apiKey},
      data: {...RequestBase.requestBase, 'browseId': browseId},
    );

    final response = Map<String, dynamic>.from(request.data);

    return parsePlaylist(response);
  }
}
