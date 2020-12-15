import 'dart:io';
import 'dart:io' as Io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spica/Structs/Post.dart';
import 'package:spica/Structs/PostDetail.dart';

extension MicroAPI_Post on MicroAPI {
  Future<Post> loadPost(String id, {@required bool loadRickroll}) async {
    try {
      final response = await http.get("https://micro.alles.cx/api/posts/$id",
          headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

      if (response.statusCode == 200) {
        var newpost = Post.fromJson(jsonDecode(response.body));
        if (loadRickroll && newpost.url != null) {
          final rickrollResponse =
              await http.get("https://astley.vercel.app/?url=${newpost.url}");
          if (rickrollResponse.statusCode == 200) {
            bool isRickroll =
                jsonDecode(rickrollResponse.body)["rickroll"] ?? false;
            newpost.containsRickroll = isRickroll;
            return newpost;
          } else {
            return newpost;
          }
        } else {
          return newpost;
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

  Future<Post> sendPost(
      {@required String content, File image, String parent, String url}) async {
    Map<String, String> newbody = {
      "content": content,
    };

    if (parent != null) {
      newbody["parent"] = parent;
    }

    if (url != null) {
      newbody["url"] = url;
    }

    if (image != null) {
      List<int> imageBytes = image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      newbody["image"] = "data:image/jpeg;base64,$base64Image";
    }

    try {
      final response = await http.post("https://push.spica.li/post/send",
          headers: {
            HttpHeaders.authorizationHeader: await loadAuthKey(),
            "Content-Type": "application/json"
          },
          body: jsonEncode(newbody));

      if (response.statusCode == 200) {
        print(response.body);
        var newpost = Post(id: jsonDecode(response.body)["id"]);
        return newpost;
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

  Future<PostDetail> loadPostDetail(String id) async {
    final mainpostresponse = await loadPost(id, loadRickroll: false);
    String highestParent = mainpostresponse.parent;
    PostDetail postDetail = PostDetail();
    postDetail.mainPost = mainpostresponse;
    postDetail.postReplies = [];
    postDetail.postAncestors = [mainpostresponse];

    for (var child in mainpostresponse.children) {
      await loadPost(child, loadRickroll: false).then((newchild) {
        postDetail.postReplies.add(newchild);
      }).catchError((err) {
        return Future.error(err);
      });
    }

    while (highestParent != null) {
      await loadPost(highestParent, loadRickroll: false).then((parent) {
        postDetail.postAncestors.add(parent);
        highestParent = parent.parent;
      }).catchError((err) {
        highestParent = null;
      });
    }
    return postDetail;
  }

  Future<VoteStatus> votePost(Post post, VoteType vote) async {
    int newVoteStatus = post.vote == vote.intValue ? 0 : vote.intValue;
    try {
      final voteResponse =
          await http.post("https://micro.alles.cx/api/posts/${post.id}/vote",
              headers: {
                HttpHeaders.authorizationHeader: await loadAuthKey(),
                "Content-Type": "application/json"
              },
              body: jsonEncode({"vote": newVoteStatus}));

      if (voteResponse.statusCode == 200) {
        int newScore = post.score;
        switch (vote) {
          case VoteType.upvote:
            if (post.vote == 1) {
              newScore -= 1;
              break;
            } else if (post.vote == 0) {
              newScore += 1;
              break;
            } else {
              newScore += 2;
              break;
            }
            break;
          case VoteType.downvote:
            if (post.vote == 1) {
              newScore -= 2;
              break;
            } else if (post.vote == 0) {
              newScore -= 1;
              break;
            } else {
              newScore += 1;
              break;
            }
            break;
        }

        return VoteStatus(score: newScore, vote: newVoteStatus);
      } else {
        return Future.error(MicroAPI.shared.getError(response: voteResponse));
      }
    } catch (err) {
      return Future.error(MicroError(
          isError: true,
          name: err.toString(),
          humanDescription: err.toString()));
    }
  }
}

enum VoteType { upvote, downvote }

extension VoteTypeExtension on VoteType {
  int get intValue {
    switch (this) {
      case VoteType.upvote:
        return 1;
      case VoteType.downvote:
        return -1;
      default:
        return 0;
    }
  }
}

class VoteStatus {
  int score;
  int vote;

  VoteStatus({this.score, this.vote});
}
