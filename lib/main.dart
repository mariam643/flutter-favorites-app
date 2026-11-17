
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/post.dart';
import 'screens/posts_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Post adapter
  Hive.registerAdapter(PostAdapter());

  // Open posts box
  await Hive.openBox<Post>('postsBox');

  // Open favorites box
  await Hive.openBox<Post>('favoritesBox');

  // Run application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Posts App',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      home: const PostsScreen(),
    );
  }
}
