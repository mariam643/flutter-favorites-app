
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

import '../models/post.dart';

class PostService {

  final String url =
      'https://jsonplaceholder.typicode.com/posts';

  Future<List<Post>> getPosts() async {

    try {

      // Fetch posts from the API
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {

        // Convert JSON response into a list
        List<dynamic> data = jsonDecode(response.body);

        List<Post> posts = data.map((post) {
          return Post.fromJson(post);
        }).toList();

        // Save API posts in postsBox
        final postsBox = Hive.box<Post>('postsBox');

        await postsBox.clear();

        for (var post in posts) {
          await postsBox.put(post.id, post);
        }

        return posts;

      } else {

        throw Exception('Failed to load posts');
      }

    } catch (e) {

      // Do not load posts from local storage
      throw Exception(
        'Unable to load posts. Please check your internet connection.',
      );
    }
  }
}
