import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_Post.dart';
import 'package:spica/Structs/Post.dart';

extension MicroAPI_Feed on MicroAPI {
  Future<List<Post>> loadFeed({int before}) async {
    try {
      final response = await http.get(
          before != null
              ? "https://micro.alles.cx/api/feed?before=$before"
              : "https://micro.alles.cx/api/feed",
          headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

      if (response.statusCode == 200) {
        List<Post> tempPosts = [];
        List<String> postIds = List.from(jsonDecode(response.body)["posts"]);
        for (var post in postIds) {
          await MicroAPI.shared
              .loadPost(post, loadRickroll: false)
              .then((post) {
            tempPosts.add(post);
          }).catchError((err) {
            return Future.error(err);
          });
        }
        tempPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return tempPosts;
      } else {
        return Future.error(MicroAPI.shared.getError(response: response));
      }
    } catch (err) {
      return Future.error(MicroError(
          isError: true,
          name: err.toString(),
          humanDescription: err.toString()));
    }
  }
}
