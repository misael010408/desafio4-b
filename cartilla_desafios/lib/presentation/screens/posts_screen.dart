import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/api_service.dart';
import '../../domain/entities/post.dart';
import '../widgets/app_shell.dart';

class PostsScreen extends StatefulWidget {
  final String? initialSearch;
  const PostsScreen({super.key, this.initialSearch});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> _future;
  final _search = TextEditingController();
  bool _buscando = false;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _future = ApiService().getPosts();
    _q = widget.initialSearch ?? '';
    _search.text = _q;
    _buscando = _q.isNotEmpty;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const MenuButton(),
        title: _buscando
            ? TextField(
                controller: _search,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Buscar por título...', border: InputBorder.none),
                onChanged: (v) => setState(() => _q = v),
              )
            : const Text('Posts'),
        actions: [
          IconButton(
            icon: Icon(_buscando ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              if (_buscando) {
                _q = '';
                _search.clear();
              }
              _buscando = !_buscando;
            }),
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _future,
        builder: (context, snap) {
          // 3 estados: cargando / error / datos
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text('No se pudo cargar: ${snap.error}'),
                  TextButton(
                    onPressed: () =>
                        setState(() => _future = ApiService().getPosts()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final posts = snap.data!
              .where((p) => p.title.toLowerCase().contains(_q.toLowerCase()))
              .toList();
          if (posts.isEmpty) return const Center(child: Text('Sin resultados'));
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, i) {
              final p = posts[i];
              return ListTile(
                title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(p.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => context.push('/posts/${p.id}', extra: p),
              );
            },
          );
        },
      ),
    );
  }
}
