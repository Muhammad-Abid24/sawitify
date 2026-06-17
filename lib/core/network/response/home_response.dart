import 'package:sawitify/data/model/album_model.dart';

class HomeResponse {
  final List<Shelf> shelves;

  HomeResponse({
    required this.shelves,
  });
}

class Shelf {
  final String title;
  final List<Album> items;

  Shelf({
    required this.title,
    required this.items,
  });
}