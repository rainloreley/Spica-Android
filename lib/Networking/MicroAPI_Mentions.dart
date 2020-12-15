import 'dart:convert';
import 'package:spica/Networking/MicroAPI_Post.dart';
import 'dart:io';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:http/http.dart' as http;
import 'package:spica/Structs/Mention.dart';

extension MicroAPI_Mentions on MicroAPI {
  Future<List<Mention>> loadMentions() async {
    try {
      final response = await http.get("https://micro.alles.cx/api/mentions",
          headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

      if (response.statusCode == 200) {
        List<Mention> tempMentions = [];
        List<Map<String, dynamic>> postIds =
            List.from(jsonDecode(response.body)["posts"]);
        int index = 0;
        int errorcount = 0;
        MicroError error;
        for (var post in postIds) {
          if (index < 30) {
            await MicroAPI.shared
                .loadPost(post["id"], loadRickroll: false)
                .then((loadedPost) {
              tempMentions
                  .add(Mention(post: loadedPost, read: post["read"] ?? true));
              index += 1;
            }).catchError((err) {
              error = err;
              errorcount += 1;
            });
          }
        }
        tempMentions
            .sort((a, b) => b.post.createdAt.compareTo(a.post.createdAt));
        if (tempMentions.length == 0 && errorcount > 0 && error != null) {
          return Future.error(error);
        } else {
          return tempMentions;
        }
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

  Future<void> markMentionsAsRead() async {
    await http.post("https://micro.alles.cx/api/mentions/read",
        headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});
    return;
  }
}

//
