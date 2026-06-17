
import 'package:flutter/cupertino.dart';

import '../../core/network/request/request_player.dart';
import '../../core/network/api_client.dart';
import '../model/player_model.dart';

class PlayerRepository {

  final ApiClient apiClient;

  PlayerRepository(
      this.apiClient,
      );

  Future<PlayerModel> getPlayer(
      String videoId,
      ) async {

    print("videoId = '$videoId'");
    debugPrint(
      'REQUEST VIDEO_ID = $videoId',
    );


    final response =
    await apiClient.apiPlayer.player(
      PlayerRequest(
        videoId: videoId,
      ).toJson(),
      false,
    );

    return PlayerModel.fromAudioJson(
      response,
    );

  }
}