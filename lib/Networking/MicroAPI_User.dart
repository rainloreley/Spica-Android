import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spica/Networking/MicroAPI.dart';
import 'package:spica/Networking/MicroAPI_Post.dart';
import 'package:spica/Networking/MicroAPI_Status.dart';
import 'package:http/http.dart' as http;
import 'package:spica/Structs/Post.dart';
import 'dart:convert';
import 'package:spica/Structs/User.dart';

extension MicroAPI_User on MicroAPI {
  Future<String> signin(
      {@required String name,
      @required String tag,
      @required String password}) async {
    try {
      final response = await http.post("https://alles.cx/api/login",
          headers: {
            HttpHeaders.authorizationHeader: await loadAuthKey(),
            "Content-Type": "application/json"
          },
          body: jsonEncode({"name": name, "tag": tag, "password": password}));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final storage = FlutterSecureStorage();
        await storage.write(
            key: "dev.abmgrt.spica.user.token", value: json["token"]);

        await MicroAPI.shared.loadSignedinUser().then((user) async {
          await storage.write(key: "dev.abmgrt.spica.user.id", value: user.id);
          await storage.write(
              key: "dev.abmgrt.spica.user.name", value: user.name);
          await storage.write(
              key: "dev.abmgrt.spica.user.tag", value: user.tag);
          return user.id;
        }).catchError((err) {
          return Future.error(err);
        });
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

  Future<User> loadSignedinUser() async {
    try {
      final response = await http.get("https://micro.alles.cx/api/me",
          headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
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

  Future<User> loadUser(
      {@required String id, @required bool loadStatus}) async {
    return await loadIdByUsername(username: id, allowEmptyUsernames: true)
        .then((usernameid) async {
      final newID = usernameid != "" ? usernameid : id;
      try {
        final response = await http.get(
            "https://micro.alles.cx/api/users/$newID",
            headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

        if (response.statusCode == 200) {
          var newUser = User.fromJson(jsonDecode(response.body));

          if (loadStatus) {
            final newstatus = await MicroAPI.shared.loadUserStatus(id: newID);
            if (newstatus != null) {
              newUser.status = newstatus;
              return newUser;
            } else {
              return Future.error(MicroError(
                  isError: true,
                  name: "statusUndefined",
                  humanDescription: "The API didn't return a valid status"));
            }
          } else {
            return newUser;
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
    }).catchError((err) {
      return Future.error(MicroError(
          isError: true,
          name: err.toString(),
          humanDescription: err.toString()));
    });
  }

  Future<List<Post>> loadUserPosts({@required String id}) async {
    try {
      final response = await http.get("https://micro.alles.cx/api/users/$id",
          headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

      if (response.statusCode == 200) {
        List<Post> tempPosts = [];
        List<String> postIds =
            List.from(jsonDecode(response.body)["posts"]["recent"]);
        for (var postid in postIds) {
          await MicroAPI.shared
              .loadPost(postid, loadRickroll: false)
              .then((post) {
            tempPosts.add(post);
          }).catchError((err) {
            return Future.error(err);
          });
        }
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

  Future<String> loadIdByUsername(
      {@required String username, @required bool allowEmptyUsernames}) async {
    try {
      final response = await http.get(
          "https://micro.alles.cx/api/username/$username",
          headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody["id"] != null) {
          return jsonBody["id"] ?? "";
        } else {
          return "";
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

  Future<bool> followUnfollowUser(
      {@required String id, @required FollowUnfollow action}) async {
    try {
      final response = await http.post(
          "https://micro.alles.cx/api/users/$id/${action == FollowUnfollow.unfollow ? "unfollow" : "follow"}",
          headers: {HttpHeaders.authorizationHeader: await loadAuthKey()});

      if (response.statusCode == 200) {
        return action == FollowUnfollow.unfollow ? false : true;
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

enum FollowUnfollow { follow, unfollow }
