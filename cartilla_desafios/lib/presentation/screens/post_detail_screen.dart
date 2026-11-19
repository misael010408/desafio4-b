import 'package:flutter/material.dart';

import '../../data/services/api_service.dart';
import '../../domain/entities/post.dart';

class PostDetailScreen extends StatelessWidget {
  final int id;
  final Post? post; // llega por "extra"; si no, se pide por id

  const PostDetailScreen({super.key, required this.id, this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post #$id')),
      body: post != null
          ? _contenido(context, post!)
          : FutureBuilder<Post>(
              future: ApiService().getPost(id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                return _contenido(context, snap.data!);
              },
            ),
    );
  }

  Widget _contenido(BuildContext context, Post p) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(p.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
}
