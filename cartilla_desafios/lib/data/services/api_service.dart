import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/post.dart';

class ApiService {
  static const _base = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> getPosts() async {
    final r = await http.get(Uri.parse('$_base/posts'));
    if (r.statusCode != 200) throw Exception('Error del servidor (${r.statusCode})');
    final lista = jsonDecode(r.body) as List<dynamic>;
    return lista.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Post> getPost(int id) async {
    final r = await http.get(Uri.parse('$_base/posts/$id'));
    if (r.statusCode != 200) throw Exception('Error del servidor (${r.statusCode})');
    return Post.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }
}
