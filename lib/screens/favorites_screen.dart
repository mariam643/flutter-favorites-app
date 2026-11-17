
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatelessWidget {

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final FavoritesService favoritesService =
        FavoritesService();

    return Scaffold(

      // AppBar
      appBar: AppBar(

        title: const Text(
          'My Favorites',

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // Listen to favoritesBox
      body: ValueListenableBuilder(

        valueListenable:
            Hive.box<Post>('favoritesBox').listenable(),

        builder: (context, box, child) {

          // Get saved favorites
          final favorites =
              favoritesService.getFavorites();

          // Empty favorites
          if (favorites.isEmpty) {

            return const Center(

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.star_border,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 16),

                  Text(
                    'No favorites yet',

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Your favorite posts will appear here.',

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Display saved favorites
          return ListView.builder(

            itemCount: favorites.length,

            itemBuilder: (context, index) {

              final post = favorites[index];

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

                  // Remove favorite
                  trailing: IconButton(

                    icon: const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 30,
                    ),

                    tooltip: 'Remove from favorites',

                    onPressed: () async {

                      await favoritesService
                          .toggleFavorite(post);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
