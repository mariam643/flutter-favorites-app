
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import '../services/favorites_service.dart';
import 'favorites_screen.dart';

class PostsScreen extends StatefulWidget {

  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {

  // Services
  final PostService postService = PostService();

  final FavoritesService favoritesService =
      FavoritesService();

  // Posts list
  List<Post> posts = [];

  // Loading state
  bool isLoading = true;

  // Error state
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    getPosts();
  }

  // Fetch posts from API
  Future<void> getPosts() async {

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {

      final result = await postService.getPosts();

      if (!mounted) return;

      setState(() {

        posts = result;

        isLoading = false;

        errorMessage = null;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {

        // Do not display cached posts
        posts = [];

        isLoading = false;

        errorMessage =
            'Unable to load posts. Please check your internet connection.';
      });
    }
  }

  // Build post card
  Widget buildPostCard(Post post) {

    final isFavorite =
        favoritesService.isFavorite(post.id);

    return Card(

      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(

        contentPadding: const EdgeInsets.all(12),

        // Post title
        title: Text(
          post.title,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        // Post body
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(post.body),
        ),

        // Favorite star
        trailing: IconButton(

          icon: Icon(
            isFavorite
                ? Icons.star
                : Icons.star_border,

            color: isFavorite
                ? Colors.amber
                : Colors.grey,

            size: 30,
          ),

          tooltip: isFavorite
              ? 'Remove from favorites'
              : 'Add to favorites',

          onPressed: () async {

            await favoritesService.toggleFavorite(post);

          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // AppBar
      appBar: AppBar(

        title: const Text(
          'Posts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [

          // Open Favorites Screen
          IconButton(

            tooltip: 'My Favorites',

            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),

            onPressed: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) =>
                      const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),

      // Screen body
      body: isLoading

          // Loading indicator
          ? const Center(
              child: CircularProgressIndicator(),
            )

          // Offline or error message
          : errorMessage != null

              ? Center(

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(

                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        const Icon(
                          Icons.wifi_off,
                          size: 65,
                          color: Colors.grey,
                        ),

                        const SizedBox(height: 16),

                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(

                          onPressed: getPosts,

                          icon: const Icon(Icons.refresh),

                          label: const Text('Retry'),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'You can still access your saved favorites.',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              // Display posts only when API succeeds
              : ValueListenableBuilder(

                  valueListenable:
                      Hive.box<Post>('favoritesBox').listenable(),

                  builder: (context, box, child) {

                    return RefreshIndicator(

                      onRefresh: getPosts,

                      child: ListView.builder(

                        physics:
                            const AlwaysScrollableScrollPhysics(),

                        itemCount: posts.length,

                        itemBuilder: (context, index) {

                          final post = posts[index];

                          return buildPostCard(post);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
