
import 'package:hive/hive.dart';

import '../models/post.dart';

class FavoritesService {

  // Access the favorites box
  final Box<Post> favoritesBox =
      Hive.box<Post>('favoritesBox');

  // Add or remove a favorite
  Future<void> toggleFavorite(Post post) async {

    if (favoritesBox.containsKey(post.id)) {

      // Remove favorite
      await favoritesBox.delete(post.id);

    } else {

      // Create a copy of the post
      Post copy = Post(
        id: post.id,
        title: post.title,
        body: post.body,
        userId: post.userId,
      );

      // Save using post ID
      await favoritesBox.put(post.id, copy);
    }
  }

  // Check if a post is favorite
  bool isFavorite(int id) {

    return favoritesBox.containsKey(id);
  }

  // Retrieve all favorites
  List<Post> getFavorites() {

    List<Post> favorites =
        favoritesBox.values.toList();

    favorites.sort(
      (a, b) => a.id.compareTo(b.id),
    );

    return favorites;
  }
}
